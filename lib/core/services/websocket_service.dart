import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// WebSocket连接状态枚举
enum WebSocketConnectionState {
  /// 断开连接
  disconnected,
  /// 连接中
  connecting,
  /// 已连接
  connected,
  /// 连接失败
  failed,
  /// 重连中
  reconnecting,
}

/// WebSocket连接状态数据类
class WebSocketState {
  final WebSocketConnectionState connectionState;
  final String? errorMessage;
  final DateTime? lastConnectedAt;
  final int reconnectAttempts;

  const WebSocketState({
    required this.connectionState,
    this.errorMessage,
    this.lastConnectedAt,
    this.reconnectAttempts = 0,
  });

  WebSocketState copyWith({
    WebSocketConnectionState? connectionState,
    String? errorMessage,
    DateTime? lastConnectedAt,
    int? reconnectAttempts,
  }) {
    return WebSocketState(
      connectionState: connectionState ?? this.connectionState,
      errorMessage: errorMessage ?? this.errorMessage,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
    );
  }

  /// 是否已连接
  bool get isConnected => connectionState == WebSocketConnectionState.connected;
  
  /// 是否正在连接
  bool get isConnecting => connectionState == WebSocketConnectionState.connecting;
  
  /// 是否断开连接
  bool get isDisconnected => connectionState == WebSocketConnectionState.disconnected;
  
  /// 是否连接失败
  bool get isFailed => connectionState == WebSocketConnectionState.failed;
}

/// WebSocket服务类
class WebSocketService extends StateNotifier<WebSocketState> {
  WebSocketChannel? _channel;
  StreamSubscription? _messageSubscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();

  WebSocketService() : super(const WebSocketState(connectionState: WebSocketConnectionState.disconnected));

  /// 消息流
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// 连接到WebSocket服务器
  Future<void> connect() async {
    if (state.isConnected || state.isConnecting) {
      return;
    }

    state = state.copyWith(
      connectionState: WebSocketConnectionState.connecting,
      errorMessage: null,
    );

    try {
      // 检查网络连接
      await _checkNetworkConnection();
      
      // 建立WebSocket连接
      _channel = IOWebSocketChannel.connect(
        Uri.parse(ApiConstants.webSocketUrl),
        connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
      );

      // 监听连接状态
      await _channel!.ready;
      
      state = state.copyWith(
        connectionState: WebSocketConnectionState.connected,
        lastConnectedAt: DateTime.now(),
        reconnectAttempts: 0,
        errorMessage: null,
      );

      // 开始监听消息
      _startListening();
      
      // 启动心跳
      _startHeartbeat();
      
    } catch (error) {
      final errorMsg = _handleConnectionError(error);
      state = state.copyWith(
        connectionState: WebSocketConnectionState.failed,
        errorMessage: errorMsg,
      );
      
      // 启动自动重连
      _scheduleReconnect();
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _stopReconnectTimer();
    _stopHeartbeat();
    
    await _messageSubscription?.cancel();
    await _channel?.sink.close();
    
    _channel = null;
    _messageSubscription = null;
    
    state = state.copyWith(
      connectionState: WebSocketConnectionState.disconnected,
      errorMessage: null,
    );
  }

  /// 发送消息
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (!state.isConnected) {
      throw WebSocketException('WebSocket未连接');
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
    } catch (error) {
      throw WebSocketException('发送消息失败: $error');
    }
  }

  /// 检查网络连接
  Future<void> _checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw NetworkException('无网络连接');
      }
    } catch (error) {
      throw NetworkException('网络连接检查失败: $error');
    }
  }

  /// 开始监听消息
  void _startListening() {
    _messageSubscription = _channel!.stream.listen(
      (data) {
        try {
          final Map<String, dynamic> message = jsonDecode(data);
          _messageController.add(message);
        } catch (error) {
          print('解析消息失败: $error');
        }
      },
      onError: (error) {
        final errorMsg = _handleConnectionError(error);
        state = state.copyWith(
          connectionState: WebSocketConnectionState.failed,
          errorMessage: errorMsg,
        );
        _scheduleReconnect();
      },
      onDone: () {
        if (state.isConnected) {
          state = state.copyWith(
            connectionState: WebSocketConnectionState.disconnected,
            errorMessage: '连接已断开',
          );
          _scheduleReconnect();
        }
      },
    );
  }

  /// 启动心跳
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(
      Duration(milliseconds: ApiConstants.heartbeatInterval),
      (timer) {
        if (state.isConnected) {
          try {
            sendMessage({'type': 'ping', 'timestamp': DateTime.now().millisecondsSinceEpoch});
          } catch (error) {
            print('心跳发送失败: $error');
          }
        }
      },
    );
  }

  /// 停止心跳
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 安排重连
  void _scheduleReconnect() {
    if (state.reconnectAttempts >= ApiConstants.maxReconnectAttempts) {
      state = state.copyWith(
        connectionState: WebSocketConnectionState.failed,
        errorMessage: '重连次数超限，请手动重试',
      );
      return;
    }

    _stopReconnectTimer();
    
    final delay = Duration(milliseconds: ApiConstants.reconnectDelay);
    _reconnectTimer = Timer(delay, () {
      state = state.copyWith(
        connectionState: WebSocketConnectionState.reconnecting,
        reconnectAttempts: state.reconnectAttempts + 1,
      );
      connect();
    });
  }

  /// 停止重连定时器
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 处理连接错误
  String _handleConnectionError(dynamic error) {
    if (error is SocketException) {
      return '网络连接失败，请检查网络设置';
    } else if (error is TimeoutException) {
      return '连接超时，请稍后重试';
    } else if (error is WebSocketException) {
      return 'WebSocket连接错误: ${error.message}';
    } else {
      return '连接失败: $error';
    }
  }

  @override
  void dispose() {
    disconnect();
    _messageController.close();
    super.dispose();
  }
}

/// WebSocket服务提供者
final webSocketServiceProvider = StateNotifierProvider<WebSocketService, WebSocketState>((ref) {
  return WebSocketService();
});
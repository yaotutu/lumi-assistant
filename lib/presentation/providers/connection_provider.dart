import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/websocket/websocket_service.dart';
import '../../core/services/network/network_checker.dart';
import '../../core/services/network/handshake_service.dart';
import '../../data/models/connection_state.dart';
import '../../data/models/websocket_state.dart';
import '../../core/utils/loggers.dart';


/// 连接管理器
class ConnectionManager extends StateNotifier<ConnectionManagerState> {
  final Ref _ref;

  ConnectionManager(this._ref) : super(ConnectionManagerStateFactory.initial()) {
    _initialize();
  }

  /// 初始化连接管理器
  void _initialize() {
    // 监听网络状态变化
    _ref.listen(networkCheckerProvider, (previous, next) {
      state = state.copyWith(networkState: next);
      _handleNetworkStateChange(previous, next);
    });

    // 监听WebSocket状态变化
    _ref.listen(webSocketServiceProvider, (previous, next) {
      state = state.copyWith(webSocketState: next);
      _handleWebSocketStateChange(previous, next);
    });

    // 监听握手状态变化
    _ref.listen(handshakeServiceProvider, (previous, next) {
      state = state.copyWith(handshakeResult: next);
    });

    state = state.copyWith(isInitialized: true);
    
    // 初始化完成后，检查是否需要自动连接
    _checkAutoConnection();
  }

  /// 处理网络状态变化
  void _handleNetworkStateChange(NetworkState? previous, NetworkState current) {
    Loggers.websocket.stateChange('${previous?.connectionState ?? 'unknown'}', '${current.connectionState}', '网络状态变化');
    
    // 网络连接可用时，检查WebSocket状态
    if (current.isConnected) {
      Loggers.websocket.fine('网络可用，检查WebSocket状态');
      if (state.webSocketState.isDisconnected || state.webSocketState.isFailed) {
        Loggers.websocket.info('WebSocket未连接，启动连接');
        connectWebSocket();
      }
    }
    
    // 网络断开时，断开WebSocket连接
    if (current.isDisconnected && state.webSocketState.isConnected) {
      Loggers.websocket.info('网络断开，断开WebSocket连接');
      disconnectWebSocket();
    }
  }

  /// 处理WebSocket状态变化
  void _handleWebSocketStateChange(WebSocketState? previous, WebSocketState current) {
    Loggers.websocket.stateChange('${previous?.connectionState ?? 'unknown'}', '${current.connectionState}', 'WebSocket状态变化');
    
    // WebSocket连接成功时，自动开始握手
    if (previous?.isConnected != true && current.isConnected) {
      Loggers.websocket.info('WebSocket连接成功，检查握手状态');
      if (state.handshakeResult.state == HandshakeState.idle) {
        Loggers.websocket.info('开始自动握手');
        startHandshake();
      } else {
        Loggers.websocket.fine('握手状态非idle，跳过自动握手: ${state.handshakeResult.state}');
      }
    }
    
    // WebSocket断开时，重置握手状态
    if (current.isDisconnected && state.handshakeResult.isCompleted) {
      Loggers.websocket.info('WebSocket断开，重置握手状态');
      final handshakeService = _ref.read(handshakeServiceProvider.notifier);
      handshakeService.reset();
    }
  }

  /// 检查是否需要自动连接
  void _checkAutoConnection() {
    Loggers.websocket.fine('检查自动连接条件');
    
    // 延迟一点时间，确保所有Provider都初始化完成
    Future.delayed(const Duration(milliseconds: 500), () {
      if (state.networkState.isConnected && 
          (state.webSocketState.isDisconnected || state.webSocketState.isFailed)) {
        Loggers.websocket.info('条件满足，启动自动连接');
        connectWebSocket();
      }
    });
  }

  /// 连接WebSocket
  /// 
  /// [serverUrl] 可选的服务器URL
  Future<void> connectWebSocket([String? serverUrl]) async {
    Loggers.websocket.userAction('开始连接WebSocket');
    
    if (!state.networkState.isConnected) {
      Loggers.websocket.warning('网络未连接，跳过WebSocket连接');
      return;
    }

    Loggers.websocket.fine('调用WebSocket服务进行连接');
    final webSocketService = _ref.read(webSocketServiceProvider.notifier);
    
    // 性能优化：音频服务在WebSocketService内部自动设置
    
    await webSocketService.connect(serverUrl);
  }
  

  /// 断开WebSocket连接
  Future<void> disconnectWebSocket() async {
    final webSocketService = _ref.read(webSocketServiceProvider.notifier);
    await webSocketService.disconnect();
  }

  /// 开始握手
  Future<void> startHandshake() async {
    if (!state.isWebSocketConnected) {
      return;
    }

    final handshakeService = _ref.read(handshakeServiceProvider.notifier);
    await handshakeService.startHandshake();
  }

  /// 重新连接
  Future<void> reconnect() async {
    // 先检查网络状态
    final networkChecker = _ref.read(networkCheckerProvider.notifier);
    await networkChecker.checkConnection();
    
    // 如果网络正常，尝试连接WebSocket
    if (state.networkState.isConnected) {
      await connectWebSocket();
    }
  }

  /// 发送消息
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (!state.isFullyConnected) {
      throw Exception('连接未就绪');
    }

    final webSocketService = _ref.read(webSocketServiceProvider.notifier);
    await webSocketService.sendMessage(message);
  }

  /// 获取消息流
  Stream<Map<String, dynamic>> get messageStream {
    final webSocketService = _ref.read(webSocketServiceProvider.notifier);
    return webSocketService.messageStream;
  }
}

/// 连接管理器提供者
final connectionManagerProvider = StateNotifierProvider<ConnectionManager, ConnectionManagerState>((ref) {
  return ConnectionManager(ref);
});

/// 便捷的连接状态提供者
final connectionStatusProvider = Provider<String>((ref) {
  final connectionState = ref.watch(connectionManagerProvider);
  return connectionState.statusDescription;
});

/// 是否完全连接的提供者
final isConnectedProvider = Provider<bool>((ref) {
  final connectionState = ref.watch(connectionManagerProvider);
  return connectionState.isFullyConnected;
});
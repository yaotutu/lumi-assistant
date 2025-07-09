import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/websocket_service.dart';
import '../../core/services/network_checker.dart';
import '../../core/services/handshake_service.dart';

/// 连接管理状态
class ConnectionManagerState {
  final WebSocketState webSocketState;
  final NetworkState networkState;
  final HandshakeResult handshakeResult;
  final bool isInitialized;

  const ConnectionManagerState({
    required this.webSocketState,
    required this.networkState,
    required this.handshakeResult,
    this.isInitialized = false,
  });

  ConnectionManagerState copyWith({
    WebSocketState? webSocketState,
    NetworkState? networkState,
    HandshakeResult? handshakeResult,
    bool? isInitialized,
  }) {
    return ConnectionManagerState(
      webSocketState: webSocketState ?? this.webSocketState,
      networkState: networkState ?? this.networkState,
      handshakeResult: handshakeResult ?? this.handshakeResult,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// 整体连接状态
  bool get isFullyConnected => networkState.isConnected && webSocketState.isConnected && handshakeResult.isCompleted;
  
  /// WebSocket是否连接
  bool get isWebSocketConnected => networkState.isConnected && webSocketState.isConnected;
  
  /// 是否可以尝试连接
  bool get canAttemptConnection => networkState.isConnected && !webSocketState.isConnected;
  
  /// 是否可以开始握手
  bool get canStartHandshake => isWebSocketConnected && !handshakeResult.isHandshaking && !handshakeResult.isCompleted;
  
  /// 连接状态描述
  String get statusDescription {
    if (!networkState.isConnected) {
      return '网络未连接';
    } else if (webSocketState.isConnecting) {
      return '正在连接服务器...';
    } else if (!webSocketState.isConnected) {
      return webSocketState.errorMessage ?? '未连接';
    } else if (handshakeResult.isHandshaking) {
      return '正在握手...';
    } else if (handshakeResult.isCompleted) {
      return '已就绪';
    } else if (handshakeResult.isFailed) {
      return handshakeResult.errorMessage ?? '握手失败';
    } else {
      return '已连接';
    }
  }
}

/// 连接管理器
class ConnectionManager extends StateNotifier<ConnectionManagerState> {
  final Ref _ref;

  ConnectionManager(this._ref) : super(ConnectionManagerState(
    webSocketState: const WebSocketState(connectionState: WebSocketConnectionState.disconnected),
    networkState: const NetworkState(connectionState: NetworkConnectionState.unknown),
    handshakeResult: const HandshakeResult(state: HandshakeState.idle),
  )) {
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
  }

  /// 处理网络状态变化
  void _handleNetworkStateChange(NetworkState? previous, NetworkState current) {
    print('[ConnectionManager] 网络状态变化: ${previous?.connectionState} -> ${current.connectionState}');
    
    // 网络从断开到连接时，尝试连接WebSocket
    if (previous?.isDisconnected == true && current.isConnected) {
      print('[ConnectionManager] 网络恢复，检查WebSocket状态');
      if (state.webSocketState.isDisconnected || state.webSocketState.isFailed) {
        print('[ConnectionManager] WebSocket未连接，启动连接');
        connectWebSocket();
      }
    }
    
    // 网络断开时，断开WebSocket连接
    if (current.isDisconnected && state.webSocketState.isConnected) {
      print('[ConnectionManager] 网络断开，断开WebSocket连接');
      disconnectWebSocket();
    }
  }

  /// 处理WebSocket状态变化
  void _handleWebSocketStateChange(WebSocketState? previous, WebSocketState current) {
    print('[ConnectionManager] WebSocket状态变化: ${previous?.connectionState} -> ${current.connectionState}');
    
    // WebSocket连接成功时，自动开始握手
    if (previous?.isConnected != true && current.isConnected) {
      print('[ConnectionManager] WebSocket连接成功，检查握手状态');
      if (state.handshakeResult.state == HandshakeState.idle) {
        print('[ConnectionManager] 开始自动握手');
        startHandshake();
      } else {
        print('[ConnectionManager] 握手状态非idle，跳过自动握手: ${state.handshakeResult.state}');
      }
    }
    
    // WebSocket断开时，重置握手状态
    if (current.isDisconnected && state.handshakeResult.isCompleted) {
      print('[ConnectionManager] WebSocket断开，重置握手状态');
      final handshakeService = _ref.read(handshakeServiceProvider.notifier);
      handshakeService.reset();
    }
  }

  /// 连接WebSocket
  Future<void> connectWebSocket() async {
    print('[ConnectionManager] 开始连接WebSocket');
    
    if (!state.networkState.isConnected) {
      print('[ConnectionManager] 网络未连接，跳过WebSocket连接');
      return;
    }

    print('[ConnectionManager] 调用WebSocket服务进行连接');
    final webSocketService = _ref.read(webSocketServiceProvider.notifier);
    await webSocketService.connect();
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
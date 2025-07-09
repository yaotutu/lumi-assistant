import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/websocket_service.dart';
import '../../core/services/network_checker.dart';

/// 连接管理状态
class ConnectionManagerState {
  final WebSocketState webSocketState;
  final NetworkState networkState;
  final bool isInitialized;

  const ConnectionManagerState({
    required this.webSocketState,
    required this.networkState,
    this.isInitialized = false,
  });

  ConnectionManagerState copyWith({
    WebSocketState? webSocketState,
    NetworkState? networkState,
    bool? isInitialized,
  }) {
    return ConnectionManagerState(
      webSocketState: webSocketState ?? this.webSocketState,
      networkState: networkState ?? this.networkState,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// 整体连接状态
  bool get isFullyConnected => networkState.isConnected && webSocketState.isConnected;
  
  /// 是否可以尝试连接
  bool get canAttemptConnection => networkState.isConnected && !webSocketState.isConnected;
  
  /// 连接状态描述
  String get statusDescription {
    if (!networkState.isConnected) {
      return '网络未连接';
    } else if (webSocketState.isConnecting) {
      return '正在连接服务器...';
    } else if (webSocketState.isConnected) {
      return '已连接';
    } else if (webSocketState.isFailed) {
      return webSocketState.errorMessage ?? '连接失败';
    } else {
      return '未连接';
    }
  }
}

/// 连接管理器
class ConnectionManager extends StateNotifier<ConnectionManagerState> {
  final Ref _ref;

  ConnectionManager(this._ref) : super(ConnectionManagerState(
    webSocketState: const WebSocketState(connectionState: WebSocketConnectionState.disconnected),
    networkState: const NetworkState(connectionState: NetworkConnectionState.unknown),
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
    });

    state = state.copyWith(isInitialized: true);
  }

  /// 处理网络状态变化
  void _handleNetworkStateChange(NetworkState? previous, NetworkState current) {
    // 网络从断开到连接时，尝试连接WebSocket
    if (previous?.isDisconnected == true && current.isConnected) {
      if (state.webSocketState.isDisconnected || state.webSocketState.isFailed) {
        connectWebSocket();
      }
    }
    
    // 网络断开时，断开WebSocket连接
    if (current.isDisconnected && state.webSocketState.isConnected) {
      disconnectWebSocket();
    }
  }

  /// 连接WebSocket
  Future<void> connectWebSocket() async {
    if (!state.networkState.isConnected) {
      return;
    }

    final webSocketService = _ref.read(webSocketServiceProvider.notifier);
    await webSocketService.connect();
  }

  /// 断开WebSocket连接
  Future<void> disconnectWebSocket() async {
    final webSocketService = _ref.read(webSocketServiceProvider.notifier);
    await webSocketService.disconnect();
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
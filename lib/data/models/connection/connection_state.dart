import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/services/network/network_checker.dart';
import '../../../core/services/network/handshake_service.dart';
import 'websocket_state.dart';

part 'connection_state.freezed.dart';

/// 连接管理状态 - 使用Freezed优化的不可变数据类
/// 
/// 这个类管理整个应用的连接状态，包括：
/// - 网络连接状态
/// - WebSocket连接状态  
/// - 握手状态
/// - 初始化状态
/// 
/// 使用Freezed的优势：
/// - 自动生成copyWith方法
/// - 自动生成equals和hashCode
/// - 自动生成toString
/// - 类型安全的序列化支持
/// - 不可变性保证
@freezed
class ConnectionManagerState with _$ConnectionManagerState {
  const factory ConnectionManagerState({
    /// WebSocket连接状态
    /// 包含连接状态、错误信息、重连次数等
    required WebSocketState webSocketState,
    
    /// 网络连接状态
    /// 检查基础网络连接是否可用
    required NetworkState networkState,
    
    /// 握手结果状态
    /// 包含握手状态、会话ID、设备ID等
    required HandshakeResult handshakeResult,
    
    /// 是否已初始化
    /// 标识连接管理器是否已完成初始化
    @Default(false) bool isInitialized,
  }) = _ConnectionManagerState;
}

/// 连接管理状态扩展方法
/// 
/// 提供便捷的状态查询方法，避免在UI层重复判断逻辑
extension ConnectionManagerStateExtension on ConnectionManagerState {
  /// 整体连接状态
  /// 需要网络、WebSocket、握手三个状态都成功
  bool get isFullyConnected => 
      networkState.isConnected && 
      webSocketState.isConnected && 
      handshakeResult.isCompleted;
  
  /// WebSocket是否连接
  /// 检查网络和WebSocket连接状态
  bool get isWebSocketConnected => 
      networkState.isConnected && 
      webSocketState.isConnected;
  
  /// 是否可以尝试连接
  /// 网络可用但WebSocket未连接时可以尝试连接
  bool get canAttemptConnection => 
      networkState.isConnected && 
      !webSocketState.isConnected;
  
  /// 是否可以开始握手
  /// WebSocket已连接但握手未完成时可以开始握手
  bool get canStartHandshake => 
      isWebSocketConnected && 
      !handshakeResult.isHandshaking && 
      !handshakeResult.isCompleted;
  
  /// 连接状态描述
  /// 返回当前连接状态的用户友好描述
  String get statusDescription {
    // 网络状态检查
    if (!networkState.isConnected) {
      return '网络未连接';
    }
    
    // WebSocket状态检查
    if (webSocketState.isConnecting) {
      return '正在连接服务器...';
    }
    
    if (!webSocketState.isConnected) {
      return webSocketState.errorMessage ?? '未连接';
    }
    
    // 握手状态检查
    if (handshakeResult.isHandshaking) {
      return '正在握手...';
    }
    
    if (handshakeResult.isCompleted) {
      return '已就绪';
    }
    
    if (handshakeResult.isFailed) {
      return handshakeResult.errorMessage ?? '握手失败';
    }
    
    return '已连接';
  }
  
  /// 获取连接质量评分 (0-100)
  /// 根据各种连接状态指标计算连接质量
  int get connectionQualityScore {
    int score = 0;
    
    // 网络连接 (30分)
    if (networkState.isConnected) {
      score += 30;
    }
    
    // WebSocket连接 (40分)
    if (webSocketState.isConnected) {
      score += 40;
      // 连接稳定性加分
      if (webSocketState.reconnectAttempts == 0) {
        score += 10;
      } else if (webSocketState.reconnectAttempts < 3) {
        score += 5;
      }
    }
    
    // 握手完成 (30分)
    if (handshakeResult.isCompleted) {
      score += 30;
    }
    
    return score.clamp(0, 100);
  }
  
  /// 是否需要重新连接
  /// 根据当前状态判断是否应该尝试重新连接
  bool get shouldReconnect {
    return networkState.isConnected && 
           !webSocketState.isConnected && 
           !webSocketState.isConnecting &&
           webSocketState.reconnectAttempts < 5;
  }
  
  /// 获取下次重连延迟时间(毫秒)
  /// 使用指数退避算法计算重连延迟
  int get nextReconnectDelay {
    final attempts = webSocketState.reconnectAttempts;
    final baseDelay = 1000; // 1秒
    final maxDelay = 30000; // 30秒
    
    final delay = baseDelay * (1 << attempts.clamp(0, 5));
    return delay.clamp(baseDelay, maxDelay);
  }
}

/// 连接管理状态工厂方法
/// 
/// 提供创建各种初始状态的便捷方法
extension ConnectionManagerStateFactory on ConnectionManagerState {
  /// 创建初始状态
  static ConnectionManagerState initial() {
    return ConnectionManagerState(
      webSocketState: WebSocketStateFactory.disconnected(),
      networkState: const NetworkState(
        connectionState: NetworkConnectionState.unknown,
      ),
      handshakeResult: const HandshakeResult(
        state: HandshakeState.idle,
      ),
      isInitialized: false,
    );
  }
  
  /// 创建已连接状态
  static ConnectionManagerState connected({
    required String sessionId,
    required String deviceId,
  }) {
    return ConnectionManagerState(
      webSocketState: WebSocketStateFactory.connected(),
      networkState: const NetworkState(
        connectionState: NetworkConnectionState.connected,
      ),
      handshakeResult: HandshakeResult(
        state: HandshakeState.completed,
        sessionId: sessionId,
        completedAt: DateTime.now(),
      ),
      isInitialized: true,
    );
  }
  
  /// 创建错误状态
  static ConnectionManagerState error({
    required String errorMessage,
    String? errorCode,
  }) {
    return ConnectionManagerState(
      webSocketState: WebSocketStateFactory.failed(
        errorMessage: errorMessage,
        errorCode: errorCode,
      ),
      networkState: const NetworkState(
        connectionState: NetworkConnectionState.connected,
      ),
      handshakeResult: HandshakeResult(
        state: HandshakeState.failed,
        errorMessage: errorMessage,
      ),
      isInitialized: true,
    );
  }
}
import 'package:freezed_annotation/freezed_annotation.dart';

part 'websocket_state.freezed.dart';

/// WebSocket连接状态枚举
/// 
/// 定义WebSocket连接的所有可能状态
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

/// WebSocket连接状态数据类 - 使用Freezed优化
/// 
/// 管理WebSocket连接的详细状态信息，包括：
/// - 连接状态
/// - 错误信息
/// - 连接时间
/// - 重连信息
/// - 统计数据
/// 
/// 使用Freezed的优势：
/// - 自动生成copyWith方法，支持部分更新
/// - 自动生成equals和hashCode，优化比较性能
/// - 自动生成toString，方便调试
/// - 类型安全的序列化支持
/// - 不可变性保证，避免状态意外修改
@freezed
class WebSocketState with _$WebSocketState {
  const factory WebSocketState({
    /// 连接状态
    required WebSocketConnectionState connectionState,
    
    /// 错误信息
    /// 连接失败时的详细错误描述
    String? errorMessage,
    
    /// 错误代码
    /// 便于错误分类和处理
    String? errorCode,
    
    /// 最后连接成功时间
    /// 用于连接时长计算和连接质量评估
    DateTime? lastConnectedAt,
    
    /// 连接断开时间
    /// 用于计算断开时长和重连策略
    DateTime? disconnectedAt,
    
    /// 重连尝试次数
    /// 用于重连策略和限制
    @Default(0) int reconnectAttempts,
    
    /// 最大重连次数
    /// 超过此次数将停止重连
    @Default(5) int maxReconnectAttempts,
    
    /// 连接尝试开始时间
    /// 用于计算连接耗时
    DateTime? connectingStartedAt,
    
    /// 连接建立总时长(毫秒)
    /// 记录连接建立的耗时
    int? connectionDuration,
    
    /// 发送消息总数
    /// 统计通过此连接发送的消息数量
    @Default(0) int messagesSent,
    
    /// 接收消息总数
    /// 统计通过此连接接收的消息数量
    @Default(0) int messagesReceived,
    
    /// 最后心跳时间
    /// 用于连接健康检查
    DateTime? lastHeartbeatAt,
    
    /// 心跳间隔(毫秒)
    /// 心跳检查的时间间隔
    @Default(30000) int heartbeatInterval,
    
    /// 连接质量评分 (0-100)
    /// 根据连接稳定性、延迟等因素计算
    @Default(0) int qualityScore,
    
    /// 平均延迟(毫秒)
    /// 基于心跳响应时间计算
    @Default(0) int averageLatency,
    
    /// 连接标签
    /// 用于标识连接的用途或类型
    String? connectionTag,
    
    /// 连接元数据
    /// 存储连接相关的附加信息
    @Default({}) Map<String, dynamic> metadata,
  }) = _WebSocketState;

}

/// WebSocket状态扩展方法
/// 
/// 提供便捷的状态查询方法
extension WebSocketStateExtension on WebSocketState {
  /// 是否已连接
  bool get isConnected => connectionState == WebSocketConnectionState.connected;
  
  /// 是否正在连接
  bool get isConnecting => connectionState == WebSocketConnectionState.connecting;
  
  /// 是否断开连接
  bool get isDisconnected => connectionState == WebSocketConnectionState.disconnected;
  
  /// 是否连接失败
  bool get isFailed => connectionState == WebSocketConnectionState.failed;
  
  /// 是否正在重连
  bool get isReconnecting => connectionState == WebSocketConnectionState.reconnecting;
  
  /// 是否有错误
  bool get hasError => errorMessage != null;
  
  /// 连接状态是否稳定
  /// 已连接且重连次数少于3次视为稳定
  bool get isStable => isConnected && reconnectAttempts < 3;
  
  /// 是否可以重连
  /// 未连接且重连次数未达上限时可以重连
  bool get canReconnect => !isConnected && reconnectAttempts < maxReconnectAttempts;
  
  /// 是否应该停止重连
  /// 重连次数达到上限时停止
  bool get shouldStopReconnecting => reconnectAttempts >= maxReconnectAttempts;
  
  /// 获取连接时长
  /// 返回当前连接的持续时间
  Duration? get connectionUptime {
    if (!isConnected || lastConnectedAt == null) return null;
    return DateTime.now().difference(lastConnectedAt!);
  }
  
  /// 获取断开时长
  /// 返回断开连接的持续时间
  Duration? get disconnectionDuration {
    if (isConnected || disconnectedAt == null) return null;
    return DateTime.now().difference(disconnectedAt!);
  }
  
  /// 获取连接状态描述
  String get statusDescription {
    switch (connectionState) {
      case WebSocketConnectionState.disconnected:
        return '未连接';
      case WebSocketConnectionState.connecting:
        return '连接中...';
      case WebSocketConnectionState.connected:
        return '已连接';
      case WebSocketConnectionState.failed:
        return '连接失败';
      case WebSocketConnectionState.reconnecting:
        return '重连中...';
    }
  }
  
  /// 获取详细状态信息
  Map<String, dynamic> get statusInfo {
    return {
      'state': connectionState.name,
      'description': statusDescription,
      'isConnected': isConnected,
      'isStable': isStable,
      'reconnectAttempts': reconnectAttempts,
      'qualityScore': qualityScore,
      'averageLatency': averageLatency,
      'uptime': connectionUptime?.inSeconds,
      'messagesSent': messagesSent,
      'messagesReceived': messagesReceived,
      'hasError': hasError,
      'errorMessage': errorMessage,
      'errorCode': errorCode,
    };
  }
  
  /// 计算下次重连延迟
  /// 使用指数退避算法
  int get nextReconnectDelay {
    const baseDelay = 1000; // 1秒
    const maxDelay = 30000; // 30秒
    
    final delay = baseDelay * (1 << reconnectAttempts.clamp(0, 5));
    return delay.clamp(baseDelay, maxDelay);
  }
  
  /// 是否需要心跳检查
  bool get needsHeartbeat {
    if (!isConnected || lastHeartbeatAt == null) return false;
    
    final now = DateTime.now();
    final timeSinceLastHeartbeat = now.difference(lastHeartbeatAt!);
    
    return timeSinceLastHeartbeat.inMilliseconds > heartbeatInterval;
  }
  
  /// 获取连接健康状态
  String get healthStatus {
    if (!isConnected) return 'disconnected';
    
    if (qualityScore >= 80) return 'excellent';
    if (qualityScore >= 60) return 'good';
    if (qualityScore >= 40) return 'fair';
    return 'poor';
  }
  
  /// 获取连接统计信息
  Map<String, dynamic> get statistics {
    return {
      'messagesSent': messagesSent,
      'messagesReceived': messagesReceived,
      'reconnectAttempts': reconnectAttempts,
      'qualityScore': qualityScore,
      'averageLatency': averageLatency,
      'connectionDuration': connectionDuration,
      'uptime': connectionUptime?.inSeconds,
      'disconnectionDuration': disconnectionDuration?.inSeconds,
      'healthStatus': healthStatus,
    };
  }
}

/// WebSocket状态工厂方法
/// 
/// 提供创建各种状态的便捷方法
extension WebSocketStateFactory on WebSocketState {
  /// 创建初始断开状态
  static WebSocketState disconnected() {
    return const WebSocketState(
      connectionState: WebSocketConnectionState.disconnected,
    );
  }
  
  /// 创建连接中状态
  static WebSocketState connecting() {
    return WebSocketState(
      connectionState: WebSocketConnectionState.connecting,
      connectingStartedAt: DateTime.now(),
    );
  }
  
  /// 创建已连接状态
  static WebSocketState connected({
    DateTime? connectedAt,
    int? connectionDuration,
  }) {
    final now = connectedAt ?? DateTime.now();
    
    return WebSocketState(
      connectionState: WebSocketConnectionState.connected,
      lastConnectedAt: now,
      lastHeartbeatAt: now,
      connectionDuration: connectionDuration,
      qualityScore: 100,
      reconnectAttempts: 0,
    );
  }
  
  /// 创建失败状态
  static WebSocketState failed({
    required String errorMessage,
    String? errorCode,
    int reconnectAttempts = 0,
  }) {
    return WebSocketState(
      connectionState: WebSocketConnectionState.failed,
      errorMessage: errorMessage,
      errorCode: errorCode,
      reconnectAttempts: reconnectAttempts,
      disconnectedAt: DateTime.now(),
    );
  }
  
  /// 创建重连中状态
  static WebSocketState reconnecting({
    required int reconnectAttempts,
    String? lastError,
  }) {
    return WebSocketState(
      connectionState: WebSocketConnectionState.reconnecting,
      reconnectAttempts: reconnectAttempts,
      errorMessage: lastError,
      connectingStartedAt: DateTime.now(),
    );
  }
}

/// WebSocket状态操作方法
/// 
/// 提供状态更新的便捷方法
extension WebSocketStateOperations on WebSocketState {
  /// 开始连接
  WebSocketState startConnecting() {
    return copyWith(
      connectionState: WebSocketConnectionState.connecting,
      connectingStartedAt: DateTime.now(),
      errorMessage: null,
      errorCode: null,
    );
  }
  
  /// 连接成功
  WebSocketState connectSuccess({DateTime? connectedAt}) {
    final now = connectedAt ?? DateTime.now();
    final duration = connectingStartedAt != null 
        ? now.difference(connectingStartedAt!).inMilliseconds 
        : null;
    
    return copyWith(
      connectionState: WebSocketConnectionState.connected,
      lastConnectedAt: now,
      lastHeartbeatAt: now,
      connectionDuration: duration,
      qualityScore: 100,
      reconnectAttempts: 0,
      errorMessage: null,
      errorCode: null,
      connectingStartedAt: null,
    );
  }
  
  /// 连接失败
  WebSocketState connectFailure({
    required String errorMessage,
    String? errorCode,
  }) {
    return copyWith(
      connectionState: WebSocketConnectionState.failed,
      errorMessage: errorMessage,
      errorCode: errorCode,
      disconnectedAt: DateTime.now(),
      connectingStartedAt: null,
    );
  }
  
  /// 断开连接
  WebSocketState disconnect() {
    return copyWith(
      connectionState: WebSocketConnectionState.disconnected,
      disconnectedAt: DateTime.now(),
      lastConnectedAt: null,
      connectingStartedAt: null,
    );
  }
  
  /// 开始重连
  WebSocketState startReconnecting() {
    return copyWith(
      connectionState: WebSocketConnectionState.reconnecting,
      reconnectAttempts: reconnectAttempts + 1,
      connectingStartedAt: DateTime.now(),
    );
  }
  
  /// 重置重连次数
  WebSocketState resetReconnectAttempts() {
    return copyWith(reconnectAttempts: 0);
  }
  
  /// 更新心跳时间
  WebSocketState updateHeartbeat() {
    return copyWith(lastHeartbeatAt: DateTime.now());
  }
  
  /// 增加发送消息计数
  WebSocketState incrementMessagesSent() {
    return copyWith(messagesSent: messagesSent + 1);
  }
  
  /// 增加接收消息计数
  WebSocketState incrementMessagesReceived() {
    return copyWith(messagesReceived: messagesReceived + 1);
  }
  
  /// 更新连接质量评分
  WebSocketState updateQualityScore(int score) {
    return copyWith(qualityScore: score.clamp(0, 100));
  }
  
  /// 更新平均延迟
  WebSocketState updateAverageLatency(int latency) {
    return copyWith(averageLatency: latency.clamp(0, 9999));
  }
  
  /// 更新连接标签
  WebSocketState updateConnectionTag(String tag) {
    return copyWith(connectionTag: tag);
  }
  
  /// 更新元数据
  WebSocketState updateMetadata(Map<String, dynamic> newMetadata) {
    return copyWith(
      metadata: {...metadata, ...newMetadata},
    );
  }
  
  /// 清除错误信息
  WebSocketState clearError() {
    return copyWith(
      errorMessage: null,
      errorCode: null,
    );
  }
}

/// WebSocket状态验证方法
/// 
/// 提供状态验证的便捷方法
extension WebSocketStateValidation on WebSocketState {
  /// 验证状态是否有效
  bool get isValid {
    // 检查重连次数是否合理
    if (reconnectAttempts < 0 || reconnectAttempts > maxReconnectAttempts) {
      return false;
    }
    
    // 检查质量评分是否在有效范围
    if (qualityScore < 0 || qualityScore > 100) {
      return false;
    }
    
    // 检查延迟是否合理
    if (averageLatency < 0) {
      return false;
    }
    
    // 检查心跳间隔是否合理
    if (heartbeatInterval <= 0) {
      return false;
    }
    
    return true;
  }
  
  /// 验证状态转换是否合法
  bool canTransitionTo(WebSocketConnectionState newState) {
    switch (connectionState) {
      case WebSocketConnectionState.disconnected:
        return newState == WebSocketConnectionState.connecting;
        
      case WebSocketConnectionState.connecting:
        return newState == WebSocketConnectionState.connected ||
               newState == WebSocketConnectionState.failed ||
               newState == WebSocketConnectionState.disconnected;
        
      case WebSocketConnectionState.connected:
        return newState == WebSocketConnectionState.disconnected ||
               newState == WebSocketConnectionState.failed ||
               newState == WebSocketConnectionState.reconnecting;
        
      case WebSocketConnectionState.failed:
        return newState == WebSocketConnectionState.reconnecting ||
               newState == WebSocketConnectionState.disconnected;
        
      case WebSocketConnectionState.reconnecting:
        return newState == WebSocketConnectionState.connected ||
               newState == WebSocketConnectionState.failed ||
               newState == WebSocketConnectionState.disconnected;
    }
  }
  
  /// 获取状态验证结果
  Map<String, dynamic> get validationResult {
    final errors = <String>[];
    
    if (!isValid) {
      if (reconnectAttempts < 0 || reconnectAttempts > maxReconnectAttempts) {
        errors.add('Invalid reconnect attempts: $reconnectAttempts');
      }
      
      if (qualityScore < 0 || qualityScore > 100) {
        errors.add('Invalid quality score: $qualityScore');
      }
      
      if (averageLatency < 0) {
        errors.add('Invalid average latency: $averageLatency');
      }
      
      if (heartbeatInterval <= 0) {
        errors.add('Invalid heartbeat interval: $heartbeatInterval');
      }
    }
    
    return {
      'isValid': isValid,
      'errors': errors,
    };
  }
}
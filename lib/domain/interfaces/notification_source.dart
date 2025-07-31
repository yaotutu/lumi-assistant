/// 通知源接口
/// 
/// 定义所有通知源必须实现的标准接口
/// 支持多种通知系统的统一管理
abstract class INotificationSource {
  /// 通知源的唯一标识
  String get sourceId;
  
  /// 通知源的显示名称
  String get sourceName;
  
  /// 是否支持标记已读
  /// 某些通知源（如 Gotify）可能支持服务端同步已读状态
  bool get supportsMarkAsRead;
  
  /// 是否支持删除通知
  /// 某些通知源可能不允许删除历史通知
  bool get supportsDelete;
  
  /// 标记通知为已读
  /// 
  /// 参数：
  /// - notificationId: 通知ID
  /// - syncToServer: 是否同步到服务器（如果支持）
  /// 
  /// 返回：操作是否成功
  Future<bool> markAsRead(String notificationId, {bool syncToServer = false});
  
  /// 批量标记为已读
  Future<bool> markAllAsRead({bool syncToServer = false});
  
  /// 删除通知
  /// 
  /// 参数：
  /// - notificationId: 通知ID
  /// - syncToServer: 是否同步到服务器（如果支持）
  Future<bool> deleteNotification(String notificationId, {bool syncToServer = false});
  
  /// 批量删除通知
  Future<bool> deleteNotifications(List<String> notificationIds, {bool syncToServer = false});
  
  /// 获取通知历史
  /// 
  /// 参数：
  /// - limit: 获取数量限制
  /// - offset: 偏移量（用于分页）
  Future<List<UnifiedNotification>> getHistory({int limit = 50, int offset = 0});
}

/// 统一的通知模型
/// 
/// 所有通知源的通知都会转换为这个统一模型
class UnifiedNotification {
  /// 通知的唯一ID（包含源标识）
  final String id;
  
  /// 通知源ID
  final String sourceId;
  
  /// 原始通知ID（在源系统中的ID）
  final String originalId;
  
  /// 标题
  final String? title;
  
  /// 内容
  final String message;
  
  /// 优先级（0-10）
  final int priority;
  
  /// 创建时间
  final DateTime timestamp;
  
  /// 是否已读（本地状态）
  bool isRead;
  
  /// 是否已同步已读状态到服务器
  bool isReadSynced;
  
  /// 额外数据
  final Map<String, dynamic>? extras;
  
  /// 点击回调
  final void Function()? onTap;
  
  UnifiedNotification({
    required this.id,
    required this.sourceId,
    required this.originalId,
    this.title,
    required this.message,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
    this.isReadSynced = false,
    this.extras,
    this.onTap,
  });
  
  /// 生成唯一ID
  static String generateId(String sourceId, String originalId) {
    return '${sourceId}_$originalId';
  }
  
  /// 复制并修改
  UnifiedNotification copyWith({
    bool? isRead,
    bool? isReadSynced,
  }) {
    return UnifiedNotification(
      id: id,
      sourceId: sourceId,
      originalId: originalId,
      title: title,
      message: message,
      priority: priority,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isReadSynced: isReadSynced ?? this.isReadSynced,
      extras: extras,
      onTap: onTap,
    );
  }
}
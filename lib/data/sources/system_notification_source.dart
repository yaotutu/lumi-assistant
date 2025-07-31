import '../models/notification/notification_source.dart';
import '../../core/utils/app_logger.dart';

/// 系统内部通知源
/// 
/// 用于应用内部生成的通知，如错误提示、系统消息等
class SystemNotificationSource implements INotificationSource {
  @override
  String get sourceId => 'system';
  
  @override
  String get sourceName => '系统通知';
  
  @override
  bool get supportsMarkAsRead => true; // 支持标记已读
  
  @override
  bool get supportsDelete => true; // 支持删除
  
  @override
  Future<bool> markAsRead(String notificationId, {bool syncToServer = false}) async {
    // 系统通知只在本地标记已读，不需要同步到服务器
    AppLogger.getLogger('System').info('标记系统通知已读: $notificationId');
    return true;
  }
  
  @override
  Future<bool> markAllAsRead({bool syncToServer = false}) async {
    // 系统通知只在本地标记，不需要同步到服务器
    AppLogger.getLogger('System').info('标记所有系统通知已读');
    return true;
  }
  
  @override
  Future<bool> deleteNotification(String notificationId, {bool syncToServer = false}) async {
    // 系统通知只在本地删除，不需要同步到服务器
    AppLogger.getLogger('System').info('删除系统通知: $notificationId');
    return true;
  }
  
  @override
  Future<bool> deleteNotifications(List<String> notificationIds, {bool syncToServer = false}) async {
    // 系统通知只在本地删除，不需要同步到服务器
    AppLogger.getLogger('System').info('批量删除系统通知: ${notificationIds.length} 条');
    return true;
  }
  
  @override
  Future<List<UnifiedNotification>> getHistory({int limit = 50, int offset = 0}) async {
    // 系统通知不保存历史，返回空列表
    return [];
  }
  
  /// 创建系统通知
  /// 
  /// 便捷方法，用于快速创建系统通知
  static UnifiedNotification createNotification({
    required String title,
    required String message,
    int priority = 5,
    Map<String, dynamic>? extras,
  }) {
    final timestamp = DateTime.now();
    return UnifiedNotification(
      id: UnifiedNotification.generateId('system', 'system_${timestamp.millisecondsSinceEpoch}'),
      sourceId: 'system',
      originalId: 'system_${timestamp.millisecondsSinceEpoch}',
      title: title,
      message: message,
      priority: priority,
      timestamp: timestamp,
      extras: extras ?? {},
    );
  }
  
  /// 单例模式
  static final SystemNotificationSource _instance = SystemNotificationSource._internal();
  factory SystemNotificationSource() => _instance;
  SystemNotificationSource._internal();
}
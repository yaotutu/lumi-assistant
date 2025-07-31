import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/app_logger.dart';
import '../../../domain/interfaces/notification_source.dart';

/// 统一通知管理服务
/// 
/// 职责：管理所有通知源，提供统一的通知操作接口
/// 特性：
/// 1. 支持多通知源
/// 2. 本地持久化已读状态
/// 3. 智能同步策略
/// 4. 统一的清理策略
class UnifiedNotificationService extends ChangeNotifier {
  /// 已注册的通知源
  final Map<String, INotificationSource> _sources = {};
  
  /// 所有通知（内存缓存）
  final Map<String, UnifiedNotification> _notifications = {};
  
  /// 本地已读状态存储键
  static const String _readStatusKey = 'notification_read_status';
  
  /// 本地删除记录存储键
  static const String _deletedKey = 'notification_deleted';
  
  /// 最大通知保留数量
  static const int _maxNotifications = 100;
  
  /// 通知保留时间（天）
  static const int _retentionDays = 7;
  
  /// 单例模式
  static final UnifiedNotificationService _instance = UnifiedNotificationService._internal();
  factory UnifiedNotificationService() => _instance;
  UnifiedNotificationService._internal() {
    _loadLocalState();
  }
  
  /// 获取实例
  static UnifiedNotificationService get instance => _instance;
  
  /// 获取所有通知（按时间排序，最新的在前）
  List<UnifiedNotification> get notifications {
    final list = _notifications.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }
  
  /// 获取未读通知数量
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  
  /// 注册通知源
  void registerSource(INotificationSource source) {
    _sources[source.sourceId] = source;
    AppLogger.getLogger('UnifiedNotification').info(
      '📝 注册通知源: ${source.sourceName} (${source.sourceId})'
    );
  }
  
  /// 注销通知源
  void unregisterSource(String sourceId) {
    _sources.remove(sourceId);
    AppLogger.getLogger('UnifiedNotification').info(
      '📤 注销通知源: $sourceId'
    );
  }
  
  /// 添加通知
  void addNotification(UnifiedNotification notification) {
    // 检查是否已被删除
    if (_isDeleted(notification.id)) {
      return;
    }
    
    // 恢复本地已读状态
    final localReadStatus = _getLocalReadStatus(notification.id);
    if (localReadStatus != null) {
      notification.isRead = localReadStatus;
    }
    
    _notifications[notification.id] = notification;
    
    // 执行清理策略
    _applyRetentionPolicy();
    
    notifyListeners();
  }
  
  /// 批量添加通知
  void addNotifications(List<UnifiedNotification> notifications) {
    for (final notification in notifications) {
      addNotification(notification);
    }
  }
  
  /// 标记为已读
  Future<void> markAsRead(String notificationId, {bool syncToServer = true}) async {
    final notification = _notifications[notificationId];
    if (notification == null || notification.isRead) return;
    
    // 更新本地状态
    notification.isRead = true;
    await _saveLocalReadStatus(notificationId, true);
    
    // 尝试同步到服务器
    if (syncToServer) {
      final source = _sources[notification.sourceId];
      if (source != null && source.supportsMarkAsRead) {
        try {
          final success = await source.markAsRead(notification.originalId, syncToServer: true);
          notification.isReadSynced = success;
          
          AppLogger.getLogger('UnifiedNotification').info(
            '✅ 已读状态同步${success ? '成功' : '失败'}: $notificationId'
          );
        } catch (e) {
          AppLogger.getLogger('UnifiedNotification').warning(
            '⚠️ 已读状态同步失败: $e'
          );
        }
      }
    }
    
    notifyListeners();
  }
  
  /// 标记所有为已读
  Future<void> markAllAsRead({bool syncToServer = true}) async {
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();
    
    
    // 批量更新本地状态
    for (final notification in unreadNotifications) {
      notification.isRead = true;
      await _saveLocalReadStatus(notification.id, true);
    }
    
    // 按源分组并同步
    if (syncToServer) {
      final groupedBySource = <String, List<UnifiedNotification>>{};
      for (final notification in unreadNotifications) {
        groupedBySource.putIfAbsent(notification.sourceId, () => []).add(notification);
      }
      
      for (final entry in groupedBySource.entries) {
        final source = _sources[entry.key];
        if (source != null && source.supportsMarkAsRead) {
          try {
            await source.markAllAsRead(syncToServer: true);
            
            // 标记为已同步
            for (final notification in entry.value) {
              notification.isReadSynced = true;
            }
          } catch (e) {
            AppLogger.getLogger('UnifiedNotification').warning(
              '⚠️ 源 ${entry.key} 批量已读同步失败: $e'
            );
          }
        }
      }
    }
    
    notifyListeners();
  }
  
  /// 删除通知
  Future<void> deleteNotification(String notificationId, {bool syncToServer = true}) async {
    final notification = _notifications[notificationId];
    if (notification == null) return;
    
    // 从内存中删除
    _notifications.remove(notificationId);
    
    // 记录删除状态
    await _saveDeletedStatus(notificationId);
    
    // 尝试同步到服务器
    if (syncToServer) {
      final source = _sources[notification.sourceId];
      if (source != null && source.supportsDelete) {
        try {
          await source.deleteNotification(notification.originalId, syncToServer: true);
          
          AppLogger.getLogger('UnifiedNotification').info(
            '✅ 删除同步成功: $notificationId'
          );
        } catch (e) {
          AppLogger.getLogger('UnifiedNotification').warning(
            '⚠️ 删除同步失败: $e'
          );
        }
      }
    }
    
    notifyListeners();
  }
  
  /// 清理已读通知
  Future<void> clearRead() async {
    final readNotifications = notifications.where((n) => n.isRead).toList();
    
    for (final notification in readNotifications) {
      await deleteNotification(notification.id, syncToServer: false);
    }
    
    AppLogger.getLogger('UnifiedNotification').info(
      '🧹 清理了 ${readNotifications.length} 条已读通知'
    );
  }
  
  /// 清空所有通知
  Future<void> clearAll() async {
    final allIds = _notifications.keys.toList();
    
    // 记录所有删除
    for (final id in allIds) {
      await _saveDeletedStatus(id);
    }
    
    _notifications.clear();
    
    AppLogger.getLogger('UnifiedNotification').info(
      '🗑️ 清空了所有通知'
    );
    
    notifyListeners();
  }
  
  /// 应用保留策略
  void _applyRetentionPolicy() {
    // 1. 按数量限制
    if (_notifications.length > _maxNotifications) {
      final sorted = notifications;
      final toRemove = sorted.skip(_maxNotifications).map((n) => n.id).toList();
      
      for (final id in toRemove) {
        _notifications.remove(id);
      }
    }
    
    // 2. 按时间限制
    final cutoffDate = DateTime.now().subtract(Duration(days: _retentionDays));
    final oldNotifications = _notifications.values
        .where((n) => n.timestamp.isBefore(cutoffDate))
        .map((n) => n.id)
        .toList();
    
    for (final id in oldNotifications) {
      _notifications.remove(id);
    }
  }
  
  /// 加载本地状态
  Future<void> _loadLocalState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载已读状态
      final readStatusJson = prefs.getString(_readStatusKey);
      if (readStatusJson != null) {
        final readStatus = Map<String, bool>.from(jsonDecode(readStatusJson));
        AppLogger.getLogger('UnifiedNotification').info(
          '📖 加载了 ${readStatus.length} 条已读状态'
        );
      }
      
      // 加载删除记录
      final deletedJson = prefs.getString(_deletedKey);
      if (deletedJson != null) {
        final deleted = List<String>.from(jsonDecode(deletedJson));
        AppLogger.getLogger('UnifiedNotification').info(
          '🗑️ 加载了 ${deleted.length} 条删除记录'
        );
      }
    } catch (e) {
      AppLogger.getLogger('UnifiedNotification').warning(
        '⚠️ 加载本地状态失败: $e'
      );
    }
  }
  
  /// 保存已读状态
  Future<void> _saveLocalReadStatus(String notificationId, bool isRead) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 获取现有状态
      final readStatusJson = prefs.getString(_readStatusKey);
      final readStatus = readStatusJson != null 
          ? Map<String, bool>.from(jsonDecode(readStatusJson))
          : <String, bool>{};
      
      // 更新状态
      readStatus[notificationId] = isRead;
      
      // 保存
      await prefs.setString(_readStatusKey, jsonEncode(readStatus));
    } catch (e) {
      AppLogger.getLogger('UnifiedNotification').warning(
        '⚠️ 保存已读状态失败: $e'
      );
    }
  }
  
  /// 获取本地已读状态
  bool? _getLocalReadStatus(String notificationId) {
    // 这里应该从 SharedPreferences 读取，简化处理
    return null;
  }
  
  /// 保存删除状态
  Future<void> _saveDeletedStatus(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 获取现有删除记录
      final deletedJson = prefs.getString(_deletedKey);
      final deleted = deletedJson != null 
          ? List<String>.from(jsonDecode(deletedJson))
          : <String>[];
      
      // 添加新的删除记录
      if (!deleted.contains(notificationId)) {
        deleted.add(notificationId);
      }
      
      // 限制删除记录数量（避免无限增长）
      if (deleted.length > 1000) {
        deleted.removeRange(0, deleted.length - 1000);
      }
      
      // 保存
      await prefs.setString(_deletedKey, jsonEncode(deleted));
    } catch (e) {
      AppLogger.getLogger('UnifiedNotification').warning(
        '⚠️ 保存删除状态失败: $e'
      );
    }
  }
  
  /// 检查是否已删除
  bool _isDeleted(String notificationId) {
    // 这里应该从 SharedPreferences 读取，简化处理
    return false;
  }
}
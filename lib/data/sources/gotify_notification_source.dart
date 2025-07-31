import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/interfaces/notification_source.dart';
import '../../core/utils/app_logger.dart';
import '../models/gotify_models.dart';

/// Gotify 通知源实现
/// 
/// 实现了 INotificationSource 接口，提供 Gotify 特定的功能
class GotifyNotificationSource implements INotificationSource {
  final String serverUrl;
  final String clientToken;
  final http.Client _httpClient = http.Client();
  
  GotifyNotificationSource({
    required this.serverUrl,
    required this.clientToken,
  });
  
  @override
  String get sourceId => 'gotify';
  
  @override
  String get sourceName => 'Gotify Server';
  
  @override
  bool get supportsMarkAsRead => false; // Gotify 不支持标记已读
  
  @override
  bool get supportsDelete => true; // Gotify 支持删除消息
  
  @override
  Future<bool> markAsRead(String notificationId, {bool syncToServer = false}) async {
    // Gotify 不支持标记已读，只在本地处理
    AppLogger.getLogger('GotifySource').info(
      '📖 Gotify 不支持服务端已读状态，仅本地标记'
    );
    return true;
  }
  
  @override
  Future<bool> markAllAsRead({bool syncToServer = false}) async {
    // Gotify 不支持批量标记已读
    return true;
  }
  
  @override
  Future<bool> deleteNotification(String notificationId, {bool syncToServer = false}) async {
    if (!syncToServer) return true;
    
    try {
      final url = '$serverUrl/message/$notificationId?token=$clientToken';
      final response = await _httpClient.delete(Uri.parse(url));
      
      if (response.statusCode == 200) {
        AppLogger.getLogger('GotifySource').info(
          '✅ 成功删除 Gotify 消息: $notificationId'
        );
        return true;
      } else {
        AppLogger.getLogger('GotifySource').warning(
          '⚠️ 删除 Gotify 消息失败: ${response.statusCode}'
        );
        return false;
      }
    } catch (e) {
      AppLogger.getLogger('GotifySource').severe(
        '❌ 删除 Gotify 消息异常', e
      );
      return false;
    }
  }
  
  @override
  Future<bool> deleteNotifications(List<String> notificationIds, {bool syncToServer = false}) async {
    if (!syncToServer) return true;
    
    // Gotify 不支持批量删除，需要逐个删除
    bool allSuccess = true;
    for (final id in notificationIds) {
      final success = await deleteNotification(id, syncToServer: true);
      if (!success) allSuccess = false;
    }
    return allSuccess;
  }
  
  @override
  Future<List<UnifiedNotification>> getHistory({int limit = 50, int offset = 0}) async {
    try {
      final url = '$serverUrl/message?limit=$limit&token=$clientToken';
      final response = await _httpClient.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final pagedResponse = GotifyPagedResponse<GotifyMessage>.fromJson(
          json,
          (json) => GotifyMessage.fromJson(json as Map<String, dynamic>),
        );
        
        // 转换为统一通知格式
        return pagedResponse.messages.map((msg) => UnifiedNotification(
          id: UnifiedNotification.generateId(sourceId, msg.id.toString()),
          sourceId: sourceId,
          originalId: msg.id.toString(),
          title: msg.title,
          message: msg.message,
          priority: msg.priority,
          timestamp: msg.date,
          extras: msg.extras,
        )).toList();
      } else {
        AppLogger.getLogger('GotifySource').warning(
          '⚠️ 获取 Gotify 历史消息失败: ${response.statusCode}'
        );
        return [];
      }
    } catch (e) {
      AppLogger.getLogger('GotifySource').severe(
        '❌ 获取 Gotify 历史消息异常', e
      );
      return [];
    }
  }
  
  /// 从 Gotify WebSocket 消息创建统一通知
  UnifiedNotification createNotificationFromWebSocketMessage(GotifyWebSocketMessage message) {
    return UnifiedNotification(
      id: UnifiedNotification.generateId(sourceId, message.id.toString()),
      sourceId: sourceId,
      originalId: message.id.toString(),
      title: message.title,
      message: message.message,
      priority: message.priority,
      timestamp: DateTime.parse(message.date),
    );
  }
  
  /// 从 Gotify 消息创建统一通知
  UnifiedNotification createNotificationFromMessage(GotifyMessage message) {
    return UnifiedNotification(
      id: UnifiedNotification.generateId(sourceId, message.id.toString()),
      sourceId: sourceId,
      originalId: message.id.toString(),
      title: message.title,
      message: message.message,
      priority: message.priority,
      timestamp: message.date,
      extras: message.extras,
    );
  }
  
  void dispose() {
    _httpClient.close();
  }
}
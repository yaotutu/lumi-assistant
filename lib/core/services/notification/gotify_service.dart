import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_logger.dart';
import '../../config/app_settings.dart';
import '../../../data/models/notification/gotify_models.dart';
import '../../../presentation/widgets/notification_bubble.dart';
import 'unified_notification_service.dart';
import '../../../data/sources/gotify_notification_source.dart';
import '../../../data/models/notification/notification_source.dart';

/// Gotify 推送通知服务
/// 
/// 职责：与 Gotify 服务器进行通信，接收和管理推送通知
/// 依赖：http（REST API 调用）、web_socket_channel（实时通知）
/// 使用场景：接收服务器推送的各类通知消息
/// 
/// 主要功能：
/// 1. REST API 调用：获取历史消息、删除消息
/// 2. WebSocket 连接：实时接收新消息
/// 3. 自动重连机制：网络断开后自动恢复
/// 4. 消息转换：将 Gotify 消息转换为应用内通知
class GotifyService {
  /// 应用设置实例
  final AppSettings _appSettings = AppSettings.instance;
  
  
  /// WebSocket 连接实例
  /// null 表示当前未连接
  WebSocketChannel? _webSocketChannel;
  
  /// WebSocket 消息流订阅
  /// 用于管理消息监听的生命周期
  StreamSubscription? _messageSubscription;
  
  /// 重连定时器
  /// 用于在连接断开后定时重连
  Timer? _reconnectTimer;
  
  /// 重连延迟时间（毫秒）
  /// 采用指数退避策略，每次失败后延迟翻倍
  int _reconnectDelay = 1000;
  
  /// 最大重连延迟时间（毫秒）
  /// 防止延迟时间无限增长
  static const int _maxReconnectDelay = 30000;
  
  /// 最大重连次数
  /// 避免无限重连占用资源
  static const int _maxReconnectAttempts = 5;
  
  /// 当前重连次数
  int _reconnectAttempts = 0;
  
  /// 是否正在运行
  /// false 时停止自动重连
  bool _isRunning = false;
  
  /// 是否正在处理重连
  /// 防止重复触发重连
  bool _isReconnecting = false;
  
  /// HTTP 客户端
  /// 用于 REST API 调用
  final http.Client _httpClient = http.Client();
  
  /// Gotify 通知源
  GotifyNotificationSource? _notificationSource;
  
  /// 启动 Gotify 服务
  /// 
  /// 执行步骤：
  /// 1. 标记服务为运行状态
  /// 2. 连接 WebSocket 以接收实时通知
  /// 3. 获取历史消息（可选）
  Future<void> start() async {
    try {
      // 标记服务已启动
      _isRunning = true;
      
      // 记录启动日志
      AppLogger.getLogger('Gotify').info('🚀 启动 Gotify 服务');
      
      // 检查配置是否有效
      final serverUrl = _appSettings.gotifyServerUrl;
      final clientToken = _appSettings.gotifyClientToken;
      
      if (serverUrl.isEmpty || clientToken.isEmpty) {
        AppLogger.getLogger('Gotify').warning('⚠️ Gotify 未配置，跳过启动');
        return;
      }
      
      AppLogger.getLogger('Gotify').info('📍 服务器地址: $serverUrl');
      
      // 创建并注册通知源
      _notificationSource = GotifyNotificationSource(
        serverUrl: serverUrl,
        clientToken: clientToken,
      );
      UnifiedNotificationService.instance.registerSource(_notificationSource!);
      
      // 连接 WebSocket
      await _connectWebSocket();
      
      // 获取最近的历史消息（可选）
      // 这里获取最近 10 条消息，避免初次启动时错过重要通知
      await _fetchRecentMessages(limit: 10);
      
    } catch (e, stackTrace) {
      // 启动失败记录错误
      AppLogger.getLogger('Gotify').severe('❌ Gotify 服务启动失败', e, stackTrace);
      
      // 启动失败后尝试重连
      _scheduleReconnect();
    }
  }
  
  /// 停止 Gotify 服务
  /// 
  /// 清理步骤：
  /// 1. 标记服务为停止状态
  /// 2. 取消所有定时器
  /// 3. 关闭 WebSocket 连接
  /// 4. 释放 HTTP 客户端
  Future<void> stop() async {
    // 标记服务已停止，防止自动重连
    _isRunning = false;
    _isReconnecting = false;
    
    // 记录停止日志
    AppLogger.getLogger('Gotify').info('🛑 停止 Gotify 服务');
    
    // 取消重连定时器
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    
    // 重置重连相关状态
    _reconnectDelay = 1000;
    _reconnectAttempts = 0;
    
    // 断开 WebSocket 连接
    await _disconnectWebSocket();
    
    // 注销通知源
    if (_notificationSource != null) {
      UnifiedNotificationService.instance.unregisterSource(_notificationSource!.sourceId);
      _notificationSource?.dispose();
      _notificationSource = null;
    }
    
    // 关闭 HTTP 客户端
    _httpClient.close();
  }
  
  /// 连接 WebSocket
  /// 
  /// WebSocket URL 格式：ws://server/stream?token=xxx
  /// 使用客户端令牌进行认证
  Future<void> _connectWebSocket() async {
    try {
      // 构建 WebSocket URL
      // 将 http:// 替换为 ws://，https:// 替换为 wss://
      final serverUrl = _appSettings.gotifyServerUrl;
      final clientToken = _appSettings.gotifyClientToken;
      
      if (serverUrl.isEmpty || clientToken.isEmpty) {
        throw Exception('Gotify 未配置');
      }
      
      // 确保URL末尾没有斜杠
      final cleanServerUrl = serverUrl.endsWith('/') 
          ? serverUrl.substring(0, serverUrl.length - 1) 
          : serverUrl;
      
      final wsUrl = cleanServerUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final url = '$wsUrl/stream?token=$clientToken';
      
      // 记录连接日志
      AppLogger.getLogger('Gotify').info('🔌 连接 Gotify WebSocket: $url');
      
      // 创建 WebSocket 连接
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(url));
      
      // 监听消息流
      _messageSubscription = _webSocketChannel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
        cancelOnError: false, // 错误时不自动取消订阅
      );
      
      // 等待一小段时间确认连接真的成功了
      // 因为有些错误是在连接建立后才抛出的
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 如果没有抛出异常，说明连接成功，重置重连延迟和次数
      _reconnectDelay = 1000;
      _reconnectAttempts = 0;
      
      AppLogger.getLogger('Gotify').info('✅ Gotify WebSocket 连接成功');
      
    } catch (e, stackTrace) {
      // 连接失败记录错误
      AppLogger.getLogger('Gotify').severe('❌ Gotify WebSocket 连接失败', e, stackTrace);
      
      // 尝试重连
      _scheduleReconnect();
    }
  }
  
  /// 断开 WebSocket 连接
  /// 
  /// 清理连接相关资源
  Future<void> _disconnectWebSocket() async {
    // 取消消息订阅
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    
    // 关闭 WebSocket 连接
    await _webSocketChannel?.sink.close();
    _webSocketChannel = null;
    
    AppLogger.getLogger('Gotify').info('🔌 Gotify WebSocket 已断开');
  }
  
  /// 处理 WebSocket 消息
  /// 
  /// 参数：
  /// - [data] WebSocket 接收到的原始数据
  /// 
  /// 消息格式：JSON 字符串，包含 Gotify 消息数据
  void _handleWebSocketMessage(dynamic data) {
    try {
      // 记录接收到的原始消息
      AppLogger.getLogger('Gotify').fine('📨 收到 Gotify 消息: $data');
      
      // 解析 JSON 数据
      final Map<String, dynamic> json = jsonDecode(data.toString());
      
      // 转换为 Gotify 消息模型
      final message = GotifyWebSocketMessage.fromJson(json);
      
      // 记录消息详情
      AppLogger.getLogger('Gotify').info('📬 Gotify 通知: ${message.title ?? "无标题"} - ${message.message}');
      
      // 转换为应用内通知并显示
      _showNotification(message);
      
    } catch (e, stackTrace) {
      // 消息解析失败
      AppLogger.getLogger('Gotify').severe('❌ Gotify 消息解析失败: $data', e, stackTrace);
    }
  }
  
  /// 处理 WebSocket 错误
  /// 
  /// 参数：
  /// - [error] 错误对象
  void _handleWebSocketError(dynamic error) {
    // 记录错误日志
    AppLogger.getLogger('Gotify').severe('❌ Gotify WebSocket 错误: $error');
    
    // 错误后尝试重连
    _scheduleReconnect();
  }
  
  /// 处理 WebSocket 连接关闭
  /// 
  /// 连接关闭可能是服务器主动断开或网络问题
  void _handleWebSocketDone() {
    // 记录连接关闭
    AppLogger.getLogger('Gotify').warning('⚠️ Gotify WebSocket 连接已关闭');
    
    // 如果服务仍在运行，尝试重连
    if (_isRunning) {
      _scheduleReconnect();
    }
  }
  
  /// 安排重连
  /// 
  /// 使用指数退避策略，避免频繁重连
  void _scheduleReconnect() {
    // 如果服务已停止，不再重连
    if (!_isRunning) {
      return;
    }
    
    // 如果已有重连定时器或正在重连，不重复创建
    if (_reconnectTimer != null || _isReconnecting) {
      return;
    }
    
    // 检查是否达到最大重连次数
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.getLogger('Gotify').severe(
        '❌ 达到最大重连次数 ($_maxReconnectAttempts)，停止重连。'
        '请检查服务器地址和令牌配置是否正确。'
      );
      return;
    }
    
    // 增加重连次数
    _reconnectAttempts++;
    
    // 记录重连计划
    AppLogger.getLogger('Gotify').info(
      '⏱️ 将在 ${_reconnectDelay}ms 后重连 Gotify '
      '(第 $_reconnectAttempts/$_maxReconnectAttempts 次尝试)'
    );
    
    // 标记正在处理重连
    _isReconnecting = true;
    
    // 创建重连定时器
    _reconnectTimer = Timer(Duration(milliseconds: _reconnectDelay), () async {
      _reconnectTimer = null;
      
      // 增加下次重连延迟（指数退避）
      _reconnectDelay = (_reconnectDelay * 2).clamp(1000, _maxReconnectDelay);
      
      // 尝试重连
      await _connectWebSocket();
      
      // 重连完成，清除标记
      _isReconnecting = false;
    });
  }
  
  /// 获取最近的消息
  /// 
  /// 参数：
  /// - [limit] 获取的消息数量
  /// 
  /// 用于在启动时获取历史消息，避免错过重要通知
  Future<void> _fetchRecentMessages({int limit = 10}) async {
    try {
      // 构建 API URL
      final serverUrl = _appSettings.gotifyServerUrl;
      final clientToken = _appSettings.gotifyClientToken;
      
      if (serverUrl.isEmpty || clientToken.isEmpty) {
        AppLogger.getLogger('Gotify').warning('⚠️ Gotify 未配置，跳过获取历史消息');
        return;
      }
      
      final url = '$serverUrl/message?limit=$limit&token=$clientToken';
      
      // 记录请求日志
      AppLogger.getLogger('Gotify').info('📥 获取最近 $limit 条 Gotify 消息');
      
      // 发送 HTTP GET 请求
      final response = await _httpClient.get(Uri.parse(url));
      
      // 检查响应状态
      if (response.statusCode != 200) {
        throw Exception('获取消息失败: ${response.statusCode} ${response.reasonPhrase}');
      }
      
      // 解析响应数据
      final json = jsonDecode(response.body);
      final pagedResponse = GotifyPagedResponse<GotifyMessage>.fromJson(
        json,
        (json) => GotifyMessage.fromJson(json as Map<String, dynamic>),
      );
      
      // 记录获取到的消息数量
      AppLogger.getLogger('Gotify').info('✅ 获取到 ${pagedResponse.messages.length} 条历史消息');
      
      // 显示历史消息（按时间倒序，最新的先显示）
      for (final message in pagedResponse.messages.reversed) {
        _showHistoricalNotification(message);
      }
      
    } catch (e, stackTrace) {
      // 获取失败不影响服务运行
      AppLogger.getLogger('Gotify').warning('⚠️ 获取历史消息失败', e, stackTrace);
    }
  }
  
  /// 删除消息
  /// 
  /// 参数：
  /// - [messageId] 要删除的消息 ID
  /// 
  /// 返回：删除是否成功
  Future<bool> deleteMessage(int messageId) async {
    try {
      // 构建 API URL
      final serverUrl = _appSettings.gotifyServerUrl;
      final clientToken = _appSettings.gotifyClientToken;
      
      if (serverUrl.isEmpty || clientToken.isEmpty) {
        AppLogger.getLogger('Gotify').warning('⚠️ Gotify 未配置');
        return false;
      }
      
      final url = '$serverUrl/message/$messageId?token=$clientToken';
      
      // 记录删除日志
      AppLogger.getLogger('Gotify').info('🗑️ 删除 Gotify 消息: ID=$messageId');
      
      // 发送 HTTP DELETE 请求
      final response = await _httpClient.delete(Uri.parse(url));
      
      // 检查响应状态
      if (response.statusCode == 200) {
        AppLogger.getLogger('Gotify').info('✅ 消息删除成功');
        return true;
      } else {
        AppLogger.getLogger('Gotify').warning('⚠️ 消息删除失败: ${response.statusCode}');
        return false;
      }
      
    } catch (e, stackTrace) {
      // 删除失败
      AppLogger.getLogger('Gotify').severe('❌ 删除消息失败', e, stackTrace);
      return false;
    }
  }
  
  /// 显示通知
  /// 
  /// 将 Gotify 消息转换为统一通知并添加到通知服务
  void _showNotification(GotifyWebSocketMessage message) {
    if (_notificationSource == null) return;
    
    // 创建统一通知
    final notification = _notificationSource!.createNotificationFromWebSocketMessage(message);
    
    // 添加到统一通知服务（这会自动触发 NotificationBubbleManager 的更新）
    UnifiedNotificationService.instance.addNotification(notification);
    
    // 触发新通知动画
    NotificationBubbleManager.instance.setNewNotificationFlag();
    
    AppLogger.getLogger('Gotify').info('🔔 显示 Gotify 通知: ${message.title ?? "无标题"} - ${message.message}');
  }
  
  /// 显示历史通知
  /// 
  /// 历史通知使用较低的优先级，避免干扰用户
  void _showHistoricalNotification(GotifyMessage message) {
    if (_notificationSource == null) return;
    
    // 创建统一通知
    final notification = _notificationSource!.createNotificationFromMessage(message);
    
    // 历史消息降低优先级
    final adjustedPriority = message.priority > 2 ? message.priority - 2 : 0;
    final adjustedNotification = UnifiedNotification(
      id: notification.id,
      sourceId: notification.sourceId,
      originalId: notification.originalId,
      title: notification.title,
      message: notification.message,
      priority: adjustedPriority,
      timestamp: notification.timestamp,
      extras: notification.extras,
    );
    
    // 添加到统一通知服务（不触发新通知动画）
    UnifiedNotificationService.instance.addNotification(adjustedNotification);
  }
  
  
  /// 单例模式
  static final GotifyService _instance = GotifyService._internal();
  factory GotifyService() => _instance;
  GotifyService._internal();
}
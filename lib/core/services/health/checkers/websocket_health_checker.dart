import 'dart:async';
import '../service_health_checker.dart';
import '../../../config/app_settings.dart';
import '../../websocket/websocket_service.dart';
import '../../../../data/models/connection/websocket_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// WebSocket 服务健康检查器
/// 
/// 检查与小智后端的WebSocket连接状态
class WebSocketHealthChecker implements IServiceHealthChecker {
  final Ref _ref;
  
  WebSocketHealthChecker(this._ref);
  
  @override
  String get serviceName => '小智后端连接';
  
  @override
  String get description => 'WebSocket 实时通信服务';
  
  @override
  Future<ServiceHealthResult> checkHealth() async {
    try {
      // 获取配置
      final settings = AppSettings.instance;
      final serverUrl = settings.serverUrl;
      
      // 检查配置
      if (serverUrl.isEmpty || serverUrl == AppSettings.defaultServerUrl) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: false,
          message: '未配置服务器地址',
        );
      }
      
      // 检查连接状态
      final state = _ref.read(webSocketServiceProvider);
      
      switch (state.connectionState) {
        case WebSocketConnectionState.connected:
          return ServiceHealthResult(
            serviceName: serviceName,
            description: description,
            isHealthy: true,
            message: '已连接到 $serverUrl',
            extras: {
              'server_url': serverUrl,
              'uptime': state.connectionUptime?.inSeconds,
              'quality': state.healthStatus,
              'messages_sent': state.messagesSent,
              'messages_received': state.messagesReceived,
            },
          );
          
        case WebSocketConnectionState.connecting:
          return ServiceHealthResult(
            serviceName: serviceName,
            description: description,
            isHealthy: false,
            message: '正在连接到 $serverUrl',
            extras: {
              'server_url': serverUrl,
            },
          );
          
        case WebSocketConnectionState.disconnected:
          return ServiceHealthResult(
            serviceName: serviceName,
            description: description,
            isHealthy: false,
            message: '未连接',
            extras: {
              'server_url': serverUrl,
              'error': state.errorMessage,
            },
          );
          
        case WebSocketConnectionState.failed:
          return ServiceHealthResult(
            serviceName: serviceName,
            description: description,
            isHealthy: false,
            message: '连接失败: ${state.errorMessage ?? "未知错误"}',
            extras: {
              'server_url': serverUrl,
              'error': state.errorMessage,
              'error_code': state.errorCode,
            },
          );
          
        case WebSocketConnectionState.reconnecting:
          return ServiceHealthResult(
            serviceName: serviceName,
            description: description,
            isHealthy: false,
            message: '正在重连 (${state.reconnectAttempts}/${state.maxReconnectAttempts})',
            extras: {
              'server_url': serverUrl,
              'reconnect_attempts': state.reconnectAttempts,
              'max_attempts': state.maxReconnectAttempts,
            },
          );
      }
      
    } catch (e) {
      return ServiceHealthResult(
        serviceName: serviceName,
        description: description,
        isHealthy: false,
        message: '检查失败: $e',
      );
    }
  }
}
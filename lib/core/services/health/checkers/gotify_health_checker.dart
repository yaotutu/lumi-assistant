import 'dart:async';
import '../service_health_checker.dart';
import '../../../config/app_settings.dart';
import '../../notification/gotify_service.dart';

/// Gotify 服务健康检查器
/// 
/// 检查 Gotify 通知服务的连接状态
class GotifyHealthChecker implements IServiceHealthChecker {
  final GotifyService _gotifyService;
  
  GotifyHealthChecker(this._gotifyService);
  
  @override
  String get serviceName => 'Gotify 通知服务';
  
  @override
  String get description => '推送通知接收服务';
  
  @override
  Future<ServiceHealthResult> checkHealth() async {
    try {
      // 获取配置
      final settings = AppSettings.instance;
      final serverUrl = settings.gotifyServerUrl;
      final clientToken = settings.gotifyClientToken;
      
      // 检查配置
      if (serverUrl.isEmpty || clientToken.isEmpty) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: false,
          message: '未配置 Gotify 服务',
          extras: {
            'configured': false,
          },
        );
      }
      
      // 检查服务是否在运行
      if (!_gotifyService.isRunning) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: false,
          message: 'Gotify 服务未启动',
          extras: {
            'server_url': serverUrl,
            'configured': true,
            'running': false,
          },
        );
      }
      
      // 检查 WebSocket 连接状态
      if (_gotifyService.isConnected) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: true,
          message: '已连接到 $serverUrl',
          extras: {
            'server_url': serverUrl,
            'configured': true,
            'running': true,
            'connected': true,
          },
        );
      } else if (_gotifyService.isReconnecting) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: false,
          message: '正在重连到 $serverUrl',
          extras: {
            'server_url': serverUrl,
            'configured': true,
            'running': true,
            'connected': false,
            'reconnecting': true,
          },
        );
      } else {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: false,
          message: '未连接到 $serverUrl',
          extras: {
            'server_url': serverUrl,
            'configured': true,
            'running': true,
            'connected': false,
            'reconnecting': false,
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
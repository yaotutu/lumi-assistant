import 'dart:async';
import '../../utils/app_logger.dart';
import '../notification/unified_notification_service.dart';
import '../../../data/sources/system_notification_source.dart';
import '../../../presentation/widgets/notification/notification_bubble.dart';

/// 服务健康检查结果
class ServiceHealthResult {
  /// 服务名称
  final String serviceName;
  
  /// 服务描述
  final String description;
  
  /// 是否健康
  final bool isHealthy;
  
  /// 状态消息
  final String message;
  
  /// 检查时间
  final DateTime timestamp;
  
  /// 额外信息
  final Map<String, dynamic>? extras;
  
  ServiceHealthResult({
    required this.serviceName,
    required this.description,
    required this.isHealthy,
    required this.message,
    DateTime? timestamp,
    this.extras,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 服务健康检查器接口
/// 
/// 所有需要健康检查的服务都应该实现这个接口
abstract class IServiceHealthChecker {
  /// 服务名称
  String get serviceName;
  
  /// 服务描述
  String get description;
  
  /// 执行健康检查
  Future<ServiceHealthResult> checkHealth();
}

/// 服务健康检查管理器
/// 
/// 职责：管理所有服务的健康检查，并在应用启动时执行
/// 设计理念：
/// 1. 可扩展性：新服务只需实现 IServiceHealthChecker 接口
/// 2. 异步执行：所有检查并行执行，提高效率
/// 3. 结果通知：通过通知系统展示检查结果
class ServiceHealthManager {
  /// 已注册的健康检查器
  final List<IServiceHealthChecker> _checkers = [];
  
  /// 检查结果
  final List<ServiceHealthResult> _results = [];
  
  /// 是否正在检查
  bool _isChecking = false;
  
  /// 获取检查结果
  List<ServiceHealthResult> get results => List.unmodifiable(_results);
  
  /// 注册健康检查器
  void registerChecker(IServiceHealthChecker checker) {
    _checkers.add(checker);
    AppLogger.getLogger('HealthCheck').info(
      '📋 注册健康检查器: ${checker.serviceName}'
    );
  }
  
  /// 注销健康检查器
  void unregisterChecker(IServiceHealthChecker checker) {
    _checkers.remove(checker);
    AppLogger.getLogger('HealthCheck').info(
      '📤 注销健康检查器: ${checker.serviceName}'
    );
  }
  
  /// 执行所有健康检查
  /// 
  /// 返回：所有服务的健康状态
  Future<List<ServiceHealthResult>> performHealthCheck() async {
    if (_isChecking) {
      AppLogger.getLogger('HealthCheck').warning('⚠️ 健康检查正在进行中');
      return _results;
    }
    
    _isChecking = true;
    _results.clear();
    
    AppLogger.getLogger('HealthCheck').info('🏥 开始服务健康检查...');
    
    // 显示开始检查的通知
    _showHealthCheckNotification(
      '系统健康检查',
      '正在检查服务状态...',
      priority: 5,
    );
    
    // 并行执行所有健康检查
    final futures = _checkers.map((checker) async {
      try {
        final result = await checker.checkHealth();
        _results.add(result);
        
        // 记录检查结果
        if (result.isHealthy) {
          AppLogger.getLogger('HealthCheck').info(
            '✅ ${result.serviceName}: ${result.message}'
          );
        } else {
          AppLogger.getLogger('HealthCheck').warning(
            '❌ ${result.serviceName}: ${result.message}'
          );
        }
        
        return result;
      } catch (e, stackTrace) {
        // 检查失败也要记录结果
        final errorResult = ServiceHealthResult(
          serviceName: checker.serviceName,
          description: checker.description,
          isHealthy: false,
          message: '健康检查失败: $e',
        );
        _results.add(errorResult);
        
        AppLogger.getLogger('HealthCheck').severe(
          '❌ ${checker.serviceName} 健康检查失败',
          e,
          stackTrace,
        );
        
        return errorResult;
      }
    });
    
    // 等待所有检查完成
    await Future.wait(futures);
    
    // 生成汇总报告
    _generateHealthReport();
    
    _isChecking = false;
    
    AppLogger.getLogger('HealthCheck').info('🏥 服务健康检查完成');
    
    return _results;
  }
  
  /// 生成健康检查报告
  void _generateHealthReport() {
    final healthyServices = _results.where((r) => r.isHealthy).toList();
    final unhealthyServices = _results.where((r) => !r.isHealthy).toList();
    
    // 构建报告内容
    final reportLines = <String>[];
    
    if (healthyServices.isNotEmpty) {
      reportLines.add('✅ 正常服务 (${healthyServices.length})：');
      for (final service in healthyServices) {
        reportLines.add('  • ${service.serviceName}: ${service.message}');
      }
    }
    
    if (unhealthyServices.isNotEmpty) {
      if (reportLines.isNotEmpty) reportLines.add('');
      reportLines.add('❌ 异常服务 (${unhealthyServices.length})：');
      for (final service in unhealthyServices) {
        reportLines.add('  • ${service.serviceName}: ${service.message}');
      }
    }
    
    // 确定通知优先级
    final priority = unhealthyServices.isEmpty ? 3 : 7;
    final title = unhealthyServices.isEmpty 
        ? '所有服务运行正常' 
        : '部分服务存在问题';
    
    // 显示汇总通知
    _showHealthCheckNotification(
      title,
      reportLines.join('\n'),
      priority: priority,
      extras: {
        'healthy_count': healthyServices.length,
        'unhealthy_count': unhealthyServices.length,
        'total_count': _results.length,
      },
    );
  }
  
  /// 显示健康检查通知
  void _showHealthCheckNotification(
    String title,
    String message, {
    int priority = 5,
    Map<String, dynamic>? extras,
  }) {
    try {
      // 确保系统通知源已注册
      final systemSource = SystemNotificationSource();
      UnifiedNotificationService.instance.registerSource(systemSource);
      
      // 创建通知
      final notification = SystemNotificationSource.createNotification(
        title: title,
        message: message,
        priority: priority,
        extras: {
          'type': 'health_check',
          ...?extras,
        },
      );
      
      // 添加到通知服务
      UnifiedNotificationService.instance.addNotification(notification);
      
      // 触发新通知动画
      NotificationBubbleManager.instance.setNewNotificationFlag();
      
    } catch (e) {
      AppLogger.getLogger('HealthCheck').severe(
        '❌ 无法显示健康检查通知: $e'
      );
    }
  }
  
  /// 单例模式
  static final ServiceHealthManager _instance = ServiceHealthManager._internal();
  factory ServiceHealthManager() => _instance;
  ServiceHealthManager._internal();
}
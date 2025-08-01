import '../service_health_checker.dart';
import '../../../utils/app_logger.dart';
import '../../../../domain/entities/weather.dart';
import '../../../../domain/repositories/weather_repository.dart';
import '../../../../presentation/providers/weather_provider.dart';
import '../../../../data/repositories/qweather_repository.dart';
import '../../../../data/models/weather_warning.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 天气服务健康检查器
/// 
/// 职责：检查天气服务的可用性
/// 检查项目：
/// - 天气服务是否启用
/// - API配置是否正确
/// - 能否成功获取天气数据
class WeatherHealthChecker implements IServiceHealthChecker {
  final Ref _ref;
  
  WeatherHealthChecker(this._ref);
  
  @override
  String get serviceName => '天气服务';
  
  @override
  String get description => '提供实时天气信息';
  
  @override
  Future<ServiceHealthResult> checkHealth() async {
    try {
      // 获取天气配置
      final config = _ref.read(weatherConfigProvider);
      
      // 如果天气服务未启用，返回跳过状态
      if (!config.enabled) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: true,  // 未启用不算不健康
          message: '天气服务未启用',
        );
      }
      
      // 获取天气仓库
      final repository = _ref.read(weatherRepositoryProvider);
      
      // 检查服务类型
      final serviceTypeName = switch (repository.serviceType) {
        WeatherServiceType.mock => '模拟数据',
        WeatherServiceType.qweather => '和风天气',
        WeatherServiceType.openweather => 'OpenWeather',
      };
      
      AppLogger.getLogger('Health').info('🌤️ 检查天气服务: $serviceTypeName');
      
      // 如果是模拟数据，直接返回健康
      if (repository.serviceType == WeatherServiceType.mock) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: true,
          message: '使用模拟数据',
          extras: {
            '服务类型': serviceTypeName,
            '位置': config.defaultLocation,
          },
        );
      }
      
      // 检查API密钥配置
      if (repository.serviceType == WeatherServiceType.qweather && 
          (config.qweatherApiKey == null || config.qweatherApiKey!.isEmpty)) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: false,
          message: '和风天气API密钥未配置',
          extras: {
            '服务类型': serviceTypeName,
            '配置状态': 'API密钥缺失',
          },
        );
      }
      
      // 尝试获取天气数据
      try {
        final weather = await repository.getCurrentWeather(config.defaultLocation);
        
        // 检查预警信息（仅和风天气支持）
        Map<String, String> warningInfo = {};
        if (repository is QWeatherRepository) {
          try {
            final warnings = await repository.getWeatherWarnings(config.defaultLocation);
            if (warnings.isNotEmpty) {
              // 找出最高级别的预警
              final highestWarning = warnings.reduce((a, b) {
                final aLevel = WarningSeverity.fromString(a.severity).level;
                final bLevel = WarningSeverity.fromString(b.severity).level;
                return aLevel >= bLevel ? a : b;
              });
              
              warningInfo['预警信息'] = '${warnings.length}条预警';
              warningInfo['最高级别'] = '${WarningSeverity.fromString(highestWarning.severity).chinese}预警';
              warningInfo['预警标题'] = highestWarning.title;
            }
          } catch (e) {
            AppLogger.getLogger('Health').warning('⚠️ 获取天气预警失败: $e');
            // 预警获取失败不影响主健康状态
          }
        }
        
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: true,
          message: '天气服务正常',
          extras: {
            '服务类型': serviceTypeName,
            '位置': config.defaultLocation,
            '温度': '${weather.temperature}°C',
            '天气': weather.description,
            '数据时间': weather.observationTime.toString(),
            ...warningInfo,
          },
        );
      } catch (e) {
        String errorMessage = '获取天气失败';
        Map<String, String> errorDetails = {
          '服务类型': serviceTypeName,
          '位置': config.defaultLocation,
        };
        
        if (e is WeatherException) {
          errorMessage = e.message;
          if (e.code != null) {
            errorDetails['错误代码'] = e.code!;
            
            // 根据错误代码提供建议
            if (e.code == '400') {
              errorDetails['建议'] = '请检查位置参数格式（使用城市ID或坐标）';
            } else if (e.code == '401') {
              errorDetails['建议'] = '请检查API密钥是否正确';
            } else if (e.code == '402') {
              errorDetails['建议'] = 'API调用次数已达上限';
            }
          }
        }
        
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: false,
          message: errorMessage,
          extras: errorDetails,
        );
      }
    } catch (e) {
      AppLogger.getLogger('Health').severe('❌ 天气健康检查失败', e);
      return ServiceHealthResult(
        serviceName: serviceName,
        description: description,
        isHealthy: false,
        message: '健康检查异常: ${e.toString()}',
      );
    }
  }
}
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../data/repositories/mock_weather_repository.dart';
import '../../data/repositories/qweather_repository.dart';
import '../../core/config/weather_config.dart';
import '../../core/config/app_settings.dart';
import '../../core/utils/app_logger.dart';
import '../widgets/notification/notification_bubble.dart';
import '../../data/models/weather_warning.dart';
import '../../data/models/notification/notification_types.dart';

/// 天气配置Provider
/// 从AppSettings同步配置
final weatherConfigProvider = Provider<WeatherConfig>((ref) {
  // 监听AppSettings变化
  final appSettings = ref.watch(appSettingsProvider);
  
  // 将weatherServiceType字符串转换为枚举
  WeatherServiceType serviceType;
  switch (appSettings.weatherServiceType) {
    case 'qweather':
      serviceType = WeatherServiceType.qweather;
      break;
    case 'openweather':
      serviceType = WeatherServiceType.openweather;
      break;
    case 'mock':
    default:
      serviceType = WeatherServiceType.mock;
  }
  
  return WeatherConfig(
    enabled: appSettings.weatherEnabled,
    serviceType: serviceType,
    defaultLocation: appSettings.weatherLocation,
    updateIntervalMinutes: appSettings.weatherUpdateInterval,
    qweatherApiKey: appSettings.qweatherApiKey,
    openweatherApiKey: appSettings.openweatherApiKey,
  );
});

/// 天气仓库Provider
/// 根据配置返回对应的天气服务实现
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final config = ref.watch(weatherConfigProvider);
  
  switch (config.serviceType) {
    case WeatherServiceType.qweather:
      if (config.qweatherApiKey == null || config.qweatherApiKey!.isEmpty) {
        AppLogger.getLogger('Weather').warning('⚠️ 和风天气API密钥未配置，使用模拟数据');
        return MockWeatherRepository();
      }
      return QWeatherRepository(apiKey: config.qweatherApiKey!);
      
    case WeatherServiceType.openweather:
      // TODO: 实现OpenWeather服务
      AppLogger.getLogger('Weather').info('OpenWeather服务暂未实现，使用模拟数据');
      return MockWeatherRepository();
      
    case WeatherServiceType.mock:
      return MockWeatherRepository();
  }
});

/// 当前天气Provider
/// 提供当前位置的天气信息
final currentWeatherProvider = FutureProvider<Weather?>((ref) async {
  final config = ref.watch(weatherConfigProvider);
  
  // 如果天气功能未启用，返回null
  if (!config.enabled) {
    return null;
  }
  
  try {
    final repository = ref.watch(weatherRepositoryProvider);
    final weather = await repository.getCurrentWeather(config.defaultLocation);
    
    AppLogger.getLogger('Weather').info('✅ 成功获取天气: ${weather.temperature}°C, ${weather.description}');
    return weather;
  } catch (e) {
    AppLogger.getLogger('Weather').severe('❌ 获取天气失败: $e');
    
    // 使用通知系统告知用户错误
    String errorMessage = '获取天气失败';
    if (e is WeatherException) {
      errorMessage = e.message;
      
      // 对特定错误给出更详细的提示
      if (e.code == '400') {
        errorMessage = '位置参数错误\n请使用城市ID(如101010100)或坐标';
      } else if (e.code == '401') {
        errorMessage = 'API密钥无效\n请检查和风天气API Key';
      }
    }
    
    // 显示错误通知
    NotificationBubbleManager.instance.addWeatherNotification(
      errorMessage,
      title: '天气服务错误',
    );
    
    // 不抛出异常，返回null让UI处理
    return null;
  }
});

/// 天气自动更新Provider
/// 定期刷新天气数据
final weatherAutoUpdateProvider = Provider<void>((ref) {
  final config = ref.watch(weatherConfigProvider);
  
  if (!config.enabled) return;
  
  // 设置定时刷新
  final timer = Stream.periodic(
    Duration(minutes: config.updateIntervalMinutes),
    (_) => ref.invalidate(currentWeatherProvider),
  ).listen((_) {});
  
  // 清理定时器
  ref.onDispose(() {
    timer.cancel();
  });
});

/// 天气服务状态
class WeatherServiceState {
  /// 是否正在加载
  final bool isLoading;
  
  /// 最后更新时间
  final DateTime? lastUpdate;
  
  /// 错误信息
  final String? error;
  
  /// 构造函数
  const WeatherServiceState({
    this.isLoading = false,
    this.lastUpdate,
    this.error,
  });
}

/// 天气服务状态Provider
final weatherServiceStateProvider = StateProvider<WeatherServiceState>((ref) {
  return const WeatherServiceState();
});

/// 天气预警Provider
/// 获取当前位置的天气预警信息
final weatherWarningsProvider = FutureProvider<List<WeatherWarning>>((ref) async {
  final config = ref.watch(weatherConfigProvider);
  
  // 如果天气功能未启用，返回空列表
  if (!config.enabled) {
    return [];
  }
  
  // 只有和风天气支持预警功能
  if (config.serviceType != WeatherServiceType.qweather) {
    return [];
  }
  
  try {
    final repository = ref.watch(weatherRepositoryProvider);
    
    // 检查是否是QWeatherRepository
    if (repository is! QWeatherRepository) {
      return [];
    }
    
    final warnings = await repository.getWeatherWarnings(config.defaultLocation);
    
    if (warnings.isNotEmpty) {
      AppLogger.getLogger('Weather').info('⚠️ 获取到 ${warnings.length} 条天气预警');
      
      // 显示最高级别的预警通知
      final highestWarning = warnings.reduce((a, b) {
        final aLevel = WarningSeverity.fromString(a.severity).level;
        final bLevel = WarningSeverity.fromString(b.severity).level;
        return aLevel >= bLevel ? a : b;
      });
      
      // 使用通知系统显示预警
      NotificationBubbleManager.instance.addWeatherNotification(
        highestWarning.title,
        title: '天气预警',
        level: NotificationLevel.urgent, // 预警使用紧急级别
      );
    }
    
    return warnings;
  } catch (e) {
    AppLogger.getLogger('Weather').severe('❌ 获取天气预警失败: $e');
    // 预警获取失败不影响主要功能，返回空列表
    return [];
  }
});

/// 天气预警自动更新Provider
/// 定期刷新预警数据（比天气更新更频繁）
final weatherWarningAutoUpdateProvider = Provider<void>((ref) {
  final config = ref.watch(weatherConfigProvider);
  
  if (!config.enabled || config.serviceType != WeatherServiceType.qweather) return;
  
  // 预警信息每10分钟更新一次（比天气更新更频繁）
  final timer = Stream.periodic(
    const Duration(minutes: 10),
    (_) => ref.invalidate(weatherWarningsProvider),
  ).listen((_) {});
  
  // 清理定时器
  ref.onDispose(() {
    timer.cancel();
  });
});
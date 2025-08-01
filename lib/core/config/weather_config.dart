import '../../domain/entities/weather.dart';

/// 天气配置管理
/// 
/// 职责：管理天气服务相关的配置
/// 包括：API密钥、默认位置、更新频率等
class WeatherConfig {
  /// 当前选择的天气服务
  final WeatherServiceType serviceType;
  
  /// 和风天气API密钥
  final String? qweatherApiKey;
  
  /// OpenWeather API密钥
  final String? openweatherApiKey;
  
  /// 默认位置
  /// 可以是城市ID、城市名或经纬度
  final String defaultLocation;
  
  /// 自动更新间隔（分钟）
  final int updateIntervalMinutes;
  
  /// 是否启用天气功能
  final bool enabled;
  
  /// 温度单位（metric: 摄氏度, imperial: 华氏度）
  final String temperatureUnit;
  
  /// 语言设置
  final String language;
  
  /// 构造函数
  const WeatherConfig({
    this.serviceType = WeatherServiceType.mock,
    this.qweatherApiKey,
    this.openweatherApiKey,
    this.defaultLocation = 'Beijing',
    this.updateIntervalMinutes = 30,
    this.enabled = true,
    this.temperatureUnit = 'metric',
    this.language = 'zh',
  });
  
  /// 默认配置
  static const WeatherConfig defaultConfig = WeatherConfig();
  
  /// 复制并修改配置
  WeatherConfig copyWith({
    WeatherServiceType? serviceType,
    String? qweatherApiKey,
    String? openweatherApiKey,
    String? defaultLocation,
    int? updateIntervalMinutes,
    bool? enabled,
    String? temperatureUnit,
    String? language,
  }) {
    return WeatherConfig(
      serviceType: serviceType ?? this.serviceType,
      qweatherApiKey: qweatherApiKey ?? this.qweatherApiKey,
      openweatherApiKey: openweatherApiKey ?? this.openweatherApiKey,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      updateIntervalMinutes: updateIntervalMinutes ?? this.updateIntervalMinutes,
      enabled: enabled ?? this.enabled,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      language: language ?? this.language,
    );
  }
  
  /// 检查配置是否有效
  bool isValid() {
    if (!enabled) return true;
    
    switch (serviceType) {
      case WeatherServiceType.qweather:
        return qweatherApiKey != null && qweatherApiKey!.isNotEmpty;
      case WeatherServiceType.openweather:
        return openweatherApiKey != null && openweatherApiKey!.isNotEmpty;
      case WeatherServiceType.mock:
        return true;
    }
  }
}
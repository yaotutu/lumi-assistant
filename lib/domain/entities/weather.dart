/// 天气信息实体
/// 
/// 职责：定义天气数据的核心结构
/// 设计原则：与具体天气服务API无关，只包含通用天气信息
class Weather {
  /// 温度（摄氏度）
  final double temperature;
  
  /// 天气描述（如：晴天、多云、雨天等）
  final String description;
  
  /// 天气图标代码
  /// 不同的天气服务可能返回不同的图标代码
  /// 需要在UI层进行映射
  final String iconCode;
  
  /// 体感温度（摄氏度）
  final double? feelsLike;
  
  /// 湿度（百分比）
  final int? humidity;
  
  /// 风速（米/秒）
  final double? windSpeed;
  
  /// 风向（度数）
  final int? windDirection;
  
  /// 能见度（米）
  final int? visibility;
  
  /// 气压（百帕）
  final int? pressure;
  
  /// 观测时间
  final DateTime observationTime;
  
  /// 数据来源（如：qweather、openweather等）
  final String source;
  
  /// 构造函数
  const Weather({
    required this.temperature,
    required this.description,
    required this.iconCode,
    this.feelsLike,
    this.humidity,
    this.windSpeed,
    this.windDirection,
    this.visibility,
    this.pressure,
    required this.observationTime,
    required this.source,
  });
  
  /// 从JSON创建Weather对象的工厂方法
  /// 具体实现由各个天气服务提供
  
  /// 复制对象并修改部分属性
  Weather copyWith({
    double? temperature,
    String? description,
    String? iconCode,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    int? windDirection,
    int? visibility,
    int? pressure,
    DateTime? observationTime,
    String? source,
  }) {
    return Weather(
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      visibility: visibility ?? this.visibility,
      pressure: pressure ?? this.pressure,
      observationTime: observationTime ?? this.observationTime,
      source: source ?? this.source,
    );
  }
}

/// 天气服务类型枚举
enum WeatherServiceType {
  /// 和风天气
  qweather,
  
  /// OpenWeather
  openweather,
  
  /// 模拟数据（用于测试）
  mock,
}
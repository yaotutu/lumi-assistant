import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_warning.freezed.dart';
part 'weather_warning.g.dart';

/// 天气预警数据模型
/// 
/// 基于和风天气API的预警数据结构
/// https://dev.qweather.com/docs/api/warning/weather-warning/
@freezed
class WeatherWarning with _$WeatherWarning {
  const factory WeatherWarning({
    /// 预警ID，唯一标识
    required String id,
    
    /// 预警发布单位，如"北京市气象台"
    String? sender,
    
    /// 预警标题，如"北京市气象台发布暴雨橙色预警"
    required String title,
    
    /// 预警详细文字描述
    required String text,
    
    /// 预警级别
    /// - Minor: 蓝色
    /// - Moderate: 黄色  
    /// - Severe: 橙色
    /// - Extreme: 红色
    required String severity,
    
    /// 预警类型编码，如"11B06"
    required String type,
    
    /// 预警类型名称，如"暴雨"
    required String typeName,
    
    /// 预警开始时间，ISO8601格式
    required String startTime,
    
    /// 预警结束时间，ISO8601格式
    required String endTime,
    
    /// 状态：active-预警中，update-预警更新
    String? status,
    
    /// 预警等级：蓝色、黄色、橙色、红色
    String? level,
  }) = _WeatherWarning;

  factory WeatherWarning.fromJson(Map<String, dynamic> json) =>
      _$WeatherWarningFromJson(json);
}

/// 天气预警响应
@freezed
class WeatherWarningResponse with _$WeatherWarningResponse {
  const factory WeatherWarningResponse({
    /// API状态码
    required String code,
    
    /// 预警列表，可能为空
    @Default([]) List<WeatherWarning> warning,
    
    /// 更新时间
    String? updateTime,
    
    /// 响应时间
    String? fxLink,
  }) = _WeatherWarningResponse;

  factory WeatherWarningResponse.fromJson(Map<String, dynamic> json) =>
      _$WeatherWarningResponseFromJson(json);
}

/// 预警级别枚举
enum WarningSeverity {
  /// 蓝色预警
  minor('Minor', '蓝色', 1),
  
  /// 黄色预警
  moderate('Moderate', '黄色', 2),
  
  /// 橙色预警
  severe('Severe', '橙色', 3),
  
  /// 红色预警
  extreme('Extreme', '红色', 4);

  final String code;
  final String chinese;
  final int level;

  const WarningSeverity(this.code, this.chinese, this.level);
  
  /// 从API返回的severity字符串获取枚举
  static WarningSeverity fromString(String severity) {
    return WarningSeverity.values.firstWhere(
      (e) => e.code == severity,
      orElse: () => WarningSeverity.minor,
    );
  }
}
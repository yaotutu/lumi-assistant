import '../entities/weather.dart';

/// 天气数据仓库接口
/// 
/// 职责：定义获取天气数据的抽象接口
/// 设计原则：
/// - 与具体实现无关
/// - 支持多种天气服务切换
/// - 统一的错误处理
abstract class WeatherRepository {
  /// 获取当前天气
  /// 
  /// 参数：
  /// - [location] 位置信息，可以是城市名、城市ID或经纬度
  /// 
  /// 返回：当前天气信息
  /// 
  /// 抛出：
  /// - [WeatherException] 当获取天气失败时
  Future<Weather> getCurrentWeather(String location);
  
  /// 获取支持的天气服务类型
  WeatherServiceType get serviceType;
  
  /// 检查服务是否可用
  Future<bool> isServiceAvailable();
}

/// 天气异常类
class WeatherException implements Exception {
  /// 错误消息
  final String message;
  
  /// 错误代码（可选）
  final String? code;
  
  /// 原始错误（可选）
  final dynamic originalError;
  
  /// 构造函数
  const WeatherException(
    this.message, {
    this.code,
    this.originalError,
  });
  
  @override
  String toString() => 'WeatherException: $message${code != null ? ' (Code: $code)' : ''}';
}
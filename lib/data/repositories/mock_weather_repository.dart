import 'dart:math';

import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';

/// 模拟天气仓库实现
/// 
/// 职责：提供模拟天气数据，用于开发和测试
/// 特点：
/// - 不需要API密钥
/// - 返回随机但合理的天气数据
/// - 支持多种天气状况模拟
class MockWeatherRepository implements WeatherRepository {
  /// 随机数生成器
  final _random = Random();
  
  /// 模拟天气状况列表
  static const _weatherConditions = [
    {'code': '100', 'text': '晴', 'icon': 'wb_sunny'},
    {'code': '101', 'text': '多云', 'icon': 'cloud'},
    {'code': '104', 'text': '阴', 'icon': 'cloud_queue'},
    {'code': '305', 'text': '小雨', 'icon': 'grain'},
    {'code': '306', 'text': '中雨', 'icon': 'water_drop'},
    {'code': '401', 'text': '小雪', 'icon': 'ac_unit'},
  ];
  
  @override
  WeatherServiceType get serviceType => WeatherServiceType.mock;
  
  @override
  Future<Weather> getCurrentWeather(String location) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));
    
    // 随机选择一种天气状况
    final condition = _weatherConditions[_random.nextInt(_weatherConditions.length)];
    
    // 生成合理的温度范围
    double baseTemp;
    switch (condition['code']) {
      case '100': // 晴
      case '101': // 多云
        baseTemp = 15 + _random.nextDouble() * 20; // 15-35°C
        break;
      case '104': // 阴
        baseTemp = 10 + _random.nextDouble() * 15; // 10-25°C
        break;
      case '305': // 小雨
      case '306': // 中雨
        baseTemp = 8 + _random.nextDouble() * 12; // 8-20°C
        break;
      case '401': // 小雪
        baseTemp = -5 + _random.nextDouble() * 8; // -5-3°C
        break;
      default:
        baseTemp = 20;
    }
    
    // 生成其他天气数据
    final temperature = double.parse(baseTemp.toStringAsFixed(1));
    final feelsLike = temperature + (_random.nextDouble() * 4 - 2); // ±2度体感温度
    
    return Weather(
      temperature: temperature,
      description: condition['text'] as String,
      iconCode: condition['icon'] as String,
      feelsLike: double.parse(feelsLike.toStringAsFixed(1)),
      humidity: 40 + _random.nextInt(40), // 40-80%
      windSpeed: double.parse((_random.nextDouble() * 10).toStringAsFixed(1)), // 0-10 m/s
      windDirection: _random.nextInt(360), // 0-359度
      visibility: 5000 + _random.nextInt(15000), // 5-20km
      pressure: 990 + _random.nextInt(40), // 990-1030 hPa
      observationTime: DateTime.now(),
      source: 'mock',
    );
  }
  
  @override
  Future<bool> isServiceAvailable() async {
    // Mock服务始终可用
    return true;
  }
}
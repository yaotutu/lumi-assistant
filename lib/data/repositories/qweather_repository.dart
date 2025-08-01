import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../core/utils/app_logger.dart';
import '../models/weather_warning.dart';

/// 和风天气仓库实现
/// 
/// 职责：实现与和风天气API的交互
/// API文档：https://dev.qweather.com/docs/api/weather/weather-now/
class QWeatherRepository implements WeatherRepository {
  /// API基础URL
  static const String _baseUrl = 'https://devapi.qweather.com';
  
  /// API版本
  static const String _apiVersion = 'v7';
  
  /// API密钥
  final String apiKey;
  
  /// HTTP客户端
  final http.Client _httpClient;
  
  /// 构造函数
  QWeatherRepository({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();
  
  @override
  WeatherServiceType get serviceType => WeatherServiceType.qweather;
  
  @override
  Future<Weather> getCurrentWeather(String location) async {
    try {
      // 构建请求URL
      final url = Uri.parse('$_baseUrl/$_apiVersion/weather/now').replace(
        queryParameters: {
          'location': location,
          'key': apiKey,
          'lang': 'zh', // 中文
          'unit': 'm', // 公制单位
        },
      );
      
      AppLogger.getLogger('Weather').info('🌤️ 请求和风天气API: $url');
      
      // 发送请求
      final response = await _httpClient.get(url);
      
      // 检查响应状态
      if (response.statusCode != 200) {
        AppLogger.getLogger('Weather').warning('❌ 和风天气API响应错误: ${response.statusCode}');
        throw WeatherException(
          '获取天气失败',
          code: response.statusCode.toString(),
        );
      }
      
      // 解析响应
      final data = json.decode(response.body);
      
      // 检查API返回的状态码
      final code = data['code']?.toString();
      if (code != '200') {
        AppLogger.getLogger('Weather').warning('❌ 和风天气API业务错误: $code');
        throw WeatherException(
          _getErrorMessage(code),
          code: code,
        );
      }
      
      // 解析天气数据
      final now = data['now'];
      if (now == null) {
        throw const WeatherException('天气数据格式错误');
      }
      
      return _parseWeatherData(now);
    } catch (e) {
      AppLogger.getLogger('Weather').severe('❌ 获取天气失败: $e');
      if (e is WeatherException) rethrow;
      throw WeatherException(
        '网络请求失败',
        originalError: e,
      );
    }
  }
  
  @override
  Future<bool> isServiceAvailable() async {
    try {
      // 使用北京作为测试位置
      await getCurrentWeather('101010100');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 解析天气数据
  Weather _parseWeatherData(Map<String, dynamic> data) {
    return Weather(
      temperature: double.parse(data['temp'].toString()),
      description: data['text'] ?? '',
      iconCode: data['icon'] ?? '',
      feelsLike: data['feelsLike'] != null 
          ? double.parse(data['feelsLike'].toString()) 
          : null,
      humidity: data['humidity'] != null 
          ? int.parse(data['humidity'].toString()) 
          : null,
      windSpeed: data['windSpeed'] != null 
          ? double.parse(data['windSpeed'].toString()) 
          : null,
      windDirection: data['wind360'] != null 
          ? int.parse(data['wind360'].toString()) 
          : null,
      visibility: data['vis'] != null 
          ? int.parse(data['vis'].toString()) * 1000 // 转换为米
          : null,
      pressure: data['pressure'] != null 
          ? int.parse(data['pressure'].toString()) 
          : null,
      observationTime: DateTime.parse(data['obsTime']),
      source: 'qweather',
    );
  }
  
  /// 获取错误消息
  String _getErrorMessage(String? code) {
    switch (code) {
      case '400':
        return '请求错误，请检查参数（位置需使用城市ID或坐标）';
      case '401':
        return 'API密钥无效';
      case '402':
        return 'API次数超限';
      case '403':
        return '无权限访问';
      case '404':
        return '查询的数据或地区不存在';
      case '429':
        return '请求频率过快';
      case '500':
        return '服务器错误';
      default:
        return '未知错误';
    }
  }
  
  /// 获取天气预警信息
  /// 
  /// 参数：
  /// - [location] 位置（城市ID或经纬度坐标）
  /// 
  /// 返回：天气预警列表，无预警时返回空列表
  Future<List<WeatherWarning>> getWeatherWarnings(String location) async {
    try {
      // 构建请求URL
      final url = Uri.parse('$_baseUrl/$_apiVersion/warning/now').replace(
        queryParameters: {
          'location': location,
          'key': apiKey,
          'lang': 'zh', // 中文
        },
      );
      
      AppLogger.getLogger('Weather').info('⚠️ 请求天气预警API: $url');
      
      // 发送请求
      final response = await _httpClient.get(url);
      
      // 检查响应状态
      if (response.statusCode != 200) {
        AppLogger.getLogger('Weather').warning('❌ 天气预警API响应错误: ${response.statusCode}');
        throw WeatherException(
          '获取天气预警失败',
          code: response.statusCode.toString(),
        );
      }
      
      // 解析响应
      final data = json.decode(response.body);
      
      // 检查API返回的状态码
      final code = data['code']?.toString();
      if (code != '200') {
        AppLogger.getLogger('Weather').warning('❌ 天气预警API业务错误: $code');
        throw WeatherException(
          _getErrorMessage(code),
          code: code,
        );
      }
      
      // 解析预警数据
      final warningResponse = WeatherWarningResponse.fromJson(data);
      
      AppLogger.getLogger('Weather').info('✅ 获取到 ${warningResponse.warning.length} 条预警信息');
      
      return warningResponse.warning;
    } catch (e) {
      AppLogger.getLogger('Weather').severe('❌ 获取天气预警失败: $e');
      if (e is WeatherException) rethrow;
      throw WeatherException(
        '获取天气预警失败',
        originalError: e,
      );
    }
  }
  
  /// 释放资源
  void dispose() {
    _httpClient.close();
  }
}
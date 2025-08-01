import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/entities/weather.dart';
import '../../providers/weather_provider.dart';

/// 天气显示组件
/// 
/// 职责：显示天气信息
/// 特点：
/// - 独立的天气展示组件，可单独使用
/// - 支持紧凑和扩展两种显示模式
/// - 自动处理加载和错误状态
/// - 支持自定义样式
class WeatherDisplayWidget extends ConsumerWidget {
  /// 显示模式
  final WeatherDisplayMode mode;
  
  /// 文字颜色
  final Color? textColor;
  
  /// 文字阴影
  final List<Shadow>? textShadows;
  
  /// 自定义天气数据（如果提供，将不使用Provider）
  final Weather? customWeather;
  
  /// 构造函数
  const WeatherDisplayWidget({
    super.key,
    this.mode = WeatherDisplayMode.compact,
    this.textColor,
    this.textShadows,
    this.customWeather,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 如果提供了自定义天气数据，直接使用
    if (customWeather != null) {
      return _buildWeatherContent(customWeather!);
    }
    
    // 否则从Provider获取天气数据
    final weatherAsync = ref.watch(currentWeatherProvider);
    
    return weatherAsync.when(
      data: (weather) {
        if (weather == null) {
          return _buildEmptyState();
        }
        return _buildWeatherContent(weather);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(),
    );
  }
  
  /// 构建天气内容
  Widget _buildWeatherContent(Weather weather) {
    switch (mode) {
      case WeatherDisplayMode.compact:
        return _buildCompactView(weather);
      case WeatherDisplayMode.extended:
        return _buildExtendedView(weather);
    }
  }
  
  /// 构建紧凑视图（图标 + 温度）
  Widget _buildCompactView(Weather weather) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 天气图标
        _buildWeatherIcon(weather.iconCode),
        const SizedBox(width: 8),
        // 温度
        Text(
          '${weather.temperature.round()}°',
          style: TextStyle(
            color: textColor ?? Colors.white.withValues(alpha: 0.85),
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
            shadows: textShadows ?? _defaultShadows,
          ),
        ),
      ],
    );
  }
  
  /// 构建扩展视图（包含更多信息）
  Widget _buildExtendedView(Weather weather) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 第一行：图标 + 温度
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWeatherIcon(weather.iconCode, size: 32),
            const SizedBox(width: 12),
            Text(
              '${weather.temperature.round()}°',
              style: TextStyle(
                color: textColor ?? Colors.white.withValues(alpha: 0.9),
                fontSize: 36,
                fontWeight: FontWeight.w300,
                shadows: textShadows ?? _defaultShadows,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 第二行：天气描述
        Text(
          weather.description,
          style: TextStyle(
            color: (textColor ?? Colors.white).withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            shadows: textShadows ?? _defaultShadows,
          ),
        ),
        // 第三行：体感温度（如果有）
        if (weather.feelsLike != null) ...[
          const SizedBox(height: 4),
          Text(
            '体感 ${weather.feelsLike!.round()}°',
            style: TextStyle(
              color: (textColor ?? Colors.white).withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w300,
              shadows: textShadows ?? _defaultShadows,
            ),
          ),
        ],
      ],
    );
  }
  
  /// 构建天气图标
  Widget _buildWeatherIcon(String iconCode, {double size = 24}) {
    // 将天气代码映射到Material图标
    final icon = _mapWeatherIcon(iconCode);
    
    return Icon(
      icon,
      color: textColor ?? Colors.white.withValues(alpha: 0.85),
      size: size,
      shadows: textShadows ?? _defaultShadows,
    );
  }
  
  /// 映射天气图标
  IconData _mapWeatherIcon(String iconCode) {
    // 如果是Material图标名称，直接映射
    switch (iconCode) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'cloud':
        return Icons.cloud;
      case 'cloud_queue':
        return Icons.cloud_queue;
      case 'grain':
        return Icons.grain;
      case 'water_drop':
        return Icons.water_drop;
      case 'ac_unit':
        return Icons.ac_unit;
    }
    
    // 和风天气图标代码映射
    // 参考：https://dev.qweather.com/docs/start/icons/
    switch (iconCode) {
      case '100': // 晴
        return Icons.wb_sunny;
      case '101': // 多云
      case '102': // 少云
      case '103': // 晴间多云
        return Icons.cloud;
      case '104': // 阴
        return Icons.cloud_queue;
      case '300': // 阵雨
      case '301': // 强阵雨
      case '305': // 小雨
      case '306': // 中雨
      case '307': // 大雨
        return Icons.water_drop;
      case '400': // 小雪
      case '401': // 中雪
      case '402': // 大雪
        return Icons.ac_unit;
      case '500': // 薄雾
      case '501': // 雾
        return Icons.foggy;
      default:
        return Icons.wb_sunny; // 默认晴天图标
    }
  }
  
  /// 构建空状态
  Widget _buildEmptyState() {
    return Icon(
      Icons.cloud_off,
      color: (textColor ?? Colors.white).withValues(alpha: 0.5),
      size: 24,
    );
  }
  
  /// 构建加载状态
  Widget _buildLoadingState() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          (textColor ?? Colors.white).withValues(alpha: 0.5),
        ),
      ),
    );
  }
  
  /// 构建错误状态
  Widget _buildErrorState() {
    return Icon(
      Icons.error_outline,
      color: (textColor ?? Colors.white).withValues(alpha: 0.5),
      size: 24,
    );
  }
  
  /// 默认文字阴影
  List<Shadow> get _defaultShadows => [
    Shadow(
      offset: const Offset(0, 1),
      blurRadius: 4,
      color: Colors.black.withValues(alpha: 0.3),
    ),
  ];
}

/// 天气显示模式
enum WeatherDisplayMode {
  /// 紧凑模式（仅图标和温度）
  compact,
  
  /// 扩展模式（包含描述和体感温度）
  extended,
}
import 'package:flutter/material.dart';
import '../interfaces/background_mode_interface.dart';

/// 天气背景模式实现
/// 
/// 功能预留：
/// - 实时天气数据获取和显示
/// - 根据天气状况动态改变背景色彩和动画
/// - 天气预报显示
/// - 空气质量指数显示
/// - 天气相关的视觉效果（雨滴、雪花、阳光等）
class WeatherBackgroundMode extends WeatherBackgroundInterface {
  // 状态管理
  bool _isInitialized = false;
  bool _isPaused = false;
  WeatherData? _currentWeather;
  List<WeatherForecast> _forecasts = [];
  
  // 天气配置
  @override
  String get currentCity => '北京';
  
  @override
  int get updateIntervalMinutes => 30;
  
  @override
  bool get enableWeatherAnimation => true;
  
  @override
  bool get showDetailedInfo => true;
  
  // 基础接口实现
  @override
  String get modeName => '天气模式';
  
  @override
  IconData get modeIcon => Icons.wb_sunny;
  
  @override
  String get modeDescription => '显示天气信息、动画效果、预报等';
  
  @override
  bool get supportsAutoUpdate => true;

  @override
  Widget buildContent(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingContent();
    }
    
    if (_isPaused) {
      return _buildPausedContent();
    }
    
    return _buildWeatherContent(context);
  }
  
  /// 构建加载中的内容
  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.white70,
          ),
          SizedBox(height: 16),
          Text(
            '天气数据获取中...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建暂停状态的内容
  Widget _buildPausedContent() {
    return const Center(
      child: Text(
        '⏸️ 天气模式已暂停',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
    );
  }
  
  /// 构建天气内容
  Widget _buildWeatherContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _currentWeather != null 
              ? getWeatherColors(_currentWeather!.condition)
              : _getDefaultWeatherColors(),
        ),
      ),
      child: Stack(
        children: [
          // 天气动画层
          if (enableWeatherAnimation && _currentWeather != null)
            buildWeatherAnimation(_currentWeather!.condition),
          
          // 主要天气信息显示
          _buildMainWeatherInfo(),
          
          // 详细信息面板
          if (showDetailedInfo) _buildDetailedWeatherInfo(),
          
          // 天气预报区域
          _buildWeatherForecast(),
        ],
      ),
    );
  }
  
  /// 构建主要天气信息
  Widget _buildMainWeatherInfo() {
    if (_currentWeather == null) {
      return const Center(
        child: Text(
          '🌤️ 天气数据加载中...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 天气图标
          _buildWeatherIcon(_currentWeather!.condition),
          
          const SizedBox(height: 20),
          
          // 温度显示
          Text(
            '${_currentWeather!.temperature.round()}°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w100,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 天气描述
          Text(
            _currentWeather!.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // 城市名称
          Text(
            _currentWeather!.city,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建详细天气信息
  Widget _buildDetailedWeatherInfo() {
    if (_currentWeather == null) return const SizedBox.shrink();
    
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDetailItem(
              icon: Icons.water_drop,
              label: '湿度',
              value: '${_currentWeather!.humidity.round()}%',
            ),
            _buildDetailItem(
              icon: Icons.air,
              label: '风速',
              value: '${_currentWeather!.windSpeed.round()} km/h',
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建详细信息项
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  /// 构建天气预报
  Widget _buildWeatherForecast() {
    if (_forecasts.isEmpty) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '未来天气',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _forecasts.take(3).map((forecast) {
                return _buildForecastItem(forecast);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建预报项
  Widget _buildForecastItem(WeatherForecast forecast) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatForecastDate(forecast.date),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        _buildSmallWeatherIcon(forecast.condition),
        const SizedBox(height: 8),
        Text(
          '${forecast.highTemp.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${forecast.lowTemp.round()}°',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  /// 构建天气图标
  Widget _buildWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor;
    
    switch (condition.toLowerCase()) {
      case 'sunny':
        iconData = Icons.wb_sunny;
        iconColor = Colors.yellow;
        break;
      case 'cloudy':
        iconData = Icons.cloud;
        iconColor = Colors.white;
        break;
      case 'rainy':
        iconData = Icons.grain;
        iconColor = Colors.lightBlue;
        break;
      case 'snowy':
        iconData = Icons.ac_unit;
        iconColor = Colors.white;
        break;
      default:
        iconData = Icons.wb_cloudy;
        iconColor = Colors.white;
    }
    
    return Icon(
      iconData,
      size: 80,
      color: iconColor.withValues(alpha: 0.9),
    );
  }
  
  /// 构建小型天气图标
  Widget _buildSmallWeatherIcon(String condition) {
    return Icon(
      _getWeatherIconData(condition),
      size: 24,
      color: Colors.white.withValues(alpha: 0.8),
    );
  }
  
  /// 获取天气图标数据
  IconData _getWeatherIconData(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny': return Icons.wb_sunny;
      case 'cloudy': return Icons.cloud;
      case 'rainy': return Icons.grain;
      case 'snowy': return Icons.ac_unit;
      default: return Icons.wb_cloudy;
    }
  }
  
  /// 格式化预报日期
  String _formatForecastDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    if (date.day == now.day) {
      return '今天';
    } else if (date.day == tomorrow.day) {
      return '明天';
    } else {
      return '${date.month}/${date.day}';
    }
  }
  
  /// 获取默认天气颜色
  List<Color> _getDefaultWeatherColors() {
    return const [
      Color(0xFF87CEEB), // 天空蓝
      Color(0xFF4682B4), // 钢蓝色
      Color(0xFF1E90FF), // 道奇蓝
    ];
  }

  // ============ 接口实现 ============
  
  @override
  Future<void> initialize() async {
    // TODO: 初始化天气系统
    await _loadWeatherData();
    _isInitialized = true;
  }

  @override
  void dispose() {
    // TODO: 清理天气相关资源
    _isInitialized = false;
    _currentWeather = null;
    _forecasts.clear();
  }

  @override
  void pause() {
    _isPaused = true;
  }

  @override
  void resume() {
    _isPaused = false;
  }

  @override
  void updateConfig(Map<String, dynamic> config) {
    // TODO: 更新天气配置
  }

  // ============ 天气接口专有实现 ============
  
  @override
  Future<WeatherData?> getCurrentWeather() async {
    // TODO: 实际的天气API调用
    // 现在返回模拟数据
    await Future.delayed(const Duration(seconds: 1));
    
    return WeatherData(
      city: '北京',
      condition: 'sunny',
      temperature: 22.5,
      humidity: 65.0,
      windSpeed: 12.0,
      description: '晴朗',
      updateTime: DateTime.now(),
    );
  }

  @override
  Future<List<WeatherForecast>> getWeatherForecast() async {
    // TODO: 实际的天气预报API调用
    // 现在返回模拟数据
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    return [
      WeatherForecast(
        date: now.add(const Duration(days: 1)),
        condition: 'cloudy',
        highTemp: 25.0,
        lowTemp: 15.0,
        description: '多云',
      ),
      WeatherForecast(
        date: now.add(const Duration(days: 2)),
        condition: 'rainy',
        highTemp: 20.0,
        lowTemp: 12.0,
        description: '小雨',
      ),
      WeatherForecast(
        date: now.add(const Duration(days: 3)),
        condition: 'sunny',
        highTemp: 28.0,
        lowTemp: 18.0,
        description: '晴朗',
      ),
    ];
  }

  @override
  List<Color> getWeatherColors(String weatherCondition) {
    switch (weatherCondition.toLowerCase()) {
      case 'sunny':
        return const [
          Color(0xFFFFD700), // 金色
          Color(0xFFFF8C00), // 深橙色
          Color(0xFFFF6347), // 番茄色
        ];
      case 'cloudy':
        return const [
          Color(0xFF708090), // 石板灰
          Color(0xFF2F4F4F), // 深石板灰
          Color(0xFF696969), // 暗灰色
        ];
      case 'rainy':
        return const [
          Color(0xFF4682B4), // 钢蓝色
          Color(0xFF5F9EA0), // 军蓝色
          Color(0xFF483D8B), // 深石板蓝
        ];
      case 'snowy':
        return const [
          Color(0xFFE6E6FA), // 薰衣草色
          Color(0xFFB0C4DE), // 浅钢蓝
          Color(0xFF87CEEB), // 天空蓝
        ];
      default:
        return _getDefaultWeatherColors();
    }
  }

  @override
  Widget buildWeatherAnimation(String weatherCondition) {
    // TODO: 实现天气动画效果
    // - 晴天：阳光粒子效果
    // - 雨天：雨滴下落动画
    // - 雪天：雪花飘落动画
    // - 多云：云朵移动动画
    
    return Center(
      child: Text(
        '🌈 ${weatherCondition.toUpperCase()} 动画效果\n（待实现）',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// 加载天气数据
  Future<void> _loadWeatherData() async {
    _currentWeather = await getCurrentWeather();
    _forecasts = await getWeatherForecast();
  }
}
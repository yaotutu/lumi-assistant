import 'package:flutter/material.dart';

/// 天气背景组件
/// 
/// 职责：
/// - 显示当前天气信息和温度
/// - 展示未来几天的天气预报
/// - 提供美观的天气图标和动画
/// 
/// 特点：
/// - 实时天气数据显示
/// - 天气状态的动态背景
/// - 温度和湿度等详细信息
/// 
/// TODO: 未来功能扩展
/// - 集成天气API获取实时数据
/// - 支持多城市天气切换
/// - 添加天气预警和提醒
/// - 实现天气动画效果
class WeatherBackground extends StatefulWidget {
  /// 构造函数
  const WeatherBackground({super.key});

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  // 动画控制器，用于云朵飘动等动画效果
  late AnimationController _animationController;
  late Animation<double> _cloudAnimation;

  // 模拟天气数据（实际应用中应从天气API获取）
  final Map<String, dynamic> _mockWeatherData = {
    'temperature': 22,
    'condition': 'sunny', // sunny, cloudy, rainy, snowy
    'humidity': 65,
    'windSpeed': 12,
    'location': '北京',
    'description': '晴朗',
    'forecast': [
      {'day': '今天', 'high': 25, 'low': 15, 'condition': 'sunny'},
      {'day': '明天', 'high': 23, 'low': 12, 'condition': 'cloudy'},
      {'day': '后天', 'high': 20, 'low': 10, 'condition': 'rainy'},
    ],
  };

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    // 云朵飘动动画
    _cloudAnimation = Tween<double>(
      begin: -100,
      end: 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 根据天气状况选择背景渐变色
      decoration: BoxDecoration(
        gradient: _getWeatherGradient(_mockWeatherData['condition']),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 天气动画背景层
          _buildWeatherAnimations(),
          
          // 遮罩层，确保文字清晰可见
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
          
          // 主要内容区域
          _buildMainContent(),
        ],
      ),
    );
  }
  
  /// 根据天气状况获取对应的背景渐变
  LinearGradient _getWeatherGradient(String condition) {
    switch (condition) {
      case 'sunny':
        // 晴天 - 蓝色到橙色渐变
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // 天空蓝
            Color(0xFF4682B4), // 钢蓝色
            Color(0xFFFFB347), // 桃色
          ],
          stops: [0.0, 0.6, 1.0],
        );
      case 'cloudy':
        // 多云 - 灰蓝色渐变
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF708090), // 石板灰
            Color(0xFF2F4F4F), // 深石板灰
            Color(0xFF696969), // 暗灰色
          ],
        );
      case 'rainy':
        // 雨天 - 深蓝灰色渐变
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2F4F4F), // 深石板灰
            Color(0xFF191970), // 午夜蓝
            Color(0xFF483D8B), // 深石板蓝
          ],
        );
      case 'snowy':
        // 雪天 - 白蓝色渐变
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE6E6FA), // 薰衣草色
            Color(0xFFB0C4DE), // 浅钢蓝
            Color(0xFF4682B4), // 钢蓝色
          ],
        );
      default:
        // 默认渐变
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB),
            Color(0xFF4682B4),
          ],
        );
    }
  }
  
  /// 构建天气动画背景
  Widget _buildWeatherAnimations() {
    return AnimatedBuilder(
      animation: _cloudAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 云朵动画（仅在多云天气显示）
            if (_mockWeatherData['condition'] == 'cloudy')
              Positioned(
                top: 100,
                left: _cloudAnimation.value,
                child: Icon(
                  Icons.cloud,
                  size: 60,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            
            // 第二朵云
            if (_mockWeatherData['condition'] == 'cloudy')
              Positioned(
                top: 150,
                left: _cloudAnimation.value + 200,
                child: Icon(
                  Icons.cloud,
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            
            // 太阳图标（晴天时显示）
            if (_mockWeatherData['condition'] == 'sunny')
              Positioned(
                top: 80,
                right: 50,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.wb_sunny,
                    size: 60,
                    color: Colors.yellow.withValues(alpha: 0.8),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  /// 构建主要内容区域
  Widget _buildMainContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部天气摘要
            _buildWeatherSummary(),
            
            const Spacer(),
            
            // 中部主要天气信息
            _buildMainWeatherInfo(),
            
            const Spacer(),
            
            // 底部天气预报
            _buildWeatherForecast(),
          ],
        ),
      ),
    );
  }
  
  /// 构建天气摘要
  Widget _buildWeatherSummary() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: Colors.white.withValues(alpha: 0.7),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          _mockWeatherData['location'],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          '实时天气',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
  
  /// 构建主要天气信息
  Widget _buildMainWeatherInfo() {
    return Center(
      child: Column(
        children: [
          // 主要天气图标
          _buildWeatherIcon(_mockWeatherData['condition']),
          
          const SizedBox(height: 24),
          
          // 温度显示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_mockWeatherData['temperature']}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 64,
                  fontWeight: FontWeight.w100,
                  height: 0.9,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '°C',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 天气描述
          Text(
            _mockWeatherData['description'],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 详细信息行
          _buildWeatherDetails(),
        ],
      ),
    );
  }
  
  /// 根据天气状况获取对应图标
  Widget _buildWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor;
    
    switch (condition) {
      case 'sunny':
        iconData = Icons.wb_sunny;
        iconColor = Colors.yellow.withValues(alpha: 0.9);
        break;
      case 'cloudy':
        iconData = Icons.cloud;
        iconColor = Colors.white.withValues(alpha: 0.8);
        break;
      case 'rainy':
        iconData = Icons.grain;
        iconColor = Colors.lightBlue.withValues(alpha: 0.8);
        break;
      case 'snowy':
        iconData = Icons.ac_unit;
        iconColor = Colors.white.withValues(alpha: 0.9);
        break;
      default:
        iconData = Icons.wb_cloudy;
        iconColor = Colors.white.withValues(alpha: 0.8);
    }
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Icon(
        iconData,
        size: 50,
        color: iconColor,
      ),
    );
  }
  
  /// 构建天气详细信息
  Widget _buildWeatherDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDetailItem(
          icon: Icons.water_drop,
          label: '湿度',
          value: '${_mockWeatherData['humidity']}%',
        ),
        _buildDetailItem(
          icon: Icons.air,
          label: '风速',
          value: '${_mockWeatherData['windSpeed']} km/h',
        ),
      ],
    );
  }
  
  /// 构建详细信息项
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.6),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
  
  /// 构建天气预报
  Widget _buildWeatherForecast() {
    return Container(
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _mockWeatherData['forecast']
                .map<Widget>((forecast) => _buildForecastItem(forecast))
                .toList(),
          ),
        ],
      ),
    );
  }
  
  /// 构建预报项
  Widget _buildForecastItem(Map<String, dynamic> forecast) {
    return Column(
      children: [
        Text(
          forecast['day'],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        _buildSmallWeatherIcon(forecast['condition']),
        const SizedBox(height: 8),
        Text(
          '${forecast['high']}°',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${forecast['low']}°',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
  
  /// 构建小型天气图标
  Widget _buildSmallWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor;
    
    switch (condition) {
      case 'sunny':
        iconData = Icons.wb_sunny;
        iconColor = Colors.yellow.withValues(alpha: 0.8);
        break;
      case 'cloudy':
        iconData = Icons.cloud;
        iconColor = Colors.white.withValues(alpha: 0.7);
        break;
      case 'rainy':
        iconData = Icons.grain;
        iconColor = Colors.lightBlue.withValues(alpha: 0.7);
        break;
      case 'snowy':
        iconData = Icons.ac_unit;
        iconColor = Colors.white.withValues(alpha: 0.8);
        break;
      default:
        iconData = Icons.wb_cloudy;
        iconColor = Colors.white.withValues(alpha: 0.7);
    }
    
    return Icon(
      iconData,
      size: 24,
      color: iconColor,
    );
  }
}
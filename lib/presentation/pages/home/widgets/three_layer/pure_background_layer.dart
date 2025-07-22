import 'dart:math';
import 'package:flutter/material.dart';

/// 纯背景层组件
/// 
/// 职责：
/// - 只负责视觉展示，完全不可点击
/// - 提供美观的背景效果（渐变、图片、装饰动画等）
/// - 不包含任何交互元素或功能组件
/// 
/// 设计原则：
/// - 纯视觉展示，无用户交互
/// - 所有点击事件都被AbsorbPointer阻止
/// - 专注于美观的视觉效果
/// - 支持多种背景模式
class PureBackgroundLayer extends StatefulWidget {
  /// 背景模式
  final BackgroundMode mode;
  
  /// 是否启用背景动画
  final bool enableAnimations;
  
  /// 构造函数
  const PureBackgroundLayer({
    super.key,
    this.mode = BackgroundMode.gradient,
    this.enableAnimations = true,
  });

  @override
  State<PureBackgroundLayer> createState() => _PureBackgroundLayerState();
}

class _PureBackgroundLayerState extends State<PureBackgroundLayer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // 渐变动画
    _fadeAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 启动动画
    if (widget.enableAnimations) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _getBackgroundDecoration(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 主要背景内容
          _buildMainBackground(),
          
          // 装饰层
          if (widget.enableAnimations) _buildDecorativeLayer(),
          
          // 渐变遮罩层
          _buildGradientOverlay(),
        ],
      ),
    );
  }
  
  /// 获取背景装饰
  BoxDecoration _getBackgroundDecoration() {
    switch (widget.mode) {
      case BackgroundMode.gradient:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E), // 深蓝色
              Color(0xFF3949AB), // 中蓝色  
              Color(0xFF5C6BC0), // 浅蓝色
              Color(0xFF7E57C2), // 淡紫色
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        );
      
      case BackgroundMode.darkGradient:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF263238), // 深灰蓝
              Color(0xFF37474F), // 中灰蓝
              Color(0xFF455A64), // 浅灰蓝
            ],
          ),
        );
      
      case BackgroundMode.warmGradient:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFBF360C), // 深橙色
              Color(0xFFE64A19), // 中橙色
              Color(0xFFFF5722), // 亮橙色
              Color(0xFFFF8A65), // 浅橙色
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        );
      
      case BackgroundMode.coolGradient:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF006064), // 深青色
              Color(0xFF00838F), // 中青色
              Color(0xFF00ACC1), // 浅青色
            ],
          ),
        );
      
      case BackgroundMode.nightGradient:
        return const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF1A237E), // 深蓝色
              Color(0xFF000051), // 深紫蓝
              Color(0xFF000000), // 黑色
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        );
    }
  }
  
  /// 构建主要背景内容
  Widget _buildMainBackground() {
    return Container(
      // 纯背景，无任何内容
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.1),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.2),
          ],
        ),
      ),
    );
  }
  
  /// 构建装饰层
  Widget _buildDecorativeLayer() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value * 0.3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// 构建渐变遮罩层
  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.1),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

/// 时间展示背景组件
/// 
/// 专门用于显示时间的纯背景组件，不可交互
class TimeDisplayBackground extends StatelessWidget {
  /// 时间显示透明度
  final double opacity;
  
  /// 构造函数
  const TimeDisplayBackground({
    super.key,
    this.opacity = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        
        return Positioned(
          bottom: 160,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // 大字体时间显示
              Text(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: opacity),
                  fontSize: 56,
                  fontWeight: FontWeight.w100,
                  letterSpacing: 4.0,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 日期显示
              Text(
                _formatDate(now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: opacity * 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 格式化日期
  String _formatDate(DateTime time) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const months = [
      '1月', '2月', '3月', '4月', '5月', '6月',
      '7月', '8月', '9月', '10月', '11月', '12月'
    ];
    return '${time.year}年${months[time.month - 1]}${time.day}日 ${weekdays[time.weekday % 7]}';
  }
}

/// 装饰元素背景组件
/// 
/// 提供各种装饰性的背景元素，纯视觉效果
class DecorativeBackground extends StatefulWidget {
  /// 装饰类型
  final DecorationType type;
  
  /// 构造函数
  const DecorativeBackground({
    super.key,
    this.type = DecorationType.particles,
  });

  @override
  State<DecorativeBackground> createState() => _DecorativeBackgroundState();
}

class _DecorativeBackgroundState extends State<DecorativeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case DecorationType.particles:
        return _buildParticles();
      case DecorationType.waves:
        return _buildWaves();
      case DecorationType.stars:
        return _buildStars();
    }
  }
  
  /// 构建粒子效果
  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
  
  /// 构建波浪效果
  Widget _buildWaves() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WavesPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
  
  /// 构建星星效果
  Widget _buildStars() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarsPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

/// 背景模式枚举
enum BackgroundMode {
  /// 标准渐变
  gradient,
  /// 深色渐变
  darkGradient,
  /// 暖色调渐变
  warmGradient,
  /// 冷色调渐变
  coolGradient,
  /// 夜间渐变
  nightGradient,
}

/// 装饰类型枚举
enum DecorationType {
  /// 粒子效果
  particles,
  /// 波浪效果
  waves,
  /// 星星效果
  stars,
}

/// 粒子绘制器
class ParticlesPainter extends CustomPainter {
  final double progress;
  
  ParticlesPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    
    // 绘制简单的粒子效果
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20 + progress)) % size.width;
      final y = size.height * (i % 3) / 3;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 波浪绘制器
class WavesPainter extends CustomPainter {
  final double progress;
  
  WavesPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 4;
    
    path.moveTo(0, size.height / 2);
    
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 + 
          waveHeight * sin((x / waveLength) * 2 * pi + progress * 2 * pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 星星绘制器
class StarsPainter extends CustomPainter {
  final double progress;
  
  StarsPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    
    // 绘制简单的星星效果
    for (int i = 0; i < 15; i++) {
      final x = size.width * (i % 5) / 5;
      final y = size.height * (i % 3) / 3;
      final opacity = (sin(progress * 2 * pi + i) + 1) / 2;
      
      paint.color = Colors.white.withValues(alpha: opacity * 0.2);
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 动态星空背景组件
/// 
/// 职责：
/// - 渲染动态移动的星星粒子
/// - 提供闪烁和移动动画效果
/// - 创建深邃的星空视觉体验
/// 
/// 特性：
/// - 多层星星：近景大星星、远景小星星
/// - 动态效果：闪烁、缓慢移动、透明度变化
/// - 性能优化：合理的星星数量和动画频率
/// - 视觉美观：深蓝渐变背景配合明亮星星
class AnimatedStarfieldBackground extends HookWidget {
  /// 构造函数
  const AnimatedStarfieldBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用动画控制器管理星星动画
    final animationController = useAnimationController(
      duration: const Duration(seconds: 20), // 完整循环20秒
    );
    
    // 启动循环动画
    useEffect(() {
      animationController.repeat();
      return null;
    }, []);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // 深蓝色渐变背景，模拟夜空
          _buildGradientBackground(),
          
          // 星星层：使用CustomPaint绘制动态星星
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _StarfieldPainter(
                  animationValue: animationController.value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// 构建明亮的星空渐变背景
  /// 
  /// 创建从深蓝到浅蓝的明亮夜空渐变效果
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [
            Color(0xFF1E3A8A), // 明亮深蓝
            Color(0xFF3B82F6), // 中等蓝（更明亮）
            Color(0xFF60A5FA), // 较亮蓝
            Color(0xFF1D4ED8), // 明亮蓝边缘
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

/// 星空绘制器
/// 
/// 负责绘制动态星星粒子系统，包括：
/// - 不同大小和亮度的星星
/// - 闪烁动画效果
/// - 缓慢的位置移动
/// - 透明度变化
class _StarfieldPainter extends CustomPainter {
  /// 动画进度值（0.0 到 1.0）
  final double animationValue;
  
  /// 星星数据列表，使用静态变量避免重复生成
  static List<_StarData>? _stars;
  
  /// 画布尺寸缓存，避免重复计算
  static Size? _cachedSize;
  
  /// 构造函数
  _StarfieldPainter({required this.animationValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    // 检查尺寸是否改变，如果改变则重新生成星星
    if (_cachedSize != size) {
      _cachedSize = size;
      _stars = _generateStars(size);
    }
    
    // 初始化星星数据（只在第一次调用时生成）
    _stars ??= _generateStars(size);
    
    // 绘制所有星星
    for (final star in _stars!) {
      _drawStar(canvas, size, star);
    }
  }
  
  /// 生成随机分布的星星数据
  /// 
  /// 参数：
  /// - [size] 画布尺寸
  /// 
  /// 返回：星星数据列表
  List<_StarData> _generateStars(Size size) {
    final random = math.Random(42); // 使用固定种子保证一致性
    final stars = <_StarData>[];
    
    // 生成120颗星星，平衡视觉效果和性能
    for (int i = 0; i < 120; i++) {
      stars.add(_StarData(
        // 随机位置
        x: random.nextDouble() * size.width,
        y: random.nextDouble() * size.height,
        
        // 随机大小：增大所有星星尺寸
        size: random.nextDouble() < 0.2 
            ? 3.0 + random.nextDouble() * 3.0  // 20%大星星(3-6像素)
            : 1.5 + random.nextDouble() * 2.0, // 80%中等星星(1.5-3.5像素)
        
        // 随机闪烁速度
        twinkleSpeed: 0.5 + random.nextDouble() * 2.0,
        
        // 随机闪烁相位偏移
        twinkleOffset: random.nextDouble() * 2 * math.pi,
        
        // 随机移动速度（非常缓慢）
        moveSpeedX: (random.nextDouble() - 0.5) * 0.3,
        moveSpeedY: (random.nextDouble() - 0.5) * 0.2,
        
        // 基础透明度（提高亮度）
        baseOpacity: 0.8 + random.nextDouble() * 0.2,
        
        // 星星颜色类型（增加颜色变化）
        colorType: random.nextInt(10), // 0-9，大部分白色，少量彩色
      ));
    }
    
    return stars;
  }
  
  /// 绘制单颗星星
  /// 
  /// 参数：
  /// - [canvas] 画布
  /// - [size] 画布尺寸
  /// - [star] 星星数据
  void _drawStar(Canvas canvas, Size size, _StarData star) {
    // 计算当前位置（包含缓慢移动）
    final currentX = (star.x + star.moveSpeedX * animationValue * size.width) % size.width;
    final currentY = (star.y + star.moveSpeedY * animationValue * size.height) % size.height;
    
    // 计算闪烁透明度（增强亮度变化）
    final twinkleFactor = math.sin(
      animationValue * 2 * math.pi * star.twinkleSpeed + star.twinkleOffset
    );
    final currentOpacity = star.baseOpacity + twinkleFactor * 0.2;
    
    // 根据颜色类型选择星星颜色
    Color starColor;
    switch (star.colorType) {
      case 0:
      case 1:
        // 20% 暖白色星星（更亮）
        starColor = const Color(0xFFFFF8DC);
        break;
      case 2:
        // 10% 浅蓝色星星
        starColor = const Color(0xFFE6F3FF);
        break;
      case 3:
        // 10% 浅黄色星星
        starColor = const Color(0xFFFFFACD);
        break;
      default:
        // 60% 纯白色星星
        starColor = Colors.white;
    }
    
    // 创建星星画笔
    final paint = Paint()
      ..color = starColor.withValues(alpha: currentOpacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    
    // 绘制星星
    if (star.size > 3.0) {
      // 大星星：绘制十字形状，更像真实星星
      _drawCrossStar(canvas, currentX, currentY, star.size, paint);
    } else {
      // 中小星星：简单圆点
      canvas.drawCircle(
        Offset(currentX, currentY),
        star.size / 2,
        paint,
      );
    }
  }
  
  /// 绘制十字形星星（用于大星星）
  /// 
  /// 参数：
  /// - [canvas] 画布
  /// - [x] X坐标
  /// - [y] Y坐标
  /// - [size] 星星大小
  /// - [paint] 画笔
  void _drawCrossStar(Canvas canvas, double x, double y, double size, Paint paint) {
    final radius = size / 2;
    
    // 绘制中心圆点
    canvas.drawCircle(Offset(x, y), radius * 0.6, paint);
    
    // 绘制十字光芒
    final dimmerPaint = Paint()
      ..color = paint.color.withValues(alpha: paint.color.a * 0.7)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    
    // 水平光芒
    canvas.drawLine(
      Offset(x - radius * 1.5, y),
      Offset(x + radius * 1.5, y),
      dimmerPaint,
    );
    
    // 垂直光芒
    canvas.drawLine(
      Offset(x, y - radius * 1.5),
      Offset(x, y + radius * 1.5),
      dimmerPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    // 当动画值改变时重新绘制
    return oldDelegate.animationValue != animationValue;
  }
}

/// 星星数据模型
/// 
/// 存储单颗星星的所有属性和动画参数
class _StarData {
  /// 初始X坐标
  final double x;
  
  /// 初始Y坐标
  final double y;
  
  /// 星星大小
  final double size;
  
  /// 闪烁速度
  final double twinkleSpeed;
  
  /// 闪烁相位偏移
  final double twinkleOffset;
  
  /// X方向移动速度
  final double moveSpeedX;
  
  /// Y方向移动速度
  final double moveSpeedY;
  
  /// 基础透明度
  final double baseOpacity;
  
  /// 星星颜色类型
  final int colorType;
  
  /// 构造函数
  _StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.moveSpeedX,
    required this.moveSpeedY,
    required this.baseOpacity,
    required this.colorType,
  });
}
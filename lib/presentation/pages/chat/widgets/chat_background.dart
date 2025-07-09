import 'package:flutter/material.dart';

/// 聊天界面背景组件
class ChatBackground extends StatelessWidget {
  const ChatBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // 主背景渐变
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A237E), // 深蓝
            Color(0xFF283593), // 中蓝
            Color(0xFF3949AB), // 浅蓝
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          // 叠加渐变遮罩，创建更柔和的聊天背景
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.05),
              Colors.black.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: CustomPaint(
          painter: ChatBackgroundPainter(),
        ),
      ),
    );
  }
}

/// 聊天背景自定义绘制器
class ChatBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制微妙的几何图案作为背景装饰
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // 绘制一些圆形装饰
    final random = [0.2, 0.7, 0.3, 0.8, 0.5]; // 固定的随机值
    for (int i = 0; i < random.length; i++) {
      final double x = size.width * random[i];
      final double y = size.height * random[(i + 1) % random.length];
      final double radius = size.width * 0.15 * random[(i + 2) % random.length];
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Colors.white.withValues(alpha: 0.02),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
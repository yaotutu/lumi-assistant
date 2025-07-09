import 'package:flutter/material.dart';

/// 背景层组件 - 负责显示背景图片和渐变效果
class BackgroundLayer extends StatelessWidget {
  const BackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // 使用复合背景：图片 + 渐变遮罩
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A237E), // 深蓝色
            Color(0xFF3949AB), // 中蓝色  
            Color(0xFF5C6BC0), // 浅蓝色
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          // 添加渐变遮罩以确保文字可读性
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}
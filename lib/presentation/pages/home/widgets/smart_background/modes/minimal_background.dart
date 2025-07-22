import 'package:flutter/material.dart';

/// 极简背景组件
/// 
/// 职责：
/// - 提供纯净的渐变背景
/// - 最小化视觉干扰
/// - 适合专注工作时使用
/// 
/// 特点：
/// - 优雅的渐变色彩
/// - 无任何文字或时间显示
/// - 完全的视觉简洁性
class MinimalBackground extends StatelessWidget {
  /// 构造函数
  const MinimalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 极简的渐变背景
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A237E), // 深蓝色
            Color(0xFF3949AB), // 中蓝色  
            Color(0xFF5C6BC0), // 浅蓝色
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        // 添加轻微的渐变遮罩，增加层次感
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.1),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.1),
            ],
          ),
        ),
        // 完全空白的内容区域
        child: const SizedBox.expand(),
      ),
    );
  }
}
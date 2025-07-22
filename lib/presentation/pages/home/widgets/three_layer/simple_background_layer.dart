import 'package:flutter/material.dart';

/// 简化的纯背景层组件
/// 
/// 职责：
/// - 只负责视觉展示，完全不可点击
/// - 提供简洁的背景效果和时间显示
/// 
/// 设计原则：
/// - 极简设计，只保留必要的背景元素
/// - 纯视觉展示，无用户交互
/// - 专注于美观的背景效果
class SimpleBackgroundLayer extends StatelessWidget {
  /// 构造函数
  const SimpleBackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 主背景渐变
        Container(
          decoration: const BoxDecoration(
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
          ),
        ),
        
        // 渐变遮罩层
        Container(
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
        ),
        
        // 时间显示组件
        const SimpleTimeDisplay(),
      ],
    );
  }
}

/// 简化的时间显示组件
/// 
/// 专门用于显示时间的纯背景组件，不可交互
class SimpleTimeDisplay extends StatelessWidget {
  /// 构造函数
  const SimpleTimeDisplay({super.key});

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
                  color: Colors.white.withValues(alpha: 0.9),
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
                  color: Colors.white.withValues(alpha: 0.7),
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
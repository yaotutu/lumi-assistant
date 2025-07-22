import 'package:flutter/material.dart';

/// 日历背景组件
/// 
/// 职责：
/// - 显示当前月份的日历视图
/// - 展示重要的日程安排和节假日
/// - 提供日期导航和事件管理
/// 
/// TODO: 未来功能扩展
/// - 集成系统日历应用
/// - 显示事件和提醒
/// - 支持农历显示
/// - 节假日标记
/// - 日程快速添加
class CalendarBackground extends StatelessWidget {
  /// 构造函数
  const CalendarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A148C), // 深紫色
            Color(0xFF7B1FA2), // 中紫色
            Color(0xFFAB47BC), // 浅紫色
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                size: 64,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 24),
              Text(
                '智能日历',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '日程管理中心',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '功能开发中...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
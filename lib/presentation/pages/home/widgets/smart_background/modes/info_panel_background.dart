import 'package:flutter/material.dart';

/// 信息面板背景组件
/// 
/// 职责：
/// - 显示系统信息和设备状态
/// - 展示网络连接、电池、存储等信息
/// - 提供实时的设备监控界面
/// 
/// TODO: 未来功能扩展
/// - 集成设备信息API
/// - 显示网络状态和速度
/// - 电池电量和充电状态
/// - 存储使用情况
/// - CPU和内存使用率
class InfoPanelBackground extends StatelessWidget {
  /// 构造函数
  const InfoPanelBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF263238), // 深灰蓝
            Color(0xFF455A64), // 中灰蓝
            Color(0xFF607D8B), // 浅灰蓝
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
                Icons.info_outline,
                size: 64,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 24),
              Text(
                '信息面板',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '设备状态监控',
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
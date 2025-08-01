import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../widgets/clock/clock_display_widget.dart';
import '../../../../widgets/weather/weather_display_widget.dart';

/// 天气时钟组件
/// 
/// 职责：组合显示时间、日期和天气信息
/// 使用场景：作为操作层的核心信息展示组件
/// 特点：
/// - 组合独立的时钟和天气组件
/// - 统一的样式配置
/// - 灵活的布局组合
class WeatherClockWidget extends ConsumerWidget {
  const WeatherClockWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 时钟组件
          const ClockDisplayWidget(
            mode: ClockDisplayMode.vertical,
            showSeconds: false,
            showDate: true,
            timeFontSize: 72,
            dateFontSize: 20,
            textColor: Colors.white,
            timeOpacity: 1.0,  // 使用纯白色提高对比度
            dateOpacity: 0.95,
            fontWeight: FontWeight.w200,
            letterSpacing: -2,
            textShadows: [
              // 外层软阴影
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 12,
                color: Color(0x66000000),  // 40% 黑色
              ),
              // 内层硬阴影
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 4,
                color: Color(0x99000000),  // 60% 黑色
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 天气组件
          const WeatherDisplayWidget(
            mode: WeatherDisplayMode.compact,
            textColor: Colors.white,
            textShadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 4,
                color: Color(0x4D000000),  // 30% 黑色
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/constants/app_constants.dart';

/// 时间面板组件 - 显示当前时间、日期和版本信息
class TimePanel extends HookWidget {
  const TimePanel({super.key});

  @override
  Widget build(BuildContext context) {
    // 性能优化：使用Hook管理时间状态，但减少更新频率
    final currentTime = useState(DateTime.now());
    
    // 优化：只在分钟变化时更新，而不是每秒更新
    useEffect(() {
      final now = DateTime.now();
      final nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
      final delayToNextMinute = nextMinute.difference(now);
      
      Timer? periodicTimer;
      
      // 首先延迟到下一分钟开始
      final firstTimer = Timer(delayToNextMinute, () {
        currentTime.value = DateTime.now();
        
        // 然后每分钟更新一次
        periodicTimer = Timer.periodic(const Duration(minutes: 1), (_) {
          currentTime.value = DateTime.now();
        });
      });
      
      // 清理函数
      return () {
        firstTimer.cancel();
        periodicTimer?.cancel();
      };
    }, []);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 时间显示
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(currentTime.value),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(currentTime.value),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          
          // 版本和里程碑信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'v${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '里程碑 5/10',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 格式化时间显示
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  /// 格式化日期显示
  String _formatDate(DateTime time) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    
    return '${time.year}年${months[time.month - 1]}${time.day}日 ${weekdays[time.weekday % 7]}';
  }
}
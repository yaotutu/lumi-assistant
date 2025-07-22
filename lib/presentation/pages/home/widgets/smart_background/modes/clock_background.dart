import 'package:flutter/material.dart';

/// 时钟背景组件
/// 
/// 职责：
/// - 显示大字体的当前时间
/// - 显示日期和星期信息
/// - 提供优雅的渐变背景
/// 
/// 特点：
/// - 实时更新时间显示
/// - 清晰易读的字体设计
/// - 适合长时间显示的屏保模式
class ClockBackground extends StatefulWidget {
  /// 构造函数
  const ClockBackground({super.key});

  @override
  State<ClockBackground> createState() => _ClockBackgroundState();
}

class _ClockBackgroundState extends State<ClockBackground> {
  // 时间更新流订阅
  late Stream<DateTime> _timeStream;
  
  @override
  void initState() {
    super.initState();
    
    // 创建每秒更新的时间流
    _timeStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 渐变背景 - 深蓝到紫色的优雅渐变
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
      child: Container(
        // 添加半透明遮罩，确保时间文字清晰可读
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Center(
          child: StreamBuilder<DateTime>(
            stream: _timeStream,
            initialData: DateTime.now(),
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 数字时钟显示
                  _buildTimeDisplay(now),
                  
                  const SizedBox(height: 24),
                  
                  // 日期显示
                  _buildDateDisplay(now),
                  
                  const SizedBox(height: 16),
                  
                  // 额外信息显示（星期、农历等）
                  _buildExtraInfo(now),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  /// 构建时间显示组件
  /// 
  /// 显示大字体的小时:分钟，秒数以较小字体显示
  Widget _buildTimeDisplay(DateTime time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 小时:分钟 - 大字体
        Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 72,
            fontWeight: FontWeight.w100,
            letterSpacing: 4.0,
            height: 0.9,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // 秒数 - 小字体
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            time.second.toString().padLeft(2, '0'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 24,
              fontWeight: FontWeight.w200,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建日期显示组件
  /// 
  /// 显示完整的日期信息，包含年月日和星期
  Widget _buildDateDisplay(DateTime time) {
    return Column(
      children: [
        // 主要日期信息
        Text(
          _formatMainDate(time),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.0,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 星期信息
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatWeekday(time),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建额外信息显示
  /// 
  /// 显示一些有用的额外信息，如时间段问候语等
  Widget _buildExtraInfo(DateTime time) {
    return Column(
      children: [
        // 时间段问候语
        Text(
          _getGreeting(time),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 一年中的天数
        Text(
          '今天是${time.year}年的第${_getDayOfYear(time)}天',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
  
  /// 格式化主要日期
  /// 
  /// 返回格式：2025年1月22日
  String _formatMainDate(DateTime time) {
    const months = [
      '1月', '2月', '3月', '4月', '5月', '6月',
      '7月', '8月', '9月', '10月', '11月', '12月'
    ];
    
    return '${time.year}年${months[time.month - 1]}${time.day}日';
  }
  
  /// 格式化星期
  /// 
  /// 返回格式：星期一
  String _formatWeekday(DateTime time) {
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    return weekdays[time.weekday % 7];
  }
  
  /// 获取时间段问候语
  /// 
  /// 根据当前时间返回合适的问候语
  String _getGreeting(DateTime time) {
    final hour = time.hour;
    
    if (hour >= 5 && hour < 9) {
      return '早上好，新的一天开始了';
    } else if (hour >= 9 && hour < 11) {
      return '上午好，精神饱满地工作吧';
    } else if (hour >= 11 && hour < 13) {
      return '接近午餐时间了';
    } else if (hour >= 13 && hour < 17) {
      return '下午好，继续加油';
    } else if (hour >= 17 && hour < 19) {
      return '傍晚了，准备下班吧';
    } else if (hour >= 19 && hour < 22) {
      return '晚上好，放松一下';
    } else if (hour >= 22 || hour < 1) {
      return '夜深了，早点休息';
    } else {
      return '深夜时光，注意休息';
    }
  }
  
  /// 计算一年中的天数
  /// 
  /// 返回当前日期是一年中的第几天
  int _getDayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final difference = date.difference(startOfYear);
    return difference.inDays + 1;
  }
}
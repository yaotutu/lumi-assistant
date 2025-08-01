import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 时钟显示组件
/// 
/// 职责：显示时间和日期
/// 特点：
/// - 独立的时钟组件，可单独使用
/// - 支持多种显示模式
/// - 实时更新
/// - 高度可定制
class ClockDisplayWidget extends HookWidget {
  /// 显示模式
  final ClockDisplayMode mode;
  
  /// 是否显示秒
  final bool showSeconds;
  
  /// 是否显示日期
  final bool showDate;
  
  /// 时间字体大小
  final double? timeFontSize;
  
  /// 日期字体大小
  final double? dateFontSize;
  
  /// 文字颜色
  final Color? textColor;
  
  /// 时间文字透明度
  final double timeOpacity;
  
  /// 日期文字透明度
  final double dateOpacity;
  
  /// 文字阴影
  final List<Shadow>? textShadows;
  
  /// 字体粗细
  final FontWeight? fontWeight;
  
  /// 字间距
  final double? letterSpacing;
  
  /// 构造函数
  const ClockDisplayWidget({
    super.key,
    this.mode = ClockDisplayMode.vertical,
    this.showSeconds = false,
    this.showDate = true,
    this.timeFontSize,
    this.dateFontSize,
    this.textColor,
    this.timeOpacity = 0.9,
    this.dateOpacity = 0.75,
    this.textShadows,
    this.fontWeight,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    // 使用Hook管理时间更新
    final currentTime = useState(DateTime.now());
    
    // 设置定时器更新时间
    useEffect(() {
      final timer = Timer.periodic(
        Duration(seconds: showSeconds ? 1 : 60),
        (timer) {
          currentTime.value = DateTime.now();
        },
      );
      
      // 如果不显示秒，调整到整分钟更新
      if (!showSeconds) {
        final now = DateTime.now();
        final nextMinute = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute + 1,
        );
        final delay = nextMinute.difference(now);
        
        Future.delayed(delay, () {
          if (context.mounted) {
            currentTime.value = DateTime.now();
          }
        });
      }
      
      // 清理定时器
      return timer.cancel;
    }, [showSeconds]);
    
    // 根据模式构建布局
    switch (mode) {
      case ClockDisplayMode.vertical:
        return _buildVerticalLayout(currentTime.value);
      case ClockDisplayMode.horizontal:
        return _buildHorizontalLayout(currentTime.value);
      case ClockDisplayMode.compact:
        return _buildCompactLayout(currentTime.value);
    }
  }
  
  /// 构建垂直布局
  Widget _buildVerticalLayout(DateTime time) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 时间显示
        _buildTimeDisplay(time),
        if (showDate) ...[
          const SizedBox(height: 16),
          // 日期显示
          _buildDateDisplay(time),
        ],
      ],
    );
  }
  
  /// 构建水平布局
  Widget _buildHorizontalLayout(DateTime time) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 时间显示
        _buildTimeDisplay(time),
        if (showDate) ...[
          const SizedBox(width: 24),
          // 日期显示
          _buildDateDisplay(time),
        ],
      ],
    );
  }
  
  /// 构建紧凑布局
  Widget _buildCompactLayout(DateTime time) {
    final timeStr = _formatTime(time);
    final dateStr = showDate ? _formatCompactDate(time) : '';
    
    return Text(
      showDate ? '$timeStr • $dateStr' : timeStr,
      style: TextStyle(
        color: (textColor ?? Colors.white).withValues(alpha: timeOpacity),
        fontSize: timeFontSize ?? 20,
        fontWeight: fontWeight ?? FontWeight.w300,
        letterSpacing: letterSpacing ?? 0.5,
        shadows: textShadows ?? _defaultShadows,
      ),
    );
  }
  
  /// 构建时间显示
  Widget _buildTimeDisplay(DateTime time) {
    return Text(
      _formatTime(time),
      style: TextStyle(
        color: (textColor ?? Colors.white).withValues(alpha: timeOpacity),
        fontSize: timeFontSize ?? _getDefaultTimeFontSize(),
        fontWeight: fontWeight ?? FontWeight.w200,
        letterSpacing: letterSpacing ?? -2,
        height: 1.0,
        shadows: textShadows ?? _defaultShadows,
      ),
    );
  }
  
  /// 构建日期显示
  Widget _buildDateDisplay(DateTime date) {
    return Text(
      _formatDate(date),
      style: TextStyle(
        color: (textColor ?? Colors.white).withValues(alpha: dateOpacity),
        fontSize: dateFontSize ?? _getDefaultDateFontSize(),
        fontWeight: fontWeight ?? FontWeight.w200,
        letterSpacing: 1.0,
        shadows: textShadows ?? _defaultShadows,
      ),
    );
  }
  
  /// 格式化时间
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    
    if (showSeconds) {
      final second = time.second.toString().padLeft(2, '0');
      return '$hour:$minute:$second';
    }
    
    return '$hour:$minute';
  }
  
  /// 格式化日期
  String _formatDate(DateTime date) {
    // 星期映射
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    final weekDay = weekDays[date.weekday % 7];
    
    // 格式化日期 - 不显示年份
    final month = date.month;
    final day = date.day;
    
    return '$month月$day日 $weekDay';
  }
  
  /// 格式化紧凑日期
  String _formatCompactDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
  
  /// 获取默认时间字体大小
  double _getDefaultTimeFontSize() {
    switch (mode) {
      case ClockDisplayMode.vertical:
        return 72;
      case ClockDisplayMode.horizontal:
        return 48;
      case ClockDisplayMode.compact:
        return 20;
    }
  }
  
  /// 获取默认日期字体大小
  double _getDefaultDateFontSize() {
    switch (mode) {
      case ClockDisplayMode.vertical:
        return 20;
      case ClockDisplayMode.horizontal:
        return 18;
      case ClockDisplayMode.compact:
        return 16;
    }
  }
  
  /// 默认文字阴影
  List<Shadow> get _defaultShadows => [
    Shadow(
      offset: const Offset(0, 2),
      blurRadius: 6,
      color: Colors.black.withValues(alpha: 0.25),
    ),
  ];
}

/// 时钟显示模式
enum ClockDisplayMode {
  /// 垂直布局（时间在上，日期在下）
  vertical,
  
  /// 水平布局（时间在左，日期在右）
  horizontal,
  
  /// 紧凑布局（单行显示）
  compact,
}
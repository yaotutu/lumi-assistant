import 'package:flutter/material.dart';

/// 时间显示浮动层组件
/// 
/// 职责：
/// - 显示当前时间和日期信息
/// - 提供实时更新的时间流
/// - 展示优雅的时间排版和设计
/// 
/// 设计特点：
/// - 大字体时间显示，易于阅读
/// - 优雅的日期格式和排版
/// - 自动更新，无需手动刷新
/// - 半透明设计，与背景和谐融合
class TimeDisplayLayer extends StatelessWidget {
  /// 时间显示位置对齐方式
  final Alignment alignment;
  
  /// 时间显示透明度
  final double opacity;
  
  /// 是否显示秒数
  final bool showSeconds;
  
  /// 是否显示详细日期信息
  final bool showDetailedDate;
  
  /// 时间字体大小
  final double timeSize;
  
  /// 日期字体大小
  final double dateSize;
  
  /// 构造函数
  const TimeDisplayLayer({
    super.key,
    this.alignment = Alignment.center,
    this.opacity = 0.9,
    this.showSeconds = false,
    this.showDetailedDate = true,
    this.timeSize = 56.0,
    this.dateSize = 16.0,
  });

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
        
        return Align(
          alignment: alignment,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 主时间显示
              _buildTimeDisplay(now),
              
              if (showDetailedDate) ...[
                const SizedBox(height: 8),
                // 详细日期显示
                _buildDateDisplay(now),
              ],
              
              // 可选的额外信息
              if (showSeconds) ...[
                const SizedBox(height: 4),
                _buildSecondsDisplay(now),
              ],
            ],
          ),
        );
      },
    );
  }
  
  /// 构建主时间显示
  Widget _buildTimeDisplay(DateTime time) {
    return Text(
      _formatTime(time),
      style: TextStyle(
        color: Colors.white.withValues(alpha: opacity),
        fontSize: timeSize,
        fontWeight: FontWeight.w100,
        letterSpacing: 4.0,
        height: 0.9,
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
  
  /// 构建日期显示
  Widget _buildDateDisplay(DateTime time) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 主要日期
        Text(
          _formatMainDate(time),
          style: TextStyle(
            color: Colors.white.withValues(alpha: opacity * 0.8),
            fontSize: dateSize,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.0,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 4),
        
        // 星期信息
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatWeekday(time),
            style: TextStyle(
              color: Colors.white.withValues(alpha: opacity * 0.9),
              fontSize: dateSize * 0.8,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建秒数显示
  Widget _buildSecondsDisplay(DateTime time) {
    return Text(
      ':${time.second.toString().padLeft(2, '0')}',
      style: TextStyle(
        color: Colors.white.withValues(alpha: opacity * 0.6),
        fontSize: timeSize * 0.4,
        fontWeight: FontWeight.w200,
        letterSpacing: 2.0,
      ),
    );
  }
  
  /// 格式化时间显示
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  /// 格式化主要日期
  String _formatMainDate(DateTime time) {
    const months = [
      '1月', '2月', '3月', '4月', '5月', '6月',
      '7月', '8月', '9月', '10月', '11月', '12月'
    ];
    
    return '${time.year}年${months[time.month - 1]}${time.day}日';
  }
  
  /// 格式化星期显示
  String _formatWeekday(DateTime time) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[time.weekday % 7];
  }
}

/// 紧凑时间显示组件
/// 
/// 用于在空间受限的区域显示时间
class CompactTimeDisplay extends StatelessWidget {
  /// 透明度
  final double opacity;
  
  /// 构造函数
  const CompactTimeDisplay({
    super.key,
    this.opacity = 0.7,
  });

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
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: opacity),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }
}

/// 时间显示配置类
/// 
/// 用于配置时间显示的各种参数
class TimeDisplayConfig {
  /// 是否显示秒数
  final bool showSeconds;
  
  /// 是否使用24小时制
  final bool use24Hour;
  
  /// 是否显示详细日期
  final bool showDetailedDate;
  
  /// 时间字体大小
  final double timeSize;
  
  /// 日期字体大小
  final double dateSize;
  
  /// 显示透明度
  final double opacity;
  
  /// 构造函数
  const TimeDisplayConfig({
    this.showSeconds = false,
    this.use24Hour = true,
    this.showDetailedDate = true,
    this.timeSize = 56.0,
    this.dateSize = 16.0,
    this.opacity = 0.9,
  });
  
  /// 创建紧凑模式配置
  static const TimeDisplayConfig compact = TimeDisplayConfig(
    showSeconds: false,
    showDetailedDate: false,
    timeSize: 24.0,
    dateSize: 12.0,
    opacity: 0.8,
  );
  
  /// 创建完整模式配置
  static const TimeDisplayConfig full = TimeDisplayConfig(
    showSeconds: true,
    showDetailedDate: true,
    timeSize: 64.0,
    dateSize: 18.0,
    opacity: 0.95,
  );
  
  /// 创建极简模式配置
  static const TimeDisplayConfig minimal = TimeDisplayConfig(
    showSeconds: false,
    showDetailedDate: false,
    timeSize: 48.0,
    dateSize: 14.0,
    opacity: 0.7,
  );
}
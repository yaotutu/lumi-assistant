import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/weather_warning.dart';

/// 天气预警显示组件
/// 
/// 职责：显示天气预警信息
/// 功能：
/// 1. 根据预警级别显示不同颜色
/// 2. 支持展开/收起详细信息
/// 3. 动画效果提醒用户注意
class WeatherWarningWidget extends HookConsumerWidget {
  final List<WeatherWarning> warnings;
  
  const WeatherWarningWidget({
    super.key,
    required this.warnings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 如果没有预警，不显示任何内容
    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 获取最高级别的预警
    final highestWarning = _getHighestSeverityWarning(warnings);
    final warningColor = _getWarningColor(highestWarning.severity);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: warningColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showWarningDetails(context, warnings),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 预警图标
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                
                // 预警信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      Text(
                        highestWarning.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // 多条预警提示
                      if (warnings.length > 1) ...[
                        const SizedBox(height: 2),
                        Text(
                          '共${warnings.length}条预警，点击查看详情',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // 箭头
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 获取最高级别的预警
  WeatherWarning _getHighestSeverityWarning(List<WeatherWarning> warnings) {
    return warnings.reduce((a, b) {
      final aLevel = WarningSeverity.fromString(a.severity).level;
      final bLevel = WarningSeverity.fromString(b.severity).level;
      return aLevel >= bLevel ? a : b;
    });
  }
  
  /// 根据预警级别获取颜色
  Color _getWarningColor(String severity) {
    final warningSeverity = WarningSeverity.fromString(severity);
    switch (warningSeverity) {
      case WarningSeverity.minor:
        return const Color(0xFF1E88E5); // 蓝色
      case WarningSeverity.moderate:
        return const Color(0xFFFFA726); // 黄色
      case WarningSeverity.severe:
        return const Color(0xFFFF7043); // 橙色
      case WarningSeverity.extreme:
        return const Color(0xFFE53935); // 红色
    }
  }
  
  /// 显示预警详情
  void _showWarningDetails(BuildContext context, List<WeatherWarning> warnings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _WarningDetailsSheet(warnings: warnings),
    );
  }
}

/// 预警详情弹窗
class _WarningDetailsSheet extends StatelessWidget {
  final List<WeatherWarning> warnings;
  
  const _WarningDetailsSheet({
    required this.warnings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '天气预警详情',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 预警列表
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: warnings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final warning = warnings[index];
                final warningColor = _getWarningColor(warning.severity);
                final warningSeverity = WarningSeverity.fromString(warning.severity);
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: warningColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题和级别
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 级别标签
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: warningColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              warningSeverity.chinese,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // 标题
                          Expanded(
                            child: Text(
                              warning.title,
                              style: TextStyle(
                                color: warningColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 详细描述
                      Text(
                        warning.text,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 时间信息
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatTime(warning.startTime)} - ${_formatTime(warning.endTime)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      
                      // 发布单位
                      if (warning.sender != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              warning.sender!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 根据预警级别获取颜色
  Color _getWarningColor(String severity) {
    final warningSeverity = WarningSeverity.fromString(severity);
    switch (warningSeverity) {
      case WarningSeverity.minor:
        return const Color(0xFF1E88E5); // 蓝色
      case WarningSeverity.moderate:
        return const Color(0xFFFFA726); // 黄色
      case WarningSeverity.severe:
        return const Color(0xFFFF7043); // 橙色
      case WarningSeverity.extreme:
        return const Color(0xFFE53935); // 红色
    }
  }
  
  /// 格式化时间
  String _formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoTime;
    }
  }
}
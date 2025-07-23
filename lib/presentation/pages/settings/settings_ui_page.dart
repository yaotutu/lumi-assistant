import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/app_settings.dart';

/// UI界面设置页面
/// 
/// 包含悬浮窗尺寸、字体缩放、动画时长等界面相关设置
class SettingsUIPage extends ConsumerWidget {
  const SettingsUIPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI界面设置'),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSliderSetting(
            title: '悬浮窗收缩尺寸',
            subtitle: '悬浮聊天窗口收缩时的大小',
            value: settings.floatingChatSize,
            min: 60.0,
            max: 120.0,
            divisions: 12,
            unit: 'px',
            onChanged: settings.updateFloatingChatSize,
            onReset: settings.isDefaultFloatingChatSize() ? null : settings.resetFloatingChatSize,
          ),
          
          _buildSliderSetting(
            title: '悬浮窗展开宽度比例',
            subtitle: '悬浮窗展开时占屏幕宽度的比例',
            value: settings.floatingChatWidthRatio,
            min: 0.6,
            max: 1.0,
            divisions: 8,
            unit: '%',
            valueTransform: (v) => (v * 100).round(),
            onChanged: settings.updateFloatingChatWidthRatio,
          ),
          
          _buildSliderSetting(
            title: '悬浮窗展开高度比例',
            subtitle: '悬浮窗展开时占屏幕高度的比例',
            value: settings.floatingChatHeightRatio,
            min: 0.5,
            max: 0.9,
            divisions: 8,
            unit: '%',
            valueTransform: (v) => (v * 100).round(),
            onChanged: settings.updateFloatingChatHeightRatio,
          ),
          
          _buildSliderSetting(
            title: '字体缩放比例',
            subtitle: '全局字体大小缩放倍数',
            value: settings.fontScale,
            min: 0.8,
            max: 1.5,
            divisions: 14,
            unit: 'x',
            onChanged: settings.updateFontScale,
            onReset: settings.isDefaultFontScale() ? null : settings.resetFontScale,
          ),
          
          _buildSliderSetting(
            title: '动画时长',
            subtitle: '界面动画的持续时间',
            value: settings.animationDuration.toDouble(),
            min: 100.0,
            max: 500.0,
            divisions: 8,
            unit: 'ms',
            valueTransform: (v) => v.round(),
            onChanged: (v) => settings.updateAnimationDuration(v.round()),
          ),
          
          _buildSliderSetting(
            title: '顶部操作栏距离',
            subtitle: '设置按钮距离状态栏的额外距离',
            value: settings.topBarDistance,
            min: 0.0,
            max: 100.0,
            divisions: 20,
            unit: 'px',
            onChanged: settings.updateTopBarDistance,
            onReset: settings.isDefaultTopBarDistance() ? null : settings.resetTopBarDistance,
          ),
        ],
      ),
    );
  }

  /// 滑块设置项
  Widget _buildSliderSetting({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    int? divisions,
    String unit = '',
    dynamic Function(double)? valueTransform,
    VoidCallback? onReset,
  }) {
    final displayValue = valueTransform?.call(value) ?? value;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$displayValue$unit',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
                if (onReset != null) ...[ 
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.restore, size: 20),
                    onPressed: onReset,
                    tooltip: '恢复默认值',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/dynamic_config.dart';

/// 动态设置页面
/// 
/// 用户可以在此页面实时修改应用配置
/// 所有修改都会立即生效并持久化保存
class DynamicSettingsPage extends HookConsumerWidget {
  const DynamicSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(dynamicConfigProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用设置'),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _showResetDialog(context, config),
            tooltip: '恢复默认设置',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('悬浮聊天窗口'),
          _buildFloatingChatSettings(config),
          
          const SizedBox(height: 24),
          _buildSectionHeader('动画效果'),
          _buildAnimationSettings(config),
          
          const SizedBox(height: 24),
          _buildSectionHeader('主题样式'),
          _buildThemeSettings(config),
          
          const SizedBox(height: 24),
          _buildSectionHeader('性能优化'),
          _buildPerformanceSettings(config),
          
          const SizedBox(height: 24),
          _buildSectionHeader('调试选项'),
          _buildDebugSettings(config),
        ],
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  /// 悬浮聊天设置
  Widget _buildFloatingChatSettings(DynamicConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSliderSetting(
              '收缩状态尺寸',
              config.floatingChatCollapsedSize,
              60.0,
              120.0,
              (value) => config.setFloatingChatCollapsedSize(value),
              '${config.floatingChatCollapsedSize.round()}px',
              '悬浮窗收缩时的大小',
            ),
            
            _buildSliderSetting(
              '展开宽度比例',
              config.floatingChatExpandedWidthRatio,
              0.7,
              1.0,
              (value) => config.setFloatingChatExpandedWidthRatio(value),
              '${(config.floatingChatExpandedWidthRatio * 100).round()}%',
              '悬浮窗展开时的屏幕宽度占比',
            ),
            
            _buildSliderSetting(
              '展开高度比例',
              config.floatingChatExpandedHeightRatio,
              0.5,
              0.9,
              (value) => config.setFloatingChatExpandedHeightRatio(value),
              '${(config.floatingChatExpandedHeightRatio * 100).round()}%',
              '悬浮窗展开时的屏幕高度占比',
            ),
            
            _buildSwitchSetting(
              '背景模糊效果',
              config.floatingChatEnableBackgroundBlur,
              (value) => config.setFloatingChatEnableBackgroundBlur(value),
              '展开时启用背景模糊',
            ),
            
            _buildSliderSetting(
              '虚拟人物字体大小',
              config.floatingChatCharacterFontSize,
              40.0,
              100.0,
              (value) => config.setFloatingChatCharacterFontSize(value),
              '${config.floatingChatCharacterFontSize.round()}px',
              '虚拟人物表情的字体大小',
            ),
          ],
        ),
      ),
    );
  }

  /// 动画设置
  Widget _buildAnimationSettings(DynamicConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSliderSetting(
              '悬浮窗动画时长',
              config.animationFloatingChatDurationMs.toDouble(),
              100.0,
              500.0,
              (value) => config.setAnimationFloatingChatDurationMs(value.round()),
              '${config.animationFloatingChatDurationMs}ms',
              '悬浮窗展开/收缩动画的持续时间',
            ),
            
            _buildSwitchSetting(
              'Material动画效果',
              config.animationEnableMaterialAnimations,
              (value) => config.setAnimationEnableMaterialAnimations(value),
              '启用Material Design动画效果',
            ),
            
            _buildSwitchSetting(
              '波纹点击效果',
              config.animationEnableRippleEffect,
              (value) => config.setAnimationEnableRippleEffect(value),
              '点击时的波纹扩散效果',
            ),
          ],
        ),
      ),
    );
  }

  /// 主题设置
  Widget _buildThemeSettings(DynamicConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchSetting(
              'Material 3设计',
              config.themeUseMaterial3,
              (value) => config.setThemeUseMaterial3(value),
              '使用Material 3设计语言',
            ),
            
            _buildSwitchSetting(
              '阴影效果',
              config.themeEnableShadows,
              (value) => config.setThemeEnableShadows(value),
              '为组件添加阴影效果',
            ),
          ],
        ),
      ),
    );
  }

  /// 性能设置
  Widget _buildPerformanceSettings(DynamicConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchSetting(
              '性能监控',
              config.performanceEnableMonitoring,
              (value) => config.setPerformanceEnableMonitoring(value),
              '显示性能监控覆盖层',
            ),
            
            _buildSliderSetting(
              '图像质量',
              config.performanceImageQuality,
              0.3,
              1.0,
              (value) => config.setPerformanceImageQuality(value),
              '${(config.performanceImageQuality * 100).round()}%',
              '图片渲染质量设置',
            ),
          ],
        ),
      ),
    );
  }

  /// 调试设置
  Widget _buildDebugSettings(DynamicConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchSetting(
              '调试日志',
              config.debugEnableLogging,
              (value) => config.setDebugEnableLogging(value),
              '输出详细的调试信息',
            ),
            
            _buildSwitchSetting(
              '网络日志',
              config.debugEnableNetworkLogging,
              (value) => config.setDebugEnableNetworkLogging(value),
              '记录网络请求详情',
            ),
            
            _buildSwitchSetting(
              '音频日志',
              config.debugEnableAudioLogging,
              (value) => config.setDebugEnableAudioLogging(value),
              '记录音频处理日志',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建滑块设置项
  Widget _buildSliderSetting(
    String title,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    String displayValue,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                displayValue,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  /// 构建开关设置项
  Widget _buildSwitchSetting(
    String title,
    bool value,
    Function(bool) onChanged,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  /// 显示重置确认对话框
  void _showResetDialog(BuildContext context, DynamicConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要将所有设置恢复为默认值吗？\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              config.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('设置已重置为默认值'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }
}
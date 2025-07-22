import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/app_settings.dart';

/// 应用设置配置页面
/// 
/// 用户可以在此页面修改各种应用配置
/// 支持恢复默认值、实时预览等功能
class SettingsConfigPage extends ConsumerWidget {
  const SettingsConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用设置'),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'reset_all':
                  _showResetAllDialog(context, settings);
                  break;
                case 'export':
                  _showExportDialog(context);
                  break;
                case 'import':
                  _showImportDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset_all',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: Colors.red),
                    SizedBox(width: 8),
                    Text('重置所有设置'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('导出设置'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green),
                    SizedBox(width: 8),
                    Text('导入设置'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUISettings(context, settings),
          const SizedBox(height: 24),
          _buildNetworkSettings(context, settings),
          const SizedBox(height: 24),
          _buildAudioSettings(context, settings),
          const SizedBox(height: 24),
          _buildThemeSettings(context, settings),
          const SizedBox(height: 24),
          _buildDebugSettings(context, settings),
        ],
      ),
    );
  }

  /// UI界面设置
  Widget _buildUISettings(BuildContext context, AppSettings settings) {
    return _buildSettingsSection(
      title: 'UI界面设置',
      icon: Icons.design_services,
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
      ],
    );
  }

  /// 网络连接设置
  Widget _buildNetworkSettings(BuildContext context, AppSettings settings) {
    return _buildSettingsSection(
      title: '网络连接设置',
      icon: Icons.wifi,
      children: [
        _buildTextSetting(
          title: 'WebSocket服务器地址',
          subtitle: '语音助手后端WebSocket服务器地址',
          value: settings.serverUrl,
          defaultValue: AppSettings.defaultServerUrl,
          onChanged: settings.updateServerUrl,
          onReset: settings.isDefaultServerUrl() ? null : settings.resetServerUrl,
          validator: (value) {
            if (value == null || value.isEmpty) return '服务器地址不能为空';
            if (!value.startsWith('ws://') && !value.startsWith('wss://')) {
              return '地址必须以 ws:// 或 wss:// 开头';
            }
            return null;
          },
        ),
        
        _buildTextSetting(
          title: 'HTTP API地址',
          subtitle: '后端HTTP API服务器地址',
          value: settings.apiUrl,
          defaultValue: AppSettings.defaultApiUrl,
          onChanged: settings.updateApiUrl,
          validator: (value) {
            if (value == null || value.isEmpty) return 'API地址不能为空';
            if (!value.startsWith('http://') && !value.startsWith('https://')) {
              return '地址必须以 http:// 或 https:// 开头';
            }
            return null;
          },
        ),
        
        _buildSliderSetting(
          title: '连接超时时间',
          subtitle: '网络连接的超时时间',
          value: settings.connectionTimeout.toDouble(),
          min: 5.0,
          max: 30.0,
          divisions: 5,
          unit: '秒',
          valueTransform: (v) => v.round(),
          onChanged: (v) => settings.updateConnectionTimeout(v.round()),
        ),
      ],
    );
  }

  /// 音频设置
  Widget _buildAudioSettings(BuildContext context, AppSettings settings) {
    return _buildSettingsSection(
      title: '音频设置',
      icon: Icons.mic,
      children: [
        _buildDropdownSetting(
          title: '音频采样率',
          subtitle: '语音录制的采样频率，影响音质',
          value: settings.sampleRate,
          options: const [8000, 16000, 22050, 44100],
          optionLabels: const ['8kHz (电话质量)', '16kHz (推荐)', '22kHz (音乐质量)', '44kHz (CD质量)'],
          onChanged: (v) => settings.updateSampleRate(v!),
        ),
        
        _buildDropdownSetting(
          title: '声道数',
          subtitle: '音频录制的声道配置',
          value: settings.channels,
          options: const [1, 2],
          optionLabels: const ['单声道 (推荐)', '立体声'],
          onChanged: (v) => settings.updateChannels(v!),
        ),
        
        _buildSliderSetting(
          title: '音频帧时长',
          subtitle: '音频数据包的时长，影响延迟',
          value: settings.frameDuration.toDouble(),
          min: 20.0,
          max: 100.0,
          divisions: 8,
          unit: 'ms',
          valueTransform: (v) => v.round(),
          onChanged: (v) => settings.updateFrameDuration(v.round()),
        ),
      ],
    );
  }

  /// 主题设置
  Widget _buildThemeSettings(BuildContext context, AppSettings settings) {
    return _buildSettingsSection(
      title: '主题样式',
      icon: Icons.palette,
      children: [
        _buildSwitchSetting(
          title: 'Material 3 设计',
          subtitle: '使用最新的Material 3设计语言',
          value: settings.useMaterial3,
          onChanged: settings.updateUseMaterial3,
        ),
        
        _buildSwitchSetting(
          title: '动画效果',
          subtitle: '启用界面动画和过渡效果',
          value: settings.enableAnimations,
          onChanged: settings.updateEnableAnimations,
        ),
        
        _buildSwitchSetting(
          title: '波纹点击效果',
          subtitle: '点击时的波纹扩散效果',
          value: settings.enableRipple,
          onChanged: settings.updateEnableRipple,
        ),
      ],
    );
  }

  /// 调试选项
  Widget _buildDebugSettings(BuildContext context, AppSettings settings) {
    return _buildSettingsSection(
      title: '开发者选项',
      icon: Icons.bug_report,
      children: [
        _buildSwitchSetting(
          title: '详细日志',
          subtitle: '输出详细的调试信息到控制台',
          value: settings.debugEnableVerboseLogging,
          onChanged: settings.updateDebugEnableVerboseLogging,
        ),
        
        _buildSwitchSetting(
          title: 'WebSocket日志',
          subtitle: '记录所有WebSocket通信和响应',
          value: settings.debugEnableWebSocketLogging,
          onChanged: settings.updateDebugEnableWebSocketLogging,
        ),
        
        _buildSwitchSetting(
          title: '音频日志',
          subtitle: '记录音频处理相关日志',
          value: settings.debugEnableAudioLogging,
          onChanged: settings.updateDebugEnableAudioLogging,
        ),
      ],
    );
  }

  /// 构建设置分组
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          ...children,
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
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
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
    );
  }

  /// 开关设置项
  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  subtitle,
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

  /// 文本输入设置项
  Widget _buildTextSetting({
    required String title,
    required String subtitle,
    required String value,
    required String defaultValue,
    required Function(String) onChanged,
    VoidCallback? onReset,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onReset != null)
                IconButton(
                  icon: const Icon(Icons.restore, size: 20),
                  onPressed: onReset,
                  tooltip: '恢复默认值',
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: '默认: $defaultValue',
              isDense: true,
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// 下拉选择设置项
  Widget _buildDropdownSetting<T>({
    required String title,
    required String subtitle,
    required T value,
    required List<T> options,
    required List<String> optionLabels,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: options.asMap().entries.map((entry) {
              return DropdownMenuItem<T>(
                value: entry.value,
                child: Text(optionLabels[entry.key]),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// 显示重置所有设置的确认对话框
  void _showResetAllDialog(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置所有设置'),
        content: const Text('确定要将所有设置恢复为默认值吗？\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              settings.resetAllSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('所有设置已重置为默认值'),
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

  /// 显示导出设置对话框
  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出设置'),
        content: const Text('导出设置功能将在后续版本中实现。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  /// 显示导入设置对话框
  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入设置'),
        content: const Text('导入设置功能将在后续版本中实现。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }
}
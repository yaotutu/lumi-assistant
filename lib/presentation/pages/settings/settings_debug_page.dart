import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import '../../../core/config/app_settings.dart';

/// 开发者选项设置页面
/// 
/// 包含调试日志、网络日志、音频日志等开发调试设置
class SettingsDebugPage extends ConsumerWidget {
  const SettingsDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('开发者选项'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 警告提示
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '开发者选项',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '这些设置主要用于开发和调试，启用后可能会影响应用性能。',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 日志等级设置
          _buildLogLevelSetting(context, settings),
          
          const SizedBox(height: 16),
          
          // 通用日志设置
          _buildGeneralLogSettings(settings),
          
          const SizedBox(height: 16),
          
          // 模块日志开关
          _buildModuleLogSettings(settings),
        ],
      ),
    );
  }

  /// 日志等级设置
  Widget _buildLogLevelSetting(BuildContext context, AppSettings settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '日志等级',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '当前等级: ${settings.logLevel.name}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: Level.LEVELS.where((level) => level != Level.ALL).map((level) {
                  final isSelected = settings.logLevel == level;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(level.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          settings.updateLogLevel(level);
                        }
                      },
                      selectedColor: Colors.red.shade700,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 通用日志设置
  Widget _buildGeneralLogSettings(AppSettings settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '通用设置',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildSwitchSetting(
              title: '详细日志',
              subtitle: '启用FINE级别的详细调试信息',
              value: settings.debugEnableVerboseLogging,
              onChanged: settings.updateDebugEnableVerboseLogging,
            ),
            const SizedBox(height: 8),
            _buildSwitchSetting(
              title: '性能日志',
              subtitle: '记录性能指标和响应时间',
              value: settings.debugEnablePerformanceLogging,
              onChanged: settings.updateDebugEnablePerformanceLogging,
            ),
          ],
        ),
      ),
    );
  }

  /// 模块日志开关设置
  Widget _buildModuleLogSettings(AppSettings settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '模块日志开关',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildSwitchSetting(
              title: 'WebSocket',
              subtitle: '网络通信日志',
              value: settings.debugEnableWebSocketLogging,
              onChanged: settings.updateDebugEnableWebSocketLogging,
            ),
            const SizedBox(height: 8),
            _buildSwitchSetting(
              title: 'MCP服务',
              subtitle: 'MCP服务器通信日志',
              value: settings.debugEnableMcpLogging,
              onChanged: settings.updateDebugEnableMcpLogging,
            ),
            const SizedBox(height: 8),
            _buildSwitchSetting(
              title: '音频处理',
              subtitle: '音频编解码和播放日志',
              value: settings.debugEnableAudioLogging,
              onChanged: settings.updateDebugEnableAudioLogging,
            ),
            const SizedBox(height: 8),
            _buildSwitchSetting(
              title: '聊天功能',
              subtitle: '消息收发和状态变化日志',
              value: settings.debugEnableChatLogging,
              onChanged: settings.updateDebugEnableChatLogging,
            ),
            const SizedBox(height: 8),
            _buildSwitchSetting(
              title: 'UI界面',
              subtitle: '界面更新和用户操作日志',
              value: settings.debugEnableUILogging,
              onChanged: settings.updateDebugEnableUILogging,
            ),
            const SizedBox(height: 8),
            _buildSwitchSetting(
              title: '设置管理',
              subtitle: '设置变更和配置加载日志',
              value: settings.debugEnableSettingsLogging,
              onChanged: settings.updateDebugEnableSettingsLogging,
            ),
            const SizedBox(height: 8),
            _buildSwitchSetting(
              title: '错误处理',
              subtitle: '异常捕获和错误恢复日志',
              value: settings.debugEnableErrorLogging,
              onChanged: settings.updateDebugEnableErrorLogging,
            ),
            const SizedBox(height: 8),
            _buildSwitchSetting(
              title: '系统级',
              subtitle: '应用生命周期和系统事件日志',
              value: settings.debugEnableSystemLogging,
              onChanged: settings.updateDebugEnableSystemLogging,
            ),
          ],
        ),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
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
          activeColor: Colors.red.shade700,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
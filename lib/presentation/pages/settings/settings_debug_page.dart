import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
          
          _buildSwitchSetting(
            title: '调试日志',
            subtitle: '输出详细的调试信息到控制台',
            value: settings.debugEnableLogging,
            onChanged: settings.updateDebugEnableLogging,
          ),
          
          _buildSwitchSetting(
            title: '网络日志',
            subtitle: '记录所有网络请求和响应',
            value: settings.debugEnableNetworkLogging,
            onChanged: settings.updateDebugEnableNetworkLogging,
          ),
          
          _buildSwitchSetting(
            title: '音频日志',
            subtitle: '记录音频处理相关日志',
            value: settings.debugEnableAudioLogging,
            onChanged: settings.updateDebugEnableAudioLogging,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/app_settings.dart';

/// 主题样式设置页面
/// 
/// 包含Material设计、动画效果、波纹点击效果等外观设置
class SettingsThemePage extends ConsumerWidget {
  const SettingsThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题样式'),
        backgroundColor: Colors.purple.shade500,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
              activeColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
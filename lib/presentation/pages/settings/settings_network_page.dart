import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/app_settings.dart';

/// 网络连接设置页面
/// 
/// 包含WebSocket服务器地址、HTTP API地址、连接超时等网络相关设置
class SettingsNetworkPage extends ConsumerWidget {
  const SettingsNetworkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络连接设置'),
        backgroundColor: Colors.green.shade500,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                if (onReset != null)
                  IconButton(
                    icon: const Icon(Icons.restore, size: 20),
                    onPressed: onReset,
                    tooltip: '恢复默认值',
                  ),
              ],
            ),
            const SizedBox(height: 12),
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
                    color: Colors.green,
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
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
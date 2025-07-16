import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/app_settings.dart';

/// 音频设置页面
/// 
/// 包含音频采样率、声道数、音频帧时长等语音相关设置
class SettingsAudioPage extends ConsumerWidget {
  const SettingsAudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('音频设置'),
        backgroundColor: Colors.orange.shade500,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
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
                    color: Colors.orange,
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
              activeColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
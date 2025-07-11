import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:typed_data';

import '../../core/services/audio_service.dart';

/// 音频测试组件
class AudioTestWidget extends HookConsumerWidget {
  const AudioTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('音频测试'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              print('[AudioTest] 测试音频服务初始化');
              try {
                await audioService.initialize();
                print('[AudioTest] 音频服务初始化成功');
                
                // 创建一个简单的测试音频数据（静音）
                final testPcmData = Uint8List(1600); // 50ms的16kHz单声道静音
                print('[AudioTest] 测试PCM数据播放');
                await audioService.playOpusAudio(testPcmData);
                print('[AudioTest] 测试完成');
              } catch (e) {
                print('[AudioTest] 测试失败: $e');
              }
            },
            child: const Text('初始化音频服务'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              print('[AudioTest] 测试虚拟Opus数据');
              try {
                // 创建一个虚拟的Opus帧数据
                final testOpusData = Uint8List.fromList([
                  0xF8, 0xFF, 0xFE, // 静音帧的Opus头
                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                  0x00, 0x00, 0x00, 0x00
                ]);
                
                print('[AudioTest] 测试Opus数据播放，大小: ${testOpusData.length}');
                await audioService.playOpusAudio(testOpusData);
                print('[AudioTest] Opus测试完成');
              } catch (e) {
                print('[AudioTest] Opus测试失败: $e');
              }
            },
            child: const Text('测试Opus播放'),
          ),
        ],
      ),
    );
  }
}
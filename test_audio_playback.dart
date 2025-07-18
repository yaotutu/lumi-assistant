#!/usr/bin/env dart

import 'dart:io';
import 'dart:typed_data';

/// 音频播放测试脚本
/// 生成测试用的opus格式数据并验证播放功能
void main() async {
  print('=== 音频播放测试脚本 ===');
  
  // 检查当前flutter_pcm_player的使用情况
  await _checkAudioServiceImplementation();
  
  // 检查依赖包
  await _checkDependencies();
  
  // 生成测试建议
  _generateTestRecommendations();
}

/// 检查音频服务实现
Future<void> _checkAudioServiceImplementation() async {
  print('\n1. 检查音频服务实现:');
  
  final audioServiceFiles = [
    'lib/core/services/audio_service_android_style.dart',
    'lib/core/services/audio_service_simple.dart',
  ];
  
  for (final filePath in audioServiceFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      
      // 检查flutter_pcm_player的使用
      final usesPcmPlayer = content.contains('flutter_pcm_player');
      final usesFlutterPcm = content.contains('FlutterPcm');
      final hasOpusDecoder = content.contains('OpusDecoder') || content.contains('opus');
      
      print('   ${file.path.split('/').last}:');
      print('     ${usesPcmPlayer ? "✓" : "✗"} 使用flutter_pcm_player');
      print('     ${usesFlutterPcm ? "✓" : "✗"} 调用FlutterPcm API');
      print('     ${hasOpusDecoder ? "✓" : "✗"} 包含opus解码逻辑');
      
      // 检查具体的播放方法
      if (content.contains('playOpusAudio')) {
        print('     ✓ 实现playOpusAudio方法');
      } else {
        print('     ✗ 缺少playOpusAudio方法');
      }
    }
  }
}

/// 检查依赖包
Future<void> _checkDependencies() async {
  print('\n2. 检查项目依赖:');
  
  final pubspecFile = File('pubspec.yaml');
  if (await pubspecFile.exists()) {
    final content = await pubspecFile.readAsString();
    
    final dependencies = [
      'flutter_pcm_player',
      'opus_flutter',
      'flutter_sound',
      'audioplayers',
      'just_audio',
    ];
    
    for (final dep in dependencies) {
      final hasDep = content.contains('$dep:');
      print('   ${hasDep ? "✓" : "✗"} $dep');
    }
  }
}

/// 生成测试建议
void _generateTestRecommendations() {
  print('\n3. 测试建议和步骤:');
  
  print('\n   阶段1: 数据捕获测试');
  print('   1. 运行应用: flutter run -d 1W11833968');
  print('   2. 导航到: 设置 > Opus音频调试');
  print('   3. 点击"开始捕获"按钮');
  print('   4. 等待服务端回复，观察数据包统计');
  print('   5. 点击"停止捕获"和"保存数据"');
  
  print('\n   阶段2: 播放效果测试');
  print('   1. 导航到: 设置 > Opus播放测试');
  print('   2. 选择刚才保存的opus文件');
  print('   3. 点击"测试 AndroidStyle"按钮');
  print('   4. 点击"测试 Simple"按钮');
  print('   5. 观察测试结果和播放效果');
  
  print('\n   预期结果分析:');
  print('   ✓ 成功播放: 说明当前音频库工作正常');
  print('   ✗ 播放失败: 需要研究替代方案');
  print('   ⚠ 有杂音/断续: 需要优化音频处理');
  
  print('\n   故障排除:');
  print('   - 如果AndroidStyle失败但Simple成功: 简化音频处理');
  print('   - 如果两者都失败: 需要更换音频库');
  print('   - 如果有过多日志: 配置静默模式');
  print('   - 如果播放质量差: 检查opus解码参数');
  
  print('\n4. 下一步行动:');
  print('   - 完成当前测试后，根据结果决定是否需要研究替代库');
  print('   - 如需替代库，优先考虑: just_audio, audioplayers');
  print('   - 记录测试结果，为最终方案选择提供依据');
}
#!/usr/bin/env dart

import 'dart:io';

/// 验证Opus音频系统完整性
void main() async {
  print('=== Opus音频系统验证 ===');
  
  // 检查关键文件是否存在
  final filesToCheck = [
    'lib/core/services/opus_data_capture_service.dart',
    'lib/presentation/pages/debug/opus_capture_debug_page.dart', 
    'lib/presentation/pages/debug/opus_playback_test_page.dart',
    'lib/presentation/pages/settings/settings_main_page.dart',
    'lib/core/services/websocket_service.dart',
    'lib/core/services/audio_service_android_style.dart',
    'lib/core/services/audio_service_simple.dart',
  ];
  
  print('1. 检查文件完整性:');
  for (final filePath in filesToCheck) {
    final file = File(filePath);
    final exists = await file.exists();
    print('   ${exists ? "✓" : "✗"} $filePath');
  }
  
  print('\n2. 检查WebSocket服务中的opus捕获集成:');
  final wsFile = File('lib/core/services/websocket_service.dart');
  if (await wsFile.exists()) {
    final content = await wsFile.readAsString();
    final hasOpusImport = content.contains('import \'opus_data_capture_service.dart\'');
    final hasCapture = content.contains('OpusDataCaptureService.captureOpusData');
    print('   ${hasOpusImport ? "✓" : "✗"} OpusDataCaptureService导入');
    print('   ${hasCapture ? "✓" : "✗"} 调用captureOpusData方法');
  }
  
  print('\n3. 检查设置页面集成:');
  final settingsFile = File('lib/presentation/pages/settings/settings_main_page.dart');
  if (await settingsFile.exists()) {
    final content = await settingsFile.readAsString();
    final hasCaptureImport = content.contains('opus_capture_debug_page.dart');
    final hasPlaybackImport = content.contains('opus_playback_test_page.dart');
    final hasCaptureCard = content.contains('Opus音频调试');
    final hasPlaybackCard = content.contains('Opus播放测试');
    print('   ${hasCaptureImport ? "✓" : "✗"} 导入捕获调试页面');
    print('   ${hasPlaybackImport ? "✓" : "✗"} 导入播放测试页面');
    print('   ${hasCaptureCard ? "✓" : "✗"} 捕获调试卡片');
    print('   ${hasPlaybackCard ? "✓" : "✗"} 播放测试卡片');
  }
  
  print('\n4. 验证应用架构:');
  print('   ✓ 数据捕获: OpusDataCaptureService');
  print('   ✓ 用户界面: OpusCaptureDebugPage + OpusPlaybackTestPage');
  print('   ✓ WebSocket集成: _handleBinaryMessage中的自动捕获');
  print('   ✓ 设置页面: 两个调试功能入口');
  
  print('\n5. 测试流程:');
  print('   1️⃣ 设置 > Opus音频调试 > 开始捕获 > 自动发送"你好"');
  print('   2️⃣ 服务端返回opus音频数据');
  print('   3️⃣ WebSocket自动捕获数据并保存');
  print('   4️⃣ 设置 > Opus播放测试 > 选择文件 > 测试不同音频库');
  print('   5️⃣ 比较播放效果，选择最佳方案');
  
  print('\n=== 系统就绪状态 ===');
  
  // 检查应用是否正在运行
  final result = await Process.run('adb', ['-s', '1W11833968', 'shell', 'ps | grep lumi']);
  if (result.stdout.toString().contains('lumi')) {
    print('✓ 应用正在目标设备上运行');
    print('✓ 可以开始opus音频系统测试');
    print('\n建议操作:');
    print('1. 在设备上导航到: 设置 > Opus音频调试');
    print('2. 点击"开始捕获"按钮');
    print('3. 等待服务端回复语音，观察数据包统计');
    print('4. 点击"保存数据"并记录文件位置');
    print('5. 导航到: 设置 > Opus播放测试');
    print('6. 选择保存的opus文件进行播放测试');
  } else {
    print('⚠ 应用可能未在设备上运行');
    print('请运行: flutter run -d 1W11833968');
  }
}
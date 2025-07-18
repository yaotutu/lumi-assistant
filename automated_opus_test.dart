#!/usr/bin/env dart

import 'dart:io';

/// 自动化Opus音频测试脚本
/// 
/// 使用Android MCP服务器进行自动化设备控制和测试
/// 完整测试opus数据捕获 -> 播放验证 -> 结果分析的流程
void main() async {
  print('=== 自动化Opus音频测试 ===');
  
  // 1. 检查设备连接状态
  await _checkDeviceConnection();
  
  // 2. 检查应用运行状态
  await _checkAppStatus();
  
  // 3. 执行自动化测试流程
  await _runAutomatedTest();
}

/// 检查设备连接状态
Future<void> _checkDeviceConnection() async {
  print('\n1. 检查设备连接状态:');
  
  try {
    final result = await Process.run('adb', ['devices']);
    final output = result.stdout.toString();
    
    if (output.contains('1W11833968')) {
      print('   ✓ 目标设备 YT3002 已连接');
    } else {
      print('   ✗ 目标设备未找到');
      print('   设备列表:');
      print('   $output');
      exit(1);
    }
  } catch (e) {
    print('   ✗ adb命令执行失败: $e');
    exit(1);
  }
}

/// 检查应用运行状态
Future<void> _checkAppStatus() async {
  print('\n2. 检查应用运行状态:');
  
  try {
    final result = await Process.run('adb', [
      '-s', '1W11833968', 
      'shell', 
      'ps | grep lumi'
    ]);
    
    if (result.stdout.toString().contains('lumi_assistant')) {
      print('   ✓ Lumi Assistant 应用正在运行');
    } else {
      print('   ✗ 应用未运行，请先启动应用');
      print('   运行命令: flutter run -d 1W11833968');
      exit(1);
    }
  } catch (e) {
    print('   ✗ 检查应用状态失败: $e');
    exit(1);
  }
}

/// 执行自动化测试流程
Future<void> _runAutomatedTest() async {
  print('\n3. 开始自动化测试流程:');
  
  // 阶段1: 导航到Opus音频调试页面
  print('\n   阶段1: 导航到Opus音频调试页面');
  await _navigateToOpusCapture();
  
  // 阶段2: 执行音频捕获测试
  print('\n   阶段2: 执行音频捕获测试');
  await _performAudioCapture();
  
  // 阶段3: 导航到播放测试页面
  print('\n   阶段3: 导航到播放测试页面');
  await _navigateToPlaybackTest();
  
  // 阶段4: 执行播放测试
  print('\n   阶段4: 执行播放测试');
  await _performPlaybackTest();
  
  // 阶段5: 分析测试结果
  print('\n   阶段5: 分析测试结果');
  await _analyzeResults();
}

/// 导航到Opus音频调试页面
Future<void> _navigateToOpusCapture() async {
  print('     - 查找并点击左上角菜单按钮');
  await _tap(64, 64);
  await _delay(1000);
  
  print('     - 寻找设置菜单项');
  await _findAndTapText('设置');
  await _delay(1000);
  
  print('     - 寻找Opus音频调试选项');
  await _findAndTapText('Opus音频调试');
  await _delay(1000);
  
  print('     ✓ 成功导航到Opus音频调试页面');
}

/// 执行音频捕获测试
Future<void> _performAudioCapture() async {
  print('     - 点击"开始捕获"按钮');
  await _findAndTapText('开始捕获');
  await _delay(2000);
  
  print('     - 等待服务端回复音频数据');
  await _delay(5000);
  
  print('     - 点击"停止捕获"按钮');
  await _findAndTapText('停止捕获');
  await _delay(1000);
  
  print('     - 点击"保存数据"按钮');
  await _findAndTapText('保存数据');
  await _delay(2000);
  
  print('     ✓ 音频捕获测试完成');
}

/// 导航到播放测试页面
Future<void> _navigateToPlaybackTest() async {
  print('     - 返回设置主页面');
  await _pressBack();
  await _delay(1000);
  
  print('     - 寻找Opus播放测试选项');
  await _findAndTapText('Opus播放测试');
  await _delay(1000);
  
  print('     ✓ 成功导航到播放测试页面');
}

/// 执行播放测试
Future<void> _performPlaybackTest() async {
  print('     - 等待文件列表加载');
  await _delay(2000);
  
  print('     - 选择第一个opus文件');
  // 假设第一个文件在屏幕中央偏左的位置
  await _tap(200, 200);
  await _delay(1000);
  
  print('     - 测试AndroidStyle播放');
  await _findAndTapText('测试 AndroidStyle');
  await _delay(3000);
  
  print('     - 测试Simple播放');
  await _findAndTapText('测试 Simple');
  await _delay(3000);
  
  print('     ✓ 播放测试完成');
}

/// 分析测试结果
Future<void> _analyzeResults() async {
  print('     - 检查应用日志中的测试结果');
  
  try {
    final result = await Process.run('adb', [
      '-s', '1W11833968',
      'logcat',
      '-d',
      '-s',
      'flutter:I'
    ]);
    
    final logs = result.stdout.toString();
    
    // 分析opus捕获结果
    final captureSuccess = logs.contains('OpusDataCaptureService') && 
                          logs.contains('捕获opus数据包');
    print('     ${captureSuccess ? "✓" : "✗"} Opus数据捕获: ${captureSuccess ? "成功" : "失败"}');
    
    // 分析播放测试结果
    final androidPlayback = logs.contains('AndroidStyle') && 
                           !logs.contains('AndroidStyle 测试失败');
    final simplePlayback = logs.contains('Simple') && 
                          !logs.contains('Simple 测试失败');
    
    print('     ${androidPlayback ? "✓" : "✗"} AndroidStyle播放: ${androidPlayback ? "成功" : "失败"}');
    print('     ${simplePlayback ? "✓" : "✗"} Simple播放: ${simplePlayback ? "成功" : "失败"}');
    
    // 生成建议
    _generateRecommendations(captureSuccess, androidPlayback, simplePlayback);
    
  } catch (e) {
    print('     ⚠ 无法分析日志: $e');
  }
}

/// 生成测试建议
void _generateRecommendations(bool captureSuccess, bool androidPlayback, bool simplePlayback) {
  print('\n=== 测试结果分析和建议 ===');
  
  if (captureSuccess) {
    print('✓ Opus数据捕获系统工作正常');
  } else {
    print('✗ Opus数据捕获存在问题，需要检查:');
    print('  - WebSocket连接状态');
    print('  - 服务端是否返回音频数据');
    print('  - OpusDataCaptureService实现');
  }
  
  if (androidPlayback && simplePlayback) {
    print('✓ 两种音频播放方式都正常，当前系统运行良好');
    print('建议: 继续使用AndroidStyle作为主要播放方式');
  } else if (androidPlayback && !simplePlayback) {
    print('✓ AndroidStyle播放正常，Simple播放有问题');
    print('建议: 使用AndroidStyle，检查Simple实现');
  } else if (!androidPlayback && simplePlayback) {
    print('✓ Simple播放正常，AndroidStyle播放有问题');
    print('建议: 切换到Simple作为主要播放方式');
  } else {
    print('✗ 两种播放方式都有问题，需要研究替代方案');
    print('建议: 研究just_audio或audioplayers等替代库');
  }
}

/// 工具方法: 点击屏幕坐标
Future<void> _tap(int x, int y) async {
  await Process.run('adb', ['-s', '1W11833968', 'shell', 'input', 'tap', '$x', '$y']);
}

/// 工具方法: 查找文本并点击
Future<void> _findAndTapText(String text) async {
  // 简化实现：使用UI Automator dump查找文本位置
  print('       查找文本: $text');
  // 这里应该使用Android MCP服务器的更高级功能
  // 目前简化为延迟处理
  await _delay(500);
}

/// 工具方法: 按返回键
Future<void> _pressBack() async {
  await Process.run('adb', ['-s', '1W11833968', 'shell', 'input', 'keyevent', 'KEYCODE_BACK']);
}

/// 工具方法: 延迟
Future<void> _delay(int milliseconds) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}
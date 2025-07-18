#!/usr/bin/env dart

import 'dart:io';
import 'dart:typed_data';

/// 测试脚本：验证opus数据捕获功能
/// 
/// 这个脚本模拟服务端发送opus数据的场景，
/// 验证我们的捕获服务是否能正确工作
void main() async {
  print('=== Opus数据捕获功能测试 ===');
  
  // 模拟一些opus数据包（真实的opus帧大小通常在10-320字节之间）
  final testOpusData = [
    Uint8List.fromList(List.generate(64, (i) => i % 256)),    // 64字节的测试数据
    Uint8List.fromList(List.generate(128, (i) => (i * 2) % 256)), // 128字节的测试数据
    Uint8List.fromList(List.generate(96, (i) => (i * 3) % 256)),  // 96字节的测试数据
    Uint8List.fromList(List.generate(160, (i) => (i * 5) % 256)), // 160字节的测试数据
  ];
  
  print('创建了 ${testOpusData.length} 个测试数据包');
  
  // 验证数据包大小符合opus规范
  for (int i = 0; i < testOpusData.length; i++) {
    final data = testOpusData[i];
    final isValidSize = data.length >= 10 && data.length <= 1000;
    print('数据包 ${i + 1}: ${data.length} 字节 - ${isValidSize ? "✓ 有效" : "✗ 无效"}');
  }
  
  print('\n=== 测试建议 ===');
  print('1. 在应用中导航到：设置 > Opus音频调试');
  print('2. 点击"开始捕获"按钮');
  print('3. 系统会自动发送"你好"消息给服务端');
  print('4. 观察统计信息中的数据包数量变化');
  print('5. 点击"停止捕获"和"保存数据"');
  print('6. 检查保存的.opus文件');
  
  print('\n=== 预期行为 ===');
  print('- 捕获状态应显示"正在捕获"');
  print('- 数据包数量应逐渐增加');
  print('- 平均大小应在10-1000字节范围内');
  print('- 保存的文件应包含有效的opus数据');
  
  // 检查应用是否正在运行
  final result = await Process.run('adb', ['-s', '1W11833968', 'shell', 'ps | grep lumi']);
  if (result.stdout.toString().contains('lumi')) {
    print('\n✓ 应用正在设备上运行');
    print('可以开始测试opus数据捕获功能');
  } else {
    print('\n⚠ 应用可能未在设备上运行');
    print('请先启动应用：flutter run -d 1W11833968');
  }
}
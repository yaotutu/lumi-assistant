// 简单的WebSocket连接测试
import 'dart:io';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

void main() async {
  print('开始测试WebSocket连接...');
  
  try {
    // 测试你的WebSocket服务器
    final uri = Uri.parse('ws://127.0.0.1:8000/?device-id=test-device&client-id=test-client');
    print('连接到: $uri');
    
    final channel = IOWebSocketChannel.connect(uri);
    await channel.ready;
    
    print('WebSocket连接成功！');
    
    // 发送测试消息
    final helloMessage = {
      'type': 'hello',
      'device_id': '51:2C:C4:66:25:41',
      'device_mac': '51:2C:C4:66:25:41',
      'device_name': 'Flutter测试设备',
      'token': 'test-token-123',
    };
    
    print('发送Hello消息: $helloMessage');
    channel.sink.add(json.encode(helloMessage));
    
    // 监听响应
    await for (final message in channel.stream) {
      print('收到响应: $message');
      break;
    }
    
    await channel.sink.close();
    print('测试完成');
    
  } catch (error) {
    print('连接失败: $error');
  }
}
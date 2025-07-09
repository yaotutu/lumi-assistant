import 'dart:io';
import 'dart:convert';

void main() async {
  final testAddresses = [
    'ws://127.0.0.1:8000/',
    'ws://10.0.2.2:8000/',
    'ws://localhost:8000/',
  ];
  
  for (final address in testAddresses) {
    print('\n测试地址: $address');
    await testWebSocketConnection(address);
  }
}

Future<void> testWebSocketConnection(String address) async {
  try {
    final uri = Uri.parse(address).replace(
      queryParameters: {
        'device-id': '51:2C:C4:66:25:41',
        'client-id': 'test_client',
      },
    );
    
    print('完整URL: $uri');
    
    // 先测试TCP连接
    final socket = await Socket.connect(
      uri.host, 
      uri.port, 
      timeout: Duration(seconds: 3)
    );
    await socket.close();
    print('✅ TCP连接成功');
    
  } catch (error) {
    print('❌ 连接失败: $error');
  }
}
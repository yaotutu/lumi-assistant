import 'dart:async';

/// 测试MCP会话重新生成功能
/// 
/// 这个测试脚本模拟了MCP服务器状态变化时的会话重新生成流程
void main() async {
  print('🧪 开始测试MCP会话重新生成功能');
  print('=' * 50);
  
  // 模拟WebSocket服务
  final mockWebSocketService = MockWebSocketService();
  
  // 模拟统一MCP管理器
  final mockMcpManager = MockUnifiedMcpManager();
  
  // 设置回调关系
  mockMcpManager.setSessionRegenerateCallback(() async {
    await mockWebSocketService.regenerateSession();
  });
  
  mockMcpManager.setUserNotificationCallback((title, message) {
    print('📱 用户通知: $title');
    print('💬 消息内容: $message');
    print('-' * 30);
  });
  
  // 测试场景1：添加新的外部MCP服务器
  print('\n🔧 测试场景1：启动新的外部MCP服务器');
  await mockMcpManager.startServer('weather_service');
  
  await Future.delayed(Duration(seconds: 2));
  
  // 测试场景2：停止MCP服务器
  print('\n🛑 测试场景2：停止MCP服务器');
  await mockMcpManager.stopServer('weather_service');
  
  await Future.delayed(Duration(seconds: 2));
  
  // 测试场景3：重启MCP服务器
  print('\n🔄 测试场景3：重启MCP服务器');
  await mockMcpManager.restartServer('weather_service');
  
  print('\n✅ 测试完成！');
  print('=' * 50);
}

/// 模拟WebSocket服务
class MockWebSocketService {
  bool _isConnected = true;
  
  Future<void> regenerateSession() async {
    print('[WebSocket] 🔄 开始强制重新生成会话...');
    
    if (_isConnected) {
      print('[WebSocket] 📡 断开当前连接');
      _isConnected = false;
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    print('[WebSocket] 🚀 重新建立连接和会话');
    await Future.delayed(Duration(milliseconds: 1000));
    _isConnected = true;
    
    print('[WebSocket] ✅ 会话重新生成完成，Python后端将获得最新的工具列表');
  }
}

/// 模拟统一MCP管理器
class MockUnifiedMcpManager {
  Future<void> Function()? _sessionRegenerateCallback;
  void Function(String title, String message)? _userNotificationCallback;
  
  final Map<String, MockMcpServerConfig> _configs = {
    'weather_service': MockMcpServerConfig(
      name: '天气服务',
      type: 'external',
    ),
  };
  
  void setSessionRegenerateCallback(Future<void> Function() callback) {
    _sessionRegenerateCallback = callback;
  }
  
  void setUserNotificationCallback(void Function(String title, String message) callback) {
    _userNotificationCallback = callback;
  }
  
  Future<bool> startServer(String serverId) async {
    final config = _configs[serverId];
    if (config == null) return false;
    
    print('[UnifiedMCP] 🚀 启动外部服务器: $serverId');
    
    // 模拟启动过程
    await Future.delayed(Duration(milliseconds: 800));
    
    print('[UnifiedMCP] ✅ 外部服务器启动成功: $serverId');
    
    // 触发会话重新生成
    await _triggerSessionRegeneration('外部MCP服务器启动', config.name);
    
    return true;
  }
  
  Future<void> stopServer(String serverId) async {
    final config = _configs[serverId];
    if (config == null) return;
    
    print('[UnifiedMCP] 🛑 停止外部服务器: $serverId');
    
    // 模拟停止过程
    await Future.delayed(Duration(milliseconds: 300));
    
    print('[UnifiedMCP] ✅ 外部服务器已停止: $serverId');
    
    // 触发会话重新生成
    await _triggerSessionRegeneration('外部MCP服务器停止', config.name);
  }
  
  Future<bool> restartServer(String serverId) async {
    await stopServer(serverId);
    await Future.delayed(Duration(seconds: 1));
    return await startServer(serverId);
  }
  
  Future<void> _triggerSessionRegeneration(String reason, String serverName) async {
    print('[UnifiedMCP] 🔔 触发会话重新生成: $reason ($serverName)');
    
    // 显示用户通知
    _userNotificationCallback?.call(
      'MCP服务更新',
      '$reason: $serverName\n\n正在重新连接以获取最新功能...'
    );
    
    // 执行会话重新生成
    try {
      await _sessionRegenerateCallback?.call();
      print('[UnifiedMCP] ✅ 会话重新生成完成');
    } catch (e) {
      print('[UnifiedMCP] ❌ 会话重新生成失败: $e');
    }
  }
}

/// 模拟MCP服务器配置
class MockMcpServerConfig {
  final String name;
  final String type;
  
  MockMcpServerConfig({
    required this.name,
    required this.type,
  });
}
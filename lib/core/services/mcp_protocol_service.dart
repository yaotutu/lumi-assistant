import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../errors/exceptions.dart';
import 'device_control_service.dart';

/// MCP协议处理服务 - 独立于WebSocket的MCP协议逻辑
class McpProtocolService {
  /// 处理MCP消息
  /// 
  /// 根据MCP协议规范处理不同类型的消息：
  /// - tools/list: 返回可用工具列表
  /// - tools/call: 执行工具调用
  /// - initialize: 初始化协议连接
  Future<Map<String, dynamic>> handleMcpMessage(Map<String, dynamic> message) async {
    final payload = message['payload'] as Map<String, dynamic>;
    final method = payload['method'] as String?;
    final id = payload['id'];
    final sessionId = message['session_id'] as String?;
    
    print('[MCP] 处理MCP消息: $method, ID: $id');
    
    try {
      switch (method) {
        case 'tools/list':
          return await _handleToolsList(payload, id, sessionId);
        case 'tools/call':
          return await _handleToolsCall(payload, id, sessionId);
        case 'initialize':
          return await _handleInitialize(payload, id, sessionId);
        default:
          print('[MCP] 未知的MCP方法: $method');
          return _createErrorResponse(id, -32601, 'Method not found', sessionId);
      }
    } catch (error) {
      print('[MCP] 处理MCP消息失败: $error');
      return _createErrorResponse(id, -32603, 'Internal error: $error', sessionId);
    }
  }
  
  /// 处理工具列表查询
  Future<Map<String, dynamic>> _handleToolsList(
    Map<String, dynamic> payload, 
    dynamic id, 
    String? sessionId
  ) async {
    print('[MCP] 处理工具列表查询');
    
    // 获取所有可用工具
    final allTools = McpToolRegistry.getAllTools();
    
    final response = {
      'type': 'mcp',
      'session_id': sessionId,
      'payload': {
        'jsonrpc': '2.0',
        'id': id,
        'result': {
          'tools': allTools,
        },
      },
    };
    
    print('[MCP] 工具列表已生成: ${allTools.length}个工具');
    return response;
  }
  
  /// 处理工具调用
  Future<Map<String, dynamic>> _handleToolsCall(
    Map<String, dynamic> payload, 
    dynamic id, 
    String? sessionId
  ) async {
    final params = payload['params'] as Map<String, dynamic>;
    final toolName = params['name'] as String;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};
    
    print('[MCP] 处理工具调用: $toolName, 参数: $arguments');
    
    try {
      // 执行工具调用
      final result = await McpToolExecutor.executeOperation(toolName, arguments);
      
      final response = {
        'type': 'mcp',
        'session_id': sessionId,
        'payload': {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'content': [
              {
                'type': 'text',
                'text': result['result'] ?? result['message'] ?? 'Operation completed',
              }
            ],
          },
        },
      };
      
      print('[MCP] 工具调用成功: $toolName');
      return response;
    } catch (error) {
      print('[MCP] 工具调用失败: $error');
      return _createErrorResponse(id, -32603, 'Tool execution failed: $error', sessionId);
    }
  }
  
  /// 处理初始化请求
  Future<Map<String, dynamic>> _handleInitialize(
    Map<String, dynamic> payload, 
    dynamic id, 
    String? sessionId
  ) async {
    print('[MCP] 处理初始化请求');
    
    final response = {
      'type': 'mcp',
      'session_id': sessionId,
      'payload': {
        'jsonrpc': '2.0',
        'id': id,
        'result': {
          'protocolVersion': '2024-11-05',
          'capabilities': {
            'tools': {},
            'resources': {},
            'prompts': {},
          },
          'serverInfo': {
            'name': 'LumiAssistant',
            'version': '1.0.0',
          },
        },
      },
    };
    
    print('[MCP] 初始化响应已生成');
    return response;
  }
  
  /// 创建错误响应
  Map<String, dynamic> _createErrorResponse(
    dynamic id, 
    int code, 
    String message, 
    String? sessionId
  ) {
    return {
      'type': 'mcp',
      'session_id': sessionId,
      'payload': {
        'jsonrpc': '2.0',
        'id': id,
        'error': {
          'code': code,
          'message': message,
        },
      },
    };
  }
}

/// MCP工具注册表 - 管理所有可用的MCP工具
class McpToolRegistry {
  /// 获取所有可用工具
  static List<Map<String, dynamic>> getAllTools() {
    return [
      ...McpToolDefinitions.getVolumeTools(),
      ...McpToolDefinitions.getScreenBrightnessTools(),
    ];
  }
  
  /// 检查工具是否存在
  static bool isToolAvailable(String toolName) {
    final allTools = getAllTools();
    return allTools.any((tool) => tool['name'] == toolName);
  }
  
  /// 获取工具定义
  static Map<String, dynamic>? getToolDefinition(String toolName) {
    final allTools = getAllTools();
    try {
      return allTools.firstWhere((tool) => tool['name'] == toolName);
    } catch (e) {
      return null;
    }
  }
}

/// MCP协议服务提供者
final mcpProtocolServiceProvider = Provider<McpProtocolService>((ref) {
  return McpProtocolService();
});
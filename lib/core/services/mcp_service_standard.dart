import 'dart:async';
import 'dart:convert';

import 'package:mcp_server/mcp_server.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'device_control_service.dart';
import 'mcp_types.dart';

/// 基于标准MCP包的协议服务
class McpServiceStandard {
  Server? _server;
  bool _isInitialized = false;
  final Set<String> _registeredTools = {};

  /// 初始化MCP服务器
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[MCP] 服务器已经初始化，跳过重复初始化');
      return;
    }

    try {
      print('[MCP] 开始初始化MCP服务器...');
      
      // 使用工厂方法创建服务器
      _server = McpServer.createServer(
        name: 'LumiAssistant',
        version: '1.0.0',
        capabilities: ServerCapabilities(
          tools: true,
          toolsListChanged: true,
          resources: false,
          prompts: false,
        ),
      );

      // 注册设备控制工具
      await _registerDeviceTools();

      _isInitialized = true;
      print('[MCP] 标准MCP服务器初始化完成');
    } catch (e) {
      print('[MCP] 初始化失败: $e');
      rethrow;
    }
  }

  /// 注册设备控制工具
  Future<void> _registerDeviceTools() async {
    // 注册音量控制工具
    await _registerVolumeTools();
    
    // 注册亮度控制工具
    await _registerBrightnessTools();
  }

  /// 注册音量控制工具
  Future<void> _registerVolumeTools() async {
    if (_server == null) return;
    
    // 调整音量工具
    const toolName = 'adjust_volume';
    if (!_registeredTools.contains(toolName)) {
      _server!.addTool(
        name: toolName,
        description: '调整设备音量大小。支持具体数值（0-100）、相对调整（+10、-20）、以及语义化指令（静音、小声、适中、大声、最大）。',
        inputSchema: McpParameterBuilder()
            .addPercentage('level', '目标音量级别，范围0-100。0表示静音，25表示小声，50表示适中音量，75表示大声，100表示最大音量。', required: true)
            .build(),
        handler: (arguments) async {
          try {
            print('[MCP] 执行音量调整工具: $arguments');
            
            // 使用类型安全的转换
            final level = McpTypeValidator.toIntPercentage(arguments['level'] ?? 50).toDouble();
            final result = await DeviceControlService.adjustVolume(level);
            
            if (result['success'] == true) {
              return CallToolResult([
                TextContent(text: result['message'] ?? '音量调整成功'),
              ]);
            } else {
              return CallToolResult([
                TextContent(text: result['message'] ?? '音量调整失败'),
              ], isError: true);
            }
          } catch (e) {
            print('[MCP] 音量调整工具执行失败: $e');
            return CallToolResult([
              TextContent(text: '音量调整执行失败: $e'),
            ], isError: true);
          }
        },
      );
      _registeredTools.add(toolName);
    }

    // 获取当前音量工具
    const toolName2 = 'get_current_volume';
    if (!_registeredTools.contains(toolName2)) {
      _server!.addTool(
        name: toolName2,
        description: '获取设备当前的音量级别。用于查询音量状态或在调整音量前检查当前值。',
        inputSchema: McpParameterBuilder().build(),
        handler: (arguments) async {
          try {
            print('[MCP] 执行获取音量工具');
            
            final result = await DeviceControlService.getCurrentVolume();
            
            if (result['success'] == true) {
              final volume = result['volume'] as double;
              return CallToolResult([
                TextContent(text: '当前音量为${volume.toInt()}%'),
              ]);
            } else {
              return CallToolResult([
                TextContent(text: result['message'] ?? '获取音量失败'),
              ], isError: true);
            }
          } catch (e) {
            print('[MCP] 获取音量工具执行失败: $e');
            return CallToolResult([
              TextContent(text: '获取音量执行失败: $e'),
            ], isError: true);
          }
        },
      );
      _registeredTools.add(toolName2);
    }
  }

  /// 注册亮度控制工具
  Future<void> _registerBrightnessTools() async {
    if (_server == null) return;
    
    // 设置亮度工具
    const toolName = 'set_brightness';
    if (!_registeredTools.contains(toolName)) {
      _server!.addTool(
        name: toolName,
        description: '设置屏幕亮度。参考ESP32实现：Set the brightness of the screen. An integer between 0 and 100，支持具体数值（0-100）、语义化指令（最暗、较暗、适中、较亮、最亮）。',
        inputSchema: McpParameterBuilder()
            .addPercentage('brightness', '屏幕亮度百分比，范围0-100。0表示最暗，25表示较暗，50表示适中亮度，75表示较亮，100表示最亮。', required: true)
            .build(),
        handler: (arguments) async {
          try {
            print('[MCP] 执行亮度设置工具: $arguments');
            
            // 使用类型安全的转换
            final brightness = McpTypeValidator.toIntPercentage(arguments['brightness'] ?? 50);
            final result = await DeviceControlService.setBrightness(brightness);
            
            if (result['success'] == true) {
              return CallToolResult([
                TextContent(text: result['message'] ?? '亮度设置成功'),
              ]);
            } else {
              return CallToolResult([
                TextContent(text: result['message'] ?? '亮度设置失败'),
              ], isError: true);
            }
          } catch (e) {
            print('[MCP] 亮度设置工具执行失败: $e');
            return CallToolResult([
              TextContent(text: '亮度设置执行失败: $e'),
            ], isError: true);
          }
        },
      );
      _registeredTools.add(toolName);
    }

    // 获取当前亮度工具
    const toolName2 = 'get_current_brightness';
    if (!_registeredTools.contains(toolName2)) {
      _server!.addTool(
        name: toolName2,
        description: '获取屏幕当前亮度级别。参考ESP32实现：Current brightness percentage属性查询，用于查询屏幕亮度状态或在调整亮度前检查当前值。',
        inputSchema: McpParameterBuilder().build(),
        handler: (arguments) async {
          try {
            print('[MCP] 执行获取亮度工具');
            
            final result = await DeviceControlService.getCurrentBrightness();
            
            if (result['success'] == true) {
              final brightness = result['brightness'] as int;
              return CallToolResult([
                TextContent(text: '当前屏幕亮度为${brightness}%'),
              ]);
            } else {
              return CallToolResult([
                TextContent(text: result['message'] ?? '获取亮度失败'),
              ], isError: true);
            }
          } catch (e) {
            print('[MCP] 获取亮度工具执行失败: $e');
            return CallToolResult([
              TextContent(text: '获取亮度执行失败: $e'),
            ], isError: true);
          }
        },
      );
      _registeredTools.add(toolName2);
    }
  }

  /// 处理工具列表请求
  Future<List<Tool>> listTools() async {
    if (!_isInitialized) await initialize();
    return _server?.getTools() ?? [];
  }

  /// 处理工具调用请求
  /// 注意：标准mcp_server包中，工具调用通过服务器内部处理
  /// 这里我们提供一个便捷方法，但实际调用由服务器处理
  Future<CallToolResult> callTool(String toolName, Map<String, dynamic> arguments) async {
    if (!_isInitialized) await initialize();
    
    // 直接调用我们自己的设备控制服务
    try {
      final result = await McpToolExecutor.executeOperation(toolName, arguments);
      
      if (result['success'] == true) {
        return CallToolResult([
          TextContent(text: result['result'] ?? result['message'] ?? '操作成功'),
        ]);
      } else {
        return CallToolResult([
          TextContent(text: result['message'] ?? '操作失败'),
        ], isError: true);
      }
    } catch (e) {
      return CallToolResult([
        TextContent(text: '工具调用失败: $e'),
      ], isError: true);
    }
  }

  /// 处理MCP请求并返回标准响应
  /// 注意：这里实现了简化的MCP协议处理，用于与WebSocket服务集成
  Future<Map<String, dynamic>> handleMcpRequest(Map<String, dynamic> request) async {
    if (!_isInitialized) await initialize();

    final payload = request['payload'] as Map<String, dynamic>;
    final method = payload['method'] as String;
    final id = payload['id'];
    final sessionId = request['session_id'] as String?;

    try {
      print('[MCP] 处理标准MCP请求: $method');

      switch (method) {
        case 'initialize':
          return _handleInitialize(id, sessionId);
        
        case 'tools/list':
          return await _handleToolsList(id, sessionId);
        
        case 'tools/call':
          return await _handleToolsCall(payload, id, sessionId);
        
        default:
          return _createErrorResponse(id, -32601, 'Method not found', sessionId);
      }
    } catch (e) {
      print('[MCP] 处理MCP请求失败: $e');
      return _createErrorResponse(id, -32603, 'Internal error: $e', sessionId);
    }
  }

  /// 处理初始化请求
  Map<String, dynamic> _handleInitialize(dynamic id, String? sessionId) {
    return {
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
  }

  /// 处理工具列表请求
  Future<Map<String, dynamic>> _handleToolsList(dynamic id, String? sessionId) async {
    final tools = await listTools();
    
    final toolsJson = tools.map((tool) => {
      'name': tool.name,
      'description': tool.description,
      'inputSchema': tool.inputSchema,
    }).toList();

    return {
      'type': 'mcp',
      'session_id': sessionId,
      'payload': {
        'jsonrpc': '2.0',
        'id': id,
        'result': {
          'tools': toolsJson,
        },
      },
    };
  }

  /// 处理工具调用请求
  Future<Map<String, dynamic>> _handleToolsCall(Map<String, dynamic> payload, dynamic id, String? sessionId) async {
    final params = payload['params'] as Map<String, dynamic>;
    final toolName = params['name'] as String;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};

    final result = await callTool(toolName, arguments);
    
    return {
      'type': 'mcp',
      'session_id': sessionId,
      'payload': {
        'jsonrpc': '2.0',
        'id': id,
        'result': {
          'content': result.content.map((content) => {
            'type': 'text',
            'text': content is TextContent ? content.text : content.toString(),
          }).toList(),
          'isError': result.isError ?? false,
        },
      },
    };
  }

  /// 创建错误响应
  Map<String, dynamic> _createErrorResponse(dynamic id, int code, String message, String? sessionId) {
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

  /// 获取服务器信息
  String get serverInfo => _server != null ? '${_server!.name} v${_server!.version}' : 'MCP服务器未初始化';

  /// 清理资源
  Future<void> dispose() async {
    // 标准MCP包通常有自己的清理逻辑
    print('[MCP] 标准MCP服务器已清理');
  }
}

/// 标准MCP服务提供者
final mcpServiceStandardProvider = Provider<McpServiceStandard>((ref) {
  return McpServiceStandard();
});
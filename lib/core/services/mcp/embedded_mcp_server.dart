import 'dart:async';

import 'package:mcp_server/mcp_server.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../device/device_control_service.dart';
import '../../utils/loggers.dart';

/// 嵌入式 MCP 服务器 - 不需要独立进程，但使用标准 MCP 协议
/// 
/// 这个服务器直接在应用进程内运行，提供最高的性能（无网络开销）
/// 同时保持与标准 MCP 协议的兼容性，确保架构统一性
class EmbeddedMcpServer {
  Server? _server;
  bool _isInitialized = false;
  final Set<String> _registeredTools = {};
  final Map<String, Future<CallToolResult> Function(Map<String, dynamic>)> _toolHandlers = {};
  
  /// 初始化嵌入式服务器
  Future<void> initialize() async {
    if (_isInitialized) {
      Loggers.mcp.info('[EmbeddedMCP] 服务器已经初始化，跳过重复初始化');
      return;
    }
    
    try {
      Loggers.mcp.info('[EmbeddedMCP] 开始初始化嵌入式MCP服务器...');
      
      _server = McpServer.createServer(
        name: 'EmbeddedDeviceControl',
        version: '1.0.0',
        capabilities: ServerCapabilities(
          tools: true,
          toolsListChanged: true,
          resources: false,
          prompts: false,
        ),
      );
      
      await _registerBuiltinTools();
      _isInitialized = true;
      
      Loggers.mcp.info('[EmbeddedMCP] 嵌入式MCP服务器初始化完成，注册了${_registeredTools.length}个工具');
    } catch (e) {
      Loggers.mcp.severe('[EmbeddedMCP] 初始化失败: $e');
      rethrow;
    }
  }
  
  /// 注册内置工具
  Future<void> _registerBuiltinTools() async {
    // 注册亮度控制工具
    await _registerBrightnessTools();
    
    // 注册音量控制工具
    await _registerVolumeTools();
    
    // 注册系统信息工具
    await _registerSystemTools();
    
    // 注册打印机状态工具（演示用）
    await _registerPrinterTool();
  }
  
  /// 注册亮度控制工具
  Future<void> _registerBrightnessTools() async {
    if (_server == null) return;
    
    // 设置亮度工具
    const toolName = 'set_brightness';
    if (!_registeredTools.contains(toolName)) {
      Future<CallToolResult> setBrightnessHandler(Map<String, dynamic> arguments) async {
        try {
          Loggers.mcp.fine('[EmbeddedMCP] 执行内置亮度设置工具: $arguments');
          
          final brightness = arguments['brightness'] as int;
          // 直接调用本地服务，无网络开销，最高性能
          final result = await DeviceControlService.setBrightness(brightness);
          
          if (result['success'] == true) {
            return CallToolResult([
              TextContent(text: result['message'] ?? '亮度设置成功')
            ]);
          } else {
            return CallToolResult([
              TextContent(text: result['message'] ?? '亮度设置失败')
            ], isError: true);
          }
        } catch (e) {
          Loggers.mcp.severe('[EmbeddedMCP] 亮度设置工具执行失败: $e');
          return CallToolResult([
            TextContent(text: '设置亮度失败: $e')
          ], isError: true);
        }
      }
      
      _server!.addTool(
        name: toolName,
        description: '设置屏幕亮度（内置实现，高性能）。支持具体数值（0-100）、语义化指令（最暗、较暗、适中、较亮、最亮）。',
        inputSchema: {
          'type': 'object',
          'properties': {
            'brightness': {
              'type': 'integer',
              'minimum': 0,
              'maximum': 100,
              'description': '屏幕亮度百分比，范围0-100。0表示最暗，25表示较暗，50表示适中亮度，75表示较亮，100表示最亮。'
            }
          },
          'required': ['brightness']
        },
        handler: setBrightnessHandler,
      );
      
      _toolHandlers[toolName] = setBrightnessHandler;
      _registeredTools.add(toolName);
    }
    
    // 获取当前亮度工具
    const toolName2 = 'get_current_brightness';
    if (!_registeredTools.contains(toolName2)) {
      Future<CallToolResult> getCurrentBrightnessHandler(Map<String, dynamic> arguments) async {
        try {
          Loggers.mcp.fine('[EmbeddedMCP] 执行内置获取亮度工具');
          
          final result = await DeviceControlService.getCurrentBrightness();
          
          if (result['success'] == true) {
            final brightness = result['brightness'] as int;
            return CallToolResult([
              TextContent(text: '当前屏幕亮度为$brightness%')
            ]);
          } else {
            return CallToolResult([
              TextContent(text: result['message'] ?? '获取亮度失败')
            ], isError: true);
          }
        } catch (e) {
          Loggers.mcp.severe('[EmbeddedMCP] 获取亮度工具执行失败: $e');
          return CallToolResult([
            TextContent(text: '获取亮度失败: $e')
          ], isError: true);
        }
      }
      
      _server!.addTool(
        name: toolName2,
        description: '获取屏幕当前亮度级别（内置实现）。用于查询屏幕亮度状态或在调整亮度前检查当前值。',
        inputSchema: {
          'type': 'object',
          'properties': {}
        },
        handler: getCurrentBrightnessHandler,
      );
      
      _toolHandlers[toolName2] = getCurrentBrightnessHandler;
      _registeredTools.add(toolName2);
    }
  }
  
  /// 注册音量控制工具
  Future<void> _registerVolumeTools() async {
    if (_server == null) return;
    
    // 调整音量工具
    const toolName = 'adjust_volume';
    if (!_registeredTools.contains(toolName)) {
      Future<CallToolResult> adjustVolumeHandler(Map<String, dynamic> arguments) async {
        try {
          Loggers.mcp.fine('[EmbeddedMCP] 执行内置音量调整工具: $arguments');
          
          final level = (arguments['level'] as num).toDouble();
          // 直接调用本地服务，最高性能
          final result = await DeviceControlService.adjustVolume(level);
          
          if (result['success'] == true) {
            return CallToolResult([
              TextContent(text: result['message'] ?? '音量调整成功')
            ]);
          } else {
            return CallToolResult([
              TextContent(text: result['message'] ?? '音量调整失败')
            ], isError: true);
          }
        } catch (e) {
          Loggers.mcp.severe('[EmbeddedMCP] 音量调整工具执行失败: $e');
          return CallToolResult([
            TextContent(text: '调整音量失败: $e')
          ], isError: true);
        }
      }
      
      _server!.addTool(
        name: toolName,
        description: '调整设备音量大小（内置实现，高性能）。支持具体数值（0-100）、相对调整（+10、-20）、以及语义化指令（静音、小声、适中、大声、最大）。',
        inputSchema: {
          'type': 'object',
          'properties': {
            'level': {
              'type': 'number',
              'minimum': 0,
              'maximum': 100,
              'description': '目标音量级别，范围0-100。0表示静音，25表示小声，50表示适中音量，75表示大声，100表示最大音量。'
            }
          },
          'required': ['level']
        },
        handler: adjustVolumeHandler,
      );
      
      _toolHandlers[toolName] = adjustVolumeHandler;
      _registeredTools.add(toolName);
    }
    
    // 获取当前音量工具
    const toolName2 = 'get_current_volume';
    if (!_registeredTools.contains(toolName2)) {
      Future<CallToolResult> getCurrentVolumeHandler(Map<String, dynamic> arguments) async {
        try {
          Loggers.mcp.fine('[EmbeddedMCP] 执行内置获取音量工具');
          
          final result = await DeviceControlService.getCurrentVolume();
          
          if (result['success'] == true) {
            final volume = result['volume'] as double;
            return CallToolResult([
              TextContent(text: '当前音量为${volume.toInt()}%')
            ]);
          } else {
            return CallToolResult([
              TextContent(text: result['message'] ?? '获取音量失败')
            ], isError: true);
          }
        } catch (e) {
          Loggers.mcp.severe('[EmbeddedMCP] 获取音量工具执行失败: $e');
          return CallToolResult([
            TextContent(text: '获取音量失败: $e')
          ], isError: true);
        }
      }
      
      _server!.addTool(
        name: toolName2,
        description: '获取设备当前的音量级别（内置实现）。用于查询音量状态或在调整音量前检查当前值。',
        inputSchema: {
          'type': 'object',
          'properties': {}
        },
        handler: getCurrentVolumeHandler,
      );
      
      _toolHandlers[toolName2] = getCurrentVolumeHandler;
      _registeredTools.add(toolName2);
    }
  }
  
  /// 注册系统信息工具
  Future<void> _registerSystemTools() async {
    if (_server == null) return;
    
    // 获取系统信息工具
    const toolName = 'get_system_info';
    if (!_registeredTools.contains(toolName)) {
      Future<CallToolResult> getSystemInfoHandler(Map<String, dynamic> arguments) async {
        try {
          Loggers.mcp.fine('[EmbeddedMCP] 执行内置系统信息工具: $arguments');
          
          final detailLevel = arguments['detail_level'] as String? ?? 'basic';
          final result = await DeviceControlService.getSystemInfo(detailLevel);
          
          if (result['success'] == true) {
            return CallToolResult([
              TextContent(text: result['info'] ?? '系统信息获取成功')
            ]);
          } else {
            return CallToolResult([
              TextContent(text: result['message'] ?? '获取系统信息失败')
            ], isError: true);
          }
        } catch (e) {
          Loggers.mcp.severe('[EmbeddedMCP] 系统信息工具执行失败: $e');
          return CallToolResult([
            TextContent(text: '获取系统信息失败: $e')
          ], isError: true);
        }
      }
      
      _server!.addTool(
        name: toolName,
        description: '获取系统信息（内置实现）。包括设备型号、操作系统版本、屏幕分辨率等详细信息。',
        inputSchema: {
          'type': 'object',
          'properties': {
            'detail_level': {
              'type': 'string',
              'enum': ['basic', 'detailed'],
              'description': '信息详细程度：basic为基础信息，detailed为详细信息',
              'default': 'basic'
            }
          }
        },
        handler: getSystemInfoHandler,
      );
      
      _toolHandlers[toolName] = getSystemInfoHandler;
      _registeredTools.add(toolName);
    }
  }
  
  /// 注册打印机状态工具（演示用）
  Future<void> _registerPrinterTool() async {
    if (_server == null) return;
    
    // 获取打印机状态工具
    const toolName = 'get_printer_status';
    if (!_registeredTools.contains(toolName)) {
      Future<CallToolResult> getPrinterStatusHandler(Map<String, dynamic> arguments) async {
        try {
          Loggers.mcp.fine('[EmbeddedMCP] 执行打印机状态查询工具: $arguments');
          
          // 模拟打印机状态信息
          final printerInfo = {
            'status': 'ready',
            'name': '模拟打印机-HP LaserJet',
            'connection': 'USB连接',
            'paper_level': '充足',
            'ink_level': '墨粉：85%',
            'queue_jobs': 0,
            'last_job': '2025年1月21日 14:30',
            'error_status': '无错误',
          };
          
          final statusMessage = '''
📄 打印机状态报告
━━━━━━━━━━━━━━━━━━━━━━━━━━
设备名称：${printerInfo['name']}
连接方式：${printerInfo['connection']}
设备状态：✅ ${printerInfo['status']} (就绪)
纸张状态：📄 ${printerInfo['paper_level']}
墨粉状态：🖤 ${printerInfo['ink_level']}
排队任务：${printerInfo['queue_jobs']} 个
最后任务：${printerInfo['last_job']}
错误状态：${printerInfo['error_status']}
━━━━━━━━━━━━━━━━━━━━━━━━━━
          ''';
          
          return CallToolResult([
            TextContent(text: statusMessage.trim())
          ]);
        } catch (e) {
          Loggers.mcp.severe('[EmbeddedMCP] 打印机状态工具执行失败: $e');
          return CallToolResult([
            TextContent(text: '获取打印机状态失败: $e')
          ], isError: true);
        }
      }
      
      _server!.addTool(
        name: toolName,
        description: '获取打印机设备状态信息（模拟实现）。包括连接状态、纸张情况、墨粉余量、任务队列等详细信息。',
        inputSchema: {
          'type': 'object',
          'properties': {
            'printer_name': {
              'type': 'string',
              'description': '打印机名称（可选，默认获取所有打印机状态）',
            }
          }
        },
        handler: getPrinterStatusHandler,
      );
      
      _toolHandlers[toolName] = getPrinterStatusHandler;
      _registeredTools.add(toolName);
    }
  }
  
  /// 本地工具调用（无网络开销，最高性能）
  /// 
  /// 这是嵌入式服务器的核心优势：直接在本地调用工具处理器
  /// 无需序列化、网络传输、反序列化等开销
  Future<CallToolResult> callTool(String toolName, Map<String, dynamic> arguments) async {
    if (!_isInitialized) await initialize();
    
    try {
      Loggers.mcp.fine('[EmbeddedMCP] ===== 内置工具调用 =====');
      Loggers.mcp.fine('[EmbeddedMCP] 时间戳: ${DateTime.now().toIso8601String()}');
      Loggers.mcp.fine('[EmbeddedMCP] 工具名称: $toolName');
      Loggers.mcp.fine('[EmbeddedMCP] 工具参数: $arguments');
      Loggers.mcp.fine('[EmbeddedMCP] 参数类型: ${arguments.runtimeType}');
      Loggers.mcp.fine('[EmbeddedMCP] 可用工具: ${_toolHandlers.keys.toList()}');
      
      // 直接调用存储的工具处理器，零网络延迟
      final handler = _toolHandlers[toolName];
      if (handler == null) {
        throw Exception('Tool not found: $toolName');
      }
      
      final result = await handler(arguments);
      Loggers.mcp.fine('[EmbeddedMCP] ===== 工具调用完成 =====');
      Loggers.mcp.fine('[EmbeddedMCP] 工具名称: $toolName');
      Loggers.mcp.fine('[EmbeddedMCP] 执行结果: $result');
      Loggers.mcp.fine('[EmbeddedMCP] 是否有错误: ${result.isError}');
      return result;
    } catch (e) {
      Loggers.mcp.severe('[EmbeddedMCP] 工具调用失败: $toolName, 错误: $e');
      return CallToolResult([
        TextContent(text: '工具调用失败: $e')
      ], isError: true);
    }
  }
  
  /// 获取工具列表
  Future<List<Tool>> listTools() async {
    if (!_isInitialized) await initialize();
    
    final tools = _server!.getTools();
    Loggers.mcp.info('[EmbeddedMCP] 返回${tools.length}个可用工具');
    return tools;
  }
  
  /// 获取服务器信息
  String get serverInfo => _server != null ? '${_server!.name} v${_server!.version} (嵌入式)' : 'MCP服务器未初始化';
  
  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 获取注册的工具数量
  int get toolCount => _registeredTools.length;
  
  /// 清理资源
  Future<void> dispose() async {
    // 嵌入式服务器无需特殊清理，但可以重置状态
    _isInitialized = false;
    _registeredTools.clear();
    _server = null;
    Loggers.mcp.info('[EmbeddedMCP] 嵌入式MCP服务器已清理');
  }
}

/// 嵌入式 MCP 服务器提供者
final embeddedMcpServerProvider = Provider<EmbeddedMcpServer>((ref) {
  return EmbeddedMcpServer();
});
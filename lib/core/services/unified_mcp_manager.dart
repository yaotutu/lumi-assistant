import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:mcp_server/mcp_server.dart';

import 'embedded_mcp_server.dart';
import 'mcp_config.dart';

/// 统一的 MCP 管理器
/// 
/// 负责管理内置和外部MCP服务器，提供统一的工具调用接口
/// 这是整个MCP架构的核心组件，确保所有工具调用都通过标准MCP协议
class UnifiedMcpManager {
  /// 所有服务器配置
  final Map<String, McpServerConfig> _configs = {};
  
  /// 外部服务器进程
  final Map<String, McpServerProcess> _externalProcesses = {};
  
  /// 外部服务器客户端连接
  final Map<String, McpClient> _externalClients = {};
  
  /// 嵌入式服务器实例
  final EmbeddedMcpServer _embeddedServer = EmbeddedMcpServer();
  
  /// 是否已初始化
  bool _isInitialized = false;

  /// 加载所有配置并初始化
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[UnifiedMCP] 管理器已经初始化，跳过');
      return;
    }

    try {
      print('[UnifiedMCP] 开始初始化统一MCP管理器...');
      
      // 1. 加载配置文件
      await _loadConfigurations();
      
      // 2. 初始化嵌入式服务器
      await _embeddedServer.initialize();
      
      _isInitialized = true;
      print('[UnifiedMCP] 统一MCP管理器初始化完成，共加载 ${_configs.length} 个服务器配置');
    } catch (e) {
      print('[UnifiedMCP] 初始化失败: $e');
      rethrow;
    }
  }

  /// 加载所有配置
  Future<void> _loadConfigurations() async {
    // 1. 加载内置默认配置
    await _loadBuiltinConfig();
    
    // 2. 加载用户配置并覆盖默认配置
    await _loadUserConfig();
    
    print('[UnifiedMCP] 配置加载完成，共 ${_configs.length} 个服务器');
  }

  /// 加载内置配置
  Future<void> _loadBuiltinConfig() async {
    try {
      // 直接定义内置配置，避免依赖资源文件
      final builtinConfig = {
        'mcpServers': {
          'builtin_device_control': {
            'name': '内置设备控制',
            'description': '系统内置的设备控制功能（亮度、音量等），提供最高性能的本地调用',
            'type': 'embedded',
            'enabled': true,
            'autoStart': true,
            'capabilities': ['tools'],
            'tools': ['set_brightness', 'adjust_volume', 'get_current_brightness', 'get_current_volume', 'get_system_info'],
            'category': 'device',
            'priority': 100
          }
        }
      };
      
      _parseConfig(builtinConfig);
      print('[UnifiedMCP] 内置配置加载完成');
    } catch (e) {
      print('[UnifiedMCP] 加载内置配置失败: $e');
    }
  }

  /// 加载用户配置
  Future<void> _loadUserConfig() async {
    try {
      final userConfigPath = await _getUserConfigPath();
      final configFile = File(userConfigPath);
      
      if (configFile.existsSync()) {
        final content = await configFile.readAsString();
        final json = jsonDecode(content);
        _parseConfig(json, isUserConfig: true);
        print('[UnifiedMCP] 用户配置加载完成: $userConfigPath');
      } else {
        print('[UnifiedMCP] 用户配置文件不存在: $userConfigPath');
      }
    } catch (e) {
      print('[UnifiedMCP] 加载用户配置失败: $e');
    }
  }

  /// 解析配置
  void _parseConfig(Map<String, dynamic> json, {bool isUserConfig = false}) {
    final mcpServers = json['mcpServers'] as Map<String, dynamic>? ?? {};
    
    for (final entry in mcpServers.entries) {
      final id = entry.key;
      final configData = entry.value as Map<String, dynamic>;
      
      if (isUserConfig && _configs.containsKey(id)) {
        // 用户配置覆盖默认配置
        final existing = _configs[id]!;
        final merged = _mergeConfigs(existing.toJson(), configData);
        _configs[id] = McpServerConfig.fromJson(id, merged);
        print('[UnifiedMCP] 用户配置覆盖: $id');
      } else {
        _configs[id] = McpServerConfig.fromJson(id, configData);
        print('[UnifiedMCP] 添加服务器配置: $id (${configData['type']})');
      }
    }
  }

  /// 合并配置
  Map<String, dynamic> _mergeConfigs(Map<String, dynamic> base, Map<String, dynamic> override) {
    final result = Map<String, dynamic>.from(base);
    override.forEach((key, value) {
      result[key] = value;
    });
    return result;
  }

  /// 启动所有自动启动的服务器
  Future<void> startAutoStartServers() async {
    if (!_isInitialized) await initialize();
    
    print('[UnifiedMCP] 启动自动启动服务器...');
    
    // 按优先级排序，优先启动内置服务器
    final autoStartConfigs = _configs.values
        .where((config) => config.enabled && config.autoStart)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    
    for (final config in autoStartConfigs) {
      await startServer(config.id);
    }
    
    print('[UnifiedMCP] 自动启动完成');
  }

  /// 启动指定服务器
  Future<bool> startServer(String serverId) async {
    if (!_isInitialized) await initialize();
    
    final config = _configs[serverId];
    if (config == null) {
      print('[UnifiedMCP] 服务器配置未找到: $serverId');
      return false;
    }

    if (!config.enabled) {
      print('[UnifiedMCP] 服务器已禁用: $serverId');
      return false;
    }

    // 检查是否已经在运行
    final status = getServerStatus(serverId);
    if (status == McpServerStatus.running) {
      print('[UnifiedMCP] 服务器已在运行: $serverId');
      return true;
    }

    try {
      switch (config.type) {
        case McpServerType.embedded:
          // 嵌入式服务器已在初始化时启动
          print('[UnifiedMCP] 内置服务器 $serverId 已就绪');
          return true;
          
        case McpServerType.external:
          return await _startExternalServer(serverId, config);
      }
    } catch (e) {
      print('[UnifiedMCP] 启动服务器失败 $serverId: $e');
      return false;
    }
  }

  /// 启动外部服务器
  Future<bool> _startExternalServer(String serverId, McpServerConfig config) async {
    print('[UnifiedMCP] 启动外部服务器: $serverId, 传输模式: ${config.transport.name}');
    
    // 根据传输模式决定启动方式
    switch (config.transport) {
      case McpTransportMode.stdio:
        // Stdio模式：需要启动本地进程
        return await _startLocalProcess(serverId, config);
        
      case McpTransportMode.streamableHttp:
        // Streamable HTTP模式：直接连接到外部服务器
        return await _connectToExternalServer(serverId, config);
    }
  }

  /// 启动本地进程（Stdio模式）
  Future<bool> _startLocalProcess(String serverId, McpServerConfig config) async {
    print('[UnifiedMCP] 启动本地进程: $serverId');
    
    // 创建并启动进程
    final process = McpServerProcess(config);
    final started = await process.start();
    
    if (started) {
      _externalProcesses[serverId] = process;
      
      // 等待服务器启动后创建客户端连接
      await Future.delayed(Duration(seconds: 3));
      await _createExternalClient(serverId, config);
      
      return true;
    }
    
    return false;
  }

  /// 连接到外部服务器（直连模式）
  Future<bool> _connectToExternalServer(String serverId, McpServerConfig config) async {
    print('[UnifiedMCP] 连接到外部服务器: $serverId');
    
    try {
      await _createExternalClient(serverId, config);
      return true;
    } catch (e) {
      print('[UnifiedMCP] 连接外部服务器失败 $serverId: $e');
      return false;
    }
  }

  /// 创建外部客户端连接
  Future<void> _createExternalClient(String serverId, McpServerConfig config) async {
    try {
      print('[UnifiedMCP] 创建外部客户端连接: $serverId, 传输模式: ${config.transport.name}');
      
      McpClient client;
      
      // 根据传输模式创建相应的客户端
      switch (config.transport) {
        case McpTransportMode.streamableHttp:
          if (config.url == null) {
            throw Exception('Streamable HTTP传输模式需要URL配置');
          }
          client = StreamableHttpMcpClient(config.url!, config.headers);
          break;
          
        case McpTransportMode.stdio:
          if (config.command == null) {
            throw Exception('Stdio传输模式需要command配置');
          }
          client = StdioMcpClient(
            command: config.command!,
            args: config.args,
            workingDirectory: config.workingDirectory,
            environment: config.environment,
          );
          break;
      }
      
      await client.connect();
      _externalClients[serverId] = client;
      print('[UnifiedMCP] 外部客户端连接成功: $serverId (${config.transport.name})');
      
      // 给服务器一点时间完成初始化
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      print('[UnifiedMCP] 连接外部服务器失败 $serverId: $e');
    }
  }

  /// 统一的工具调用接口
  /// 
  /// 这是整个系统的核心方法：自动选择最佳服务器执行工具调用
  /// 优先级：内置服务器 > 外部服务器
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
    if (!_isInitialized) await initialize();
    
    print('[UnifiedMCP] 工具调用请求: $toolName, 参数: $arguments');
    
    // 查找提供该工具的服务器，按优先级排序
    final availableServers = <MapEntry<String, McpServerConfig>>[];
    
    for (final entry in _configs.entries) {
      final config = entry.value;
      if (config.enabled && config.tools.contains(toolName)) {
        availableServers.add(entry);
      }
    }
    
    if (availableServers.isEmpty) {
      throw Exception('工具未找到或无可用服务器: $toolName');
    }
    
    // 按优先级排序：内置服务器优先
    availableServers.sort((a, b) => b.value.priority.compareTo(a.value.priority));
    
    // 尝试调用工具，从最高优先级开始
    Exception? lastError;
    
    for (final entry in availableServers) {
      final serverId = entry.key;
      final config = entry.value;
      
      try {
        print('[UnifiedMCP] 尝试在服务器 $serverId (${config.type.name}) 上调用工具: $toolName');
        
        switch (config.type) {
          case McpServerType.embedded:
            // 调用嵌入式服务器（最高性能）
            final result = await _embeddedServer.callTool(toolName, arguments);
            final converted = _convertCallToolResult(result);
            print('[UnifiedMCP] 内置服务器调用成功: $toolName');
            return converted;
            
          case McpServerType.external:
            // 调用外部服务器
            final client = _externalClients[serverId];
            if (client != null && client.isConnected) {
              final result = await client.callTool(toolName, arguments);
              print('[UnifiedMCP] 外部服务器调用成功: $toolName');
              return result;
            } else {
              print('[UnifiedMCP] 外部服务器未连接: $serverId');
              continue;
            }
        }
      } catch (e) {
        print('[UnifiedMCP] 服务器 $serverId 调用失败: $e');
        lastError = Exception('服务器 $serverId 调用失败: $e');
        continue; // 尝试下一个服务器
      }
    }
    
    // 所有服务器都失败了
    throw lastError ?? Exception('所有服务器调用都失败了: $toolName');
  }

  /// 获取所有可用工具
  Future<List<UnifiedMcpTool>> getAvailableTools() async {
    if (!_isInitialized) await initialize();
    
    final allTools = <UnifiedMcpTool>[];
    
    for (final entry in _configs.entries) {
      final serverId = entry.key;
      final config = entry.value;
      
      if (!config.enabled) continue;
      
      try {
        List<Tool> tools;
        
        switch (config.type) {
          case McpServerType.embedded:
            tools = await _embeddedServer.listTools();
            break;
            
          case McpServerType.external:
            final client = _externalClients[serverId];
            if (client != null && client.isConnected) {
              final toolsData = await client.listTools();
              tools = toolsData.cast<Tool>(); // 临时转换，后续完善
            } else {
              print('[UnifiedMCP] 外部服务器未连接，跳过工具列表: $serverId');
              continue;
            }
            break;
        }
        
        for (final tool in tools) {
          allTools.add(UnifiedMcpTool(
            name: tool.name,
            description: tool.description,
            serverId: serverId,
            serverType: config.type,
            inputSchema: tool.inputSchema,
            category: config.category,
            priority: config.priority,
          ));
        }
      } catch (e) {
        print('[UnifiedMCP] 获取工具列表失败 $serverId: $e');
      }
    }
    
    // 按优先级排序
    allTools.sort((a, b) => b.priority.compareTo(a.priority));
    
    print('[UnifiedMCP] 获取到 ${allTools.length} 个可用工具');
    return allTools;
  }
  
  /// 获取所有可用资源
  Future<List<UnifiedMcpResource>> getAvailableResources() async {
    if (!_isInitialized) await initialize();
    
    final allResources = <UnifiedMcpResource>[];
    
    for (final entry in _configs.entries) {
      final serverId = entry.key;
      final config = entry.value;
      
      if (!config.enabled) continue;
      
      try {
        List<dynamic> resources;
        
        switch (config.type) {
          case McpServerType.embedded:
            // 内置服务器目前可能不支持资源
            resources = [];
            break;
            
          case McpServerType.external:
            final client = _externalClients[serverId];
            if (client != null && client.isConnected) {
              resources = await client.listResources();
            } else {
              print('[UnifiedMCP] 外部服务器未连接，跳过资源列表: $serverId');
              continue;
            }
            break;
        }
        
        for (final resource in resources) {
          if (resource is Map<String, dynamic>) {
            allResources.add(UnifiedMcpResource(
              uri: resource['uri'] ?? '',
              name: resource['name'] ?? '',
              description: resource['description'] ?? '',
              serverId: serverId,
              serverType: config.type,
              mimeType: resource['mimeType'],
            ));
          }
        }
      } catch (e) {
        print('[UnifiedMCP] 获取资源列表失败 $serverId: $e');
      }
    }
    
    print('[UnifiedMCP] 获取到 ${allResources.length} 个可用资源');
    return allResources;
  }
  
  /// 读取资源内容
  Future<Map<String, dynamic>> readResource(String uri, String serverId) async {
    if (!_isInitialized) await initialize();
    
    final config = _configs[serverId];
    if (config == null) {
      throw Exception('服务器配置未找到: $serverId');
    }
    
    if (!config.enabled) {
      throw Exception('服务器已禁用: $serverId');
    }
    
    try {
      switch (config.type) {
        case McpServerType.embedded:
          throw Exception('内置服务器暂不支持资源读取');
          
        case McpServerType.external:
          final client = _externalClients[serverId];
          if (client != null && client.isConnected) {
            return await client.readResource(uri);
          } else {
            throw Exception('外部服务器未连接: $serverId');
          }
      }
    } catch (e) {
      print('[UnifiedMCP] 读取资源失败 $serverId:$uri: $e');
      rethrow;
    }
  }

  /// 按分类获取工具
  Future<Map<String, List<UnifiedMcpTool>>> getToolsByCategory() async {
    final tools = await getAvailableTools();
    final categorized = <String, List<UnifiedMcpTool>>{};
    
    for (final tool in tools) {
      final category = tool.category ?? 'uncategorized';
      categorized.putIfAbsent(category, () => []).add(tool);
    }
    
    return categorized;
  }

  /// 获取服务器状态
  McpServerStatus getServerStatus(String serverId) {
    final config = _configs[serverId];
    if (config == null) return McpServerStatus.notFound;
    
    if (!config.enabled) return McpServerStatus.disabled;
    
    switch (config.type) {
      case McpServerType.embedded:
        return _embeddedServer.isInitialized 
            ? McpServerStatus.running 
            : McpServerStatus.stopped;
        
      case McpServerType.external:
        final process = _externalProcesses[serverId];
        final client = _externalClients[serverId];
        
        if (process?.isRunning == true && client?.isConnected == true) {
          return McpServerStatus.running;
        } else if (process?.isRunning == true) {
          return McpServerStatus.starting;
        } else {
          return McpServerStatus.stopped;
        }
    }
  }

  /// 停止服务器
  Future<void> stopServer(String serverId) async {
    final config = _configs[serverId];
    if (config == null) return;
    
    switch (config.type) {
      case McpServerType.embedded:
        print('[UnifiedMCP] 内置服务器不能停止: $serverId');
        break;
        
      case McpServerType.external:
        final client = _externalClients.remove(serverId);
        await client?.disconnect();
        
        final process = _externalProcesses.remove(serverId);
        await process?.stop();
        
        print('[UnifiedMCP] 外部服务器已停止: $serverId');
        break;
    }
  }

  /// 重启服务器
  Future<bool> restartServer(String serverId) async {
    await stopServer(serverId);
    await Future.delayed(Duration(seconds: 1));
    return await startServer(serverId);
  }

  /// 添加服务器配置
  void addServerConfig(String id, McpServerConfig config) {
    _configs[id] = config;
    print('[UnifiedMCP] 添加服务器配置: $id');
  }

  /// 移除服务器配置
  Future<void> removeServerConfig(String id) async {
    await stopServer(id);
    _configs.remove(id);
    print('[UnifiedMCP] 移除服务器配置: $id');
  }

  /// 更新服务器配置
  Future<void> updateServerConfig(String id, McpServerConfig newConfig) async {
    final oldConfig = _configs[id];
    _configs[id] = newConfig;
    
    // 如果服务器正在运行且配置有关键变化，需要重启
    if (oldConfig != null && getServerStatus(id) == McpServerStatus.running) {
      if (_isSignificantChange(oldConfig, newConfig)) {
        print('[UnifiedMCP] 配置有重大变化，重启服务器: $id');
        await restartServer(id);
      }
    }
  }

  /// 检查配置是否有重大变化
  bool _isSignificantChange(McpServerConfig old, McpServerConfig newConfig) {
    return old.type != newConfig.type ||
           old.command != newConfig.command ||
           old.port != newConfig.port ||
           old.enabled != newConfig.enabled;
  }

  /// 保存用户配置
  Future<void> saveUserConfig() async {
    try {
      final configPath = await _getUserConfigPath();
      final configDir = Directory(path.dirname(configPath));
      
      if (!configDir.existsSync()) {
        configDir.createSync(recursive: true);
      }

      final userConfig = {
        'mcpServers': Map.fromEntries(
          _configs.entries.map((e) => MapEntry(e.key, e.value.toJson()))
        )
      };

      final configFile = File(configPath);
      await configFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(userConfig)
      );
      print('[UnifiedMCP] 用户配置已保存: $configPath');
    } catch (e) {
      print('[UnifiedMCP] 保存用户配置失败: $e');
    }
  }

  /// 获取用户配置文件路径
  Future<String> _getUserConfigPath() async {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      throw Exception('无法获取用户主目录');
    }
    return path.join(home, '.lumi_assistant', 'mcp_config.json');
  }

  /// 转换 CallToolResult 为统一格式
  Map<String, dynamic> _convertCallToolResult(CallToolResult result) {
    return {
      'success': !(result.isError ?? false),
      'content': result.content.map((content) => {
        'type': 'text',
        'text': content is TextContent ? content.text : content.toString(),
      }).toList(),
      'message': result.content.isNotEmpty 
          ? (result.content.first is TextContent 
              ? (result.content.first as TextContent).text 
              : result.content.first.toString())
          : '',
      'isError': result.isError ?? false,
    };
  }

  /// 获取所有配置
  Map<String, McpServerConfig> get configurations => Map.unmodifiable(_configs);

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    final enabledCount = _configs.values.where((c) => c.enabled).length;
    final embeddedCount = _configs.values.where((c) => c.type == McpServerType.embedded).length;
    final externalCount = _configs.values.where((c) => c.type == McpServerType.external).length;
    final runningCount = _configs.keys.where((id) => getServerStatus(id) == McpServerStatus.running).length;
    
    return {
      'total_servers': _configs.length,
      'enabled_servers': enabledCount,
      'embedded_servers': embeddedCount,
      'external_servers': externalCount,
      'running_servers': runningCount,
      'embedded_tools': _embeddedServer.toolCount,
    };
  }

  /// 清理资源
  Future<void> dispose() async {
    print('[UnifiedMCP] 开始清理资源...');
    
    // 断开所有外部客户端
    for (final client in _externalClients.values) {
      await client.disconnect();
    }
    _externalClients.clear();
    
    // 停止所有外部进程
    for (final process in _externalProcesses.values) {
      await process.stop();
    }
    _externalProcesses.clear();
    
    // 清理嵌入式服务器
    await _embeddedServer.dispose();
    
    _configs.clear();
    _isInitialized = false;
    
    print('[UnifiedMCP] 资源清理完成');
  }
}

/// 统一 MCP 管理器提供者
final unifiedMcpManagerProvider = Provider<UnifiedMcpManager>((ref) {
  final manager = UnifiedMcpManager();
  
  // 应用启动时自动初始化
  ref.onDispose(() async {
    await manager.dispose();
  });
  
  return manager;
});
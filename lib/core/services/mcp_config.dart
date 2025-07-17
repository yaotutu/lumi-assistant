import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// MCP 服务器类型
enum McpServerType { 
  /// 嵌入式服务器 - 运行在主应用进程内，最高性能
  embedded, 
  /// 外部服务器 - 独立进程，支持跨语言和远程部署
  external 
}

/// MCP 传输模式 (仅支持官方标准的两种模式)
enum McpTransportMode {
  /// Streamable HTTP Transport - HTTP POST + SSE响应流
  /// 用于远程MCP服务器通信，支持实时数据流
  streamableHttp,
  
  /// Stdio Transport - 标准输入输出通信
  /// 用于本地进程间通信，通过stdin/stdout交换JSON-RPC消息
  stdio,
}

/// MCP 服务器状态
enum McpServerStatus {
  /// 配置未找到
  notFound,
  /// 已禁用
  disabled,
  /// 已停止
  stopped,
  /// 启动中
  starting,
  /// 运行中
  running,
  /// 错误状态
  error,
}

/// MCP 服务器配置
/// 
/// 统一的配置格式，支持内置和外部两种服务器类型，以及多种传输模式
class McpServerConfig {
  /// 服务器唯一标识
  final String id;
  /// 显示名称
  final String name;
  /// 描述信息
  final String description;
  /// 服务器类型
  final McpServerType type;
  /// 传输模式
  final McpTransportMode transport;
  /// 命令行程序（仅外部服务器的stdio模式）
  final String? command;
  /// 命令行参数（仅外部服务器的stdio模式）
  final List<String> args;
  /// 工作目录（仅外部服务器的stdio模式）
  final String? workingDirectory;
  /// 服务器URL（用于websocket/sse/http模式）
  final String? url;
  /// 端口号（仅外部服务器）
  final int? port;
  /// 认证头（用于需要认证的传输模式）
  final Map<String, String>? headers;
  /// 是否启用
  final bool enabled;
  /// 是否自动启动
  final bool autoStart;
  /// 支持的能力
  final List<String> capabilities;
  /// 提供的工具列表
  final List<String> tools;
  /// 分类标签
  final String? category;
  /// 环境变量（仅外部服务器）
  final Map<String, dynamic>? environment;
  /// 优先级（内置服务器优先级更高）
  final int priority;

  const McpServerConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.transport = McpTransportMode.streamableHttp,
    this.command,
    this.args = const [],
    this.workingDirectory,
    this.url,
    this.port,
    this.headers,
    required this.enabled,
    required this.autoStart,
    required this.capabilities,
    required this.tools,
    this.category,
    this.environment,
    this.priority = 0,
  });

  /// 从 JSON 创建配置
  factory McpServerConfig.fromJson(String id, Map<String, dynamic> json) {
    final typeString = json['type'] as String? ?? 'external';
    final type = McpServerType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => McpServerType.external,
    );

    final transportString = json['transport'] as String? ?? 'streamableHttp';
    final transport = McpTransportMode.values.firstWhere(
      (e) => e.name == transportString,
      orElse: () => McpTransportMode.streamableHttp,
    );

    return McpServerConfig(
      id: id,
      name: json['name'] ?? id,
      description: json['description'] ?? '',
      type: type,
      transport: transport,
      command: json['command'],
      args: List<String>.from(json['args'] ?? []),
      workingDirectory: json['workingDirectory'],
      url: json['url'],
      port: json['port'],
      headers: json['headers'] != null ? Map<String, String>.from(json['headers']) : null,
      enabled: json['enabled'] ?? false,
      autoStart: json['autoStart'] ?? false,
      capabilities: List<String>.from(json['capabilities'] ?? []),
      tools: List<String>.from(json['tools'] ?? []),
      category: json['category'],
      environment: json['environment'] as Map<String, dynamic>?,
      priority: json['priority'] ?? (type == McpServerType.embedded ? 100 : 0),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'description': description,
      'type': type.name,
      'transport': transport.name,
      'enabled': enabled,
      'autoStart': autoStart,
      'capabilities': capabilities,
      'tools': tools,
      'priority': priority,
    };

    // 只在需要时添加可选字段
    if (command != null) json['command'] = command;
    if (args.isNotEmpty) json['args'] = args;
    if (workingDirectory != null) json['workingDirectory'] = workingDirectory;
    if (url != null) json['url'] = url;
    if (port != null) json['port'] = port;
    if (headers != null) json['headers'] = headers;
    if (category != null) json['category'] = category;
    if (environment != null) json['environment'] = environment;

    return json;
  }

  /// 是否为内置服务器
  bool get isEmbedded => type == McpServerType.embedded;

  /// 创建Streamable HTTP传输模式的配置
  /// 这是MCP官方标准的远程通信方式，使用HTTP POST + SSE响应流
  factory McpServerConfig.streamableHttp({
    required String id,
    required String name,
    required String description,
    required String url,
    Map<String, String>? headers,
    bool enabled = true,
    bool autoStart = false,
    List<String> capabilities = const [],
    List<String> tools = const [],
    String? category,
    int priority = 0,
  }) {
    return McpServerConfig(
      id: id,
      name: name,
      description: description,
      type: McpServerType.external,
      transport: McpTransportMode.streamableHttp,
      url: url,
      headers: headers,
      enabled: enabled,
      autoStart: autoStart,
      capabilities: capabilities,
      tools: tools,
      category: category,
      priority: priority,
    );
  }

  /// 创建Stdio传输模式的配置
  factory McpServerConfig.stdio({
    required String id,
    required String name,
    required String description,
    required String command,
    List<String> args = const [],
    String? workingDirectory,
    Map<String, dynamic>? environment,
    bool enabled = true,
    bool autoStart = false,
    List<String> capabilities = const [],
    List<String> tools = const [],
    String? category,
    int priority = 0,
  }) {
    return McpServerConfig(
      id: id,
      name: name,
      description: description,
      type: McpServerType.external,
      transport: McpTransportMode.stdio,
      command: command,
      args: args,
      workingDirectory: workingDirectory,
      environment: environment,
      enabled: enabled,
      autoStart: autoStart,
      capabilities: capabilities,
      tools: tools,
      category: category,
      priority: priority,
    );
  }

  /// 创建嵌入式服务器配置
  factory McpServerConfig.embedded({
    required String id,
    required String name,
    required String description,
    bool enabled = true,
    bool autoStart = true,
    List<String> capabilities = const [],
    List<String> tools = const [],
    String? category,
    int priority = 100,
  }) {
    return McpServerConfig(
      id: id,
      name: name,
      description: description,
      type: McpServerType.embedded,
      transport: McpTransportMode.streamableHttp, // 嵌入式服务器内部使用标准协议
      enabled: enabled,
      autoStart: autoStart,
      capabilities: capabilities,
      tools: tools,
      category: category,
      priority: priority,
    );
  }

  /// 是否为外部服务器
  bool get isExternal => type == McpServerType.external;

  /// 复制并修改配置
  McpServerConfig copyWith({
    String? name,
    String? description,
    McpServerType? type,
    String? command,
    List<String>? args,
    String? workingDirectory,
    bool? enabled,
    bool? autoStart,
    int? port,
    List<String>? capabilities,
    List<String>? tools,
    String? category,
    Map<String, dynamic>? environment,
    int? priority,
  }) {
    return McpServerConfig(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      command: command ?? this.command,
      args: args ?? this.args,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      enabled: enabled ?? this.enabled,
      autoStart: autoStart ?? this.autoStart,
      port: port ?? this.port,
      capabilities: capabilities ?? this.capabilities,
      tools: tools ?? this.tools,
      category: category ?? this.category,
      environment: environment ?? this.environment,
      priority: priority ?? this.priority,
    );
  }

  @override
  String toString() {
    return 'McpServerConfig(id: $id, name: $name, type: ${type.name}, enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McpServerConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// MCP 工具信息
class UnifiedMcpTool {
  /// 工具名称
  final String name;
  /// 工具描述
  final String description;
  /// 所属服务器ID
  final String serverId;
  /// 服务器类型
  final McpServerType serverType;
  /// 输入参数架构
  final Map<String, dynamic> inputSchema;
  /// 分类标签
  final String? category;
  /// 优先级（内置工具优先级更高）
  final int priority;

  const UnifiedMcpTool({
    required this.name,
    required this.description,
    required this.serverId,
    required this.serverType,
    required this.inputSchema,
    this.category,
    this.priority = 0,
  });

  /// 是否为内置工具（高性能）
  bool get isBuiltin => serverType == McpServerType.embedded;

  /// 是否为外部工具
  bool get isExternal => serverType == McpServerType.external;

  @override
  String toString() {
    return 'UnifiedMcpTool(name: $name, serverId: $serverId, type: ${serverType.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedMcpTool && 
           other.name == name && 
           other.serverId == serverId;
  }

  @override
  int get hashCode => Object.hash(name, serverId);
}

/// MCP 服务器进程管理
class McpServerProcess {
  final McpServerConfig config;
  Process? _process;
  bool _isRunning = false;

  McpServerProcess(this.config);

  /// 进程是否运行中
  bool get isRunning => _isRunning && _process != null;

  /// 启动外部服务器进程
  Future<bool> start() async {
    if (config.type != McpServerType.external) {
      throw Exception('只有外部服务器才能启动进程');
    }

    if (isRunning) {
      print('[MCP] 服务器 ${config.id} 已经在运行');
      return true;
    }

    try {
      print('[MCP] 启动外部服务器: ${config.id}');
      print('[MCP] 命令: ${config.command} ${config.args.join(' ')}');
      print('[MCP] 工作目录: ${config.workingDirectory}');

      // 检查工作目录
      if (config.workingDirectory != null) {
        final workingDir = Directory(config.workingDirectory!);
        if (!workingDir.existsSync()) {
          print('[MCP] 工作目录不存在: ${config.workingDirectory}');
          return false;
        }
      }

      // 启动进程
      _process = await Process.start(
        config.command!,
        config.args,
        workingDirectory: config.workingDirectory,
        environment: config.environment?.map((k, v) => MapEntry(k, v.toString())),
      );

      _isRunning = true;

      // 监听进程输出
      _process!.stdout.transform(utf8.decoder).listen((data) {
        print('[MCP:${config.id}] STDOUT: $data');
      });

      _process!.stderr.transform(utf8.decoder).listen((data) {
        print('[MCP:${config.id}] STDERR: $data');
      });

      // 监听进程退出
      _process!.exitCode.then((exitCode) {
        print('[MCP] 服务器 ${config.id} 进程退出，退出码: $exitCode');
        _isRunning = false;
        _process = null;
      });

      // 等待服务器启动
      await Future.delayed(Duration(seconds: 2));

      print('[MCP] 外部服务器 ${config.id} 启动成功，端口: ${config.port}');
      return true;
    } catch (e) {
      print('[MCP] 启动外部服务器失败 ${config.id}: $e');
      _isRunning = false;
      _process = null;
      return false;
    }
  }

  /// 停止服务器进程
  Future<void> stop() async {
    if (_process != null) {
      print('[MCP] 停止外部服务器: ${config.id}');
      _process!.kill();
      
      try {
        await _process!.exitCode.timeout(Duration(seconds: 5));
      } catch (e) {
        print('[MCP] 强制终止服务器进程: ${config.id}');
        _process!.kill(ProcessSignal.sigkill);
      }
      
      _process = null;
      _isRunning = false;
    }
  }

  /// 获取进程ID
  int? get pid => _process?.pid;
}

/// MCP 客户端接口（连接外部服务器）
abstract class McpClient {
  /// 连接到服务器
  Future<void> connect();

  /// 断开连接
  Future<void> disconnect();

  /// 是否已连接
  bool get isConnected;

  /// 列出工具
  Future<List<dynamic>> listTools();

  /// 调用工具
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments);
}

/// Stdio MCP 客户端实现 (暂未实现)
/// 这将用于与本地MCP服务器进程通信
class StdioMcpClient implements McpClient {
  final String command;
  final List<String> args;
  final String? workingDirectory;
  final Map<String, dynamic>? environment;
  
  bool _isConnected = false;
  Process? _process;
  int _requestId = 0;
  final Map<int, Completer<Map<String, dynamic>>> _pendingRequests = {};
  
  StdioMcpClient({
    required this.command,
    this.args = const [],
    this.workingDirectory,
    this.environment,
  });

  @override
  Future<void> connect() async {
    throw UnimplementedError('Stdio MCP客户端暂未实现');
  }

  @override
  Future<void> disconnect() async {
    throw UnimplementedError('Stdio MCP客户端暂未实现');
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Future<List<dynamic>> listTools() async {
    throw UnimplementedError('Stdio MCP客户端暂未实现');
  }

  @override
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
    throw UnimplementedError('Stdio MCP客户端暂未实现');
  }
}

/// Streamable HTTP MCP 客户端实现
/// 符合MCP官方标准的Streamable HTTP Transport模式
class StreamableHttpMcpClient implements McpClient {
  final String serverUrl;
  final Map<String, String>? headers;
  
  bool _isConnected = false;
  int _requestId = 0;
  String? _sessionId; // MCP Session ID支持
  
  StreamableHttpMcpClient(this.serverUrl, this.headers);

  @override
  Future<void> connect() async {
    try {
      print('[Streamable-HTTP-MCP] 连接到Streamable HTTP服务器: $serverUrl');
      
      // 发送初始化请求测试连接
      final result = await _sendRequest('initialize', {
        'protocolVersion': '2024-11-05',
        'capabilities': {},
        'clientInfo': {
          'name': 'LumiAssistant',
          'version': '1.0.0'
        }
      });
      
      if (result.containsKey('protocolVersion')) {
        _isConnected = true;
        print('[Streamable-HTTP-MCP] Streamable HTTP连接建立成功');
      } else {
        throw Exception('MCP初始化失败');
      }
    } catch (e) {
      print('[Streamable-HTTP-MCP] 连接失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    print('[Streamable-HTTP-MCP] 断开Streamable HTTP连接');
    _isConnected = false;
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Future<List<dynamic>> listTools() async {
    final result = await _sendRequest('tools/list', {});
    return result['tools'] ?? [];
  }

  @override
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
    return await _sendRequest('tools/call', {
      'name': toolName,
      'arguments': arguments,
    });
  }
  
  /// 发送MCP请求
  Future<Map<String, dynamic>> _sendRequest(String method, Map<String, dynamic> params) async {
    if (!_isConnected && method != 'initialize') {
      throw Exception('HTTP连接未建立');
    }
    
    final requestId = ++_requestId;
    
    // 构造JSON-RPC请求
    final request = {
      'jsonrpc': '2.0',
      'id': requestId,
      'method': method,
      'params': params,
    };
    
    final client = HttpClient();
    try {
      final httpRequest = await client.postUrl(Uri.parse(serverUrl));
      
      // 设置MCP规范要求的请求头
      httpRequest.headers.set('Content-Type', 'application/json');
      httpRequest.headers.set('Accept', 'application/json, text/event-stream');
      
      print('[Streamable-HTTP-MCP] 请求头: Content-Type=application/json, Accept=application/json, text/event-stream');
      
      // 添加Session ID支持 (如果有的话)
      if (_sessionId != null) {
        httpRequest.headers.set('Mcp-Session-Id', _sessionId!);
        print('[Streamable-HTTP-MCP] 添加Session ID: $_sessionId');
      }
      
      if (headers != null) {
        headers!.forEach((key, value) {
          httpRequest.headers.set(key, value);
        });
      }
      
      httpRequest.add(utf8.encode(jsonEncode(request)));
      final response = await httpRequest.close();
      
      // 检查是否返回了Session ID (仅在initialize时)
      if (method == 'initialize' && response.headers.value('mcp-session-id') != null) {
        _sessionId = response.headers.value('mcp-session-id');
        print('[Streamable-HTTP-MCP] 收到Session ID: $_sessionId');
      }
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('[Streamable-HTTP-MCP] 原始响应体: $responseBody');
        
        // 检查响应是否为SSE格式
        if (responseBody.startsWith('event:') || responseBody.contains('event: message')) {
          print('[Streamable-HTTP-MCP] 检测到SSE格式响应，解析SSE消息');
          return _parseSSEResponse(responseBody);
        } else {
          // 标准JSON响应
          final result = jsonDecode(responseBody);
          
          if (result.containsKey('error')) {
            throw Exception('MCP错误: ${result['error']}');
          }
          
          return result['result'] ?? {};
        }
      } else {
        throw Exception('HTTP请求失败: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }
  
  /// 解析SSE格式的响应
  Map<String, dynamic> _parseSSEResponse(String sseData) {
    print('[Streamable-HTTP-MCP] 开始解析SSE响应');
    print('[Streamable-HTTP-MCP] 原始SSE数据: $sseData');
    
    final lines = sseData.split('\n');
    String? currentEvent;
    final dataLines = <String>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.startsWith('event: ')) {
        currentEvent = trimmedLine.substring(7);
        print('[Streamable-HTTP-MCP] SSE事件类型: $currentEvent');
      } else if (trimmedLine.startsWith('data: ')) {
        final data = trimmedLine.substring(6);
        dataLines.add(data);
        print('[Streamable-HTTP-MCP] SSE数据行: $data');
      } else if (trimmedLine.isEmpty && dataLines.isNotEmpty) {
        // 空行表示一个SSE事件结束，处理累积的数据
        final combinedData = dataLines.join('\n');
        print('[Streamable-HTTP-MCP] 处理完整SSE事件，数据: $combinedData');
        
        if (currentEvent == 'message' && combinedData.isNotEmpty) {
          try {
            final jsonData = jsonDecode(combinedData);
            print('[Streamable-HTTP-MCP] 成功解析SSE中的JSON数据: $jsonData');
            
            if (jsonData is Map<String, dynamic>) {
              if (jsonData.containsKey('error')) {
                throw Exception('MCP错误: ${jsonData['error']}');
              }
              
              // 返回result部分，如果没有则返回整个对象
              return jsonData['result'] ?? jsonData;
            }
          } catch (e) {
            print('[Streamable-HTTP-MCP] JSON解析失败: $e');
            print('[Streamable-HTTP-MCP] 原始数据: $combinedData');
          }
        }
        
        // 重置状态准备处理下一个事件
        dataLines.clear();
        currentEvent = null;
      }
    }
    
    // 处理最后一个事件（如果没有以空行结尾）
    if (dataLines.isNotEmpty && currentEvent == 'message') {
      final combinedData = dataLines.join('\n');
      try {
        final jsonData = jsonDecode(combinedData);
        print('[Streamable-HTTP-MCP] 最后事件解析成功: $jsonData');
        
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            throw Exception('MCP错误: ${jsonData['error']}');
          }
          
          return jsonData['result'] ?? jsonData;
        }
      } catch (e) {
        print('[Streamable-HTTP-MCP] 最后事件JSON解析失败: $e');
      }
    }
    
    // 如果没有找到有效的JSON数据，返回空对象
    print('[Streamable-HTTP-MCP] 未找到有效的JSON数据，返回空响应');
    return {};
  }
}


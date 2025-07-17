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

/// MCP 传输模式
enum McpTransportMode {
  /// WebSocket传输 - 全双工实时通信
  websocket,
  /// Server-Sent Events - 服务端推送
  sse,
  /// HTTP/REST - 简单请求响应
  http,
  /// 本地进程 - 通过stdin/stdout通信
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
    this.transport = McpTransportMode.websocket,
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

    final transportString = json['transport'] as String? ?? 'websocket';
    final transport = McpTransportMode.values.firstWhere(
      (e) => e.name == transportString,
      orElse: () => McpTransportMode.websocket,
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

  /// 创建WebSocket传输模式的配置
  factory McpServerConfig.websocket({
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
      transport: McpTransportMode.websocket,
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

  /// 创建SSE传输模式的配置
  factory McpServerConfig.sse({
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
      transport: McpTransportMode.sse,
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

  /// 创建HTTP传输模式的配置
  factory McpServerConfig.http({
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
      transport: McpTransportMode.http,
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
      transport: McpTransportMode.websocket, // 嵌入式服务器内部使用WebSocket协议
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

/// SSE MCP 客户端实现
class SseMcpClient implements McpClient {
  final String serverUrl;
  final Map<String, String>? headers;
  
  bool _isConnected = false;
  StreamSubscription? _subscription;
  int _requestId = 0;
  final Map<int, Completer<Map<String, dynamic>>> _pendingRequests = {};
  String? _sessionEndpoint;
  String? _currentEventType;
  
  SseMcpClient(this.serverUrl, this.headers);

  @override
  Future<void> connect() async {
    try {
      print('[SSE-MCP] 连接到SSE服务器: $serverUrl');
      
      // 创建SSE连接
      final uri = Uri.parse(serverUrl);
      final request = await HttpClient().getUrl(uri);
      
      // 添加必要的headers
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');
      if (headers != null) {
        headers!.forEach((key, value) {
          request.headers.set(key, value);
        });
      }
      
      final response = await request.close();
      
      if (response.statusCode == 200) {
        _isConnected = true;
        _subscription = response
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(_handleSseMessage);
        
        print('[SSE-MCP] SSE连接建立成功');
        
        // 等待获取session端点
        await _waitForSessionEndpoint();
        
        // 发送MCP初始化握手
        await _initializeMcpSession();
        
      } else {
        throw Exception('SSE连接失败: ${response.statusCode}');
      }
    } catch (e) {
      print('[SSE-MCP] 连接失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    print('[SSE-MCP] 断开SSE连接');
    _isConnected = false;
    await _subscription?.cancel();
    _subscription = null;
    
    // 清理所有待处理请求
    for (final completer in _pendingRequests.values) {
      completer.completeError(Exception('连接已断开'));
    }
    _pendingRequests.clear();
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
  
  /// 等待获取session端点
  Future<void> _waitForSessionEndpoint() async {
    print('[SSE-MCP] 等待获取session端点...');
    var waitCount = 0;
    while (_sessionEndpoint == null && waitCount < 50) {
      await Future.delayed(Duration(milliseconds: 100));
      waitCount++;
    }
    
    if (_sessionEndpoint == null) {
      throw Exception('无法获取session端点');
    }
    print('[SSE-MCP] 获取到session端点: $_sessionEndpoint');
  }
  
  /// 初始化MCP会话
  Future<void> _initializeMcpSession() async {
    print('[SSE-MCP] 初始化MCP会话...');
    
    try {
      final result = await _sendRequest('initialize', {
        'protocolVersion': '2024-11-05',
        'capabilities': {
          'tools': {}
        },
        'clientInfo': {
          'name': 'LumiAssistant',
          'version': '1.0.0'
        }
      });
      
      print('[SSE-MCP] MCP会话初始化成功: $result');
    } catch (e) {
      print('[SSE-MCP] MCP会话初始化失败: $e');
      throw Exception('MCP会话初始化失败: $e');
    }
  }
  
  /// 发送MCP请求
  Future<Map<String, dynamic>> _sendRequest(String method, Map<String, dynamic> params) async {
    if (!_isConnected) {
      throw Exception('SSE连接未建立');
    }
    
    if (_sessionEndpoint == null) {
      throw Exception('Session端点未就绪');
    }
    
    final requestId = ++_requestId;
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestId] = completer;
    
    // 构造JSON-RPC请求
    final request = {
      'jsonrpc': '2.0',
      'id': requestId,
      'method': method,
      'params': params,
    };
    
    // 使用从SSE获取的session端点
    final baseUrl = serverUrl.contains('/sse') 
        ? serverUrl.substring(0, serverUrl.lastIndexOf('/sse'))
        : serverUrl;
    
    final sessionUrl = '$baseUrl$_sessionEndpoint';
    
    try {
      print('[SSE-MCP] 使用session端点: $sessionUrl');
      
      // 发送HTTP POST请求（异步）
      await _httpPostAsync(sessionUrl, request);
      
      // 等待SSE流返回响应
      final response = await completer.future;
      
      if (response.containsKey('error')) {
        throw Exception('MCP错误: ${response['error']}');
      }
      
      return response['result'] ?? response;
    } catch (e) {
      print('[SSE-MCP] 请求失败: $e');
      _pendingRequests.remove(requestId);
      rethrow;
    }
  }
  
  /// 处理SSE消息
  void _handleSseMessage(String line) {
    print('[SSE-MCP] 收到原始行: $line');
    
    if (line.startsWith('data: ')) {
      final data = line.substring(6);
      if (data.trim().isEmpty) return;
      
      // 处理端点信息
      if (data.startsWith('/messages/')) {
        print('[SSE-MCP] 收到session端点: $data');
        _sessionEndpoint = data;
        return;
      }
      
      // 尝试解析JSON数据
      try {
        final message = jsonDecode(data);
        print('[SSE-MCP] 收到JSON消息: $message');
        
        if (message.containsKey('id')) {
          final requestId = message['id'] as int;
          final completer = _pendingRequests.remove(requestId);
          if (completer != null) {
            if (message.containsKey('error')) {
              completer.completeError(Exception('MCP错误: ${message['error']}'));
            } else {
              completer.complete(message['result'] ?? {});
            }
          }
        }
      } catch (e) {
        print('[SSE-MCP] JSON解析消息失败: $e');
        print('[SSE-MCP] 原始数据: $data');
      }
    } else if (line.startsWith('event: ')) {
      final eventType = line.substring(7);
      print('[SSE-MCP] 收到事件类型: $eventType');
      _currentEventType = eventType;
    } else if (line.startsWith(': ')) {
      // SSE注释行（如ping消息）
      print('[SSE-MCP] 收到注释: $line');
    } else if (line.trim().isEmpty) {
      // 空行表示事件结束
      _currentEventType = null;
    } else {
      print('[SSE-MCP] 收到其他消息: $line');
    }
  }
  
  /// HTTP POST请求（异步，不等待响应）
  Future<void> _httpPostAsync(String url, Map<String, dynamic> data) async {
    final client = HttpClient();
    try {
      print('[SSE-MCP] 发送异步POST请求到: $url');
      final request = await client.postUrl(Uri.parse(url));
      request.headers.set('Content-Type', 'application/json');
      
      if (headers != null) {
        headers!.forEach((key, value) {
          request.headers.set(key, value);
        });
      }
      
      request.add(utf8.encode(jsonEncode(data)));
      final response = await request.close();
      
      print('[SSE-MCP] 异步POST请求发送完成，状态码: ${response.statusCode}');
      
      if (response.statusCode != 202 && response.statusCode != 200) {
        throw Exception('HTTP请求失败: ${response.statusCode}');
      }
      
      // 读取响应体（如果有）但不等待
      response.transform(utf8.decoder).listen(
        (data) => print('[SSE-MCP] HTTP响应体: $data'),
        onError: (error) => print('[SSE-MCP] HTTP响应读取错误: $error'),
      );
      
    } finally {
      client.close();
    }
  }
  
  /// HTTP POST请求（同步，等待响应）
  Future<Map<String, dynamic>> _httpPost(String url, Map<String, dynamic> data) async {
    final client = HttpClient();
    try {
      var currentUrl = url;
      var redirectCount = 0;
      const maxRedirects = 5;
      
      while (redirectCount < maxRedirects) {
        print('[SSE-MCP] 发送POST请求到: $currentUrl');
        final request = await client.postUrl(Uri.parse(currentUrl));
        request.headers.set('Content-Type', 'application/json');
        
        if (headers != null) {
          headers!.forEach((key, value) {
            request.headers.set(key, value);
          });
        }
        
        request.add(utf8.encode(jsonEncode(data)));
        final response = await request.close();
        
        print('[SSE-MCP] 收到响应状态码: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final responseBody = await response.transform(utf8.decoder).join();
          print('[SSE-MCP] 响应体: $responseBody');
          return jsonDecode(responseBody);
        } else if (response.statusCode == 202) {
          // 202 Accepted - 异步响应，将在SSE流中返回结果
          print('[SSE-MCP] 请求已被接受，响应将通过SSE流返回');
          response.transform(utf8.decoder).listen(
            (data) => print('[SSE-MCP] 202响应体: $data'),
            onError: (error) => print('[SSE-MCP] 202响应读取错误: $error'),
          );
          return {}; // 返回空对象，实际响应通过SSE流处理
        } else if (response.statusCode == 307 || response.statusCode == 302) {
          // 处理重定向
          final location = response.headers.value('location');
          if (location != null) {
            // 如果是相对路径，构造完整URL
            if (location.startsWith('/')) {
              final uri = Uri.parse(currentUrl);
              currentUrl = '${uri.scheme}://${uri.host}:${uri.port}$location';
            } else {
              currentUrl = location;
            }
            print('[SSE-MCP] 重定向到: $currentUrl');
            redirectCount++;
            continue;
          }
        }
        
        throw Exception('HTTP请求失败: ${response.statusCode}');
      }
      
      throw Exception('重定向次数过多');
    } finally {
      client.close();
    }
  }
}

/// HTTP MCP 客户端实现
class HttpMcpClient implements McpClient {
  final String serverUrl;
  final Map<String, String>? headers;
  
  bool _isConnected = false;
  int _requestId = 0;
  
  HttpMcpClient(this.serverUrl, this.headers);

  @override
  Future<void> connect() async {
    try {
      print('[HTTP-MCP] 连接到HTTP服务器: $serverUrl');
      
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
        print('[HTTP-MCP] HTTP连接建立成功');
      } else {
        throw Exception('MCP初始化失败');
      }
    } catch (e) {
      print('[HTTP-MCP] 连接失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    print('[HTTP-MCP] 断开HTTP连接');
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
      httpRequest.headers.set('Content-Type', 'application/json');
      
      if (headers != null) {
        headers!.forEach((key, value) {
          httpRequest.headers.set(key, value);
        });
      }
      
      httpRequest.add(utf8.encode(jsonEncode(request)));
      final response = await httpRequest.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final result = jsonDecode(responseBody);
        
        if (result.containsKey('error')) {
          throw Exception('MCP错误: ${result['error']}');
        }
        
        return result['result'] ?? {};
      } else {
        throw Exception('HTTP请求失败: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }
}

/// WebSocket MCP 客户端实现
class WebSocketMcpClient implements McpClient {
  final String serverUrl;
  final Map<String, String>? headers;
  
  WebSocket? _webSocket;
  bool _isConnected = false;
  int _requestId = 0;
  final Map<int, Completer<Map<String, dynamic>>> _pendingRequests = {};
  
  WebSocketMcpClient(this.serverUrl, this.headers);

  @override
  Future<void> connect() async {
    try {
      print('[WS-MCP] 连接到WebSocket服务器: $serverUrl');
      
      _webSocket = await WebSocket.connect(serverUrl, headers: headers);
      _isConnected = true;
      
      _webSocket!.listen(
        _handleMessage,
        onError: (error) {
          print('[WS-MCP] WebSocket错误: $error');
          _isConnected = false;
        },
        onDone: () {
          print('[WS-MCP] WebSocket连接关闭');
          _isConnected = false;
        },
      );
      
      print('[WS-MCP] WebSocket连接建立成功');
    } catch (e) {
      print('[WS-MCP] 连接失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    print('[WS-MCP] 断开WebSocket连接');
    _isConnected = false;
    await _webSocket?.close();
    _webSocket = null;
    
    // 清理所有待处理请求
    for (final completer in _pendingRequests.values) {
      completer.completeError(Exception('连接已断开'));
    }
    _pendingRequests.clear();
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
    if (!_isConnected || _webSocket == null) {
      throw Exception('WebSocket连接未建立');
    }
    
    final requestId = ++_requestId;
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestId] = completer;
    
    // 构造JSON-RPC请求
    final request = {
      'jsonrpc': '2.0',
      'id': requestId,
      'method': method,
      'params': params,
    };
    
    _webSocket!.add(jsonEncode(request));
    return await completer.future;
  }
  
  /// 处理WebSocket消息
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      print('[WS-MCP] 收到消息: $data');
      
      if (data.containsKey('id')) {
        final requestId = data['id'] as int;
        final completer = _pendingRequests.remove(requestId);
        if (completer != null) {
          if (data.containsKey('error')) {
            completer.completeError(Exception('MCP错误: ${data['error']}'));
          } else {
            completer.complete(data['result'] ?? {});
          }
        }
      }
    } catch (e) {
      print('[WS-MCP] 解析消息失败: $e');
    }
  }
}
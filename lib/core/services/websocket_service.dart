import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../../data/models/websocket_state.dart';
import 'audio_service_android_style.dart';
import 'audio_service_simple.dart';
import 'unified_mcp_manager.dart';


/// WebSocket服务类
class WebSocketService extends StateNotifier<WebSocketState> {
  WebSocketChannel? _channel;
  StreamSubscription? _messageSubscription;
  Timer? _reconnectTimer;
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();
  
  // 性能优化：使用单一的音频服务实例，而不是维护多个实例
  dynamic _activeAudioService;
  String _audioServiceType = 'android_style'; // 默认使用最稳定的Android风格服务
  
  // 统一MCP管理器
  final UnifiedMcpManager _mcpManager;

  WebSocketService(this._mcpManager) : super(WebSocketStateFactory.disconnected());

  /// 消息流
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// 性能优化：设置单一音频服务实例
  void setAudioService(dynamic audioService, String serviceType) {
    _activeAudioService = audioService;
    _audioServiceType = serviceType;
    print('[WebSocket] 音频服务已设置: $serviceType');
  }

  /// 连接到WebSocket服务器
  /// 
  /// [serverUrl] 可选的服务器URL，如果不提供则使用默认URL
  Future<void> connect([String? serverUrl]) async {
    print('[WebSocket] 开始连接流程');
    
    if (state.isConnected || state.isConnecting) {
      print('[WebSocket] 连接已存在或正在连接中，跳过连接流程');
      return;
    }

    print('[WebSocket] 设置连接状态为连接中');
    state = state.startConnecting();

    try {
      print('[WebSocket] 开始检查网络连接');
      // 检查网络连接
      await _checkNetworkConnection();
      print('[WebSocket] 网络连接检查通过');
      
      // 构建WebSocket URL - 完全按照Android客户端方式
      final deviceId = await _getDeviceId();
      final baseUrl = serverUrl ?? ApiConstants.webSocketBaseUrl;
      print('[WebSocket] 使用服务器URL: $baseUrl');
      
      // Android客户端直接使用原始URL，不添加query parameters
      final uri = Uri.parse(baseUrl);
      
      print('[WebSocket] 准备连接到: $uri');
      print('[WebSocket] 连接超时设置: ${ApiConstants.connectionTimeout}ms');
      
      // 建立WebSocket连接 - 完全按照Android客户端方式
      print('[WebSocket] 开始创建WebSocket连接...');
      try {
        // 按照Android客户端的headers格式
        final headers = <String, dynamic>{
          'device-id': deviceId,
          'client-id': deviceId,
          'protocol-version': ApiConstants.protocolVersion.toString(),
          'Authorization': 'Bearer ${ApiConstants.defaultToken}',
        };
        
        print('[WebSocket] 连接Headers: $headers');
        
        _channel = IOWebSocketChannel.connect(
          uri,
          headers: headers,
          connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
        );
        print('[WebSocket] WebSocket连接对象创建成功');
      } catch (connectError) {
        print('[WebSocket] 创建WebSocket连接失败: $connectError');
        rethrow;
      }

      print('[WebSocket] WebSocket通道已创建，等待连接就绪');
      // 监听连接状态
      await _channel!.ready;
      print('[WebSocket] WebSocket连接就绪');
      
      state = state.connectSuccess();

      print('[WebSocket] 开始监听消息流');
      // 开始监听消息
      _startListening();
      
      // ===== 关键时序处理：200ms延迟发送HELLO握手消息 =====
      // 
      // 问题背景：
      // 1. WebSocket连接分为两个阶段：
      //    - 阶段1：HTTP升级握手 (HTTP → WebSocket协议切换)
      //    - 阶段2：应用层握手 (发送hello消息进行业务初始化)
      //
      // 2. 时序问题：
      //    - _channel.ready 表示协议层握手完成
      //    - 但服务端还需要时间完成应用层初始化：
      //      * 创建ConnectionHandler
      //      * 验证device-id和Authorization
      //      * 初始化session和超时检查
      //      * 准备消息路由
      //
      // 3. 如果立即发送hello消息会导致：
      //    - 服务端还在初始化阶段，未准备好接收消息
      //    - 出现"EOFError: stream ends after 0 bytes"
      //    - 连接握手失败
      //
      // 4. 解决方案：
      //    - 参考Android客户端的成功实现
      //    - 在协议握手完成后等待200ms
      //    - 给服务端足够时间完成应用层初始化
      //    - 200ms是基于实际测试的经验值
      //
      // 5. 更好的解决方案(未来改进)：
      //    - 服务端提供应用层ready信号
      //    - 客户端使用重试机制而非固定延迟
      //
      Timer(Duration(milliseconds: 200), () async {
        if (state.isConnected) {
          print('[WebSocket] 发送HELLO握手消息(延迟200ms - 等待服务端应用层初始化完成)');
          try {
            await _sendHello();
          } catch (error) {
            print('[WebSocket] 延迟HELLO握手失败: $error');
          }
        }
      });
      
      
    } catch (error) {
      print('[WebSocket] 连接失败，错误详情: $error');
      print('[WebSocket] 错误类型: ${error.runtimeType}');
      final errorMsg = _handleConnectionError(error);
      print('[WebSocket] 处理后的错误消息: $errorMsg');
      
      state = state.connectFailure(errorMessage: errorMsg);
      
      print('[WebSocket] 启动自动重连机制');
      // 启动自动重连
      _scheduleReconnect();
    }
  }


  /// 断开连接
  Future<void> disconnect() async {
    print('[WebSocket] 开始断开连接');
    _stopReconnectTimer();
    
    await _messageSubscription?.cancel();
    await _channel?.sink.close();
    
    _channel = null;
    _messageSubscription = null;
    
    state = state.disconnect();
    print('[WebSocket] 连接已断开');
  }

  /// 发送消息
  Future<void> sendMessage(Map<String, dynamic> message) async {
    print('[WebSocket] 准备发送消息: ${message['type']}');
    
    if (!state.isConnected) {
      print('[WebSocket] 发送失败: WebSocket未连接');
      throw AppExceptionFactory.createWebSocketException(
        'WebSocket未连接',
        code: 'WEBSOCKET_NOT_CONNECTED',
        connectionState: state.connectionState.name,
      );
    }

    try {
      final jsonMessage = jsonEncode(message);
      print('[WebSocket] 发送JSON消息: $jsonMessage');
      _channel!.sink.add(jsonMessage);
      print('[WebSocket] 消息发送成功');
    } catch (error) {
      print('[WebSocket] 发送消息失败: $error');
      throw AppExceptionFactory.createWebSocketException(
        '发送消息失败: $error',
        code: 'MESSAGE_SEND_FAILED',
        connectionState: state.connectionState.name,
        details: {'error': error.toString()},
      );
    }
  }

  /// 发送二进制数据
  Future<void> sendBinaryData(Uint8List data) async {
    if (!state.isConnected) {
      print('[WebSocket] 发送二进制数据失败: WebSocket未连接');
      throw AppExceptionFactory.createWebSocketException(
        'WebSocket未连接',
        code: 'WEBSOCKET_NOT_CONNECTED',
        connectionState: state.connectionState.name,
      );
    }

    try {
      _channel!.sink.add(data);
      // 不打印详细日志以避免过多输出
      // print('[WebSocket] 二进制数据发送成功: ${data.length} bytes');
    } catch (error) {
      print('[WebSocket] 发送二进制数据失败: $error');
      throw AppExceptionFactory.createWebSocketException(
        '发送二进制数据失败: $error',
        code: 'BINARY_SEND_FAILED',
        connectionState: state.connectionState.name,
        details: {'error': error.toString(), 'dataSize': data.length},
      );
    }
  }

  /// 检查网络连接
  Future<void> _checkNetworkConnection() async {
    try {
      print('[WebSocket] 正在检查网络连接...');
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        print('[WebSocket] 网络连接检查失败: 无网络连接');
        throw AppExceptionFactory.createNetworkException(
          '无网络连接',
          code: 'NO_NETWORK_CONNECTION',
        );
      }
      print('[WebSocket] 网络连接检查成功');
    } catch (error) {
      print('[WebSocket] 网络连接检查异常: $error');
      throw AppExceptionFactory.createNetworkException(
        '网络连接检查失败: $error',
        code: 'NETWORK_CHECK_FAILED',
        details: {'error': error.toString()},
      );
    }
  }

  /// 开始监听消息
  void _startListening() {
    print('[WebSocket] 开始监听消息流');
    _messageSubscription = _channel!.stream.listen(
      (data) {
        try {
          // 检查是否为二进制数据
          if (data is List<int>) {
            _handleBinaryMessage(Uint8List.fromList(data));
          } else if (data is String) {
            _handleTextMessage(data);
          } else {
            print('[WebSocket] 未知消息类型: ${data.runtimeType}');
          }
        } catch (error) {
          print('[WebSocket] 处理消息失败: $error');
        }
      },
      onError: (error) {
        print('[WebSocket] 消息流错误: $error');
        final errorMsg = _handleConnectionError(error);
        state = state.connectFailure(errorMessage: errorMsg);
        print('[WebSocket] 由于消息流错误，启动重连');
        _scheduleReconnect();
      },
      onDone: () {
        print('[WebSocket] 消息流已关闭');
        if (state.isConnected) {
          state = state.disconnect();
          print('[WebSocket] 由于连接断开，启动重连');
          _scheduleReconnect();
        }
      },
    );
  }

  /// 处理文本消息
  void _handleTextMessage(String data) {
    try {
      print('[WebSocket] 收到文本消息: $data');
      final Map<String, dynamic> message = jsonDecode(data);
      print('[WebSocket] 解析消息成功: ${message['type']}');
      
      // 检查是否为MCP消息
      if (message['type'] == 'mcp') {
        print('[WebSocket] 检测到MCP消息，路由到统一MCP管理器');
        _handleMcpMessage(message);
      } else {
        print('[WebSocket] 非MCP消息，添加到消息流: ${message['type']}');
        _messageController.add(message);
      }
    } catch (error) {
      print('[WebSocket] 解析文本消息失败: $error');
    }
  }

  /// 处理二进制消息（音频数据）
  void _handleBinaryMessage(Uint8List data) async {
    try {
      // 检查是否为音频数据（Opus帧通常是10-320字节）
      if (data.length >= 10 && data.length <= 1000) {
        // 性能优化：使用单一的音频服务实例
        if (_activeAudioService != null) {
          await _activeAudioService.playOpusAudio(data);
        }
      }
    } catch (error) {
      print('[WebSocket] 处理二进制消息失败: $error');
    }
  }



  /// 安排重连
  void _scheduleReconnect() {
    print('[WebSocket] 准备安排重连，当前重连次数: ${state.reconnectAttempts}');
    
    if (state.shouldStopReconnecting) {
      print('[WebSocket] 重连次数已达上限 ${ApiConstants.maxReconnectAttempts}，停止重连');
      state = state.connectFailure(errorMessage: '重连次数超限，请手动重试');
      return;
    }

    _stopReconnectTimer();
    
    final delay = Duration(milliseconds: ApiConstants.reconnectDelay);
    print('[WebSocket] 将在 ${ApiConstants.reconnectDelay}ms 后重连');
    _reconnectTimer = Timer(delay, () {
      print('[WebSocket] 开始第 ${state.reconnectAttempts + 1} 次重连');
      state = state.startReconnecting();
      connect();
    });
  }

  /// 停止重连定时器
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 处理连接错误
  String _handleConnectionError(dynamic error) {
    if (error is SocketException) {
      return '网络连接失败，请检查网络设置';
    } else if (error is TimeoutException) {
      return '连接超时，请稍后重试';
    } else if (error is AppException) {
      return error.userFriendlyMessage;
    } else {
      return '连接失败: $error';
    }
  }

  /// 获取设备ID - 生成MAC地址格式
  Future<String> _getDeviceId() async {
    try {
      // 生成一个MAC地址样式的设备ID
      final random = DateTime.now().millisecondsSinceEpoch;
      final mac = StringBuffer();
      
      for (int i = 0; i < 6; i++) {
        if (i > 0) mac.write(':');
        final byte = (random >> (i * 8)) & 0xFF;
        mac.write(byte.toRadixString(16).padLeft(2, '0').toUpperCase());
      }
      
      return mac.toString();
    } catch (error) {
      // 如果获取失败，使用默认MAC格式
      return '51:2C:C4:66:25:41';
    }
  }


  /// 处理MCP消息 - 路由到统一MCP管理器
  Future<void> _handleMcpMessage(Map<String, dynamic> message) async {
    print('[WebSocket] 路由MCP消息到统一管理器');
    print('[WebSocket] MCP消息内容: $message');
    
    // 在顶层声明method变量，确保在catch块中也能访问
    String? method;
    
    try {
      // 确保统一MCP管理器已初始化
      await _mcpManager.initialize();
      print('[WebSocket] 统一MCP管理器初始化完成');
      
      // 解析MCP请求
      final payload = message['payload'] as Map<String, dynamic>?;
      if (payload == null) {
        throw Exception('MCP消息缺少payload');
      }
      
      method = payload['method'] as String?;
      final id = payload['id'];
      final sessionId = message['session_id'] as String?;
      
      Map<String, dynamic> response;
      
      switch (method) {
        case 'tools/call':
          // 工具调用请求
          final params = payload['params'] as Map<String, dynamic>?;
          if (params == null) {
            throw Exception('工具调用缺少参数');
          }
          
          final toolName = params['name'] as String;
          final arguments = params['arguments'] as Map<String, dynamic>? ?? {};
          
          print('[WebSocket] ===== MCP工具调用 =====');
          print('[WebSocket] 工具名称: $toolName');
          print('[WebSocket] 调用参数: $arguments');
          print('[WebSocket] 会话ID: $sessionId');
          
          // 通过统一的MCP管理器调用工具
          final toolResult = await _mcpManager.callTool(toolName, arguments);
          
          print('[WebSocket] 工具调用成功: $toolName');
          print('[WebSocket] 调用结果: $toolResult');
          
          response = {
            'type': 'mcp',
            'session_id': sessionId,
            'payload': {
              'jsonrpc': '2.0',
              'id': id,
              'result': {
                'content': toolResult['content'] ?? [
                  {'type': 'text', 'text': toolResult['message'] ?? '操作完成'}
                ],
                'isError': toolResult['isError'] ?? false,
              },
            },
          };
          break;
          
        case 'tools/list':
          // 工具列表请求
          print('[WebSocket] ===== Python后端请求工具列表 =====');
          print('[WebSocket] 会话ID: $sessionId');
          print('[WebSocket] 请求ID: $id');
          
          final tools = await _mcpManager.getAvailableTools();
          
          print('[WebSocket] 准备发送工具列表给Python后端，工具数量: ${tools.length}');
          final toolsResponse = tools.map((tool) => {
            'name': tool.name,
            'description': tool.description,
            'inputSchema': tool.inputSchema,
          }).toList();
          
          print('[WebSocket] 工具列表响应内容:');
          for (int i = 0; i < toolsResponse.length; i++) {
            print('[WebSocket]   ${i + 1}. ${toolsResponse[i]['name']} - ${toolsResponse[i]['description']}');
          }
          
          response = {
            'type': 'mcp',
            'session_id': sessionId,
            'payload': {
              'jsonrpc': '2.0',
              'id': id,
              'result': {
                'tools': toolsResponse,
              },
            },
          };
          print('[WebSocket] ===============================');
          break;
          
        case 'initialize':
          // 初始化请求
          response = {
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
          break;
          
        default:
          throw Exception('不支持的MCP方法: $method');
      }
      
      print('[WebSocket] MCP响应生成: ${response['payload']['result']}');
      
      // 发送响应
      await sendMessage(response);
      print('[WebSocket] MCP响应已发送');
    } catch (error) {
      print('[WebSocket] ===== MCP调用失败 =====');
      print('[WebSocket] 错误详情: $error');
      print('[WebSocket] 错误类型: ${error.runtimeType}');
      print('[WebSocket] 方法: $method');
      print('[WebSocket] 会话ID: ${message['session_id']}');
      
      // 生成用户友好的错误信息
      final userFriendlyError = _generateUserFriendlyError(error, method ?? 'unknown');
      
      // 发送详细的错误响应
      final errorResponse = {
        'type': 'mcp',
        'session_id': message['session_id'],
        'payload': {
          'jsonrpc': '2.0',
          'id': message['payload']?['id'],
          'error': {
            'code': _getErrorCode(error),
            'message': userFriendlyError,
            'data': {
              'original_error': error.toString(),
              'method': method ?? 'unknown',
              'timestamp': DateTime.now().toIso8601String(),
            },
          },
        },
      };
      
      await sendMessage(errorResponse);
      print('[WebSocket] 错误响应已发送');
      print('[WebSocket] ===========================');
    }
  }
  
  /// 生成用户友好的错误信息
  String _generateUserFriendlyError(dynamic error, String method) {
    final errorString = error.toString().toLowerCase();
    
    // 网络相关错误
    if (errorString.contains('connection') || 
        errorString.contains('timeout') ||
        errorString.contains('network')) {
      return '网络连接出现问题，请检查设备连接状态';
    }
    
    // 权限相关错误
    if (errorString.contains('permission') || 
        errorString.contains('access denied') ||
        errorString.contains('unauthorized')) {
      return '权限不足，无法执行此操作';
    }
    
    // 设备不可用
    if (errorString.contains('not found') || 
        errorString.contains('unavailable') ||
        errorString.contains('offline')) {
      return '设备暂时不可用，请稍后再试';
    }
    
    // 参数错误
    if (errorString.contains('invalid') || 
        errorString.contains('parameter') ||
        errorString.contains('argument')) {
      return '操作参数有误，请检查输入';
    }
    
    // 服务器错误
    if (errorString.contains('server') || 
        errorString.contains('internal') ||
        errorString.contains('service')) {
      return '服务暂时不可用，请稍后重试';
    }
    
    // 特定方法的错误
    switch (method) {
      case 'tools/call':
        return '工具调用失败，请检查设备状态';
      case 'tools/list':
        return '无法获取可用工具列表';
      case 'initialize':
        return 'MCP协议初始化失败';
      default:
        return '操作执行失败，请稍后重试';
    }
  }
  
  /// 获取错误代码
  int _getErrorCode(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // 标准JSON-RPC错误代码
    if (errorString.contains('invalid request')) {
      return -32600;
    } else if (errorString.contains('method not found')) {
      return -32601;
    } else if (errorString.contains('invalid params')) {
      return -32602;
    } else if (errorString.contains('parse error')) {
      return -32700;
    } else if (errorString.contains('timeout')) {
      return -32001; // 自定义超时错误
    } else if (errorString.contains('permission')) {
      return -32002; // 自定义权限错误
    } else if (errorString.contains('not found')) {
      return -32003; // 自定义资源未找到错误
    } else {
      return -32603; // 内部错误
    }
  }
  

  /// 发送HELLO握手消息
  /// 
  /// 这是WebSocket应用层握手的关键步骤：
  /// 1. 协议层握手完成后，客户端需要发送hello消息告知服务端客户端信息
  /// 2. 服务端收到hello后会回复包含session_id的hello响应
  /// 3. 握手完成后才能进行正常的业务消息收发
  /// 
  /// 消息格式遵循ESP32客户端和服务端API规范（支持MCP协议）：
  /// {
  ///   "type": "hello",
  ///   "version": 1,
  ///   "transport": "websocket",
  ///   "features": {
  ///     "mcp": true  // 声明支持MCP协议
  ///   },
  ///   "audio_params": {
  ///     "format": "opus",
  ///     "sample_rate": 16000,
  ///     "channels": 1,
  ///     "frame_duration": 60
  ///   }
  /// }
  Future<void> _sendHello() async {
    try {
      final helloMsg = {
        'type': 'hello',
        'version': 1,
        'transport': 'websocket',
        'features': {
          'mcp': true,  // 声明支持MCP协议，参考ESP32实现
        },
        'audio_params': {
          'format': 'opus',
          'sample_rate': 16000,
          'channels': 1,
          'frame_duration': 60,
        },
      };
      print('[WebSocket] 发送HELLO握手消息（支持MCP协议）: $helloMsg');
      await sendMessage(helloMsg);
      
      // MCP协议：服务器会在握手完成后主动发送tools/list请求
      // 我们只需要等待并响应服务器的查询，不需要主动注册
      print('[WebSocket] Hello握手完成，等待服务器MCP工具查询');
    } catch (error) {
      print('[WebSocket] 发送HELLO握手失败: $error');
      throw AppExceptionFactory.createWebSocketException(
        'HELLO握手失败: ${error.toString()}',
        code: 'HANDSHAKE_FAILED',
      );
    }
  }

  /// 强制重新生成会话（用于MCP工具变化后确保工具同步）
  Future<void> regenerateSession() async {
    print('[WebSocket] 开始强制重新生成会话...');
    
    if (!state.isConnected) {
      print('[WebSocket] 当前未连接，直接建立新连接');
      await connect();
      return;
    }
    
    // 优雅断开当前连接
    print('[WebSocket] 断开当前连接');
    await disconnect();
    
    // 短暂延迟确保资源清理完成
    await Future.delayed(Duration(milliseconds: 500));
    
    // 重新建立连接，这会触发新的hello握手和工具列表请求
    print('[WebSocket] 重新建立连接和会话');
    await connect();
    
    print('[WebSocket] 会话重新生成完成，Python后端将获得最新的工具列表');
  }

  @override
  void dispose() {
    disconnect();
    _messageController.close();
    super.dispose();
  }
}

/// WebSocket服务提供者
final webSocketServiceProvider = StateNotifierProvider<WebSocketService, WebSocketState>((ref) {
  // 注入统一MCP管理器
  final mcpManager = ref.read(unifiedMcpManagerProvider);
  final service = WebSocketService(mcpManager);
  
  // 初始化统一MCP管理器
  Future.microtask(() async {
    try {
      // 注入会话重新生成回调
      mcpManager.setSessionRegenerateCallback(() async {
        await service.regenerateSession();
      });
      
      await mcpManager.initialize();
      await mcpManager.startAutoStartServers();
    } catch (e) {
      print('[WebSocket] 统一MCP管理器初始化失败: $e');
    }
  });
  
  // 性能优化：延迟注入单一音频服务，避免循环依赖和内存浪费
  Future.microtask(() {
    try {
      // 只注入最稳定的Android风格音频服务
      final audioServiceAndroidStyle = AudioServiceAndroidStyle();
      service.setAudioService(audioServiceAndroidStyle, 'android_style');
    } catch (e) {
      print('[WebSocket] 音频服务注入失败，尝试fallback: $e');
      try {
        // 如果失败，尝试使用简化服务作为fallback
        final audioServiceSimple = AudioServiceSimple();
        service.setAudioService(audioServiceSimple, 'simple');
      } catch (fallbackError) {
        print('[WebSocket] Fallback音频服务也失败: $fallbackError');
      }
    }
  });
  
  return service;
});
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
import 'audio_service.dart';
import 'audio_service_v2.dart';
import 'audio_service_v3.dart';
import 'audio_service_simple.dart';
import 'audio_service_direct.dart';


/// WebSocket服务类
class WebSocketService extends StateNotifier<WebSocketState> {
  WebSocketChannel? _channel;
  StreamSubscription? _messageSubscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();
  AudioService? _audioService;
  AudioServiceV2? _audioServiceV2;
  AudioServiceV3? _audioServiceV3;
  AudioServiceSimple? _audioServiceSimple;
  AudioServiceDirect? _audioServiceDirect;

  WebSocketService() : super(WebSocketStateFactory.disconnected());

  /// 消息流
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// 设置音频服务
  void setAudioService(AudioService audioService) {
    _audioService = audioService;
    print('[WebSocket] 音频服务已设置');
  }

  /// 设置音频服务V2
  void setAudioServiceV2(AudioServiceV2 audioServiceV2) {
    _audioServiceV2 = audioServiceV2;
    print('[WebSocket] 音频服务V2已设置');
  }

  /// 设置音频服务V3
  void setAudioServiceV3(AudioServiceV3 audioServiceV3) {
    _audioServiceV3 = audioServiceV3;
    print('[WebSocket] 音频服务V3已设置（Android客户端方式）');
  }

  /// 设置简化音频服务
  void setAudioServiceSimple(AudioServiceSimple audioServiceSimple) {
    _audioServiceSimple = audioServiceSimple;
    print('[WebSocket] 简化音频服务已设置');
  }

  /// 设置直接PCM播放音频服务
  void setAudioServiceDirect(AudioServiceDirect audioServiceDirect) {
    _audioServiceDirect = audioServiceDirect;
    print('[WebSocket] 直接PCM播放音频服务已设置（严格按照约定）');
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
      
      // 构建WebSocket URL - 按照小智Android项目方式
      final deviceId = await _getDeviceId();
      final baseUrl = serverUrl ?? ApiConstants.webSocketBaseUrl;
      print('[WebSocket] 使用服务器URL: $baseUrl');
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'device-id': deviceId,
          'client-id': deviceId,  // 使用相同的device-id作为client-id
        },
      );
      
      print('[WebSocket] 准备连接到: $uri');
      print('[WebSocket] URI主机: ${uri.host}');
      print('[WebSocket] URI端口: ${uri.port}');
      print('[WebSocket] URI路径: ${uri.path}');
      print('[WebSocket] URI查询参数: ${uri.query}');
      print('[WebSocket] 连接超时设置: ${ApiConstants.connectionTimeout}ms');
      
      // 先测试TCP连接
      print('[WebSocket] 测试TCP连接到 ${uri.host}:${uri.port}');
      await _testTcpConnection(uri.host, uri.port);
      print('[WebSocket] TCP连接测试通过');
      
      // 建立WebSocket连接 - 按照小智Android项目方式
      print('[WebSocket] 开始创建WebSocket连接...');
      try {
        // 尝试使用Headers传递认证信息
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
      
      // 连接成功后，发送认证消息（作为备用方案）
      print('[WebSocket] 发送认证消息作为备用方案');
      final authMessage = 'Authorization: Bearer ${ApiConstants.defaultToken}';
      _channel!.sink.add(authMessage);
      
      state = state.connectSuccess();

      print('[WebSocket] 连接成功，开始监听消息');
      // 开始监听消息
      _startListening();
      
      print('[WebSocket] 启动心跳机制');
      // 启动心跳
      _startHeartbeat();
      
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

  /// 测试TCP连接
  Future<void> _testTcpConnection(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host, 
        port, 
        timeout: const Duration(seconds: 5)
      );
      await socket.close();
      print('[WebSocket] TCP连接测试成功');
    } catch (error) {
      print('[WebSocket] TCP连接测试失败: $error');
      throw AppExceptionFactory.createNetworkException(
        '无法连接到服务器 $host:$port - $error',
        code: 'TCP_CONNECTION_FAILED',
        details: {'host': host, 'port': port, 'error': error.toString()},
      );
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    print('[WebSocket] 开始断开连接');
    _stopReconnectTimer();
    _stopHeartbeat();
    
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
          print('[WebSocket] 收到原始消息，类型: ${data.runtimeType}');
          
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
      _messageController.add(message);
    } catch (error) {
      print('[WebSocket] 解析文本消息失败: $error');
    }
  }

  /// 处理二进制消息（音频数据）
  void _handleBinaryMessage(Uint8List data) async {
    try {
      print('[WebSocket] ===== 收到二进制消息 =====');
      print('[WebSocket] 数据大小: ${data.length} bytes');
      
      // 分析二进制数据的头部，判断格式
      _analyzeBinaryData(data);
      
      // 检查是否为音频数据（Opus帧通常是10-320字节）
      if (data.length >= 10 && data.length <= 1000) {
        print('[WebSocket] 判断为音频数据，开始播放');
        print('[WebSocket] 音频服务状态: ${_audioService != null ? "可用" : "不可用"}');
        
        // 优先使用直接PCM播放音频服务（严格按照约定）
        if (_audioServiceDirect != null) {
          print('[WebSocket] 调用直接PCM播放音频服务（严格按照约定：Opus->PCM->直接播放PCM）');
          await _audioServiceDirect!.playOpusAudio(data);
          print('[WebSocket] 音频播放请求已完成(Direct)');
        } else if (_audioServiceSimple != null) {
          print('[WebSocket] 调用简化音频服务播放音频（Android客户端方式）');
          await _audioServiceSimple!.playOpusAudio(data);
          print('[WebSocket] 音频播放请求已完成(Simple)');
        } else if (_audioServiceV2 != null) {
          print('[WebSocket] 调用音频服务V2播放音频（JustAudio）');
          await _audioServiceV2!.playOpusAudio(data);
          print('[WebSocket] 音频播放请求已完成(V2)');
        } else if (_audioServiceV3 != null) {
          print('[WebSocket] 调用音频服务V3播放音频（Android客户端方式）');
          await _audioServiceV3!.playOpusAudio(data);
          print('[WebSocket] 音频播放请求已完成(V3)');
        } else if (_audioService != null) {
          print('[WebSocket] 调用音频服务V1播放音频（flutter_pcm_player）');
          await _audioService!.playOpusAudio(data);
          print('[WebSocket] 音频播放请求已完成(V1)');
        } else {
          print('[WebSocket] 音频服务不可用，跳过播放');
        }
      } else {
        print('[WebSocket] 二进制数据大小不符合Opus帧规范: ${data.length} bytes');
        print('[WebSocket] 可能不是音频数据，跳过播放');
      }
      print('[WebSocket] ===== 二进制消息处理结束 =====');
    } catch (error) {
      print('[WebSocket] 处理二进制消息失败: $error');
      print('[WebSocket] 错误类型: ${error.runtimeType}');
    }
  }

  /// 分析二进制数据格式
  void _analyzeBinaryData(Uint8List data) {
    if (data.isEmpty) return;
    
    // 打印前16个字节的十六进制表示
    final headerLength = data.length < 16 ? data.length : 16;
    final headerHex = data.take(headerLength)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');
    
    print('[WebSocket] 二进制数据头部(hex): $headerHex');
    
    // 尝试识别常见的音频格式
    if (data.length >= 4) {
      // 检查Opus魔数（OggS）
      if (data[0] == 0x4F && data[1] == 0x67 && data[2] == 0x67 && data[3] == 0x53) {
        print('[WebSocket] 检测到OGG容器格式（可能包含Opus）');
      }
      // 检查原始Opus帧
      else if (data[0] == 0x4F && data[1] == 0x70 && data[2] == 0x75 && data[3] == 0x73) {
        print('[WebSocket] 检测到Opus魔数');
      }
      // 检查WAV格式
      else if (data[0] == 0x52 && data[1] == 0x49 && data[2] == 0x46 && data[3] == 0x46) {
        print('[WebSocket] 检测到WAV文件格式');
      }
      // 检查MP3格式
      else if ((data[0] == 0xFF && (data[1] & 0xE0) == 0xE0) || 
               (data[0] == 0x49 && data[1] == 0x44 && data[2] == 0x33)) {
        print('[WebSocket] 检测到MP3文件格式');
      }
      else {
        print('[WebSocket] 未识别的音频格式，可能是原始Opus帧或其他格式');
      }
    }
  }

  /// 启动心跳
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(
      Duration(milliseconds: ApiConstants.heartbeatInterval),
      (timer) {
        if (state.isConnected) {
          try {
            sendMessage({'type': 'ping', 'timestamp': DateTime.now().millisecondsSinceEpoch});
          } catch (error) {
            print('[WebSocket] 心跳发送失败: $error');
          }
        }
      },
    );
  }

  /// 停止心跳
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
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

  @override
  void dispose() {
    disconnect();
    _messageController.close();
    super.dispose();
  }
}

/// WebSocket服务提供者
final webSocketServiceProvider = StateNotifierProvider<WebSocketService, WebSocketState>((ref) {
  final service = WebSocketService();
  
  // 延迟注入音频服务，避免循环依赖
  Future.microtask(() {
    try {
      final audioService = ref.read(audioServiceProvider);
      service.setAudioService(audioService);
      
      final audioServiceV2 = ref.read(audioServiceV2Provider);
      service.setAudioServiceV2(audioServiceV2);
      
      final audioServiceV3 = ref.read(audioServiceV3Provider);
      service.setAudioServiceV3(audioServiceV3);
      
      final audioServiceSimple = ref.read(audioServiceSimpleProvider);
      service.setAudioServiceSimple(audioServiceSimple);
      
      final audioServiceDirect = ref.read(audioServiceDirectProvider);
      service.setAudioServiceDirect(audioServiceDirect);
    } catch (e) {
      print('[WebSocket] 音频服务注入失败: $e');
    }
  });
  
  return service;
});
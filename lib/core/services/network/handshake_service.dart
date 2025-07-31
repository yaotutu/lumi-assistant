import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/chat/message_model.dart';
import '../device/device_info_service.dart';
import '../websocket/websocket_service.dart';
import '../../errors/exceptions.dart';
import '../../errors/error_handler.dart';
import '../../utils/loggers.dart';

/// 握手状态枚举
enum HandshakeState {
  /// 未开始
  idle,
  /// 握手中
  handshaking,
  /// 握手成功
  completed,
  /// 握手失败
  failed,
  /// 超时
  timeout,
}

/// 握手结果数据类
class HandshakeResult {
  final HandshakeState state;
  final String? sessionId;
  final String? errorMessage;
  final DateTime? completedAt;
  final Map<String, dynamic>? serverInfo;

  const HandshakeResult({
    required this.state,
    this.sessionId,
    this.errorMessage,
    this.completedAt,
    this.serverInfo,
  });

  HandshakeResult copyWith({
    HandshakeState? state,
    String? sessionId,
    String? errorMessage,
    DateTime? completedAt,
    Map<String, dynamic>? serverInfo,
  }) {
    return HandshakeResult(
      state: state ?? this.state,
      sessionId: sessionId ?? this.sessionId,
      errorMessage: errorMessage ?? this.errorMessage,
      completedAt: completedAt ?? this.completedAt,
      serverInfo: serverInfo ?? this.serverInfo,
    );
  }

  /// 是否握手成功
  bool get isCompleted => state == HandshakeState.completed;
  
  /// 是否握手失败
  bool get isFailed => state == HandshakeState.failed || state == HandshakeState.timeout;
  
  /// 是否正在握手
  bool get isHandshaking => state == HandshakeState.handshaking;
}

/// 握手服务
class HandshakeService extends StateNotifier<HandshakeResult> {
  final WebSocketService _webSocketService;
  final DeviceInfoService _deviceInfoService;
  
  Timer? _timeoutTimer;
  StreamSubscription? _messageSubscription;

  HandshakeService(this._webSocketService, this._deviceInfoService) 
      : super(const HandshakeResult(state: HandshakeState.idle));

  /// 开始握手流程
  Future<void> startHandshake() async {
    Loggers.websocket.userAction('开始握手流程');
    
    if (state.isHandshaking) {
      Loggers.websocket.warning('握手正在进行中，跳过');
      return;
    }

    Loggers.websocket.stateChange('idle', 'handshaking', '设置握手状态为进行中');
    // 重置状态
    state = const HandshakeResult(state: HandshakeState.handshaking);
    
    try {
      Loggers.websocket.fine('开始监听WebSocket消息');
      // 监听WebSocket消息
      _startListening();
      
      Loggers.websocket.info('发送Hello握手消息');
      // 发送Hello消息
      await _sendHelloMessage();
      
      Loggers.websocket.fine('启动握手超时定时器');
      // 启动超时定时器
      _startTimeoutTimer();
      
    } catch (error) {
      Loggers.websocket.severe('握手流程异常', error);
      final errorMessage = ErrorHandler.handleError(error as Exception, StackTrace.current);
      state = HandshakeResult(
        state: HandshakeState.failed,
        errorMessage: errorMessage,
      );
    }
  }

  /// 发送Hello消息
  Future<void> _sendHelloMessage() async {
    try {
      // 获取设备信息
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      
      // 生成设备MAC地址样式的ID
      final deviceMac = _generateDeviceMac();
      
      // 创建Hello消息 - 按照小智Android项目格式
      final helloMessage = {
        'type': 'hello',
        'version': 1,
        'transport': 'websocket',
        'device_id': deviceMac,
        'device_mac': deviceMac,
        'device_name': '${deviceInfo.platform} ${deviceInfo.model}',
        'token': 'your-token1',
        'audio_params': {
          'format': 'opus',
          'sample_rate': 16000,
          'channels': 1,
          'frame_duration': 60,
        },
      };

      Loggers.websocket.fine('发送Hello消息: $helloMessage');
      
      // 发送消息
      await _webSocketService.sendMessage(helloMessage);
      
    } catch (error) {
      Loggers.websocket.severe('发送Hello消息失败', error);
      throw AppExceptionFactory.createWebSocketException(
        '发送Hello消息失败: $error',
        code: 'HANDSHAKE_SEND_FAILED',
      );
    }
  }

  /// 生成MAC地址样式的设备ID
  String _generateDeviceMac() {
    // 生成一个MAC地址样式的字符串
    final random = DateTime.now().millisecondsSinceEpoch;
    final mac = StringBuffer();
    
    for (int i = 0; i < 6; i++) {
      if (i > 0) mac.write(':');
      final byte = (random >> (i * 8)) & 0xFF;
      mac.write(byte.toRadixString(16).padLeft(2, '0').toUpperCase());
    }
    
    return mac.toString();
  }

  /// 获取客户端能力列表
  // 已删除未使用的_getClientCapabilities方法

  /// 开始监听WebSocket消息
  void _startListening() {
    _messageSubscription?.cancel();
    _messageSubscription = _webSocketService.messageStream.listen(
      _handleMessage,
      onError: (error) {
        state = HandshakeResult(
          state: HandshakeState.failed,
          errorMessage: '握手过程中连接异常: $error',
        );
      },
    );
  }

  /// 处理收到的消息
  void _handleMessage(Map<String, dynamic> data) {
    try {
      final messageType = data['type'] as String?;
      
      switch (messageType) {
        case 'hello':
          _handleHelloResponse(data);
          break;
        case 'error':
          _handleErrorResponse(data);
          break;
        default:
          // 其他消息类型，握手阶段不处理
          break;
      }
    } catch (error) {
      state = HandshakeResult(
        state: HandshakeState.failed,
        errorMessage: '解析握手响应失败: $error',
      );
    }
  }

  /// 处理Hello响应
  void _handleHelloResponse(Map<String, dynamic> data) {
    try {
      // 提取会话ID
      final sessionId = data['session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        state = const HandshakeResult(
          state: HandshakeState.failed,
          errorMessage: '服务器未返回会话ID',
        );
        return;
      }

      // 提取服务器信息
      final serverInfo = data['server_info'] as Map<String, dynamic>?;
      
      // 握手成功
      state = HandshakeResult(
        state: HandshakeState.completed,
        sessionId: sessionId,
        completedAt: DateTime.now(),
        serverInfo: serverInfo,
      );
      
      // 清理资源
      _cleanup();
      
    } catch (error) {
      state = HandshakeResult(
        state: HandshakeState.failed,
        errorMessage: '处理握手响应失败: $error',
      );
    }
  }

  /// 处理错误响应
  void _handleErrorResponse(Map<String, dynamic> data) {
    try {
      final errorMessage = ErrorMessage.fromJson(data);
      
      state = HandshakeResult(
        state: HandshakeState.failed,
        errorMessage: '握手失败: ${errorMessage.errorMessage}',
      );
      
    } catch (error) {
      state = HandshakeResult(
        state: HandshakeState.failed,
        errorMessage: '握手过程中收到错误响应',
      );
    }
  }

  /// 启动超时定时器
  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (state.isHandshaking) {
        state = const HandshakeResult(
          state: HandshakeState.timeout,
          errorMessage: '握手超时',
        );
        _cleanup();
      }
    });
  }

  /// 停止握手流程
  void stopHandshake() {
    if (state.isHandshaking) {
      state = const HandshakeResult(
        state: HandshakeState.idle,
        errorMessage: '握手已取消',
      );
    }
    _cleanup();
  }

  /// 重置握手状态
  void reset() {
    _cleanup();
    state = const HandshakeResult(state: HandshakeState.idle);
  }

  /// 清理资源
  void _cleanup() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

/// 握手服务提供者
final handshakeServiceProvider = StateNotifierProvider<HandshakeService, HandshakeResult>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider.notifier);
  final deviceInfoService = DeviceInfoService();
  return HandshakeService(webSocketService, deviceInfoService);
});

/// 握手状态提供者
final handshakeStateProvider = Provider<HandshakeState>((ref) {
  final handshakeResult = ref.watch(handshakeServiceProvider);
  return handshakeResult.state;
});

/// 会话ID提供者
final sessionIdProvider = Provider<String?>((ref) {
  final handshakeResult = ref.watch(handshakeServiceProvider);
  return handshakeResult.sessionId;
});

/// 是否握手完成提供者
final isHandshakeCompletedProvider = Provider<bool>((ref) {
  final handshakeResult = ref.watch(handshakeServiceProvider);
  return handshakeResult.isCompleted;
});
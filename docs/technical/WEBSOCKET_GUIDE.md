# 🌐 WebSocket 通信指南

> Lumi Assistant 项目中 WebSocket 通信的完整实现指南

## 📋 目录

- [WebSocket架构概览](#websocket架构概览)
- [消息协议规范](#消息协议规范)
- [服务实现详解](#服务实现详解)
- [状态管理集成](#状态管理集成)
- [错误处理和重连](#错误处理和重连)
- [最佳实践](#最佳实践)

## 🏗️ WebSocket架构概览

### 通信架构

```
Flutter客户端                    Python后端服务器
    │                               │
    ├── WebSocketService           ├── WebSocket Handler
    ├── HandshakeService           ├── Session Manager
    ├── MessageParser              ├── Message Router
    └── ConnectionManager          └── Response Generator
              │                               │
              └──── WebSocket Connection ─────┘
                   ws://192.168.110.199:8000/
```

### 核心组件

- **WebSocketService**: WebSocket连接管理
- **HandshakeService**: 握手流程处理
- **ConnectionProvider**: 连接状态管理
- **MessageParser**: 消息序列化/反序列化
- **ErrorHandler**: 错误处理和重连逻辑

## 📡 消息协议规范

### 1. 连接握手流程

#### Hello消息（客户端 → 服务器）
```json
{
  "id": "uuid-generated-by-client",
  "type": "hello",
  "version": 1,
  "transport": "websocket",
  "device_id": "flutter_client_001",
  "device_info": {
    "platform": "android",
    "model": "YT3002", 
    "os_version": "7.0"
  },
  "audio_params": {
    "format": "opus",
    "sample_rate": 16000,
    "channels": 1,
    "frame_duration": 60
  }
}
```

#### Hello响应（服务器 → 客户端）
```json
{
  "id": "original-hello-id",
  "type": "hello",
  "session_id": "uuid-generated-by-server",
  "version": 1,
  "transport": "websocket",
  "server_info": {
    "version": "1.0.0",
    "capabilities": ["chat", "voice", "tts", "stt"]
  },
  "audio_params": {
    "format": "opus",
    "sample_rate": 16000,
    "channels": 1,
    "frame_duration": 60
  }
}
```

### 2. 聊天消息

#### Chat消息（客户端 → 服务器）
```json
{
  "id": "uuid-generated-by-client",
  "type": "chat", 
  "content": "用户输入的文字内容",
  "session_id": "session-uuid",
  "device_id": "flutter_client_001",
  "timestamp": "2025-07-22T10:30:00Z"
}
```

#### Response消息（服务器 → 客户端）
```json
{
  "id": "original-chat-id",
  "type": "response",
  "content": "AI助手的回复内容",
  "session_id": "session-uuid",
  "timestamp": "2025-07-22T10:30:05Z"
}
```

### 3. 语音控制消息

#### Listen消息（客户端 → 服务器）
```json
{
  "id": "uuid-generated-by-client",
  "type": "listen",
  "state": "start|stop|detect",
  "mode": "auto|manual",
  "session_id": "session-uuid",
  "device_id": "flutter_client_001",
  "timestamp": "2025-07-22T10:30:00Z"
}
```

### 4. TTS消息（服务器 → 客户端）

#### TTS开始
```json
{
  "type": "tts",
  "state": "start",
  "text": "开始语音合成",
  "session_id": "session-uuid"
}
```

#### TTS句子片段
```json
{
  "type": "tts", 
  "state": "sentence_start",
  "text": "这是一个句子片段",
  "session_id": "session-uuid"
}
```

#### TTS结束
```json
{
  "type": "tts",
  "state": "stop", 
  "session_id": "session-uuid"
}
```

### 5. STT消息（服务器 → 客户端）

```json
{
  "type": "stt",
  "text": "识别到的语音文字",
  "confidence": 0.95,
  "is_final": true,
  "session_id": "session-uuid"
}
```

### 6. 音频数据传输

音频数据使用二进制帧传输：
- **格式**: Opus编码的二进制数据
- **帧长**: 60ms (960 samples at 16kHz)
- **传输方式**: WebSocket二进制消息

## 🔧 服务实现详解

### 1. WebSocketService实现

```dart
// lib/core/services/websocket_service.dart
class WebSocketService {
  WebSocket? _webSocket;
  final StreamController<dynamic> _messageController = StreamController.broadcast();
  final StreamController<ConnectionState> _connectionController = StreamController.broadcast();
  
  // 消息流
  Stream<dynamic> get messageStream => _messageController.stream;
  
  // 连接状态流
  Stream<ConnectionState> get connectionStateStream => _connectionController.stream;
  
  // 连接到WebSocket服务器
  Future<void> connect(String url, {Map<String, String>? headers}) async {
    try {
      AppLogger.webSocket.info('🔄 开始连接WebSocket: $url');
      
      _webSocket = await WebSocket.connect(url, headers: headers);
      _connectionController.add(ConnectionState.connected());
      
      AppLogger.webSocket.info('✅ WebSocket连接成功');
      
      // 监听消息
      _webSocket!.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );
      
    } catch (error, stackTrace) {
      AppLogger.error.severe('❌ WebSocket连接失败: $error', error, stackTrace);
      _connectionController.add(ConnectionState.failed(error.toString()));
      throw WebSocketException('连接失败: $error');
    }
  }
  
  // 发送JSON消息
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (_webSocket == null) {
      throw WebSocketException('WebSocket未连接');
    }
    
    try {
      final jsonMessage = jsonEncode(message);
      AppLogger.webSocket.fine('📤 发送消息: $jsonMessage');
      
      _webSocket!.add(jsonMessage);
      
    } catch (error) {
      AppLogger.error.severe('❌ 消息发送失败: $error', error);
      throw WebSocketException('消息发送失败: $error');
    }
  }
  
  // 发送二进制数据（音频）
  Future<void> sendBinaryData(Uint8List data) async {
    if (_webSocket == null) {
      throw WebSocketException('WebSocket未连接');
    }
    
    try {
      AppLogger.webSocket.finest('📤 发送二进制数据: ${data.length} bytes');
      _webSocket!.add(data);
      
    } catch (error) {
      AppLogger.error.severe('❌ 二进制数据发送失败: $error', error);
      throw WebSocketException('二进制数据发送失败: $error');
    }
  }
  
  // 处理接收到的消息
  void _onMessage(dynamic message) {
    try {
      AppLogger.webSocket.fine('📥 接收到消息: ${message.toString()}');
      
      if (message is String) {
        // JSON消息
        final decoded = jsonDecode(message);
        _messageController.add(decoded);
      } else if (message is List<int>) {
        // 二进制消息（TTS音频数据）
        final audioData = Uint8List.fromList(message);
        _messageController.add({
          'type': 'binary_audio',
          'data': audioData,
        });
      }
      
    } catch (error) {
      AppLogger.error.severe('❌ 消息解析失败: $error', error);
    }
  }
  
  // 处理连接错误
  void _onError(dynamic error) {
    AppLogger.webSocket.warning('⚠️ WebSocket错误: $error');
    _connectionController.add(ConnectionState.error(error.toString()));
  }
  
  // 处理连接断开
  void _onDisconnected() {
    AppLogger.webSocket.info('🔌 WebSocket连接已断开');
    _connectionController.add(ConnectionState.disconnected());
  }
  
  // 关闭连接
  Future<void> disconnect() async {
    if (_webSocket != null) {
      AppLogger.webSocket.info('🔌 主动断开WebSocket连接');
      await _webSocket!.close();
      _webSocket = null;
    }
  }
  
  // 清理资源
  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
    await _connectionController.close();
  }
}
```

### 2. HandshakeService实现

```dart
// lib/core/services/handshake_service.dart
class HandshakeService {
  final WebSocketService _webSocketService;
  final DeviceInfoService _deviceInfoService;
  
  HandshakeService(this._webSocketService, this._deviceInfoService);
  
  // 执行握手流程
  Future<HandshakeResult> performHandshake() async {
    try {
      AppLogger.webSocket.info('🤝 开始执行握手流程');
      
      // 1. 生成握手消息
      final helloMessage = await _createHelloMessage();
      
      // 2. 发送握手消息
      await _webSocketService.sendMessage(helloMessage);
      AppLogger.webSocket.info('📤 握手消息已发送');
      
      // 3. 等待服务器响应
      final response = await _waitForHandshakeResponse(helloMessage['id']);
      
      // 4. 解析握手结果
      return _parseHandshakeResponse(response);
      
    } catch (error, stackTrace) {
      AppLogger.error.severe('❌ 握手流程失败: $error', error, stackTrace);
      throw HandshakeException('握手失败: $error');
    }
  }
  
  // 创建Hello消息
  Future<Map<String, dynamic>> _createHelloMessage() async {
    final deviceInfo = await _deviceInfoService.getDeviceInfo();
    final messageId = const Uuid().v4();
    
    return {
      'id': messageId,
      'type': 'hello',
      'version': 1,
      'transport': 'websocket',
      'device_id': deviceInfo.deviceId,
      'device_info': {
        'platform': deviceInfo.platform,
        'model': deviceInfo.model,
        'os_version': deviceInfo.osVersion,
      },
      'audio_params': {
        'format': 'opus',
        'sample_rate': AudioConstants.sampleRate,
        'channels': AudioConstants.channels,
        'frame_duration': AudioConstants.frameDuration,
      },
    };
  }
  
  // 等待握手响应
  Future<Map<String, dynamic>> _waitForHandshakeResponse(String messageId) async {
    const timeout = Duration(seconds: 10);
    
    return await _webSocketService.messageStream
        .where((message) => 
            message is Map<String, dynamic> &&
            message['type'] == 'hello' &&
            message['id'] == messageId)
        .cast<Map<String, dynamic>>()
        .timeout(timeout)
        .first;
  }
  
  // 解析握手响应
  HandshakeResult _parseHandshakeResponse(Map<String, dynamic> response) {
    final sessionId = response['session_id'] as String?;
    final serverInfo = response['server_info'] as Map<String, dynamic>?;
    
    if (sessionId == null) {
      throw HandshakeException('服务器响应中缺少session_id');
    }
    
    AppLogger.webSocket.info('✅ 握手成功，会话ID: $sessionId');
    
    return HandshakeResult(
      sessionId: sessionId,
      serverVersion: serverInfo?['version'] ?? 'unknown',
      capabilities: List<String>.from(serverInfo?['capabilities'] ?? []),
    );
  }
}

@freezed
class HandshakeResult with _$HandshakeResult {
  const factory HandshakeResult({
    required String sessionId,
    required String serverVersion,
    required List<String> capabilities,
  }) = _HandshakeResult;
}
```

### 3. 连接状态管理

```dart
// lib/presentation/providers/connection_provider.dart
final connectionProvider = StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  final handshakeService = ref.watch(handshakeServiceProvider);
  final networkChecker = ref.watch(networkCheckerProvider);
  
  return ConnectionNotifier(webSocketService, handshakeService, networkChecker);
});

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  ConnectionNotifier(
    this._webSocketService,
    this._handshakeService,
    this._networkChecker,
  ) : super(const ConnectionState.initial()) {
    _initializeConnectionListener();
  }
  
  final WebSocketService _webSocketService;
  final HandshakeService _handshakeService;
  final NetworkChecker _networkChecker;
  
  StreamSubscription? _connectionSubscription;
  
  // 初始化连接状态监听
  void _initializeConnectionListener() {
    _connectionSubscription = _webSocketService.connectionStateStream.listen(
      (connectionState) {
        state = connectionState;
        
        // 连接成功后自动进行握手
        if (connectionState is ConnectionConnected) {
          _performHandshake();
        }
      },
    );
  }
  
  // 连接到服务器
  Future<void> connect() async {
    try {
      state = const ConnectionState.connecting();
      
      // 1. 检查网络连接
      final isNetworkAvailable = await _networkChecker.isConnected();
      if (!isNetworkAvailable) {
        throw NetworkException('网络不可用');
      }
      
      // 2. 连接WebSocket
      await _webSocketService.connect(ApiConstants.websocketUrl);
      
    } catch (error) {
      state = ConnectionState.failed(error.toString());
    }
  }
  
  // 执行握手
  Future<void> _performHandshake() async {
    try {
      state = const ConnectionState.handshaking();
      
      final result = await _handshakeService.performHandshake();
      
      state = ConnectionState.ready(
        sessionId: result.sessionId,
        serverVersion: result.serverVersion,
      );
      
    } catch (error) {
      state = ConnectionState.failed('握手失败: $error');
    }
  }
  
  // 断开连接
  Future<void> disconnect() async {
    await _webSocketService.disconnect();
    state = const ConnectionState.disconnected();
  }
  
  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState.initial() = ConnectionInitial;
  const factory ConnectionState.connecting() = ConnectionConnecting;
  const factory ConnectionState.connected() = ConnectionConnected;
  const factory ConnectionState.handshaking() = ConnectionHandshaking;
  const factory ConnectionState.ready({
    required String sessionId,
    required String serverVersion,
  }) = ConnectionReady;
  const factory ConnectionState.disconnected() = ConnectionDisconnected;
  const factory ConnectionState.failed(String error) = ConnectionFailed;
  const factory ConnectionState.error(String message) = ConnectionError;
}
```

## 🔄 错误处理和重连

### 自动重连机制

```dart
class ReconnectionManager {
  final WebSocketService _webSocketService;
  final Duration _initialDelay;
  final int _maxRetries;
  
  int _retryCount = 0;
  Timer? _reconnectTimer;
  bool _isReconnecting = false;
  
  ReconnectionManager(
    this._webSocketService, {
    Duration initialDelay = const Duration(seconds: 1),
    int maxRetries = 5,
  }) : _initialDelay = initialDelay, _maxRetries = maxRetries;
  
  // 开始重连尝试
  void startReconnection() {
    if (_isReconnecting) return;
    
    _isReconnecting = true;
    _retryCount = 0;
    
    AppLogger.webSocket.info('🔄 开始自动重连机制');
    _scheduleReconnect();
  }
  
  // 调度重连
  void _scheduleReconnect() {
    if (_retryCount >= _maxRetries) {
      AppLogger.webSocket.warning('❌ 达到最大重连次数，停止重连');
      _isReconnecting = false;
      return;
    }
    
    final delay = _calculateDelay(_retryCount);
    AppLogger.webSocket.info('⏳ 等待 ${delay.inSeconds}秒 后进行第${_retryCount + 1}次重连');
    
    _reconnectTimer = Timer(delay, () {
      _attemptReconnect();
    });
  }
  
  // 尝试重连
  Future<void> _attemptReconnect() async {
    _retryCount++;
    
    try {
      AppLogger.webSocket.info('🔄 第${_retryCount}次重连尝试');
      
      await _webSocketService.connect(ApiConstants.websocketUrl);
      
      AppLogger.webSocket.info('✅ 重连成功');
      _isReconnecting = false;
      _retryCount = 0;
      
    } catch (error) {
      AppLogger.webSocket.warning('❌ 第${_retryCount}次重连失败: $error');
      _scheduleReconnect(); // 继续重连
    }
  }
  
  // 计算退避延迟
  Duration _calculateDelay(int retryCount) {
    // 指数退避算法
    final delaySeconds = _initialDelay.inSeconds * math.pow(2, retryCount);
    return Duration(seconds: delaySeconds.toInt().clamp(1, 60));
  }
  
  // 停止重连
  void stopReconnection() {
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    AppLogger.webSocket.info('🛑 停止自动重连');
  }
  
  void dispose() {
    stopReconnection();
  }
}
```

### 消息队列和重试

```dart
class MessageQueue {
  final WebSocketService _webSocketService;
  final Queue<QueuedMessage> _messageQueue = Queue();
  final Set<String> _pendingMessages = {};
  
  MessageQueue(this._webSocketService);
  
  // 发送消息（带重试）
  Future<void> sendMessage(Map<String, dynamic> message) async {
    final messageId = message['id'] as String;
    final queuedMessage = QueuedMessage(
      id: messageId,
      message: message,
      timestamp: DateTime.now(),
      retryCount: 0,
    );
    
    await _sendWithRetry(queuedMessage);
  }
  
  // 带重试的发送
  Future<void> _sendWithRetry(QueuedMessage queuedMessage) async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);
    
    while (queuedMessage.retryCount < maxRetries) {
      try {
        await _webSocketService.sendMessage(queuedMessage.message);
        _pendingMessages.add(queuedMessage.id);
        
        AppLogger.webSocket.info('✅ 消息发送成功: ${queuedMessage.id}');
        return;
        
      } catch (error) {
        queuedMessage.retryCount++;
        AppLogger.webSocket.warning(
          '❌ 消息发送失败 (${queuedMessage.retryCount}/$maxRetries): $error'
        );
        
        if (queuedMessage.retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }
    
    // 重试失败，加入离线队列
    _messageQueue.add(queuedMessage);
    AppLogger.webSocket.severe('❌ 消息发送最终失败，已加入离线队列: ${queuedMessage.id}');
  }
  
  // 处理离线消息队列
  Future<void> processOfflineMessages() async {
    AppLogger.webSocket.info('📤 开始处理离线消息队列 (${_messageQueue.length}条)');
    
    while (_messageQueue.isNotEmpty) {
      final message = _messageQueue.removeFirst();
      message.retryCount = 0; // 重置重试次数
      
      await _sendWithRetry(message);
    }
  }
}

@freezed
class QueuedMessage with _$QueuedMessage {
  const factory QueuedMessage({
    required String id,
    required Map<String, dynamic> message,
    required DateTime timestamp,
    required int retryCount,
  }) = _QueuedMessage;
}
```

## 💡 最佳实践

### 1. 连接生命周期管理

```dart
class WebSocketLifecycleManager {
  final WebSocketService _webSocketService;
  final ReconnectionManager _reconnectionManager;
  
  // 应用状态监听
  void setupAppStateListener() {
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(
      onResumed: () {
        AppLogger.webSocket.info('📱 应用恢复，检查WebSocket连接');
        _checkAndReconnect();
      },
      onPaused: () {
        AppLogger.webSocket.info('📱 应用暂停，保持WebSocket连接');
        // 在暂停时保持连接，但可以减少心跳频率
      },
    ));
  }
  
  Future<void> _checkAndReconnect() async {
    if (!_webSocketService.isConnected) {
      _reconnectionManager.startReconnection();
    }
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResumed;
  final VoidCallback onPaused;
  
  _AppLifecycleObserver({required this.onResumed, required this.onPaused});
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      default:
        break;
    }
  }
}
```

### 2. 消息处理性能优化

```dart
class MessageProcessor {
  final StreamController<ProcessedMessage> _processedMessageController;
  
  // 消息处理管道
  void setupMessagePipeline(Stream<dynamic> messageStream) {
    messageStream
        .where(_isValidMessage)           // 过滤无效消息
        .map(_parseMessage)               // 解析消息
        .where(_isProcessableMessage)     // 过滤可处理消息
        .asyncMap(_processMessage)        // 异步处理消息
        .handleError(_handleError)        // 错误处理
        .listen(_forwardMessage);         // 转发处理结果
  }
  
  bool _isValidMessage(dynamic message) {
    return message is Map<String, dynamic> && message.containsKey('type');
  }
  
  ProcessedMessage _parseMessage(dynamic rawMessage) {
    final message = rawMessage as Map<String, dynamic>;
    return ProcessedMessage.fromJson(message);
  }
  
  bool _isProcessableMessage(ProcessedMessage message) {
    const supportedTypes = {'chat', 'response', 'tts', 'stt', 'hello'};
    return supportedTypes.contains(message.type);
  }
  
  Future<ProcessedMessage> _processMessage(ProcessedMessage message) async {
    // 根据消息类型进行特定处理
    switch (message.type) {
      case 'response':
        return _processResponseMessage(message);
      case 'tts':
        return _processTtsMessage(message);
      default:
        return message;
    }
  }
  
  void _handleError(Object error, StackTrace stackTrace) {
    AppLogger.error.severe('消息处理出错: $error', error, stackTrace);
  }
  
  void _forwardMessage(ProcessedMessage message) {
    _processedMessageController.add(message);
  }
}
```

### 3. 连接状态UI反馈

```dart
class ConnectionStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionProvider);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(connectionState),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(connectionState),
          SizedBox(width: 4),
          Text(
            _getStatusText(connectionState),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(ConnectionState state) {
    return state.when(
      initial: () => Colors.grey,
      connecting: () => Colors.orange,
      connected: () => Colors.blue,
      handshaking: () => Colors.purple,
      ready: (_, __) => Colors.green,
      disconnected: () => Colors.red,
      failed: (_) => Colors.red,
      error: (_) => Colors.red,
    );
  }
  
  Widget _buildStatusIcon(ConnectionState state) {
    return state.when(
      initial: () => Icon(Icons.wifi_off, color: Colors.white, size: 14),
      connecting: () => SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      ),
      connected: () => Icon(Icons.wifi, color: Colors.white, size: 14),
      handshaking: () => Icon(Icons.handshake, color: Colors.white, size: 14),
      ready: (_, __) => Icon(Icons.check_circle, color: Colors.white, size: 14),
      disconnected: () => Icon(Icons.wifi_off, color: Colors.white, size: 14),
      failed: (_) => Icon(Icons.error, color: Colors.white, size: 14),
      error: (_) => Icon(Icons.warning, color: Colors.white, size: 14),
    );
  }
  
  String _getStatusText(ConnectionState state) {
    return state.when(
      initial: () => '未连接',
      connecting: () => '连接中',
      connected: () => '已连接',
      handshaking: () => '握手中',
      ready: (_, __) => '已就绪',
      disconnected: () => '已断开',
      failed: (_) => '连接失败',
      error: (_) => '连接错误',
    );
  }
}
```

## 📚 相关资源

- [WebSocket API文档](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
- [Dart WebSocket库](https://api.dart.dev/stable/dart-io/WebSocket-class.html)
- [项目WebSocket实现](../lib/core/services/websocket_service.dart)
- [后端API规范](../../../xiaozhi-esp32-server/main/xiaozhi-server/docs/)

---

**最后更新**: 2025-07-22
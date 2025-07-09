# Lumi Assistant - 开发指南

## 快速开始

### 前置要求
- Flutter SDK 3.16+
- Android Studio / VS Code
- Android设备或模拟器
- 后端服务运行在 `localhost:8000`

### 开发环境配置
```bash
# 1. 检查Flutter环境
flutter doctor

# 2. 克隆项目（如果需要）
git clone [项目地址]
cd lumi-assistant

# 3. 安装依赖
flutter pub get

# 4. 运行项目
flutter run
```

## 开发规范

### 代码规范

#### 1. 文件命名
- 文件名使用小写加下划线: `chat_service.dart`
- 类名使用大驼峰: `ChatService`
- 变量和方法名使用小驼峰: `sendMessage`

#### 2. 目录结构规范
```
lib/
├── core/           # 核心功能，不依赖具体业务
├── data/           # 数据层，实现Repository
├── domain/         # 业务层，定义Entity和UseCase
└── presentation/   # 展示层，UI相关代码
```

#### 3. 导入顺序
```dart
// 1. Dart核心库
import 'dart:async';
import 'dart:convert';

// 2. Flutter框架
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 第三方库
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';

// 4. 项目内部导入
import '../core/constants/api_constants.dart';
import '../data/models/chat_message_model.dart';
```

#### 4. 注释规范
```dart
/// WebSocket连接服务
/// 
/// 负责管理与后端的WebSocket连接，包括：
/// - 连接建立和断开
/// - 消息发送和接收
/// - 重连机制
/// - 状态管理
class WebSocketService {
  /// 连接到WebSocket服务器
  /// 
  /// [url] WebSocket服务器地址
  /// 返回连接是否成功
  Future<bool> connect(String url) async {
    // 实现连接逻辑
  }
}
```

### Git提交规范

#### 提交消息格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

#### 类型说明
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

#### 示例
```
feat(chat): 实现基础聊天消息发送功能

- 添加ChatService类处理消息发送
- 实现消息状态管理
- 添加发送失败重试机制

Closes #123
```

## 架构指南

### 状态管理

#### 使用Riverpod + Hooks
```dart
// 1. 定义状态
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  
  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });
  
  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 2. 定义状态管理器
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._webSocketService) : super(const ChatState());
  
  final WebSocketService _webSocketService;
  
  Future<void> sendMessage(String content) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _webSocketService.sendChatMessage(content);
      // 添加消息到本地状态
      final message = ChatMessage(
        id: DateTime.now().toString(),
        content: content,
        type: MessageType.user,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, message],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// 3. 定义Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final webSocketService = ref.read(webSocketServiceProvider);
  return ChatNotifier(webSocketService);
});

// 4. 在UI中使用
class ChatPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);
    
    return Scaffold(
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: ListView.builder(
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: chatState.messages[index],
                );
              },
            ),
          ),
          // 输入框
          ChatInput(
            onSend: chatNotifier.sendMessage,
            isLoading: chatState.isLoading,
          ),
        ],
      ),
    );
  }
}
```

### 错误处理

#### 统一错误处理
```dart
// 1. 定义错误类型
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
}

class NetworkException extends AppException {
  const NetworkException(String message, {String? code}) 
      : super(message, code: code);
}

class WebSocketException extends AppException {
  const WebSocketException(String message, {String? code}) 
      : super(message, code: code);
}

// 2. 错误处理器
class ErrorHandler {
  static String getErrorMessage(Exception error) {
    if (error is NetworkException) {
      return '网络连接失败，请检查网络设置';
    } else if (error is WebSocketException) {
      return 'WebSocket连接异常，正在尝试重连';
    } else {
      return '发生未知错误，请稍后重试';
    }
  }
  
  static void logError(Exception error, StackTrace stackTrace) {
    // 记录错误日志
    print('Error: $error');
    print('StackTrace: $stackTrace');
  }
}

// 3. 在状态管理中使用
class ChatNotifier extends StateNotifier<ChatState> {
  Future<void> sendMessage(String content) async {
    try {
      // 发送消息逻辑
    } catch (e, stackTrace) {
      ErrorHandler.logError(e as Exception, stackTrace);
      final errorMessage = ErrorHandler.getErrorMessage(e as Exception);
      state = state.copyWith(error: errorMessage);
    }
  }
}
```

### 网络通信

#### WebSocket连接管理
```dart
class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  
  /// 连接WebSocket
  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
      
      // 监听消息
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
      
      // 发送Hello消息
      await _sendHelloMessage();
      
      // 启动心跳
      _startHeartbeat();
      
      _reconnectAttempts = 0;
    } catch (e) {
      throw WebSocketException('连接失败: $e');
    }
  }
  
  /// 发送消息
  void sendMessage(Map<String, dynamic> message) {
    if (_channel?.closeCode == null) {
      _channel!.sink.add(jsonEncode(message));
    } else {
      throw WebSocketException('连接已断开');
    }
  }
  
  /// 处理接收消息
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data) as Map<String, dynamic>;
      _messageController?.add(message);
    } catch (e) {
      print('解析消息失败: $e');
    }
  }
  
  /// 处理连接错误
  void _handleError(error) {
    print('WebSocket错误: $error');
    _attemptReconnect();
  }
  
  /// 处理连接断开
  void _handleDisconnect() {
    print('WebSocket连接断开');
    _stopHeartbeat();
    _attemptReconnect();
  }
  
  /// 尝试重连
  void _attemptReconnect() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);
      
      _reconnectTimer = Timer(delay, () async {
        try {
          await connect(_lastUrl); // 保存上次连接的URL
        } catch (e) {
          print('重连失败: $e');
        }
      });
    }
  }
  
  /// 启动心跳
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      try {
        sendMessage({'type': 'ping', 'timestamp': DateTime.now().millisecondsSinceEpoch});
      } catch (e) {
        print('心跳发送失败: $e');
      }
    });
  }
  
  /// 停止心跳
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
  
  /// 断开连接
  void disconnect() {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messageController?.close();
  }
}
```

## 测试指南

### 单元测试

#### 测试状态管理
```dart
// test/presentation/providers/chat_provider_test.dart
void main() {
  group('ChatNotifier', () {
    late MockWebSocketService mockWebSocketService;
    late ChatNotifier chatNotifier;
    
    setUp(() {
      mockWebSocketService = MockWebSocketService();
      chatNotifier = ChatNotifier(mockWebSocketService);
    });
    
    test('should send message successfully', () async {
      // Arrange
      const message = 'Hello World';
      when(mockWebSocketService.sendChatMessage(message))
          .thenAnswer((_) async {});
      
      // Act
      await chatNotifier.sendMessage(message);
      
      // Assert
      expect(chatNotifier.state.messages.length, 1);
      expect(chatNotifier.state.messages.first.content, message);
      expect(chatNotifier.state.isLoading, false);
    });
    
    test('should handle error when sending message fails', () async {
      // Arrange
      const message = 'Hello World';
      when(mockWebSocketService.sendChatMessage(message))
          .thenThrow(NetworkException('Connection failed'));
      
      // Act
      await chatNotifier.sendMessage(message);
      
      // Assert
      expect(chatNotifier.state.error, isNotNull);
      expect(chatNotifier.state.isLoading, false);
    });
  });
}
```

#### 运行测试
```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/presentation/providers/chat_provider_test.dart

# 生成测试覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Widget测试

```dart
// test/presentation/widgets/chat_input_test.dart
void main() {
  group('ChatInput Widget', () {
    testWidgets('should display input field and send button', (tester) async {
      // Arrange
      bool messageSent = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChatInput(
            onSend: (message) {
              messageSent = true;
            },
          ),
        ),
      );
      
      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });
    
    testWidgets('should call onSend when send button is pressed', (tester) async {
      // Arrange
      String? sentMessage;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChatInput(
            onSend: (message) {
              sentMessage = message;
            },
          ),
        ),
      );
      
      // Act
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      
      // Assert
      expect(sentMessage, 'Test message');
    });
  });
}
```

## 调试指南

### 日志记录

```dart
// core/utils/logger.dart
class Logger {
  static const String _tag = 'LumiAssistant';
  
  static void debug(String message) {
    print('[$_tag] DEBUG: $message');
  }
  
  static void info(String message) {
    print('[$_tag] INFO: $message');
  }
  
  static void warning(String message) {
    print('[$_tag] WARNING: $message');
  }
  
  static void error(String message, [Exception? error, StackTrace? stackTrace]) {
    print('[$_tag] ERROR: $message');
    if (error != null) {
      print('Exception: $error');
    }
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }
}
```

### 性能监控

```dart
// core/utils/performance_monitor.dart
class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};
  
  static void startTimer(String name) {
    _stopwatches[name] = Stopwatch()..start();
  }
  
  static void endTimer(String name) {
    final stopwatch = _stopwatches[name];
    if (stopwatch != null) {
      stopwatch.stop();
      Logger.info('$name took ${stopwatch.elapsedMilliseconds}ms');
      _stopwatches.remove(name);
    }
  }
}

// 使用示例
Future<void> sendMessage(String content) async {
  PerformanceMonitor.startTimer('sendMessage');
  
  try {
    // 发送消息逻辑
  } finally {
    PerformanceMonitor.endTimer('sendMessage');
  }
}
```

## 部署指南

### 构建Release版本

```bash
# 构建APK
flutter build apk --release

# 构建App Bundle（推荐用于Play Store）
flutter build appbundle --release

# 构建分架构APK
flutter build apk --split-per-abi --release
```

### 版本管理

```yaml
# pubspec.yaml
version: 1.0.0+1
# 格式: major.minor.patch+buildNumber
```

### 混淆配置

```
# android/app/proguard-rules.pro
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
```

---

**文档版本**: v1.0  
**创建时间**: 2025-07-08  
**维护者**: Claude
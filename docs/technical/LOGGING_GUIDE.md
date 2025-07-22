# 📝 日志系统使用指南

> 在 Lumi Assistant 项目中使用 Logging 系统的完整指南

## 📋 目录

- [日志系统架构](#日志系统架构)
- [日志级别和使用场景](#日志级别和使用场景)
- [AppLogger使用指南](#applogger使用指南)
- [最佳实践](#最佳实践)
- [性能和调试](#性能和调试)

## 🏗️ 日志系统架构

### 核心组件

项目采用分层日志系统，包含以下组件：

```
lib/core/utils/
├── app_logger.dart          # 统一日志管理器
└── loggers.dart            # 分组日志记录器
```

### 架构设计

```dart
// 核心架构
AppLogger (统一管理)
  ├── WebSocket Logger    # WebSocket连接和消息
  ├── Audio Logger       # 音频录制和播放
  ├── Chat Logger        # 聊天功能
  ├── UI Logger          # 用户界面事件
  ├── Service Logger     # 服务层操作
  └── Error Logger       # 错误和异常
```

## 📊 日志级别和使用场景

### 1. FINEST (最详细)
**使用场景**：内部实现细节，通常在开发调试时使用

```dart
AppLogger.audio.finest('开始初始化音频编码器配置');
AppLogger.webSocket.finest('WebSocket心跳检查');
```

### 2. FINER (更详细)
**使用场景**：详细的执行流程，函数调用跟踪

```dart
AppLogger.service.finer('HandshakeService.sendHello() 开始执行');
AppLogger.audio.finer('AudioService.startRecording() - 权限检查通过');
```

### 3. FINE (详细)
**使用场景**：详细的调试信息，开发阶段的详细日志

```dart
AppLogger.chat.fine('聊天消息发送准备完成: $messageContent');
AppLogger.webSocket.fine('WebSocket连接参数: $connectionParams');
```

### 4. INFO (信息)
**使用场景**：重要的业务流程信息，正常操作的关键步骤

```dart
AppLogger.webSocket.info('WebSocket连接成功: $serverUrl');
AppLogger.chat.info('消息发送成功，消息ID: $messageId');
AppLogger.audio.info('音频录制开始，采样率: ${AudioConstants.sampleRate}Hz');
```

### 5. WARNING (警告)
**使用场景**：潜在问题，但不影响核心功能的情况

```dart
AppLogger.webSocket.warning('WebSocket连接不稳定，尝试重连');
AppLogger.audio.warning('音频权限未授予，已请求用户授权');
AppLogger.chat.warning('消息发送超时，将进行重试');
```

### 6. SEVERE (严重)
**使用场景**：严重错误，影响核心功能的问题

```dart
AppLogger.error.severe('WebSocket连接失败: $error');
AppLogger.error.severe('音频录制初始化失败: $exception');
AppLogger.error.severe('聊天服务崩溃: $error');
```

## 🎯 AppLogger使用指南

### 基本使用

```dart
import 'package:lumi_assistant/core/utils/app_logger.dart';

class ExampleService {
  Future<void> performOperation() async {
    // 1. 记录操作开始
    AppLogger.service.info('开始执行重要操作');
    
    try {
      // 2. 记录详细过程
      AppLogger.service.fine('正在准备操作参数');
      
      final result = await someAsyncOperation();
      
      // 3. 记录成功结果
      AppLogger.service.info('操作成功完成，结果: $result');
      
    } catch (e, stackTrace) {
      // 4. 记录错误
      AppLogger.error.severe('操作失败: $e', e, stackTrace);
      rethrow;
    }
  }
}
```

### 分类日志使用

```dart
// WebSocket相关
class WebSocketService {
  Future<void> connect(String url) async {
    AppLogger.webSocket.info('🔄 开始连接WebSocket: $url');
    
    try {
      _webSocket = await WebSocket.connect(url);
      AppLogger.webSocket.info('✅ WebSocket连接成功');
      
      _webSocket.listen(
        (message) {
          AppLogger.webSocket.fine('📥 接收到消息: ${message.toString()}');
          _handleMessage(message);
        },
        onError: (error) {
          AppLogger.webSocket.warning('⚠️ WebSocket错误: $error');
        },
        onDone: () {
          AppLogger.webSocket.info('🔌 WebSocket连接关闭');
        },
      );
      
    } catch (e, stackTrace) {
      AppLogger.error.severe('❌ WebSocket连接失败: $e', e, stackTrace);
      throw WebSocketException('连接失败: $e');
    }
  }
}

// 音频相关
class AudioService {
  Future<void> startRecording() async {
    AppLogger.audio.info('🎤 开始音频录制');
    
    // 权限检查
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      AppLogger.audio.warning('⚠️ 录音权限未授予');
      throw AudioException('录音权限被拒绝');
    }
    
    try {
      await _recorder.start();
      AppLogger.audio.info('✅ 音频录制已开始');
      
    } catch (e) {
      AppLogger.error.severe('❌ 音频录制启动失败: $e', e);
      throw AudioException('录制启动失败: $e');
    }
  }
}

// 聊天功能相关
class ChatService {
  Future<void> sendMessage(String content) async {
    final messageId = _generateMessageId();
    AppLogger.chat.info('💬 发送聊天消息，ID: $messageId');
    AppLogger.chat.fine('消息内容: $content');
    
    try {
      await _webSocketService.sendMessage({
        'id': messageId,
        'type': 'chat',
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      AppLogger.chat.info('✅ 消息发送成功，ID: $messageId');
      
    } catch (e) {
      AppLogger.error.severe('❌ 消息发送失败，ID: $messageId, 错误: $e', e);
      throw ChatException('消息发送失败: $e');
    }
  }
}
```

### UI事件日志

```dart
class ChatPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      AppLogger.ui.info('📱 ChatPage 初始化完成');
      return () {
        AppLogger.ui.info('📱 ChatPage 销毁');
      };
    }, []);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('聊天'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            AppLogger.ui.fine('🔙 用户点击返回按钮');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final chatState = ref.watch(chatProvider);
                AppLogger.ui.fine('📝 渲染消息列表，消息数量: ${chatState.messages.length}');
                
                return ListView.builder(
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    return ChatMessageItem(
                      message: chatState.messages[index],
                    );
                  },
                );
              },
            ),
          ),
          
          // 输入区域
          _buildInputArea(ref),
        ],
      ),
    );
  }
  
  Widget _buildInputArea(WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onSubmitted: (text) {
                AppLogger.ui.info('⌨️ 用户提交消息: ${text.length}字符');
                _sendMessage(ref, text);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              AppLogger.ui.fine('📤 用户点击发送按钮');
              // 发送逻辑
            },
          ),
        ],
      ),
    );
  }
}
```

## 💡 最佳实践

### 1. 日志内容规范

```dart
// ✅ 好的日志格式
AppLogger.webSocket.info('🔄 状态变化: ${oldState} → ${newState} (原因: ${reason})');
AppLogger.audio.info('🎤 录制统计: 时长 ${duration}ms, 大小 ${bytes}bytes');
AppLogger.chat.info('💬 消息处理: 类型=${type}, 状态=${status}');

// ❌ 避免的日志格式
AppLogger.service.info('操作'); // 信息不足
AppLogger.error.severe(e.toString()); // 缺少上下文
AppLogger.webSocket.info('$data'); // 可能包含敏感信息
```

### 2. 结构化日志

```dart
class StructuredLogger {
  static void logWebSocketEvent({
    required String event,
    required String state,
    String? reason,
    Map<String, dynamic>? metadata,
  }) {
    final logData = {
      'event': event,
      'state': state,
      if (reason != null) 'reason': reason,
      if (metadata != null) ...metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    AppLogger.webSocket.info('WebSocket事件: ${jsonEncode(logData)}');
  }
}

// 使用示例
StructuredLogger.logWebSocketEvent(
  event: 'connection_state_change',
  state: 'connected',
  reason: '握手成功',
  metadata: {
    'server_url': serverUrl,
    'session_id': sessionId,
  },
);
```

### 3. 性能敏感区域的日志

```dart
class PerformanceLogger {
  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();
    AppLogger.service.fine('⏱️ 开始执行: $operation');
    
    try {
      final result = await action();
      stopwatch.stop();
      AppLogger.service.info('✅ $operation 完成，耗时: ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      AppLogger.error.severe('❌ $operation 失败，耗时: ${stopwatch.elapsedMilliseconds}ms，错误: $e', e);
      rethrow;
    }
  }
}

// 使用示例
final result = await PerformanceLogger.measureAsync(
  '音频编码处理',
  () => audioEncoder.encode(audioData),
);
```

### 4. 条件日志记录

```dart
class ConditionalLogger {
  // 只在调试模式下记录详细日志
  static void debugOnly(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      AppLogger.service.fine(message, error, stackTrace);
    }
  }
  
  // 基于配置的日志级别
  static void logWithLevel(Level level, String message) {
    if (AppLogger.shouldLog(level)) {
      switch (level) {
        case Level.INFO:
          AppLogger.service.info(message);
          break;
        case Level.WARNING:
          AppLogger.service.warning(message);
          break;
        case Level.SEVERE:
          AppLogger.error.severe(message);
          break;
      }
    }
  }
}
```

### 5. 异步操作日志跟踪

```dart
class AsyncOperationTracker {
  static Future<T> trackOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
    Map<String, dynamic>? metadata,
  }) async {
    final operationId = _generateOperationId();
    
    AppLogger.service.info('🚀 开始异步操作: $operationName (ID: $operationId)');
    if (metadata != null) {
      AppLogger.service.fine('操作参数: ${jsonEncode(metadata)}');
    }
    
    try {
      final result = await operation();
      AppLogger.service.info('✅ 异步操作完成: $operationName (ID: $operationId)');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error.severe('❌ 异步操作失败: $operationName (ID: $operationId), 错误: $e', e, stackTrace);
      rethrow;
    }
  }
  
  static String _generateOperationId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// 使用示例
final response = await AsyncOperationTracker.trackOperation(
  operationName: 'WebSocket消息发送',
  operation: () => webSocketService.sendMessage(message),
  metadata: {
    'message_type': message.type,
    'message_id': message.id,
  },
);
```

## 🚀 性能和调试

### 1. 日志级别配置

```dart
// lib/core/utils/app_logger.dart
class AppLogger {
  // 开发环境：显示所有日志
  // 生产环境：只显示INFO及以上级别
  static Level get currentLevel {
    if (kDebugMode) {
      return Level.FINE;  // 开发模式显示详细日志
    } else if (kProfileMode) {
      return Level.INFO;  // Profile模式显示重要信息
    } else {
      return Level.WARNING;  // 发布版本只显示警告和错误
    }
  }
  
  static bool shouldLog(Level level) {
    return level.value >= currentLevel.value;
  }
}
```

### 2. 日志过滤和搜索

```dart
// 在IDE中使用过滤器查看特定类型的日志
// - 搜索 "🔄" 查看状态变化日志
// - 搜索 "❌" 查看错误日志
// - 搜索 "WebSocket" 查看WebSocket相关日志
// - 搜索 "💬" 查看聊天相关日志

class LogFilter {
  static const String CONNECTION_EVENTS = '🔄';
  static const String ERROR_EVENTS = '❌';
  static const String SUCCESS_EVENTS = '✅';
  static const String CHAT_EVENTS = '💬';
  static const String AUDIO_EVENTS = '🎤';
  static const String UI_EVENTS = '📱';
}
```

### 3. 生产环境日志收集

```dart
class ProductionLogger {
  static void setupProductionLogging() {
    if (!kDebugMode) {
      // 在生产环境中，可以将关键日志发送到分析服务
      Logger.root.onRecord.listen((record) {
        if (record.level >= Level.WARNING) {
          _sendToAnalyticsService(record);
        }
      });
    }
  }
  
  static void _sendToAnalyticsService(LogRecord record) {
    // 发送到Firebase、Sentry等服务
    // 注意：不要发送敏感信息
  }
}
```

### 4. 内存使用优化

```dart
class MemoryEfficientLogger {
  // 避免在生产环境中记录大量详细日志
  static void logLargeData(String prefix, dynamic data) {
    if (kDebugMode) {
      // 开发环境：记录完整数据
      AppLogger.service.fine('$prefix: ${jsonEncode(data)}');
    } else {
      // 生产环境：只记录摘要
      final summary = _generateDataSummary(data);
      AppLogger.service.info('$prefix: $summary');
    }
  }
  
  static String _generateDataSummary(dynamic data) {
    if (data is List) {
      return '列表数据，长度: ${data.length}';
    } else if (data is Map) {
      return '映射数据，键数量: ${data.keys.length}';
    } else if (data is String) {
      return '字符串数据，长度: ${data.length}字符';
    }
    return '数据类型: ${data.runtimeType}';
  }
}
```

## 🐛 调试技巧

### 1. 调试模式增强日志

```dart
extension DebuggingExtensions on AppLogger {
  static void debugDump(String title, Object? data) {
    if (kDebugMode) {
      service.fine('🔍 DEBUG DUMP: $title');
      service.fine('类型: ${data.runtimeType}');
      service.fine('内容: $data');
      service.fine('━━━━━━━━━━━━━━━━━━━━');
    }
  }
  
  static void traceCall(String methodName, [Map<String, dynamic>? params]) {
    if (kDebugMode) {
      final paramsStr = params != null ? jsonEncode(params) : '无参数';
      service.finest('🔍 TRACE: $methodName($paramsStr)');
    }
  }
}

// 使用示例
AppLogger.debugDump('聊天状态', chatState);
AppLogger.traceCall('sendMessage', {'content': message, 'type': 'text'});
```

### 2. 异常追踪

```dart
class ExceptionTracker {
  static void trackException(
    String context,
    Object exception,
    StackTrace stackTrace, {
    Map<String, dynamic>? additionalInfo,
  }) {
    final errorId = _generateErrorId();
    
    AppLogger.error.severe(
      '🚨 异常追踪 [ID: $errorId]\n'
      '上下文: $context\n'
      '异常: $exception\n'
      '${additionalInfo != null ? '附加信息: ${jsonEncode(additionalInfo)}\n' : ''}'
      '堆栈跟踪:\n$stackTrace',
      exception,
      stackTrace,
    );
  }
  
  static String _generateErrorId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
```

## 📚 相关资源

- [Dart Logging包文档](https://pub.dev/packages/logging)
- [Flutter调试指南](https://flutter.dev/docs/testing/debugging)
- [项目日志实现](../lib/core/utils/)

---

**最后更新**: 2025-07-22
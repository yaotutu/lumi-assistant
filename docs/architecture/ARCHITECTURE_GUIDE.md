# 🏗️ 项目架构指南

> Lumi Assistant 项目的完整架构设计和实现指南

## 📋 目录

- [整体架构概览](#整体架构概览)
- [分层架构详解](#分层架构详解)
- [目录结构设计](#目录结构设计)
- [组件协作模式](#组件协作模式)
- [设计原则和最佳实践](#设计原则和最佳实践)

## 🎯 整体架构概览

### 架构模式

项目采用**现代化 Clean Architecture + MVVM 变种**，结合 Flutter 最佳实践：

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│    (Pages, Widgets, Providers)         │
├─────────────────────────────────────────┤
│           Application Layer             │
│         (Use Cases, Services)           │
├─────────────────────────────────────────┤
│             Domain Layer                │
│      (Entities, Repository Interface)   │
├─────────────────────────────────────────┤
│              Data Layer                 │
│   (Models, Repositories, Data Sources)  │
├─────────────────────────────────────────┤
│         Infrastructure Layer            │
│    (External APIs, Device Services)     │
└─────────────────────────────────────────┘
```

### 核心技术栈

- **状态管理**: hooks_riverpod (替代传统 Provider)
- **数据序列化**: Freezed + json_annotation
- **网络通信**: WebSocket (web_socket_channel)
- **音频处理**: 原生 Android AudioTrack + Opus编解码
- **依赖注入**: Riverpod Provider系统
- **响应式编程**: Stream + Future + AsyncValue

## 🏗️ 分层架构详解

### 1. Presentation Layer (表现层)

**职责**：UI渲染、用户交互、状态展示

```
presentation/
├── pages/              # 页面级组件
│   ├── home/          # 主页相关
│   ├── chat/          # 聊天相关
│   └── settings/      # 设置相关
├── widgets/           # 通用组件
│   ├── chat/         # 聊天组件
│   ├── floating_chat/ # 悬浮聊天
│   └── virtual_character/ # 虚拟角色
├── providers/         # 状态管理
└── themes/           # 主题样式
```

#### 页面导向架构

每个页面采用独立的目录结构：

```dart
// 示例：chat页面结构
pages/chat/
├── chat_page.dart           # 主页面组件
└── widgets/                 # 页面专用组件
    ├── chat_background.dart
    ├── chat_input_section.dart
    ├── chat_interface.dart
    └── chat_message_item.dart
```

#### 状态管理架构

```dart
// Provider定义
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return ChatNotifier(webSocketService);
});

// HookConsumerWidget使用
class ChatPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final controller = useTextEditingController();
    
    return Scaffold(
      body: _buildChatInterface(context, ref, chatState),
    );
  }
}
```

### 2. Core Layer (核心层)

**职责**：业务逻辑、服务管理、工具类

```
core/
├── constants/         # 常量配置
├── services/         # 核心服务
├── utils/           # 工具类
├── errors/          # 错误处理
├── config/          # 配置管理
└── network/         # 网络基础设施
```

#### 服务架构模式

```dart
// 服务基类
abstract class BaseService {
  bool get isInitialized;
  Future<void> initialize();
  Future<void> dispose();
}

// 具体服务实现
class WebSocketService extends BaseService {
  WebSocket? _webSocket;
  final StreamController<dynamic> _messageController;
  
  @override
  Future<void> initialize() async {
    // 初始化WebSocket连接
  }
  
  @override
  Future<void> dispose() async {
    await _webSocket?.close();
    await _messageController.close();
  }
}
```

#### 配置管理系统

```dart
// 双层配置架构
class AppSettings extends ChangeNotifier {
  // 静态默认值
  static const _defaultServerUrl = 'ws://192.168.110.199:8000';
  
  // 用户动态设置
  String? _userServerUrl;
  
  // 公共访问接口
  String get serverUrl => _userServerUrl ?? _defaultServerUrl;
  
  // 设置更新
  Future<void> updateServerUrl(String url) async {
    _userServerUrl = url;
    notifyListeners();
    await _saveSettings();
  }
}
```

### 3. Data Layer (数据层)

**职责**：数据模型、数据持久化、外部数据源

```
data/
├── models/          # 数据模型
├── repositories/    # 数据仓库实现
└── datasources/     # 数据源
```

#### 数据模型设计

```dart
// 使用Freezed创建不可变数据模型
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
    @Default(MessageStatus.sent) MessageStatus status,
    String? sessionId,
  }) = _ChatMessage;
  
  factory ChatMessage.fromJson(Map<String, Object?> json) =>
      _$ChatMessageFromJson(json);
}

// 状态模型
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    @Default(false) bool isConnected,
    String? error,
  }) = _ChatState;
}
```

### 4. Domain Layer (领域层)

**职责**：业务实体、仓库接口、用例定义

```
domain/
├── entities/        # 业务实体
├── repositories/    # 仓库接口
└── usecases/       # 用例
```

#### 仓库接口模式

```dart
// 抽象仓库接口
abstract class ChatRepository {
  Stream<ChatMessage> get messageStream;
  Future<void> sendMessage(ChatMessage message);
  Future<List<ChatMessage>> getMessageHistory();
}

// 数据层实现
class ChatRepositoryImpl implements ChatRepository {
  final WebSocketService _webSocketService;
  final LocalStorageService _storageService;
  
  @override
  Stream<ChatMessage> get messageStream => 
      _webSocketService.messageStream
          .where((msg) => msg['type'] == 'chat')
          .map((json) => ChatMessage.fromJson(json));
}
```

## 📁 目录结构设计

### 完整目录结构

```
lib/
├── main.dart                    # 应用入口
├── core/                       # 核心层
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── app_constants.dart
│   │   ├── audio_constants.dart
│   │   └── device_constants.dart
│   ├── services/               # 核心服务
│   │   ├── websocket_service.dart
│   │   ├── audio_service_android_style.dart
│   │   ├── handshake_service.dart
│   │   ├── device_control_service.dart
│   │   └── network_checker.dart
│   ├── utils/                  # 工具类
│   │   ├── app_logger.dart
│   │   ├── screen_utils.dart
│   │   └── emotion_mapper.dart
│   ├── errors/                 # 错误处理
│   │   ├── exceptions.dart
│   │   └── error_handler.dart
│   └── config/                 # 配置管理
│       ├── app_settings.dart
│       └── dynamic_config.dart
├── data/                       # 数据层
│   ├── models/                 # 数据模型
│   │   ├── message_model.dart
│   │   ├── chat_state.dart
│   │   ├── connection_state.dart
│   │   └── websocket_state.dart
│   ├── repositories/           # 数据仓库实现
│   └── datasources/           # 数据源
├── domain/                     # 领域层
│   ├── entities/              # 业务实体
│   ├── repositories/          # 仓库接口
│   └── usecases/             # 用例
└── presentation/              # 表现层
    ├── pages/                 # 页面
    │   ├── home/
    │   │   ├── home_page.dart
    │   │   └── widgets/
    │   ├── chat/
    │   │   ├── chat_page.dart
    │   │   └── widgets/
    │   └── settings/
    │       ├── settings_main_page.dart
    │       ├── settings_ui_page.dart
    │       └── settings_network_page.dart
    ├── widgets/               # 通用组件
    │   ├── chat/
    │   ├── floating_chat/
    │   ├── virtual_character/
    │   └── settings/
    ├── providers/             # 状态管理
    │   ├── chat_provider.dart
    │   ├── connection_provider.dart
    │   └── audio_provider.dart
    └── themes/               # 主题样式
        └── app_theme.dart
```

### 文件命名规范

- **文件名**: snake_case (例：`chat_service.dart`)
- **类名**: PascalCase (例：`ChatService`)
- **变量/方法**: camelCase (例：`sendMessage`)
- **常量**: SCREAMING_SNAKE_CASE (例：`DEFAULT_TIMEOUT`)

## 🔄 组件协作模式

### 数据流向

```
User Action → Widget → Provider → Service → Repository → Data Source
     ↑                                                           ↓
UI Update ← State Change ← Notifier ← Service ← Repository ← Response
```

### WebSocket消息处理流程

```dart
// 1. 服务层接收消息
class WebSocketService {
  void _handleMessage(dynamic message) {
    final decoded = jsonDecode(message);
    _messageController.add(decoded);
  }
}

// 2. Provider层处理业务逻辑
class ChatNotifier extends StateNotifier<ChatState> {
  void _initializeWebSocketListener() {
    _webSocketService.messageStream.listen((message) {
      switch (message['type']) {
        case 'response':
          _handleAiResponse(message);
          break;
        case 'tts':
          _handleTtsMessage(message);
          break;
      }
    });
  }
}

// 3. UI层响应状态变化
class ChatPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    
    return ListView.builder(
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) => 
          ChatMessageItem(message: chatState.messages[index]),
    );
  }
}
```

### 错误处理流程

```dart
// 1. 统一异常定义
@freezed
class AppException with _$AppException {
  const factory AppException.network(String message) = NetworkException;
  const factory AppException.webSocket(String message) = WebSocketException;
  const factory AppException.audio(String message) = AudioException;
}

// 2. 错误处理器
class ErrorHandler {
  static Future<T> withRetry<T>({
    required Future<T> Function() action,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await action();
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        await Future.delayed(delay * attempt);
      }
    }
    throw StateError('Unreachable');
  }
}

// 3. Provider中的错误处理
class ChatNotifier extends StateNotifier<ChatState> {
  Future<void> sendMessage(String content) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await ErrorHandler.withRetry(
        action: () => _webSocketService.sendMessage(content),
        maxRetries: 3,
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '消息发送失败: ${e.toString()}',
      );
    }
  }
}
```

## 💡 设计原则和最佳实践

### 1. SOLID原则应用

#### Single Responsibility Principle (单一职责)
```dart
// ✅ 好的设计 - 每个类职责单一
class WebSocketService {
  // 只负责WebSocket连接和消息传输
}

class MessageParser {
  // 只负责消息解析和格式化
}

class ChatNotifier {
  // 只负责聊天状态管理
}

// ❌ 避免的设计
class ChatService {
  // 既负责WebSocket连接，又负责UI状态管理，又负责消息解析
}
```

#### Open/Closed Principle (开闭原则)
```dart
// 抽象基类
abstract class AudioService {
  Future<void> startRecording();
  Future<void> stopRecording();
}

// 具体实现 - 对扩展开放
class AndroidAudioService extends AudioService {
  @override
  Future<void> startRecording() {
    // Android特定实现
  }
}

class IOSAudioService extends AudioService {
  @override
  Future<void> startRecording() {
    // iOS特定实现
  }
}

// 工厂模式 - 对修改关闭
class AudioServiceFactory {
  static AudioService createService() {
    if (Platform.isAndroid) return AndroidAudioService();
    if (Platform.isIOS) return IOSAudioService();
    throw UnsupportedError('平台不支持');
  }
}
```

### 2. 依赖倒置

```dart
// ✅ 依赖抽象而非具体实现
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  // 通过Provider系统注入依赖
  final webSocketService = ref.watch(webSocketServiceProvider);
  final errorHandler = ref.watch(errorHandlerProvider);
  return ChatNotifier(webSocketService, errorHandler);
});

// ChatNotifier不直接依赖具体的WebSocket实现
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._webSocketService, this._errorHandler);
  
  final WebSocketService _webSocketService;  // 依赖接口
  final ErrorHandler _errorHandler;          // 依赖接口
}
```

### 3. 组合优于继承

```dart
// ✅ 使用组合
class ChatPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          ChatBackground(),         // 组合：背景组件
          ChatMessageList(),        // 组合：消息列表
          ChatInputSection(),       // 组合：输入区域
        ],
      ),
    );
  }
}

// ❌ 避免深层继承
class ChatPage extends BasePage extends StatefulWidget {
  // 深层继承链难以维护
}
```

### 4. 响应式设计

```dart
// 屏幕适配
class ScreenUtils {
  static bool isLargeScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600;
  }
  
  static double getResponsiveWidth(BuildContext context, {
    required double mobile,
    required double tablet,
  }) {
    return isLargeScreen(context) ? tablet : mobile;
  }
}

// 响应式布局
Widget build(BuildContext context) {
  final isLarge = ScreenUtils.isLargeScreen(context);
  
  return isLarge 
      ? _buildLargeScreenLayout()
      : _buildMobileLayout();
}
```

### 5. 性能优化原则

#### 状态管理优化
```dart
// ✅ 细粒度状态分割
final chatMessagesProvider = Provider((ref) {
  return ref.watch(chatProvider.select((state) => state.messages));
});

final chatLoadingProvider = Provider((ref) {
  return ref.watch(chatProvider.select((state) => state.isLoading));
});

// 组件只监听需要的状态片段
class MessageList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider); // 只监听messages
    return ListView.builder(...);
  }
}
```

#### Widget构建优化
```dart
// ✅ 使用const构造函数
const ChatBackground();

// ✅ 提取静态组件
class _StaticHeader extends StatelessWidget {
  const _StaticHeader();
  
  @override
  Widget build(BuildContext context) {
    return Container(...); // 不会重建的部分
  }
}

// ✅ 使用Builder减少重建范围
Consumer(
  builder: (context, ref, child) {
    final isLoading = ref.watch(loadingProvider);
    return isLoading ? LoadingWidget() : child!;
  },
  child: const ExpensiveWidget(), // 只有loading状态变化时才重建
);
```

## 📚 相关资源

- [Clean Architecture概述](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter架构最佳实践](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Riverpod架构指南](https://riverpod.dev/docs/concepts/reading)
- [项目实际代码示例](../lib/)

---

**最后更新**: 2025-07-22
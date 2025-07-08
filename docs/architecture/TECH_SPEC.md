# Lumi Assistant - 技术规格说明

## 项目架构

### 技术栈选型

#### 核心框架
```yaml
name: lumi_assistant
description: 智能语音助手Flutter客户端

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  flutter_hooks: ^0.20.3
  hooks_riverpod: ^2.4.9
  
  # 网络通信  
  dio: ^5.3.2
  web_socket_channel: ^2.4.0
  connectivity_plus: ^5.0.1
  
  # 音频处理(后期使用)
  flutter_sound: ^9.2.13
  record: ^5.0.1
  audioplayers: ^5.2.1
  
  # 图像处理(后期使用)
  image_picker: ^1.0.4
  camera: ^0.10.5
  
  # UI组件
  flutter_screenutil: ^5.9.0
  animations: ^2.0.8
  lottie: ^2.7.0
  
  # 工具库
  shared_preferences: ^2.2.2
  permission_handler: ^11.0.1
  package_info_plus: ^4.2.0
  uuid: ^4.1.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
```

### 项目目录结构

```
lib/
├── main.dart                     # 应用入口
├── app/                         # 应用配置
│   ├── app.dart                # 主应用组件
│   ├── routes/                 # 路由配置
│   └── themes/                 # 主题配置
├── core/                       # 核心功能层
│   ├── constants/             # 常量定义
│   │   ├── api_constants.dart # API相关常量
│   │   ├── app_constants.dart # 应用常量
│   │   └── ui_constants.dart  # UI相关常量
│   ├── errors/                # 错误处理
│   │   ├── exceptions.dart    # 异常定义
│   │   ├── failures.dart     # 失败类型
│   │   └── error_handler.dart # 错误处理器
│   ├── network/              # 网络配置
│   │   ├── dio_client.dart   # HTTP客户端
│   │   ├── websocket_client.dart # WebSocket客户端
│   │   └── network_info.dart # 网络状态检查
│   ├── services/             # 核心服务
│   │   ├── auth_service.dart # 认证服务
│   │   ├── storage_service.dart # 存储服务
│   │   └── device_service.dart # 设备服务
│   └── utils/               # 工具类
│       ├── logger.dart      # 日志工具
│       ├── formatters.dart  # 格式化工具
│       └── validators.dart  # 验证工具
├── data/                    # 数据层
│   ├── datasources/        # 数据源
│   │   ├── local/         # 本地数据源
│   │   │   ├── chat_local_datasource.dart
│   │   │   └── settings_local_datasource.dart
│   │   └── remote/        # 远程数据源
│   │       ├── websocket_datasource.dart
│   │       └── api_datasource.dart
│   ├── models/            # 数据模型
│   │   ├── chat_message_model.dart
│   │   ├── websocket_message_model.dart
│   │   ├── connection_state_model.dart
│   │   └── user_settings_model.dart
│   └── repositories/      # 仓库实现
│       ├── chat_repository_impl.dart
│       ├── connection_repository_impl.dart
│       └── settings_repository_impl.dart
├── domain/                # 业务层
│   ├── entities/         # 实体类
│   │   ├── chat_message.dart
│   │   ├── connection_state.dart
│   │   └── user_settings.dart
│   ├── repositories/     # 仓库接口
│   │   ├── chat_repository.dart
│   │   ├── connection_repository.dart
│   │   └── settings_repository.dart
│   └── usecases/        # 用例
│       ├── send_message_usecase.dart
│       ├── connect_websocket_usecase.dart
│       ├── load_chat_history_usecase.dart
│       └── save_chat_message_usecase.dart
├── presentation/        # 展示层
│   ├── providers/      # 状态提供者
│   │   ├── chat_provider.dart
│   │   ├── connection_provider.dart
│   │   ├── ui_provider.dart
│   │   └── settings_provider.dart
│   ├── pages/         # 页面
│   │   ├── home/      # 主页
│   │   │   ├── home_page.dart
│   │   │   └── widgets/
│   │   │       ├── background_widget.dart
│   │   │       ├── info_panel_widget.dart
│   │   │       └── assistant_button_widget.dart
│   │   ├── chat/      # 聊天页面
│   │   │   ├── chat_page.dart
│   │   │   └── widgets/
│   │   │       ├── chat_input_widget.dart
│   │   │       ├── message_bubble_widget.dart
│   │   │       ├── message_list_widget.dart
│   │   │       └── chat_overlay_widget.dart
│   │   └── settings/ # 设置页面
│   │       └── settings_page.dart
│   ├── widgets/      # 通用组件
│   │   ├── common/
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   └── status_indicator_widget.dart
│   │   └── animations/
│   │       └── fade_slide_transition.dart
│   └── themes/       # 主题配置
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_text_styles.dart
└── generated/       # 自动生成的文件
    └── assets.dart  # 资源文件引用
```

## 现代化架构设计

> **重要**: 本项目采用现代化Flutter架构，详细设计请参考 [现代化架构设计](MODERN_ARCHITECTURE.md)

### 核心架构原则

**分层架构 + 声明式状态管理 + 组合式设计**

```
┌─────────────────────────┐
│  Presentation Layer     │  ← Hooks Widget + Riverpod  
├─────────────────────────┤
│  Application Layer      │  ← Use Cases + Services
├─────────────────────────┤
│     Data Layer          │  ← Repository + DataSource
├─────────────────────────┤
│   Infrastructure        │  ← Network + Storage + Device
└─────────────────────────┘
```

### 为什么不使用MVVM？

1. **声明式UI优势**: Flutter天然支持状态驱动UI重建
2. **Hooks函数式特性**: 更适合组合式设计而非ViewModel
3. **Riverpod声明式特性**: 提供了更优雅的状态管理和依赖注入
4. **组件化思维**: 小而专注的组件比传统ViewModel更灵活

### 状态管理架构

```dart
// ✅ 现代化方式：声明式状态管理
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    String? error,
  }) = _ChatState;
}

// 函数式状态管理
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._webSocketService) : super(const ChatState());
  
  Future<void> sendMessage(String content) async {
    // 乐观更新
    state = state.copyWith(messages: [...state.messages, userMessage]);
    // 网络请求
    await _webSocketService.sendChatMessage(content);
  }
}

// UI组件：只关注展示和交互
class ChatPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    return Column(
      children: [
        ChatMessageList(messages: chatState.messages),
        ChatInputArea(),
      ],
    );
  }
}
```

### 单向数据流

```
User Action → Provider → Service → Repository → DataSource
     ↓
UI Update ← State Change ← Response ← Network/Storage
```

### WebSocket通信架构

```dart
// WebSocket消息处理流程
class WebSocketService {
  // 连接管理
  Future<void> connect();
  Future<void> disconnect();
  void reconnect();
  
  // 消息发送
  void sendHelloMessage();
  void sendChatMessage(String text);
  void sendImageMessage(String base64, String question);
  
  // 消息接收
  Stream<WebSocketMessage> get messageStream;
  
  // 状态管理
  Stream<ConnectionState> get connectionState;
}

// 消息类型定义
abstract class WebSocketMessage {
  final String type;
  final String? sessionId;
}

class HelloMessage extends WebSocketMessage { }
class ChatMessage extends WebSocketMessage { }
class LlmResponse extends WebSocketMessage { }
class ErrorMessage extends WebSocketMessage { }
```

## 核心组件设计

### 1. 连接管理组件

```dart
class ConnectionManager {
  // 连接状态
  final ValueNotifier<ConnectionState> connectionState;
  
  // 重连策略
  final ReconnectStrategy reconnectStrategy;
  
  // 心跳检测
  Timer? _heartbeatTimer;
  
  // 网络状态监听
  StreamSubscription? _connectivitySubscription;
}
```

### 2. 消息管理组件

```dart
class MessageManager {
  // 消息队列
  final Queue<ChatMessage> _messageQueue;
  
  // 消息状态追踪
  final Map<String, MessageStatus> _messageStatus;
  
  // 重发机制
  Future<void> retryFailedMessages();
  
  // 消息持久化
  Future<void> saveMessage(ChatMessage message);
  Future<List<ChatMessage>> loadHistory();
}
```

### 3. UI状态管理

```dart
class UiState {
  final bool isChatOpen;
  final bool isLoading;
  final String? errorMessage;
  final ConnectionStatus connectionStatus;
  
  UiState copyWith({
    bool? isChatOpen,
    bool? isLoading,
    String? errorMessage,
    ConnectionStatus? connectionStatus,
  });
}
```

## 数据模型定义

### WebSocket消息模型

```dart
// Hello消息
class HelloMessageModel {
  final String type = 'hello';
  final int version;
  final AudioParams audioParams;
}

// 聊天消息
class ChatMessageModel {
  final String type = 'chat';
  final String text;
}

// LLM响应
class LlmResponseModel {
  final String type = 'llm';
  final String text;
  final String? emotion;
  final String sessionId;
  final bool? isStreaming;
  final String? finishReason;
}
```

### 本地数据模型

```dart
// 聊天消息实体
class ChatMessage {
  final String id;
  final String content;
  final MessageType type; // user, ai, system
  final DateTime timestamp;
  final MessageStatus status; // sending, sent, failed, received
  final String? sessionId;
  final Map<String, dynamic>? metadata;
}

// 连接状态
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error
}
```

## 配置和常量

### API配置

```dart
class ApiConstants {
  // WebSocket
  static const String wsBaseUrl = 'ws://localhost:8080/ws';
  static const String wsProtocol = 'websocket';
  
  // HTTP API
  static const String httpBaseUrl = 'http://localhost:8080/api';
  
  // 超时配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  
  // 重连配置
  static const int maxReconnectAttempts = 5;
  static const Duration initialReconnectDelay = Duration(seconds: 2);
}
```

### UI配置

```dart
class UiConstants {
  // 布局尺寸
  static const double assistantButtonSize = 64.0;
  static const double chatOverlayWidth = 0.9;
  static const double chatOverlayHeight = 0.8;
  
  // 动画时长
  static const Duration fadeAnimationDuration = Duration(milliseconds: 300);
  static const Duration slideAnimationDuration = Duration(milliseconds: 250);
  
  // 消息相关
  static const int maxMessageLength = 1000;
  static const int maxHistoryMessages = 100;
}
```

## 错误处理策略

### 异常类型定义

```dart
// 网络异常
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
}

// WebSocket异常
class WebSocketException implements Exception {
  final String message;
  final int? closeCode;
}

// 业务异常
class BusinessException implements Exception {
  final String message;
  final String? errorCode;
}
```

### 错误处理流程

```dart
class ErrorHandler {
  static void handleError(Exception error, StackTrace stackTrace) {
    // 1. 记录错误日志
    Logger.error(error, stackTrace);
    
    // 2. 根据错误类型处理
    if (error is NetworkException) {
      _handleNetworkError(error);
    } else if (error is WebSocketException) {
      _handleWebSocketError(error);
    }
    
    // 3. 用户提示
    _showUserFriendlyMessage(error);
  }
}
```

## 性能优化策略

### 内存管理
- 及时释放StreamSubscription
- 使用WeakReference避免循环引用
- 限制聊天历史记录数量
- 图片缓存策略

### 网络优化
- 消息队列避免重复发送
- 连接复用和心跳保活
- 断线重连指数退避
- 音频数据流式传输

### UI性能
- ListView.builder大列表优化
- 图片懒加载和缓存
- 动画性能监控
- Widget复用策略

---

**文档版本**: v1.0  
**创建时间**: 2025-07-08  
**最后更新**: 2025-07-08
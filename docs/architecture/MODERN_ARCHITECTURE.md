# Lumi Assistant - 现代化架构设计

## 🏗️ 架构理念

### 为什么不使用MVVM？

在现代Flutter开发中，MVVM模式并非最佳选择，原因如下：

1. **声明式UI的天然优势**：Flutter本身就是声明式框架，状态驱动UI重建
2. **Hooks的函数式特性**：更适合函数式编程和组合式设计
3. **Riverpod的声明式特性**：提供了更优雅的依赖注入和状态管理
4. **组件化的思维**：小而专注的组件比传统的ViewModel更灵活

## 🎯 采用的现代化架构

### 1. 分层架构 + 声明式状态管理

```
┌─────────────────────────┐
│    Presentation Layer   │  ← Hooks Widget + Riverpod
├─────────────────────────┤
│    Application Layer    │  ← Use Cases + Services  
├─────────────────────────┤
│       Data Layer        │  ← Repository + DataSource
├─────────────────────────┤
│    Infrastructure       │  ← Network + Storage + Device
└─────────────────────────┘
```

### 2. 核心设计原则

**组合优于继承**
```dart
// ✅ 推荐：组合式设计
class ChatPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final messageController = useTextEditingController();
    
    return Scaffold(
      body: Column(
        children: [
          ChatMessageList(messages: chatState.messages),
          ChatInput(controller: messageController, onSend: _sendMessage),
        ],
      ),
    );
  }
}

// ❌ 避免：MVVM的ViewModel模式
class ChatViewModel extends ChangeNotifier {
  // 大量业务逻辑混在一起
}
```

**状态与逻辑分离**
```dart
// ✅ 推荐：状态管理与UI逻辑分离
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.read(webSocketServiceProvider));
});

// UI只关注展示和用户交互
class ChatInput extends HookWidget {
  final VoidCallback onSend;
  
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    
    return Row(
      children: [
        Expanded(child: TextField(controller: controller)),
        IconButton(onPressed: () => onSend(controller.text), icon: Icon(Icons.send)),
      ],
    );
  }
}
```

## 📁 现代化目录结构

```
lib/
├── app/                        # 应用级配置
│   ├── app.dart               # 应用入口配置
│   ├── router/                # 路由配置
│   └── theme/                 # 全局主题
├── features/                   # 功能模块（按业务划分）
│   ├── chat/                  # 聊天功能
│   │   ├── data/              # 聊天相关数据层
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/            # 聊天业务逻辑
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/      # 聊天UI层
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   ├── connection/            # 连接管理功能
│   └── settings/              # 设置功能
├── shared/                    # 共享组件和工具
│   ├── data/                  # 共享数据层
│   ├── domain/                # 共享业务层
│   ├── presentation/          # 共享UI组件
│   │   ├── widgets/
│   │   ├── extensions/
│   │   └── utils/
│   └── infrastructure/        # 基础设施
│       ├── network/
│       ├── storage/
│       └── logging/
└── main.dart
```

## 🔧 核心架构组件

### 1. 状态管理：Riverpod + Hooks

```dart
// 状态定义：使用@freezed确保不可变性
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    @Default(ConnectionStatus.disconnected) ConnectionStatus connectionStatus,
    String? error,
  }) = _ChatState;
}

// 状态管理：函数式方法
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._webSocketService) : super(const ChatState());
  
  final WebSocketService _webSocketService;
  
  // 纯函数式的状态更新
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    // 乐观更新：立即添加用户消息
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );
    
    try {
      await _webSocketService.sendChatMessage(content);
      // 更新消息状态为已发送
      _updateMessageStatus(userMessage.id, MessageStatus.sent);
    } catch (e) {
      _updateMessageStatus(userMessage.id, MessageStatus.failed);
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
  
  void _updateMessageStatus(String messageId, MessageStatus status) {
    final messages = state.messages.map((msg) =>
      msg.id == messageId ? msg.copyWith(status: status) : msg
    ).toList();
    
    state = state.copyWith(messages: messages);
  }
}

// Provider定义
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.read(webSocketServiceProvider));
});
```

### 2. UI组件：Hooks + 组合式设计

```dart
// 页面级组件：只负责布局和状态监听
class ChatPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final scrollController = useScrollController();
    
    // 监听消息变化，自动滚动到底部
    ref.listen<List<ChatMessage>>(
      chatProvider.select((state) => state.messages),
      (previous, next) {
        if (next.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      },
    );
    
    return Scaffold(
      appBar: AppBar(
        title: ConnectionStatusIndicator(),
        actions: [ChatMenuButton()],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessageList(
              messages: chatState.messages,
              scrollController: scrollController,
            ),
          ),
          if (chatState.error != null)
            ErrorBanner(error: chatState.error!),
          ChatInputArea(),
        ],
      ),
    );
  }
}

// 功能组件：单一职责，可复用
class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    Key? key,
    required this.messages,
    required this.scrollController,
  }) : super(key: key);
  
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  
  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const EmptyStateWidget();
    }
    
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          message: message,
          isFromUser: message.type == MessageType.user,
        );
      },
    );
  }
}

// 输入组件：使用Hooks管理本地状态
class ChatInputArea extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final isComposing = useState(false);
    
    void handleSend() {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        ref.read(chatProvider.notifier).sendMessage(text);
        controller.clear();
        isComposing.value = false;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  isComposing.value = text.trim().isNotEmpty;
                },
                onSubmitted: (_) => handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isComposing.value
                  ? IconButton(
                      onPressed: handleSend,
                      icon: const Icon(Icons.send),
                    )
                  : IconButton(
                      onPressed: () {
                        // 未来添加语音功能
                      },
                      icon: const Icon(Icons.mic),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. 服务层：函数式接口设计

```dart
// 服务接口：纯函数式
abstract class WebSocketService {
  Stream<ConnectionStatus> get connectionStatus;
  Stream<WebSocketMessage> get messageStream;
  
  Future<void> connect(String url);
  Future<void> disconnect();
  Future<void> sendMessage(Map<String, dynamic> message);
}

// 实现：状态隔离
class WebSocketServiceImpl implements WebSocketService {
  WebSocketServiceImpl(this._logger);
  
  final Logger _logger;
  WebSocketChannel? _channel;
  final _connectionController = StreamController<ConnectionStatus>.broadcast();
  final _messageController = StreamController<WebSocketMessage>.broadcast();
  
  @override
  Stream<ConnectionStatus> get connectionStatus => _connectionController.stream;
  
  @override
  Stream<WebSocketMessage> get messageStream => _messageController.stream;
  
  @override
  Future<void> connect(String url) async {
    try {
      _connectionController.add(ConnectionStatus.connecting);
      
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen(
        (data) => _handleMessage(data),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnected(),
      );
      
      _connectionController.add(ConnectionStatus.connected);
      _logger.info('WebSocket connected to $url');
      
    } catch (e) {
      _connectionController.add(ConnectionStatus.error);
      _logger.error('Failed to connect to $url: $e');
      rethrow;
    }
  }
  
  // 其他方法实现...
}
```

## 🎨 UI设计模式

### 1. 原子化组件设计

```dart
// 原子组件：最小可复用单元
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    required this.isFromUser,
  }) : super(key: key);
  
  final ChatMessage message;
  final bool isFromUser;
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isFromUser 
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isFromUser ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: (isFromUser ? Colors.white : Colors.grey).withOpacity(0.7),
                  ),
                ),
                if (isFromUser) ...[
                  const SizedBox(width: 4),
                  MessageStatusIcon(status: message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

// 状态指示组件
class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon({Key? key, required this.status}) : super(key: key);
  
  final MessageStatus status;
  
  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.7)),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 12,
          color: Colors.white.withOpacity(0.7),
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 12,
          color: Colors.red.withOpacity(0.7),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
```

### 2. 响应式设计

```dart
// 响应式布局Hook
ScreenSize useScreenSize() {
  return use(const _ScreenSizeHook());
}

class _ScreenSizeHook extends Hook<ScreenSize> {
  const _ScreenSizeHook();
  
  @override
  _ScreenSizeHookState createState() => _ScreenSizeHookState();
}

class _ScreenSizeHookState extends HookState<ScreenSize, _ScreenSizeHook> {
  late ScreenSize _screenSize;
  
  @override
  void initHook() {
    super.initHook();
    _updateScreenSize();
  }
  
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateScreenSize();
  }
  
  void _updateScreenSize() {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    
    if (width < 600) {
      _screenSize = ScreenSize.mobile;
    } else if (width < 1200) {
      _screenSize = ScreenSize.tablet;
    } else {
      _screenSize = ScreenSize.desktop;
    }
  }
  
  @override
  ScreenSize build(BuildContext context) => _screenSize;
}

// 使用响应式设计
class ChatLayout extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = useScreenSize();
    
    return switch (screenSize) {
      ScreenSize.mobile => _MobileChatLayout(),
      ScreenSize.tablet => _TabletChatLayout(),
      ScreenSize.desktop => _DesktopChatLayout(),
    };
  }
}
```

## 🔄 数据流设计

### 单向数据流

```
User Action → Provider → Service → Repository → DataSource
     ↓
UI Update ← State Change ← Response ← Network/Storage
```

### 示例：发送消息的完整数据流

```dart
// 1. 用户操作
onPressed: () => ref.read(chatProvider.notifier).sendMessage(text)

// 2. Provider处理
Future<void> sendMessage(String content) async {
  // 乐观更新UI
  state = state.copyWith(messages: [...state.messages, userMessage]);
  
  // 调用Service
  await _webSocketService.sendChatMessage(content);
}

// 3. Service处理
Future<void> sendChatMessage(String content) async {
  final message = {
    'type': 'chat',
    'text': content,
  };
  
  // 调用Repository
  await _webSocketRepository.sendMessage(message);
}

// 4. Repository处理
Future<void> sendMessage(Map<String, dynamic> message) async {
  // 调用DataSource
  await _webSocketDataSource.send(jsonEncode(message));
}

// 5. DataSource处理
void send(String data) {
  _channel.sink.add(data);
}

// 6. 响应处理（反向流）
// DataSource接收 → Repository解析 → Service处理 → Provider更新状态 → UI重建
```

## 🧪 测试策略

### 1. 组件测试

```dart
void main() {
  group('MessageBubble', () {
    testWidgets('displays user message correctly', (tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Hello',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: MessageBubble(message: message, isFromUser: true),
        ),
      );
      
      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(MessageStatusIcon), findsOneWidget);
    });
  });
}
```

### 2. Provider测试

```dart
void main() {
  group('ChatNotifier', () {
    late MockWebSocketService mockService;
    late ProviderContainer container;
    
    setUp(() {
      mockService = MockWebSocketService();
      container = ProviderContainer(
        overrides: [
          webSocketServiceProvider.overrideWithValue(mockService),
        ],
      );
    });
    
    test('sends message successfully', () async {
      when(mockService.sendChatMessage(any)).thenAnswer((_) async {});
      
      final notifier = container.read(chatProvider.notifier);
      await notifier.sendMessage('Hello');
      
      final state = container.read(chatProvider);
      expect(state.messages, hasLength(1));
      expect(state.messages.first.content, 'Hello');
    });
  });
}
```

## 📋 总结

这种现代化架构的优势：

1. **更好的可测试性**：每个组件职责单一，易于测试
2. **更高的可复用性**：原子化组件可以在不同地方复用
3. **更清晰的数据流**：单向数据流，状态可预测
4. **更好的性能**：细粒度的状态更新，减少不必要的重建
5. **更易维护**：功能模块化，修改影响范围可控

这种架构更符合Flutter的声明式特性，也更适合现代前端开发的最佳实践。

---

**文档版本**: v1.0  
**创建时间**: 2025-07-08
# 🎯 Riverpod 状态管理指南

> 在 Lumi Assistant 项目中使用 hooks_riverpod 的完整指南

## 📋 目录

- [基础概念](#基础概念)
- [Provider类型和使用场景](#provider类型和使用场景)
- [项目中的实际应用](#项目中的实际应用)
- [最佳实践](#最佳实践)
- [常见问题和解决方案](#常见问题和解决方案)

## 🎯 基础概念

### 什么是Riverpod？

Riverpod是Flutter的响应式缓存和数据绑定框架，是Provider的进化版本，具有以下优势：

- **编译时安全** - 避免运行时错误
- **无BuildContext依赖** - 可以在任何地方读取状态
- **更好的可测试性** - 易于Mock和单元测试
- **自动内存管理** - 自动处理Provider的生命周期

### 核心组件

```dart
// 1. ProviderScope - 应用根组件
ProviderScope(
  child: MyApp(),
)

// 2. Consumer系列 - 状态监听组件
Consumer(builder: (context, ref, child) => ...)
ConsumerWidget - 有状态Widget基类
HookConsumerWidget - 结合Hooks的Widget基类

// 3. ref对象 - 状态交互接口
ref.watch(provider)  // 监听状态变化
ref.read(provider)   // 读取当前状态
ref.listen(provider) // 监听状态变化但不重建UI
```

## 🏗️ Provider类型和使用场景

### 1. Provider - 只读数据

用于提供不变的值或计算结果：

```dart
// 示例：API常量配置
final apiConstantsProvider = Provider<ApiConstants>((ref) {
  return ApiConstants();
});

// 项目中的应用：lib/core/constants/api_constants.dart
final apiConfigProvider = Provider<ApiConstants>((ref) {
  return const ApiConstants();
});

// 使用
class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiConfig = ref.watch(apiConfigProvider);
    return Text('Server URL: ${apiConfig.websocketUrl}');
  }
}
```

### 2. StateProvider - 简单状态

用于管理简单的可变状态：

```dart
// 示例：计数器
final counterProvider = StateProvider<int>((ref) => 0);

// 使用
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### 3. StateNotifierProvider - 复杂状态管理

用于管理复杂的业务逻辑和状态变化：

```dart
// 状态类
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    @Default(false) bool isConnected,
    String? error,
  }) = _ChatState;
}

// StateNotifier类
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._webSocketService) : super(const ChatState()) {
    _initializeWebSocketListener();
  }

  final WebSocketService _webSocketService;

  void addMessage(ChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  Future<void> sendMessage(String content) async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _webSocketService.sendMessage(content);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider定义
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return ChatNotifier(webSocketService);
});
```

### 4. FutureProvider - 异步数据

用于处理异步操作和Future数据：

```dart
// 异步数据加载
final userDataProvider = FutureProvider<UserData>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.fetchUserData();
});

// 使用
class UserWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    
    return userData.when(
      data: (user) => Text('Hello, ${user.name}'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 5. StreamProvider - 流数据

用于处理Stream数据流：

```dart
// WebSocket消息流
final webSocketMessagesProvider = StreamProvider<WebSocketMessage>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.messageStream;
});

// 使用
class MessageStreamWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(webSocketMessagesProvider);
    
    return messagesAsync.when(
      data: (message) => Text('Received: ${message.content}'),
      loading: () => Text('Waiting for messages...'),
      error: (error, stack) => Text('Connection error'),
    );
  }
}
```

## 🚀 项目中的实际应用

### 1. 连接状态管理

```dart
// lib/presentation/providers/connection_provider.dart
final connectionProvider = StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  final networkChecker = ref.watch(networkCheckerProvider);
  return ConnectionNotifier(webSocketService, networkChecker);
});

// 使用示例
class ConnectionStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionProvider);
    
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: connectionState.isConnected ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        connectionState.isConnected ? '已连接' : '未连接',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
```

### 2. 聊天消息管理

```dart
// lib/presentation/providers/chat_provider.dart
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return ChatNotifier(webSocketService);
});

// 聊天页面使用
class ChatPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final controller = useTextEditingController();
    
    return Scaffold(
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: ListView.builder(
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                return ChatMessageItem(
                  message: chatState.messages[index],
                );
              },
            ),
          ),
          // 输入区域
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: chatState.isLoading ? null : () {
                    final content = controller.text;
                    if (content.isNotEmpty) {
                      ref.read(chatProvider.notifier).sendMessage(content);
                      controller.clear();
                    }
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. 服务依赖注入

```dart
// lib/core/services/websocket_service.dart
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

final networkCheckerProvider = Provider<NetworkChecker>((ref) {
  return NetworkChecker();
});

// 多层依赖
final chatServiceProvider = Provider<ChatService>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  final errorHandler = ref.watch(errorHandlerProvider);
  return ChatService(webSocketService, errorHandler);
});
```

## 💡 最佳实践

### 1. Provider命名规范

```dart
// ✅ 好的命名
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) => ...);
final webSocketServiceProvider = Provider<WebSocketService>((ref) => ...);
final userDataProvider = FutureProvider<UserData>((ref) => ...);

// ❌ 避免的命名
final provider1 = StateNotifierProvider(...);
final data = FutureProvider(...);
final manager = Provider(...);
```

### 2. 状态更新模式

```dart
class ChatNotifier extends StateNotifier<ChatState> {
  // ✅ 使用copyWith进行不可变更新
  void addMessage(ChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }
  
  // ❌ 避免直接修改状态
  void addMessageBad(ChatMessage message) {
    state.messages.add(message); // 这不会触发UI更新
  }
}
```

### 3. 错误处理

```dart
class DataNotifier extends StateNotifier<AsyncValue<Data>> {
  DataNotifier() : super(const AsyncValue.loading());
  
  Future<void> fetchData() async {
    state = const AsyncValue.loading();
    
    try {
      final data = await apiService.fetchData();
      state = AsyncValue.data(data);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

// 使用时的错误处理
Widget build(BuildContext context, WidgetRef ref) {
  final dataAsync = ref.watch(dataProvider);
  
  return dataAsync.when(
    data: (data) => DataWidget(data),
    loading: () => LoadingWidget(),
    error: (error, stack) => ErrorWidget(error),
  );
}
```

### 4. 生命周期管理

```dart
final timerProvider = StateNotifierProvider.autoDispose<TimerNotifier, int>((ref) {
  final notifier = TimerNotifier();
  
  // 当Provider被销毁时清理资源
  ref.onDispose(() {
    notifier.dispose();
  });
  
  return notifier;
});

class TimerNotifier extends StateNotifier<int> {
  TimerNotifier() : super(0) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      state++;
    });
  }
  
  Timer? _timer;
  
  void dispose() {
    _timer?.cancel();
  }
}
```

### 5. 组合Provider

```dart
// 组合多个Provider的数据
final combinedDataProvider = Provider<CombinedData>((ref) {
  final userData = ref.watch(userDataProvider);
  final settingsData = ref.watch(settingsDataProvider);
  
  return userData.when(
    data: (user) => settingsData.when(
      data: (settings) => CombinedData(user, settings),
      loading: () => CombinedData.loading(),
      error: (e, s) => CombinedData.error(e),
    ),
    loading: () => CombinedData.loading(),
    error: (e, s) => CombinedData.error(e),
  );
});
```

## 🧪 测试指南

### 1. Provider单元测试

```dart
// test/providers/chat_provider_test.dart
void main() {
  group('ChatProvider Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Mock WebSocket服务
          webSocketServiceProvider.overrideWithValue(
            MockWebSocketService(),
          ),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('should add message to state', () {
      // Arrange
      final message = ChatMessage(content: 'Test', isUser: true);
      
      // Act
      container.read(chatProvider.notifier).addMessage(message);
      
      // Assert
      final state = container.read(chatProvider);
      expect(state.messages, contains(message));
    });
  });
}
```

### 2. Widget测试

```dart
// test/widgets/chat_widget_test.dart
void main() {
  testWidgets('ChatWidget should display messages', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatProvider.overrideWith((ref) => MockChatNotifier()),
        ],
        child: MaterialApp(
          home: ChatWidget(),
        ),
      ),
    );
    
    expect(find.text('Test message'), findsOneWidget);
  });
}
```

## ❓ 常见问题和解决方案

### 1. Provider循环依赖

```dart
// ❌ 问题：循环依赖
final providerA = Provider<A>((ref) {
  final b = ref.watch(providerB);
  return A(b);
});

final providerB = Provider<B>((ref) {
  final a = ref.watch(providerA); // 循环依赖
  return B(a);
});

// ✅ 解决：重构依赖关系
final sharedServiceProvider = Provider<SharedService>((ref) {
  return SharedService();
});

final providerA = Provider<A>((ref) {
  final shared = ref.watch(sharedServiceProvider);
  return A(shared);
});

final providerB = Provider<B>((ref) {
  final shared = ref.watch(sharedServiceProvider);
  return B(shared);
});
```

### 2. 内存泄漏

```dart
// ❌ 问题：未正确清理资源
final streamProvider = StreamProvider<Data>((ref) {
  return someDataStream(); // Stream可能不会自动关闭
});

// ✅ 解决：使用autoDispose和手动清理
final streamProvider = StreamProvider.autoDispose<Data>((ref) {
  final controller = StreamController<Data>();
  
  ref.onDispose(() {
    controller.close();
  });
  
  return controller.stream;
});
```

### 3. 状态不更新

```dart
// ❌ 问题：修改可变对象
class ListNotifier extends StateNotifier<List<String>> {
  ListNotifier() : super([]);
  
  void addItem(String item) {
    state.add(item); // 这不会触发UI更新
  }
}

// ✅ 解决：创建新的不可变对象
class ListNotifier extends StateNotifier<List<String>> {
  ListNotifier() : super([]);
  
  void addItem(String item) {
    state = [...state, item]; // 创建新列表
  }
}
```

### 4. 读取Provider的时机

```dart
// ❌ 问题：在build方法中使用ref.read
Widget build(BuildContext context, WidgetRef ref) {
  // ref.read不会监听变化，可能导致UI不更新
  final data = ref.read(dataProvider);
  return Text(data.toString());
}

// ✅ 解决：使用ref.watch监听变化
Widget build(BuildContext context, WidgetRef ref) {
  final data = ref.watch(dataProvider);
  return Text(data.toString());
}

// ✅ 在事件处理中使用ref.read
void _onButtonPressed(WidgetRef ref) {
  // 事件处理中可以使用ref.read
  ref.read(counterProvider.notifier).state++;
}
```

## 📚 相关资源

- [Riverpod官方文档](https://riverpod.dev/)
- [Flutter Hooks文档](https://pub.dev/packages/flutter_hooks)
- [Freezed代码生成](https://pub.dev/packages/freezed)
- [项目中的Provider示例](../lib/presentation/providers/)

---

**最后更新**: 2025-07-22
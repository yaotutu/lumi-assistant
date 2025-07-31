# 🧪 测试指南

> 确保代码质量的测试策略

## 🎯 测试策略

### 测试金字塔
```
    🔺 E2E Tests (少量)
   🔺🔺 Integration Tests (适量)  
  🔺🔺🔺 Unit Tests (大量)
```

- 🧪 **单元测试** - 测试独立的函数和类
- 🔗 **集成测试** - 测试组件间交互
- 🎭 **端到端测试** - 测试完整用户流程
- 📱 **Widget测试** - 测试UI组件

## 📁 测试结构

```
test/
├── unit/                    # 单元测试
│   ├── core/               # 核心功能测试
│   ├── data/               # 数据层测试
│   └── models/             # 模型测试
├── widget/                 # Widget测试
│   ├── pages/              # 页面组件测试
│   └── widgets/            # 通用组件测试
├── integration/            # 集成测试
│   ├── services/           # 服务集成测试
│   └── flows/              # 业务流程测试
└── test_utils/             # 测试工具和Mock
    ├── mocks/              # Mock对象
    ├── fixtures/           # 测试数据
    └── helpers/            # 测试辅助函数
```

## 🧪 单元测试

### 测试覆盖范围
- ✅ 所有Service类的核心方法
- ✅ 状态管理Provider的状态变化
- ✅ 工具函数和扩展方法
- ✅ 数据模型的序列化/反序列化
- ✅ 异常处理逻辑

### 示例：Service测试
```dart
// test/unit/core/services/websocket_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../lib/core/services/websocket_service.dart';

class MockWebSocket extends Mock implements WebSocket {}

void main() {
  group('WebSocketService', () {
    late WebSocketService service;
    late MockWebSocket mockWebSocket;

    setUp(() {
      mockWebSocket = MockWebSocket();
      service = WebSocketService();
    });

    test('should connect to websocket successfully', () async {
      // Arrange
      const url = 'ws://localhost:8000';
      
      // Act
      await service.connect(url);
      
      // Assert
      expect(service.isConnected, true);
    });

    test('should handle connection failure', () async {
      // Arrange
      when(mockWebSocket.connect(any))
          .thenThrow(WebSocketException('Connection failed'));
      
      // Act & Assert
      expect(
        () => service.connect('invalid-url'),
        throwsA(isA<WebSocketException>()),
      );
    });
  });
}
```

### 示例：Provider测试
```dart
// test/unit/presentation/providers/chat_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../lib/presentation/providers/chat_provider.dart';

void main() {
  group('ChatProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should add message to chat state', () {
      // Arrange
      final provider = container.read(chatProvider.notifier);
      const message = ChatMessage(content: 'Hello', isUser: true);

      // Act
      provider.addMessage(message);

      // Assert
      final state = container.read(chatProvider);
      expect(state.messages.length, 1);
      expect(state.messages.first, message);
    });
  });
}
```

## 📱 Widget测试

### UI组件测试
```dart
// test/widget/widgets/chat_message_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../lib/presentation/widgets/chat_message_widget.dart';

void main() {
  group('ChatMessageWidget', () {
    testWidgets('should display user message correctly', (tester) async {
      // Arrange
      const message = ChatMessage(
        content: 'Hello World',
        isUser: true,
        timestamp: '12:30',
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ChatMessageWidget(message: message),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('12:30'), findsOneWidget);
      
      // 验证用户消息的样式
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.alignment, Alignment.centerRight);
    });

    testWidgets('should handle long messages with text wrapping', (tester) async {
      // Arrange
      const longMessage = ChatMessage(
        content: 'This is a very long message that should wrap to multiple lines',
        isUser: false,
        timestamp: '12:31',
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200, // 限制宽度测试换行
                child: ChatMessageWidget(message: longMessage),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(longMessage.content), findsOneWidget);
      
      // 验证文本是否正确换行（高度会增加）
      final textWidget = tester.widget<Text>(find.text(longMessage.content));
      expect(textWidget.softWrap, true);
    });
  });
}
```

## 🔗 集成测试

### 服务集成测试
```dart
// test/integration/services/chat_service_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/core/services/websocket_service.dart';
import '../../lib/core/services/chat_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chat Service Integration', () {
    testWidgets('should send and receive messages', (tester) async {
      // Arrange
      final wsService = WebSocketService();
      final chatService = ChatService(wsService);
      
      // Act
      await chatService.connect('ws://localhost:8000');
      await chatService.sendMessage('Hello');
      
      // Wait for response
      await tester.pump(Duration(seconds: 2));
      
      // Assert
      expect(chatService.isConnected, true);
      // 验证消息发送成功的状态
    });
  });
}
```

### 完整流程测试
```dart
// test/integration/flows/chat_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chat Flow Integration', () {
    testWidgets('complete chat conversation flow', (tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 验证初始状态
      expect(find.byType(HomePage), findsOneWidget);
      
      // 点击聊天按钮
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();
      
      // 输入消息
      await tester.enterText(find.byType(TextField), 'Hello Assistant');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      
      // 验证消息显示
      expect(find.text('Hello Assistant'), findsOneWidget);
      
      // 等待响应
      await tester.pump(Duration(seconds: 3));
      
      // 验证响应消息存在
      expect(find.textContaining('Hi'), findsOneWidget);
    });
  });
}
```

## 🎭 Mock和测试数据

### Mock对象
```dart
// test/test_utils/mocks/mock_services.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../lib/core/services/websocket_service.dart';
import '../../lib/core/services/audio_service.dart';

@GenerateMocks([
  WebSocketService,
  AudioService,
])
import 'mock_services.mocks.dart';

// 使用时
final mockWebSocketService = MockWebSocketService();
when(mockWebSocketService.connect(any))
    .thenAnswer((_) async => true);
```

### 测试数据
```dart
// test/test_utils/fixtures/chat_fixtures.dart
import '../../lib/data/models/chat_message.dart';

class ChatFixtures {
  static const sampleUserMessage = ChatMessage(
    id: '1',
    content: 'Hello, how are you?',
    isUser: true,
    timestamp: '2025-07-22T10:30:00Z',
  );

  static const sampleAssistantMessage = ChatMessage(
    id: '2',
    content: 'I am doing well, thank you for asking!',
    isUser: false,
    timestamp: '2025-07-22T10:30:05Z',
  );

  static final List<ChatMessage> sampleConversation = [
    sampleUserMessage,
    sampleAssistantMessage,
  ];
}
```

### 测试辅助函数
```dart
// test/test_utils/helpers/widget_test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class WidgetTestHelpers {
  /// 创建测试用的Widget包装器
  static Widget createTestableWidget(Widget child, {List<Override>? overrides}) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  /// 等待动画完成
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// 查找并点击按钮
  static Future<void> tapButton(WidgetTester tester, String buttonText) async {
    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();
  }
}
```

## 🎯 测试命令

### 基本测试命令
```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/unit/services/websocket_service_test.dart

# 运行特定测试组
flutter test --name "WebSocketService"

# 生成测试覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 高级测试选项
```bash
# 详细输出
flutter test --reporter=expanded

# 并行运行测试
flutter test --concurrency=4

# 只运行失败的测试
flutter test --run-skipped

# 监控模式（文件改动时自动运行）
flutter test --watch
```

### 设备测试
```bash
# 在连接的设备上运行集成测试
flutter test integration_test/ -d 1W11833968

# 在所有连接的设备上运行
flutter test integration_test/ -d all
```

## 📊 测试覆盖率

### 目标覆盖率
- 🎯 **单元测试覆盖率**: ≥ 80%
- 🎯 **核心功能覆盖率**: ≥ 90%
- 🎯 **关键路径覆盖率**: 100%

### 覆盖率报告
```bash
# 生成覆盖率报告
flutter test --coverage

# 查看覆盖率摘要
lcov --summary coverage/lcov.info

# 生成HTML报告
genhtml coverage/lcov.info -o coverage/html

# 过滤不需要覆盖的文件
lcov --remove coverage/lcov.info \
  'lib/*/*.g.dart' \
  'lib/*/*.freezed.dart' \
  -o coverage/filtered.info
```

## 🚀 持续集成测试

### GitHub Actions配置
测试在以下情况自动运行：
- ✅ Pull Request创建时
- ✅ 代码推送到main/dev分支时
- ✅ 每日定时运行

### 测试失败处理
1. 🔍 查看GitHub Actions日志
2. 🧪 在本地重现问题
3. 🔧 修复测试或代码
4. ✅ 重新提交

## 📚 测试最佳实践

### 编写好测试的原则
- 🎯 **单一职责** - 每个测试只验证一个功能点
- 📝 **清晰命名** - 测试名称说明测试内容和期望
- 🔄 **独立运行** - 测试间不应有依赖关系
- 📊 **覆盖边界** - 测试正常情况和边界条件
- ⚡ **执行快速** - 单元测试应该毫秒级完成

### 测试结构模式
```dart
// AAA模式：Arrange, Act, Assert
test('should return correct result when input is valid', () {
  // Arrange - 准备测试数据
  final input = 'test input';
  final expected = 'expected result';
  
  // Act - 执行被测试的方法
  final result = functionUnderTest(input);
  
  // Assert - 验证结果
  expect(result, expected);
});
```

---

**好的测试是高质量代码的保证 🧪**
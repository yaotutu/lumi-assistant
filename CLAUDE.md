# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lumi Assistant is a Flutter-based intelligent voice assistant client using modern Flutter architecture and AI technologies.

## Architecture

The project uses **modern Flutter architecture** rejecting traditional MVVM in favor of:
- **Layered Architecture**: Presentation → Application → Data → Infrastructure
- **Declarative State Management**: flutter_hooks + hooks_riverpod
- **Compositional Design**: Small, focused, reusable components
- **Functional Programming**: Hooks-based approach with pure functions
- **Responsive Design**: Adaptive UI based on screen size and capabilities

Key architectural principles:
- Composition over inheritance
- Single-directional data flow: `User Action → Provider → Service → Repository → DataSource`
- Atomic UI components with clear separation of concerns
- State isolation using Riverpod providers
- **Screen-adaptive layouts**: Different UI patterns for large and small screens

## Directory Structure

```
lib/
├── core/                    # Core utilities, constants, services
├── data/                   # Data layer (models, repositories, datasources)
├── domain/                 # Business layer (entities, repository interfaces, use cases)
└── presentation/           # UI layer (providers, pages, widgets)
    ├── pages/               # Page-oriented organization
    │   └── home/            # Home page and its components
    │       ├── home_page.dart
    │       └── widgets/     # Home page specific widgets
    ├── widgets/             # Shared widgets across pages
    └── themes/              # App themes and styling
```

### File Organization Rules

**Page-Oriented Structure**: Each page should have its own directory containing:
- Main page file (e.g., `home_page.dart`)
- `widgets/` subdirectory for page-specific components
- Any page-specific services, models, or utilities

**Shared Components**: Common widgets used across multiple pages go in `presentation/widgets/`

## Development Commands

### Environment Setup
```bash
# Check Flutter environment
flutter doctor

# Install dependencies
flutter pub get

# Run the app (preferred device: YT3002)
flutter run -d 1W11833968

# Alternative: List all devices first
flutter devices
```

### Device Configuration
**Primary Testing Device**: YT3002 (Device ID: 1W11833968)
- Platform: Android 7.0 (API 24)
- Architecture: android-arm64
- Screen Resolution: 1280x736 (Landscape-oriented)
- Usage: Primary development and testing device

### Quick Commands for YT3002 Device
```bash
# Quick run on YT3002 (preferred device)
flutter run -d 1W11833968

# Build and run debug APK on YT3002
flutter run -d 1W11833968 --debug

# Clean build on YT3002
flutter clean && flutter pub get && flutter run -d 1W11833968
```



## Platform Support

| 平台 | 支持状态 | 音频实现 | 兼容性 |
|------|----------|----------|--------|
| **Android** | ✅ **完整支持** | 原生AudioTrack | Android 6.0+ (API 23+) |
| **iOS** | ⚠️ **接口预留** | 待实现 | iOS 12.0+ (预期) |
| **Web** | ❌ **不支持** | N/A | N/A |
| **Desktop** | ❌ **不支持** | N/A | N/A |

## Backend Integration

**Python Backend Server**: `/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server`
**WebSocket**: `ws://YOUR_SERVER_IP:8000/` (固定使用Python服务器)
**HTTP API**: `http://YOUR_SERVER_IP:8000/api`
**Authentication**: Bearer Token + Device-ID headers

Message types: `hello` (handshake), `chat` (text), `listen` (voice), `image` (vision)

**服务器配置说明**：
- 开发环境：使用局域网IP `YOUR_SERVER_IP` (Python服务器)
- 不支持服务器切换功能，统一使用Python后端
- 配置位置：`lib/core/constants/api_constants.dart`

## Reference Implementation

**ESP32 Client**: `/Users/yaotutu/Desktop/code/xiaozhi-esp32` **[PRIMARY REFERENCE]**
- **Most Standard Client**: This is the most standard and reliable client implementation
- **Primary Reference**: When encountering any issues, always refer to this ESP32 client first
- **Complete Implementation**: Contains the most complete and tested implementation patterns

**Android Client**: `/Users/yaotutu/Desktop/code/xiaozhi-android-client` **[Secondary Reference]**
- Use as secondary reference for Flutter-specific patterns
- Follow similar WebSocket handling and UI interaction patterns

### 参考优先级

1. **首选**：遇到任何问题时，首先参考ESP32客户端的实现方式
2. **次选**：ESP32客户端无法提供参考时，再参考Android客户端
3. **API规范**：所有接口规范都来自Python后端项目的`docs/`目录

## Development Status

**Current Features**:
- ✅ **WebSocket Communication**: Real-time connection with Python backend
- ✅ **Text Chat**: Send and receive text messages via WebSocket
- ✅ **IoT Device Control**: Volume control through MCP protocol
- ✅ **Responsive UI**: Adaptive layout for different screen sizes
- ✅ **Settings System**: Configurable app settings and preferences

**IoT Device Control**:
- ✅ **Architecture**: IoT tool registration and execution mechanism
- ✅ **Volume Control**: adjust_volume and get_current_volume tools
- ✅ **WebSocket Integration**: IoT tool call message handling
- ✅ **AI Integration**: Voice assistant can control device volume through IoT calls

## Code Patterns

### State Management
```dart
// Riverpod Provider with Hooks
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.read(webSocketServiceProvider));
});

// Hook Consumer Widget
class ChatPage extends HookConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final controller = useTextEditingController();
    // ...
  }
}
```

### Error Handling
Use custom exception types (`NetworkException`, `WebSocketException`) with centralized error handling via `ErrorHandler` class.

### File Naming
- snake_case for files: `chat_service.dart`
- PascalCase for classes: `ChatService`
- camelCase for variables/methods: `sendMessage`

## Code Documentation Standards

**核心原则**: 代码注释要极其详细，宁可过多不可过少

### 注释详细度要求
- **每个关键行都要有注释** - 解释这一行在做什么
- **每个函数都要有文档注释** - 说明功能、参数、返回值
- **每个类都要有详细说明** - 职责、使用场景、依赖关系
- **复杂逻辑必须逐行注释** - 帮助后续维护者理解思路
- **业务逻辑要解释"为什么"** - 不仅说做什么，还要说为什么这样做

### 注释示例标准

```dart
/// WebSocket服务类
/// 
/// 职责：管理与Python后端服务器的实时双向通信
/// 依赖：NetworkChecker（网络状态检查）、AppLogger（日志记录）
/// 使用场景：聊天消息发送、音频流传输、IoT设备控制
class WebSocketService extends BaseService {
  // WebSocket连接实例，null表示未连接
  WebSocket? _webSocket;
  
  /// 连接到WebSocket服务器
  /// 
  /// 参数：
  /// - [url] 服务器WebSocket地址，格式：ws://host:port
  /// - [headers] 可选的HTTP头，用于认证和设备标识
  /// 
  /// 返回：Future<void> 连接完成时resolve，失败时抛出WebSocketException
  /// 
  /// 抛出：
  /// - NetworkException：网络不可用
  /// - WebSocketException：连接失败或协议错误
  Future<void> connect(String url, {Map<String, String>? headers}) async {
    try {
      // 记录连接开始日志，便于调试连接问题
      AppLogger.webSocket.info('🔄 开始连接WebSocket: $url');
      
      // 使用dart:io的WebSocket.connect方法建立连接
      // 这是一个异步操作，可能因网络问题、服务器不可达等原因失败
      _webSocket = await WebSocket.connect(url, headers: headers);
      
      // 连接成功后，通过状态流通知外部监听者
      _connectionController.add(ConnectionState.connected());
      
      // ... 更多注释
    } catch (error, stackTrace) {
      // 连接失败时，记录详细的错误信息和堆栈跟踪
      AppLogger.error.severe('❌ WebSocket连接失败: $error', error, stackTrace);
      throw WebSocketException('连接失败: $error');
    }
  }
}
```

## Configuration System Architecture

### 配置系统设计原则

**核心理念**: 统一配置入口，分层管理，专业分组

项目采用**双层配置架构**，所有应用配置必须遵循以下设计原则：

#### 1. **统一配置入口规则**
- **所有配置项**必须统一放在 `lib/core/config/app_settings.dart` 中管理
- **禁止**在代码中散布硬编码的配置值
- **所有组件**都必须从 `AppSettings` 获取配置，不得直接使用魔法数字

#### 2. **双层架构设计**
```dart
// 静态默认值 - 性能优化，零运行时开销
static const _defaultFloatingChatSize = 80.0;

// 用户动态设置 - 可在设置页面修改
double? _userFloatingChatSize;

// 公共访问接口 - 自动选择用户设置或默认值
double get floatingChatSize => _userFloatingChatSize ?? _defaultFloatingChatSize;
```

#### 3. **分层设置页面结构**

**主设置页面** (`SettingsMainPage`) - 分组导航入口
```
设置主页面
├── UI界面设置 (蓝色主题)
├── 网络连接设置 (绿色主题)  
├── 音频设置 (橙色主题)
├── 主题样式 (紫色主题)
└── 开发者选项 (红色主题)
```

## Global Font Scaling Best Practices

### 字体缩放架构原则

**核心理念**: 全局统一，使用Flutter原生机制

项目使用**Flutter的MediaQuery.textScaler机制**实现全局字体缩放，而不是在每个组件中单独设置字体大小。

#### 全局字体缩放实现

在`main.dart`中的MaterialApp.builder实现：

```dart
builder: (context, child) {
  final settings = ref.watch(appSettingsProvider);
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      // 使用配置系统的字体缩放比例
      textScaler: TextScaler.linear(settings.fontScale),
    ),
    child: child!,
  );
},
```

#### 组件字体大小规范

**✅ 正确做法**：
```dart
// 使用默认字体大小，由全局textScaler缩放
Text('Hello World', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))

// 特殊情况：明确需要小字体的场景
Text('提示信息', style: TextStyle(fontSize: 12, color: Colors.grey))
```

**❌ 错误做法**：
```dart
// 不要基于设备类型或其他条件动态计算字体大小
final fontSize = isCompact ? 12.0 : 14.0;
Text('Content', style: TextStyle(fontSize: fontSize))
```

## Quality Standards

- **All code must compile without warnings** - 零警告原则
- **Hot reload must work properly** - 确保开发效率
- **Follow the compositional architecture patterns** - 遵循组合式架构
- **Use Hooks for local component state, Riverpod for global state** - 状态管理规范
- **Maintain clear separation between presentation, business, and data layers** - 分层架构清晰
- **Follow comprehensive logging practices using AppLogger** - 完善的日志记录
- **📝 极其详细的代码注释** - 每个关键行、每个函数、每个类都要有详细注释

### 🔍 强制性Lint检测规则

**重要**: 每次功能完成后，必须执行lint检测并修复所有问题。

```bash
flutter analyze
```

**Lint检测要求**：
- ✅ 所有error必须修复
- ✅ 所有warning必须修复  
- ✅ 建议修复info级别的提示
- ✅ 只有在lint检测通过后才能提交代码

## Integration Guidelines

### When implementing new features:
1. **Reference ESP32 client** (`/Users/yaotutu/Desktop/code/xiaozhi-esp32`) as the primary reference for implementation patterns
2. **Check Python backend docs** (`/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server/docs/`) for API specifications
3. **Follow WebSocket protocol** as implemented in ESP32 client (most standard implementation)
4. **Maintain session management** with proper device-id and session-id handling
5. **Use consistent error handling** patterns across all network operations

### Audio feature implementation (future development):
- **Primary reference**: ESP32 client's audio processing implementation
- **Secondary reference**: Android client's `AudioUtil` class for Flutter-specific integration
- Follow the audio processing pipeline: `Microphone → PCM16 → Opus → WebSocket`
- Implement real-time audio streaming with 60ms frame duration
- Use 16kHz sample rate, mono channel configuration

### UI/UX consistency:
- Follow Material Design 3 with neumorphism elements
- Maintain gradient backgrounds and floating elements
- Implement smooth animations and transitions
- Ensure responsive design for different screen sizes

## 项目记忆重要提醒

1. **参考项目位置**：
   - **ESP32客户端**：`/Users/yaotutu/Desktop/code/xiaozhi-esp32` **[最标准的客户端实现]**
   - **Android客户端**：`/Users/yaotutu/Desktop/code/xiaozhi-android-client` **[次要参考]**
   - **Python后端**：`/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server`

2. **当前开发重点**：
   - 文本消息发送功能已完成，需要实现服务器响应消息的完整处理
   - IoT设备控制功能已实现音量控制，可作为扩展其他设备功能的基础
   - 重点关注消息状态管理和错误处理机制
   - 下一步实现音频录制和TTS播放功能
   - 不支持服务器切换功能，统一使用Python后端

## Git提交规范

**重要**: Git提交规范已独立提取到 `docs/git-commit-convention.md`

在需要Git提交时，请参考该文件中的详细规范。所有提交必须遵循Conventional Commits格式。
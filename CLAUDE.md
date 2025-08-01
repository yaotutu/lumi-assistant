# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lumi Assistant is a Flutter-based intelligent voice assistant client featuring comprehensive IoT device control, push notification integration, and web-based configuration. Built with modern Flutter architecture for Android 6.0+ devices.

## Architecture

The project uses **modern Flutter architecture** with extended service integration:
- **Layered Architecture**: Presentation → Application → Data → Infrastructure
- **Declarative State Management**: flutter_hooks + hooks_riverpod
- **Service-Oriented Design**: WebSocket, Gotify, MCP, Health Check services
- **Compositional UI**: Four-layer home layout system
- **Responsive Design**: Adaptive UI based on screen size and capabilities

Key architectural principles:
- Composition over inheritance
- Single-directional data flow: `User Action → Provider → Service → Repository → DataSource`
- Service isolation with health monitoring
- Unified notification management across multiple sources
- **Screen-adaptive layouts**: Different UI patterns for large and small screens

## Core Services Architecture

```
┌─ WebSocket Service ────────────────────────┐
│  ├─ Connection Management                  │
│  ├─ Message Routing                        │
│  └─ Auto-reconnection                      │
└────────────────────────────────────────────┘
                    │
┌─ Unified MCP Manager──────────────────────┐
│  ├─ Embedded Servers (Brightness, Volume) │
│  ├─ External Servers (HTTP/Stdio)         │
│  └─ Session Management                     │
└────────────────────────────────────────────┘
                    │
┌─ Gotify Service ──────────────────────────┐
│  ├─ WebSocket Notifications               │
│  ├─ HTTP API (History/Delete)             │
│  └─ Authentication & Reconnection         │
└────────────────────────────────────────────┘
                    │
┌─ Unified Notification Service ────────────┐
│  ├─ Multiple Sources (Gotify, System)     │
│  ├─ Read Status Management                │
│  └─ UI Integration                         │
└────────────────────────────────────────────┘
                    │
┌─ Health Check System ─────────────────────┐
│  ├─ Service Status Monitoring             │
│  ├─ Parallel Health Checks                │
│  └─ Status Notifications                  │
└────────────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── core/
│   ├── services/
│   │   ├── websocket/           # WebSocket communication
│   │   ├── notification/        # Gotify & unified notifications
│   │   ├── mcp/                # MCP protocol & tool management
│   │   ├── health/             # Service health monitoring
│   │   ├── config/             # App settings & web config
│   │   └── audio/              # Audio processing
│   ├── config/                 # Configuration management
│   └── constants/              # API constants & endpoints
├── data/
│   ├── models/                 # Data models & DTOs
│   ├── sources/                # Notification sources
│   └── repositories/           # Data access layer
└── presentation/
    ├── pages/                  # Page-oriented organization
    ├── providers/              # Riverpod state providers
    ├── widgets/                # Organized widget hierarchy
    │   ├── notification/       # Notification UI components
    │   ├── status/            # Connection/health status
    │   ├── dialog/            # Dialog components
    │   ├── voice/             # Voice input widgets
    │   ├── common/            # Shared UI components
    │   └── virtual_character/ # Character renderer system
    └── themes/                # App themes and styling
```

### Widget Organization Rules

**Functional Organization**: Widgets are organized by function, not feature:
- `notification/` - All notification-related UI components
- `status/` - Connection and health status displays
- `dialog/` - Modal dialogs and overlays
- `voice/` - Voice input and audio controls
- `common/` - Shared components used across features

## Development Commands

### Environment Setup
```bash
# Check Flutter environment
flutter doctor

# Install dependencies
flutter pub get

# Run the app (preferred device: YT3002)
flutter run -d 1W11833968

# Quick analysis and hot reload
flutter analyze && echo "r" | nc localhost [dart_vm_port]
```

### Device Configuration
**Primary Testing Device**: YT3002 (Device ID: 1W11833968)
- Platform: Android 7.0 (API 24)
- Architecture: android-arm64
- Screen Resolution: 1280x736 (Landscape-oriented)
- Usage: Primary development and testing device

### Service Testing Commands
```bash
# Test Gotify integration
curl -X POST "http://YOUR_GOTIFY_SERVER/message?token=YOUR_TOKEN" \
  -F "title=Test" -F "message=Hello from Lumi"

# Test web configuration access
curl http://YOUR_DEVICE_IP:8888/api/settings

# Check MCP tool availability
# (Through app UI - MCP tools are listed in device control panel)
```

## Platform Support

| 平台 | 支持状态 | 音频实现 | 网络配置 | 通知支持 |
|------|----------|----------|----------|----------|
| **Android** | ✅ **完整支持** | 原生AudioTrack | Web配置界面 | Gotify推送 |
| **iOS** | ⚠️ **接口预留** | 待实现 | 待实现 | 待实现 |
| **Web** | ❌ **不支持** | N/A | N/A | N/A |
| **Desktop** | ❌ **不支持** | N/A | N/A | N/A |

## Backend Integration

**Python Backend Server**: `/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server`

### Connection Endpoints
- **WebSocket**: `ws://YOUR_SERVER_IP:8000/`
- **HTTP API**: `http://YOUR_SERVER_IP:8000/api`
- **Web Config**: `http://DEVICE_IP:8888` (served by Flutter app)

### Protocol Support
- **Message Types**: `hello` (handshake), `chat` (text), `listen` (voice), `image` (vision)
- **MCP Tools**: Volume control, brightness adjustment, custom tools
- **Authentication**: Bearer Token + Device-ID headers

### Gotify Integration
- **WebSocket Stream**: `ws://GOTIFY_SERVER/stream?token=CLIENT_TOKEN`
- **Message API**: `http://GOTIFY_SERVER/message`
- **Client Management**: Through Gotify web UI

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
- ✅ **WebSocket Communication**: Real-time bidirectional communication
- ✅ **Text Chat**: Send and receive text messages via WebSocket
- ✅ **Gotify Push Notifications**: Real-time notification integration
- ✅ **Web Configuration Interface**: Browser-based settings management
- ✅ **MCP Tool Integration**: IoT device control (volume, brightness)
- ✅ **Health Check System**: Service status monitoring and reporting
- ✅ **Unified Notification System**: Multiple notification sources
- ✅ **Virtual Character System**: Extensible character renderer
- ✅ **Four-Layer UI Architecture**: Background, status, actions, floating chat

**Notification System**:
- ✅ **Gotify Integration**: WebSocket + HTTP API support
- ✅ **Unified Management**: Multiple sources with consistent UI
- ✅ **Read Status Sync**: Local and server-side read state management
- ✅ **Notification Detail Dialog**: Full message viewing with overlay positioning

**MCP Integration**:
- ✅ **Embedded Tools**: Brightness and volume control
- ✅ **External Server Support**: HTTP and stdio communication
- ✅ **Session Management**: Auto-regeneration on server changes
- ✅ **Timeout Handling**: User notifications for unresponsive tools

## Code Patterns

### Service Integration Pattern
```dart
// Service provider with health monitoring
final gotifyServiceProvider = Provider<GotifyService>((ref) {
  return GotifyService();
});

// Health check integration
final healthCheckInitializerProvider = Provider<void>((ref) {
  final healthManager = ServiceHealthManager();
  healthManager.registerChecker(GotifyHealthChecker(ref.read(gotifyServiceProvider)));
  // Register other checkers...
});
```

### Notification Source Pattern
```dart
// Unified notification source interface
abstract class INotificationSource {
  String get sourceId;
  String get sourceName;
  Future<bool> markAsRead(String notificationId, {bool syncToServer = false});
  Future<List<UnifiedNotification>> getHistory({int limit = 50});
}

// Implementation for Gotify
class GotifyNotificationSource implements INotificationSource {
  // Gotify-specific implementation
}
```

### MCP Tool Registration
```dart
// Register MCP tools
final mcpManager = UnifiedMcpManager();
await mcpManager.addEmbeddedServer('brightness', BrightnessControlServer());
await mcpManager.addExternalServer('custom-tools', 'http://localhost:3001');

// Execute tools through WebSocket messages
final toolCall = McpToolCall(
  tool: 'adjust_volume',
  arguments: {'level': 0.8},
);
await mcpManager.executeTool(toolCall);
```

### Error Handling
Use custom exception types (`NetworkException`, `WebSocketException`, `McpException`) with centralized error handling via health check system.

### File Naming
- snake_case for files: `gotify_service.dart`
- PascalCase for classes: `GotifyService`
- camelCase for variables/methods: `sendMessage`

## Configuration System Architecture

### 配置系统设计原则

**核心理念**: 双层配置架构 + Web配置界面

项目采用**双层配置架构**配合Web配置界面：

#### 1. **统一配置入口规则**
- **所有配置项**必须统一放在 `lib/core/config/app_settings.dart` 中管理
- **网络配置**通过Web界面 (`http://DEVICE_IP:8888`) 进行设置
- **禁止**在代码中散布硬编码的配置值

#### 2. **双层架构设计**
```dart
// 静态默认值 - 性能优化，零运行时开销
static const _defaultGotifyEnabled = false;

// 用户动态设置 - 可通过Web界面修改
bool? _userGotifyEnabled;

// 公共访问接口 - 自动选择用户设置或默认值
bool get gotifyEnabled => _userGotifyEnabled ?? _defaultGotifyEnabled;
```

#### 3. **Web配置架构**
```
Web Config Service (Port 8888)
├── API Endpoints (/api/*)
├── Static Web Interface
├── Settings Persistence
└── Real-time Updates
```

## Notification System Architecture

### 通知系统设计原则

**核心理念**: 多源统一，分层管理，Overlay显示

#### 1. **通知源管理**
```dart
// 统一通知服务
UnifiedNotificationService.instance
├── registerSource(INotificationSource)
├── addNotification(UnifiedNotification)
└── getNotifications()

// 通知源实现
├── GotifyNotificationSource (外部推送)
└── SystemNotificationSource (内部通知)
```

#### 2. **UI层级管理**
- **通知气泡**: Overlay定位，左侧固定
- **详情对话框**: 最高层级Overlay，确保不被遮挡
- **通知面板**: 可滑动列表，支持操作

#### 3. **状态同步机制**
- 本地已读状态立即更新
- 服务器同步异步执行
- 支持离线操作缓存

## Global Font Scaling Best Practices

### 字体缩放架构原则

**核心理念**: 全局统一，使用Flutter原生机制

项目使用**Flutter的MediaQuery.textScaler机制**实现全局字体缩放：

```dart
builder: (context, child) {
  final settings = ref.watch(appSettingsProvider);
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(settings.fontScale),
    ),
    child: child!,
  );
},
```

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

## Quality Standards

- **All code must compile without warnings** - 零警告原则
- **Hot reload must work properly** - 确保开发效率
- **Follow service isolation principles** - 服务隔离设计
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
1. **Reference ESP32 client** (`/Users/yaotutu/Desktop/code/xiaozhi-esp32`) as the primary reference
2. **Check Python backend docs** (`/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server/docs/`) for API specifications
3. **Follow WebSocket protocol** as implemented in ESP32 client
4. **Integrate with health check system** for new services
5. **Use unified notification system** for user feedback
6. **Support web configuration** for network-related settings

### Service Implementation Pattern:
1. **Create service class** with proper error handling
2. **Add health checker** implementing `IServiceHealthChecker`
3. **Register with health manager** in appropriate provider
4. **Add web configuration** if network settings required
5. **Integrate with unified notification** for status updates

### MCP Tool Development:
- **Primary reference**: MCP specification and existing embedded tools
- **Tool interface**: Follow MCP protocol for tool definitions
- **Timeout handling**: Implement proper timeout with user notifications
- **Error reporting**: Use health check system for tool availability

### UI/UX consistency:
- **Four-layer architecture**: Respect background, status, actions, floating chat layers
- **Notification positioning**: Use Overlay for proper z-index management
- **Material Design 3**: Follow current design system
- **Responsive design**: Support different screen sizes and orientations

## 项目记忆重要提醒

1. **参考项目位置**：
   - **ESP32客户端**：`/Users/yaotutu/Desktop/code/xiaozhi-esp32` **[最标准的客户端实现]**
   - **Android客户端**：`/Users/yaotutu/Desktop/code/xiaozhi-android-client` **[次要参考]**
   - **Python后端**：`/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server`

2. **当前开发重点**：
   - ✅ **Gotify通知推送集成** - 已完成WebSocket和HTTP API支持
   - ✅ **Web配置界面** - 已实现浏览器配置，避免手动输入
   - ✅ **健康检查系统** - 已建立服务监控和状态报告
   - ✅ **MCP工具集成** - 已支持内嵌和外部工具服务器
   - ✅ **统一通知系统** - 已实现多源通知管理
   - 🔄 **音频录制和TTS播放** - 下一步重点功能
   - 🔄 **桌面待机系统** - 信息展示终端功能

3. **服务配置要点**：
   - **不支持服务器切换功能**，统一使用Python后端
   - **Gotify为可选服务**，未配置时不影响核心功能
   - **Web配置端口固定为8888**，确保无冲突
   - **MCP工具支持热插拔**，可动态添加外部服务器

## Git提交规范

**重要**: Git提交规范已独立提取到 `docs/git-commit-convention.md`

### 🚨 Git提交前的强制要求

**在执行任何 git commit 命令之前，必须始终询问用户确认**：

1. **显示即将提交的内容**：
   ```bash
   git status
   git diff --cached  # 显示暂存的更改
   ```

2. **向用户确认**：
   - "我准备提交以下更改，请确认是否继续？"
   - 显示提交信息预览
   - 等待用户明确同意后再执行

3. **提交流程**：
   - 用户确认后才执行 `git commit`
   - 如果用户拒绝，询问是否需要修改提交内容
   - 永远不要在未经用户确认的情况下提交代码

### 提交信息格式

在需要Git提交时，请参考 `docs/git-commit-convention.md` 文件中的详细规范。所有提交必须遵循Conventional Commits格式。
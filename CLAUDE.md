# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lumi Assistant is a Flutter-based intelligent voice assistant client using a milestone-driven development approach. The project is currently in **Phase 1** (text chat functionality) with 10 planned milestones, each requiring user verification before proceeding.

**Current Status**: Milestone 3 (Hello handshake flow) - Successfully completed. Ready for Milestone 4 (Basic UI framework).

## Architecture

The project uses **modern Flutter architecture** rejecting traditional MVVM in favor of:
- **Layered Architecture**: Presentation → Application → Data → Infrastructure
- **Declarative State Management**: flutter_hooks + hooks_riverpod
- **Compositional Design**: Small, focused, reusable components
- **Functional Programming**: Hooks-based approach with pure functions

Key architectural principles:
- Composition over inheritance
- Single-directional data flow: `User Action → Provider → Service → Repository → DataSource`
- Atomic UI components with clear separation of concerns
- State isolation using Riverpod providers, not traditional Provider pattern

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
    │           ├── background_layer.dart
    │           ├── app_status_bar.dart
    │           ├── time_panel.dart
    │           ├── interaction_layer.dart
    │           └── floating_actions.dart
    ├── widgets/             # Shared widgets across pages
    └── themes/              # App themes and styling
```

### File Organization Rules

**Page-Oriented Structure**: Each page should have its own directory containing:
- Main page file (e.g., `home_page.dart`)
- `widgets/` subdirectory for page-specific components
- Any page-specific services, models, or utilities

**Shared Components**: Common widgets used across multiple pages go in `presentation/widgets/`

**Benefits**:
- Clear separation of concerns per page
- Easy to locate and maintain page-specific code
- Better scalability for large applications
- Intuitive file organization

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
**Preferred Testing Device**: YT3002 (Device ID: 1W11833968)
- Platform: Android 7.0 (API 24)
- Architecture: android-arm64
- Usage: Primary development and testing device

When multiple devices are connected, always use the `-d 1W11833968` flag to target the YT3002 device specifically.

### Quick Commands for YT3002 Device
```bash
# Quick run on YT3002 (preferred device)
flutter run -d 1W11833968

# Hot reload on YT3002
flutter run -d 1W11833968 --hot

# Build and run debug APK on YT3002
flutter run -d 1W11833968 --debug

# Clean build on YT3002
flutter clean && flutter pub get && flutter run -d 1W11833968
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test directory
flutter test test/presentation/providers/

# Generate test coverage
flutter test --coverage
```

### Building
```bash
# Build APK for release
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Analyze code
flutter analyze
```

## Backend Integration

**Python Backend Server**: `/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server`
**WebSocket**: `ws://192.168.110.199:8000/` (固定使用Python服务器)
**HTTP API**: `http://192.168.110.199:8000/api` (固定使用Python服务器)
**Authentication**: Bearer Token + Device-ID headers

Message types: `hello` (handshake), `chat` (text), `listen` (voice), `image` (vision)

**服务器配置说明**：
- 开发环境：使用局域网IP `192.168.110.199` (Python服务器)
- 不支持服务器切换功能，统一使用Python后端
- 配置位置：`lib/core/constants/api_constants.dart`

## Reference Implementation

**Android Client**: `/Users/yaotutu/Desktop/code/xiaozhi-android-client`
- Use this Android client as the main reference for implementation patterns
- Follow similar WebSocket handling and UI interaction patterns
- Reference authentication and message handling approaches

## Milestone-Driven Development

**Critical**: This project follows strict milestone verification:
1. Each milestone must be fully completed before moving to next
2. User verification required after each milestone
3. No feature should be started without completing current milestone
4. All progress tracked in `docs/planning/MILESTONE_TRACKING.md`

**里程碑完成状态**:
- ✅ 里程碑1：项目基础搭建 - 已完成
- ✅ 里程碑2：网络连接基础 - 已完成  
- ✅ 里程碑3：Hello握手流程 - 已完成
- 🔄 里程碑4：基础UI框架 - 准备开始

**当前里程碑4任务**:
- 主界面布局设计
- 背景图片显示
- 基础信息面板（时间显示）
- 右下角按钮组件

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

## Documentation Structure

Important docs are organized in `docs/`:
- `planning/` - Project plans and milestone tracking
- `architecture/` - Technical architecture and specifications  
- `frontend/` - Development guidelines and best practices

**Always check milestone status** in `docs/planning/MILESTONE_TRACKING.md` before making changes.

## Quality Standards

- All code must compile without warnings
- Each milestone requires specific verification criteria
- Hot reload must work properly
- Follow the compositional architecture patterns
- Use Hooks for local component state, Riverpod for global state
- Maintain clear separation between presentation, business, and data layers
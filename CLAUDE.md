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

## Project Memory and Context

### Reference Projects Overview

#### Android Client (`/Users/yaotutu/Desktop/code/xiaozhi-android-client`)
**Project Type**: Flutter application (not native Android)
**Architecture**: Provider-based state management with service layer pattern
**Key Features**:
- Real-time WebSocket communication with event-driven architecture
- Opus audio codec integration for voice processing
- Multi-conversation management with persistent storage
- Material Design 3 UI with neumorphism elements
- Voice call interface with audio visualization

**Key Implementation Patterns to Reference**:
```dart
// Event-driven WebSocket architecture
enum XiaozhiEventType { connected, disconnected, message, error, binaryMessage }

// Service layer pattern
class XiaozhiService {
  static final XiaozhiService instance = XiaozhiService._internal();
  late XiaozhiWebSocketManager _webSocketManager;
}

// Audio processing pipeline
class AudioUtil {
  static const int SAMPLE_RATE = 16000;
  static const int CHANNELS = 1;
  static const int FRAME_DURATION = 60; // milliseconds
}
```

#### Python Backend (`/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server`)
**Project Type**: AsyncIO-based Python server with comprehensive AI integration
**Architecture**: Provider pattern with plugin system for AI services
**Core Features**:
- WebSocket server for real-time audio streaming
- HTTP API for OTA updates and vision analysis
- Multi-modal AI: ASR, LLM, TTS, Vision, VAD
- IoT device control with MCP protocol
- Function calling and plugin system

**API Documentation Source**: All interface specifications are derived from this backend's `/docs` directory

### WebSocket Protocol (from Python Backend)

#### Connection Flow:
1. **Client Connection**: `ws://192.168.110.199:8000/xiaozhi/v1/`
2. **Authentication**: Headers (`device-id`, `Authorization: Bearer token`)
3. **Handshake**: `hello` message exchange with session management
4. **Audio Streaming**: Binary Opus frames + JSON text messages

#### Message Types:
```json
// Client Hello
{
  "type": "hello",
  "version": 1,
  "transport": "websocket",
  "audio_params": {
    "format": "opus",
    "sample_rate": 16000,
    "channels": 1,
    "frame_duration": 60
  }
}

// Server Hello Response
{
  "type": "hello",
  "session_id": "uuid-generated-by-server",
  "version": 1,
  "transport": "websocket",
  "audio_params": { ... }
}

// Listen Control
{
  "type": "listen",
  "state": "start|stop|detect",
  "mode": "auto|manual",
  "text": "optional text input"
}

// TTS Response
{
  "type": "tts",
  "state": "start|sentence_start|sentence_end|stop",
  "text": "Generated response text",
  "session_id": "uuid"
}

// STT Recognition
{
  "type": "stt",
  "text": "Recognized speech text",
  "confidence": 0.95,
  "is_final": true,
  "session_id": "uuid"
}
```

### HTTP API Endpoints (from Python Backend)

#### OTA Updates:
```http
POST /xiaozhi/ota/
Headers: device-id, Authorization
Body: {"application": {"version": "1.0.0", "build": "timestamp"}}

Response: {
  "server_time": {"timestamp": 1699123456789, "timezone_offset": 480},
  "websocket": {"url": "ws://192.168.110.199:8000/xiaozhi/v1/"}
}
```

#### Vision Analysis:
```http
POST /mcp/vision/explain
Content-Type: multipart/form-data
Headers: Authorization, Device-Id
Form: question (text), image (file)

Response: {
  "success": true,
  "action": "RESPONSE",
  "response": "Image analysis result..."
}
```

### Audio Processing Specifications (from both projects)

#### Audio Format:
- **Codec**: Opus (libopus)
- **Sample Rate**: 16kHz
- **Channels**: Mono (1 channel)
- **Frame Duration**: 60ms
- **Bitrate**: Adaptive (8-64 kbps)

#### Processing Pipeline:
```
Microphone → PCM16 → Opus Encoder → WebSocket Binary → Server
Server → Opus Audio → WebSocket Binary → Opus Decoder → PCM → Speaker
```

### Integration Patterns for Flutter

#### WebSocket Service Pattern (from Android Client):
```dart
class WebSocketService {
  late WebSocket _webSocket;
  final StreamController<XiaozhiEvent> _eventController = StreamController.broadcast();
  
  Future<void> connect(String url, Map<String, String> headers) async {
    _webSocket = await WebSocket.connect(url, headers: headers);
    _webSocket.listen(_onMessage, onError: _onError);
  }
  
  void sendHello() {
    final hello = {
      'type': 'hello',
      'version': 1,
      'transport': 'websocket',
      'audio_params': {
        'format': 'opus',
        'sample_rate': 16000,
        'channels': 1,
        'frame_duration': 60
      }
    };
    _webSocket.add(jsonEncode(hello));
  }
}
```

#### Provider Pattern (from Backend):
```dart
// AI Service Integration
abstract class ASRProvider {
  Future<String> speechToText(List<int> opusData, String sessionId);
}

abstract class LLMProvider {
  Stream<String> generateResponse(String sessionId, List<Map<String, dynamic>> dialogue);
}

abstract class TTSProvider {
  Future<Uint8List> textToSpeech(String text);
}
```

### Development Priorities (based on reference implementations)

#### Phase 1: Foundation (Current)
- ✅ WebSocket connection with authentication
- ✅ Basic hello handshake protocol
- ✅ Text message exchange
- ✅ Session management

#### Phase 2: Audio Integration
- 🔄 Opus audio recording/encoding
- 🔄 Audio streaming to server
- 🔄 TTS audio reception/playback
- 🔄 Real-time audio processing

#### Phase 3: Advanced Features
- ⏸️ Vision analysis integration
- ⏸️ Function calling display
- ⏸️ IoT device control UI
- ⏸️ Multi-conversation management

#### Phase 4: Production Features
- ⏸️ Error handling and reconnection
- ⏸️ Offline mode support
- ⏸️ Performance monitoring
- ⏸️ Voice call interface

### Key Learnings from Reference Projects

1. **Event-Driven Architecture**: Both projects use listener patterns for real-time communication
2. **Service Layer Separation**: Clear separation between UI and business logic
3. **Robust Audio Processing**: Comprehensive audio pipeline with proper resource management
4. **Session Management**: Proper handling of server sessions and reconnection
5. **Error Handling**: Graceful degradation and user-friendly error messages

### Migration Path (Android Client → Current Flutter)

**State Management**: `Provider` → `hooks_riverpod` (already implemented)
**Architecture**: `Traditional` → `Clean Architecture` (partially implemented)
**Audio Processing**: `Simple` → `Comprehensive Opus Pipeline` (to be implemented)
**UI Pattern**: `Material Design` → `Material Design 3 + Neumorphism` (partially implemented)

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
- ✅ 里程碑4：基础UI框架 - 已完成
- ✅ 里程碑5：聊天界面基础 - 已完成
- ✅ 里程碑6：文字消息发送 - 已完成
- ⏸️ 里程碑7：LLM响应处理 - 等待中

**当前状态**: 里程碑6已完成，可以进入下一阶段开发

**下一阶段任务**（里程碑7：LLM响应处理）:
- 实现服务器响应消息接收和显示
- 完善聊天消息流管理
- 处理不同类型的服务器响应
- 实现消息状态追踪和错误处理

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

### 项目记忆重要提醒

1. **参考项目位置**：
   - Android客户端：`/Users/yaotutu/Desktop/code/xiaozhi-android-client`
   - Python后端：`/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server`

2. **API文档来源**：
   - 所有接口规范都来自Python后端项目的`docs/`目录
   - WebSocket协议和HTTP API的详细定义在上面的项目记忆中

3. **开发优先级**：
   - 当前阶段主要关注文本聊天功能的完善
   - 音频功能在后续阶段实现，需要参考Android客户端的Opus音频处理
   - 多模态功能（视觉、IoT控制）将在最后实现

4. **技术架构对齐**：
   - 当前项目使用的hooks_riverpod比Android客户端的Provider更现代
   - 但需要参考Android客户端的WebSocket事件驱动架构
   - 音频处理管道需要完全遵循Android客户端的模式

5. **当前开发重点**：
   - 里程碑6已完成文本消息发送功能
   - 下一步需要实现服务器响应消息的完整处理
   - 重点关注消息状态管理和错误处理机制
   - 不支持服务器切换功能，统一使用Python后端

## Quality Standards

- All code must compile without warnings
- Each milestone requires specific verification criteria
- Hot reload must work properly
- Follow the compositional architecture patterns
- Use Hooks for local component state, Riverpod for global state
- Maintain clear separation between presentation, business, and data layers

## Integration Guidelines

### When implementing new features:
1. **Reference Android client** (`/Users/yaotutu/Desktop/code/xiaozhi-android-client`) for implementation patterns
2. **Check Python backend docs** (`/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server/docs/`) for API specifications
3. **Follow WebSocket protocol** as defined in project memory section above
4. **Maintain session management** with proper device-id and session-id handling
5. **Use consistent error handling** patterns across all network operations

### Audio feature implementation (future milestone):
- Reference Android client's `AudioUtil` class for Opus codec integration
- Follow the audio processing pipeline: `Microphone → PCM16 → Opus → WebSocket`
- Implement real-time audio streaming with 60ms frame duration
- Use 16kHz sample rate, mono channel configuration

### UI/UX consistency:
- Follow Material Design 3 with neumorphism elements
- Maintain gradient backgrounds and floating elements
- Implement smooth animations and transitions
- Ensure responsive design for different screen sizes
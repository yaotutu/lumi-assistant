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
- **Responsive Design**: Adaptive UI based on screen size and capabilities

Key architectural principles:
- Composition over inheritance
- Single-directional data flow: `User Action → Provider → Service → Repository → DataSource`
- Atomic UI components with clear separation of concerns
- State isolation using Riverpod providers, not traditional Provider pattern
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
**Primary Testing Device**: YT3002 (Device ID: 1W11833968)
- Platform: Android 7.0 (API 24)
- Architecture: android-arm64
- Screen Resolution: 1280x736 (Landscape-oriented)
- Usage: Primary development and testing device

**Additional Testing**: Test on multiple device types to ensure compatibility:
- Different screen sizes (phone, tablet, landscape devices)
- Various Android versions
- Different pixel densities

When multiple devices are connected, use the `-d 1W11833968` flag to target the YT3002 device for primary testing.

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

## Screen Optimization Guidelines

### Responsive Design Principles
**IMPORTANT**: This app should work on various screen sizes and orientations:
- **Approach**: Use responsive design patterns that adapt to different screen sizes
- **Sizing**: Use relative measurements instead of fixed pixel values
- **Layout**: Implement flexible layouts that work across different aspect ratios
- **Testing**: Test on multiple device sizes and orientations

### UI Architecture for Different Screen Modes

#### Large Screen Mode (Priority Implementation)
**Target**: Screens with width >= 600px (portrait) or >= 800px (landscape)

**Features**:
- **Collapsed State**: Small floating icon in bottom-right corner
- **Expanded State**: Left-right split layout (70% chat + 30% character animation)
- **Adaptation Strategy**: Focus on proper center area display, allow margins/padding variations
- **Background**: Supports background concepts, tolerates imperfect edge adaptation

```dart
// Large screen layout parameters
FloatingChatLayoutParams(
  collapsedSize: 100.0,
  expandedWidthRatio: 0.8,
  expandedHeightRatio: 0.6,
  showFullChatInterface: true,
  showCharacterOnRight: true,
  centerContent: true,
)
```

#### Small Screen Mode (Future Implementation)
**Target**: Screens with width < 600px (portrait) or < 800px (landscape)

**Features**:
- **Main Content**: Character animation displayed in center
- **Text Display**: Voice recognition text shown at top
- **Simplified Interface**: No full chat history display
- **Tiny Screen Exception**: Very small screens don't show floating icon on non-chat pages

```dart
// Small screen layout parameters
FloatingChatLayoutParams(
  collapsedSize: 80.0,
  expandedWidthRatio: 0.9,
  expandedHeightRatio: 0.7,
  showFullChatInterface: false,
  showCharacterOnRight: false,
  centerContent: true,
)
```

### Universal UI Design Principles

#### 1. **Avoid Fixed Pixel Sizes**
```dart
// ❌ 错误做法：使用固定像素
Container(
  width: 80,
  height: 80,
  child: Text('🙂', style: TextStyle(fontSize: 24)),
)

// ✅ 正确做法：使用相对尺寸
Container(
  width: containerSize,
  height: containerSize,
  child: Text('🙂', style: TextStyle(fontSize: containerSize * 0.5)),
)
```

#### 2. **Emoji和特殊字符处理**
```dart
// ✅ Emoji显示最佳实践
Text(
  '🙂',
  style: TextStyle(
    fontSize: containerSize * 0.5,  // 相对于容器大小
    height: 1.0,                    // 设置行高为1.0，避免额外空间
    color: Colors.white,
  ),
  textAlign: TextAlign.center,
)

// ✅ 容器设计最佳实践
Container(
  width: double.infinity,          // 充分利用可用空间
  height: double.infinity,         // 充分利用可用空间
  padding: EdgeInsets.all(4),      // 最小必要边距
  child: Center(child: emoji),     // 居中显示
)
```

#### 3. **布局空间计算**
```dart
// ✅ 科学的空间分配
// 总空间 = 内容空间 + 必要边距
// 内容空间 = 字体大小 * 1.2 (预留行高空间)
// 必要边距 = 总空间 * 0.1 (10%边距)

final contentSize = totalSize * 0.8;  // 80%用于内容
final fontSize = contentSize * 0.6;   // 60%用于字体
final padding = totalSize * 0.1;      // 10%用于边距
```

#### 4. **响应式设计模式**
```dart
// ✅ 屏幕尺寸适配
LayoutBuilder(
  builder: (context, constraints) {
    final isLandscape = constraints.maxWidth > constraints.maxHeight;
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    
    // 根据屏幕特性选择布局
    if (isLandscape) {
      return _buildLandscapeLayout(screenWidth, screenHeight);
    } else {
      return _buildPortraitLayout(screenWidth, screenHeight);
    }
  },
)
```

#### 5. **字体和间距优化**
```dart
// ✅ 响应式字体和间距
final textScaleFactor = MediaQuery.of(context).textScaleFactor;
final screenWidth = MediaQuery.of(context).size.width;
final screenHeight = MediaQuery.of(context).size.height;

// 基于屏幕尺寸的字体大小（取较小值保证兼容性）
final minScreenDimension = math.min(screenWidth, screenHeight);
final baseFontSize = minScreenDimension / 20;  // 响应式基础字体
final scaledFontSize = baseFontSize * textScaleFactor;

// 基于屏幕的间距
final baseSpacing = minScreenDimension / 100;  // 响应式间距
```

### 常见布局陷阱及解决方案

#### 1. **边距累积问题**
```dart
// ❌ 问题：多层边距累积
Container(
  padding: EdgeInsets.all(16),     // 外层16px
  child: Container(
    padding: EdgeInsets.all(8),    // 内层8px
    child: Text('内容'),           // 实际可用空间被大量压缩
  ),
)

// ✅ 解决：统一边距管理
Container(
  padding: EdgeInsets.all(4),      // 最小必要边距
  child: Center(child: Text('内容')), // 使用Center而不是嵌套Container
)
```

#### 2. **Flexible vs Expanded使用**
```dart
// ❌ 可能导致内容被压缩
Flexible(child: Text('🙂', style: TextStyle(fontSize: 48)))

// ✅ 确保内容完整显示
Expanded(
  child: Center(
    child: Text('🙂', style: TextStyle(fontSize: 48, height: 1.0))
  )
)
```

#### 3. **动画和过渡优化**
```dart
// ✅ 响应式动画参数
AnimationController(
  duration: Duration(milliseconds: 300),  // 适中的动画时长
  vsync: this,
)

// ✅ 缩放动画的安全范围
Tween<double>(
  begin: 1.0,
  end: 1.2,  // 保守的缩放范围，适用于各种屏幕
)
```

### 测试和验证流程

#### 1. **布局测试清单**
- [ ] 在多种分辨率下测试所有界面（包括常见的移动设备尺寸）
- [ ] 验证emoji和特殊字符在不同屏幕上完整显示
- [ ] 检查是否有内容超出屏幕边界
- [ ] 测试不同字体大小设置的兼容性
- [ ] 验证横屏和竖屏切换（如果支持）
- [ ] 测试不同像素密度设备的显示效果

#### 2. **调试工具使用**
```dart
// ✅ 添加布局调试信息
print('Screen: ${MediaQuery.of(context).size}');
print('Device pixel ratio: ${MediaQuery.of(context).devicePixelRatio}');
print('Text scale factor: ${MediaQuery.of(context).textScaleFactor}');

// ✅ 使用Flutter Inspector
// 在Android Studio中使用Layout Inspector
// 使用flutter run --debug 进行调试
```

#### 3. **性能考虑**
- 避免过度复杂的布局嵌套
- 使用const构造函数优化性能
- 合理使用Expanded和Flexible
- 避免频繁的rebuild

### 设计原则总结

1. **内容优先**: 先确定内容需要多少空间，再设计容器
2. **相对尺寸**: 使用百分比而不是固定像素
3. **充分利用**: 使用double.infinity充分利用可用空间
4. **最小边距**: 使用最小必要的边距，避免空间浪费
5. **实际测试**: 在目标设备上实际测试所有布局
6. **响应式设计**: 考虑不同屏幕尺寸和方向
7. **边界检查**: 确保所有内容都在可视区域内

**记住**: 应用应该在各种屏幕尺寸上都能正常工作。使用响应式设计原则，避免硬编码特定设备的参数。

### Screen Detection and Adaptation

#### ScreenUtils Class
The `ScreenUtils` class provides screen mode detection and layout parameter calculation:

```dart
// Screen mode detection
final screenMode = ScreenUtils.getScreenMode(context);
final isLargeScreen = ScreenUtils.isLargeScreen(context);
final shouldShow = ScreenUtils.shouldShowFloatingChatIcon(context);

// Layout parameters
final layoutParams = ScreenUtils.getFloatingChatLayoutParams(context);
```

#### Implementation Strategy
1. **Current Focus**: Implement and optimize large screen mode
2. **Future Extension**: Add small screen mode using existing interfaces
3. **Testing**: Verify functionality across different screen sizes
4. **Fallback**: Graceful degradation for edge cases

## Testing
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

**ESP32 Client**: `/Users/yaotutu/Desktop/code/xiaozhi-esp32`
- **Most Standard Client**: This is the most standard and reliable client implementation
- **Primary Reference**: When encountering any issues, always refer to this ESP32 client first
- **Complete Implementation**: Contains the most complete and tested implementation patterns
- **Hardware Reference**: Shows how to properly integrate with the Python backend from embedded devices

## Project Memory and Context

### Reference Projects Overview

#### ESP32 Client (`/Users/yaotutu/Desktop/code/xiaozhi-esp32`) **[PRIMARY REFERENCE]**
**Project Type**: C++ embedded client for ESP32 microcontroller
**Architecture**: Event-driven embedded system with real-time processing
**Key Features**:
- **Most Standard Implementation**: This is the gold standard for Python backend integration
- **Complete Protocol Implementation**: Full WebSocket protocol with all message types
- **Hardware Integration**: Direct hardware control (LEDs, buttons, speakers, microphones)
- **Real-time Audio Processing**: Optimized Opus audio encoding/decoding
- **Production-Ready**: Stable, tested, and battle-proven implementation
- **IoT Device Control**: Native hardware control capabilities

**Why This is the Primary Reference**:
- **Proven Stability**: Most reliable and tested client implementation
- **Complete Feature Set**: Implements all backend protocols correctly
- **Hardware Integration**: Shows proper device control patterns
- **Performance Optimized**: Efficient resource usage and real-time processing
- **Protocol Compliance**: Strict adherence to backend API specifications

**Key Implementation Patterns to Reference**:
```cpp
// WebSocket connection and message handling
class WebSocketManager {
  void connect(const char* url);
  void sendMessage(const char* message);
  void handleMessage(const char* message);
};

// Audio processing pipeline
class AudioProcessor {
  static const int SAMPLE_RATE = 16000;
  static const int CHANNELS = 1;
  static const int FRAME_SIZE = 960; // 60ms at 16kHz
};

// Hardware control interface
class HardwareController {
  void setLED(bool state);
  void setVolume(uint8_t level);
  bool getButtonState();
};
```

#### Android Client (`/Users/yaotutu/Desktop/code/xiaozhi-android-client`) **[SECONDARY REFERENCE]**
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

**IoT设备控制功能状态**:
- ✅ **基础架构**：IoT工具注册和执行机制 - 已完成
- ✅ **音量控制**：adjust_volume和get_current_volume工具 - 已完成
- ✅ **WebSocket集成**：IoT工具调用消息处理 - 已完成
- ✅ **AI集成**：语音助手可通过IoT调用控制设备音量 - 已完成
- 🔄 **功能扩展**：可基于现有架构添加更多设备控制功能

**下一阶段任务**（里程碑7：LLM响应处理）:
- 实现服务器响应消息接收和显示
- 完善聊天消息流管理
- 处理不同类型的服务器响应（包括IoT工具调用结果）
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
   - **ESP32客户端**：`/Users/yaotutu/Desktop/code/xiaozhi-esp32` **[最标准的客户端实现]**
   - **Android客户端**：`/Users/yaotutu/Desktop/code/xiaozhi-android-client` **[次要参考]**
   - **Python后端**：`/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server`

2. **参考优先级**：
   - **首选**：遇到任何问题时，首先参考ESP32客户端的实现方式
   - **次选**：ESP32客户端无法提供参考时，再参考Android客户端
   - **API规范**：所有接口规范都来自Python后端项目的`docs/`目录

3. **ESP32客户端的重要性**：
   - **最标准的客户端**：经过充分测试，实现最完整和可靠
   - **协议参考**：WebSocket协议实现的标准参考
   - **硬件控制**：展示了如何正确实现设备控制功能
   - **性能优化**：实时处理和资源优化的最佳实践

4. **开发优先级**：
   - 当前阶段主要关注文本聊天功能的完善
   - 音频功能在后续阶段实现，需要参考ESP32客户端的Opus音频处理
   - IoT设备控制功能已完成基础实现（音量控制）
   - 多模态功能（视觉、更多IoT控制）将在后续实现

5. **技术架构对齐**：
   - 当前项目使用的hooks_riverpod比Android客户端的Provider更现代
   - 但需要参考ESP32客户端的WebSocket协议实现
   - 音频处理管道需要完全遵循ESP32客户端的模式
   - IoT设备控制功能要参考ESP32客户端的硬件控制接口

6. **当前开发重点**：
   - 里程碑6已完成文本消息发送功能
   - 里程碑7需要实现服务器响应消息的完整处理
   - IoT设备控制功能已实现音量控制，可作为扩展其他设备功能的基础
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
1. **Reference ESP32 client** (`/Users/yaotutu/Desktop/code/xiaozhi-esp32`) as the primary reference for implementation patterns
2. **Check Python backend docs** (`/Users/yaotutu/Desktop/code/xiaozhi-esp32-server/main/xiaozhi-server/docs/`) for API specifications
3. **Follow WebSocket protocol** as implemented in ESP32 client (most standard implementation)
4. **Maintain session management** with proper device-id and session-id handling
5. **Use consistent error handling** patterns across all network operations
6. **Hardware control patterns** should follow ESP32 client's hardware abstraction layer

### Audio feature implementation (future milestone):
- **Primary reference**: ESP32 client's audio processing implementation
- **Secondary reference**: Android client's `AudioUtil` class for Flutter-specific integration
- Follow the audio processing pipeline: `Microphone → PCM16 → Opus → WebSocket`
- Implement real-time audio streaming with 60ms frame duration
- Use 16kHz sample rate, mono channel configuration
- Reference ESP32 client for optimal buffer management and real-time processing

### IoT device control implementation:
- **Follow ESP32 patterns**: Reference ESP32 client's hardware control interface
- **Device abstraction**: Create Flutter equivalents of ESP32's hardware control classes
- **Message handling**: Follow ESP32 client's IoT message processing patterns
- **Error handling**: Implement similar error recovery mechanisms

### UI/UX consistency:
- Follow Material Design 3 with neumorphism elements
- Maintain gradient backgrounds and floating elements
- Implement smooth animations and transitions
- Ensure responsive design for different screen sizes

## Configuration System Architecture

### 配置系统设计原则

**核心理念**: 统一配置入口，分层管理，专业分组

项目采用**双层配置架构**，所有应用配置必须遵循以下设计原则：

#### 1. **统一配置入口规则**
- **所有配置项**必须统一放在 `lib/core/config/app_settings.dart` 中管理
- **禁止**在代码中散布硬编码的配置值
- **所有组件**都必须从 `AppSettings` 获取配置，不得直接使用魔法数字
- **新增配置项**时必须同时添加到配置系统中

#### 2. **双层架构设计**
```dart
// 静态默认值 - 性能优化，零运行时开销
static const _defaultFloatingChatSize = 80.0;

// 用户动态设置 - 可在设置页面修改
double? _userFloatingChatSize;

// 公共访问接口 - 自动选择用户设置或默认值
double get floatingChatSize => _userFloatingChatSize ?? _defaultFloatingChatSize;
```

**架构优势**：
- **性能优化**：静态默认值减少运行时判断
- **用户灵活性**：可在设置页面随时调整
- **代码简洁**：统一的配置访问接口
- **易于扩展**：后期可轻松添加新配置

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

**专业设置子页面** - 按功能域分组：
- `SettingsUIPage`: 界面相关（悬浮窗、字体、动画等）
- `SettingsNetworkPage`: 网络相关（服务器地址、超时等）
- `SettingsAudioPage`: 音频相关（采样率、声道、帧时长等）
- `SettingsThemePage`: 主题相关（Material、动画、波纹等）
- `SettingsDebugPage`: 调试相关（各种日志开关）

#### 4. **配置项分类规则**

新增配置项时，必须按以下规则分类：

| 配置类型 | 归属页面 | 命名前缀 | 示例 |
|---------|---------|---------|------|
| UI布局尺寸 | UI界面设置 | `floating`, `font`, `animation` | `floatingChatSize` |
| 网络连接 | 网络设置 | `server`, `api`, `connection` | `serverUrl` |
| 音频处理 | 音频设置 | `sample`, `channels`, `frame` | `sampleRate` |
| 主题外观 | 主题样式 | `use`, `enable` | `useMaterial3` |
| 调试开关 | 开发者选项 | `debug` | `debugEnableLogging` |

#### 5. **配置项实现规范**

**添加新配置项的完整流程**：

1. **在 `AppSettings` 中定义**：
```dart
// 1. 添加静态默认值
static const _defaultNewSetting = 'default_value';

// 2. 添加用户设置字段
String? _userNewSetting;

// 3. 添加公共访问接口
String get newSetting => _userNewSetting ?? _defaultNewSetting;

// 4. 添加更新方法
Future<void> updateNewSetting(String value) async {
  _userNewSetting = value;
  notifyListeners();
  await _saveSettings();
}

// 5. 添加重置方法（如需要）
Future<void> resetNewSetting() async {
  _userNewSetting = null;
  notifyListeners();
  await _saveSettings();
}

// 6. 在loadSettings()中添加加载逻辑
_userNewSetting = prefs.getString('user_new_setting');

// 7. 在_saveSettings()中添加保存逻辑
if (_userNewSetting != null) {
  await prefs.setString('user_new_setting', _userNewSetting!);
} else {
  await prefs.remove('user_new_setting');
}
```

2. **在对应设置页面中添加UI控件**：
   - 根据配置类型选择合适的设置子页面
   - 使用统一的UI组件样式
   - 提供重置功能（如果需要）

3. **在业务代码中使用**：
```dart
// ✅ 正确方式 - 从配置系统获取
final settings = ref.watch(appSettingsProvider);
final value = settings.newSetting;

// ❌ 错误方式 - 硬编码
final value = 'hardcoded_value';
```

#### 6. **配置系统扩展指南**

**添加新配置分组时**：
1. 创建新的设置子页面 `SettingsXxxPage`
2. 在主设置页面添加对应的导航卡片
3. 选择合适的主题色彩
4. 遵循现有的UI设计模式

**配置项命名规范**：
- 使用驼峰命名法
- 体现配置的功能和作用域
- 保持简洁且见名知意
- 避免缩写和模糊词汇

#### 7. **性能和用户体验要求**

- **即时生效**：配置变更必须立即反映到UI中
- **持久化存储**：所有用户设置自动保存到SharedPreferences
- **重置功能**：支持单项重置和全局重置
- **验证机制**：输入验证和错误提示
- **响应式设计**：适配不同屏幕尺寸

### 实施检查清单

在添加任何新的配置功能时，请确认：

- [ ] 配置项已添加到 `AppSettings` 类中
- [ ] 遵循双层架构设计（静态默认值 + 用户设置）
- [ ] 配置项已归类到正确的设置子页面
- [ ] 提供了适当的UI控件和交互
- [ ] 实现了持久化存储
- [ ] 业务代码从配置系统获取值，无硬编码
- [ ] 添加了必要的验证和错误处理
- [ ] 测试了配置变更的即时生效

**重要提醒**：这个配置系统是应用的核心基础设施，任何破坏性修改都可能影响整个应用的稳定性。请严格遵循以上规则进行配置相关的开发工作。

## Global Font Scaling Best Practices

### 字体缩放架构原则

**核心理念**: 全局统一，使用Flutter原生机制

项目使用**Flutter的MediaQuery.textScaler机制**实现全局字体缩放，而不是在每个组件中单独设置字体大小。

#### 1. **全局字体缩放实现**

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

#### 2. **组件字体大小规范**

**✅ 正确做法**：
```dart
// 使用默认字体大小，由全局textScaler缩放
Text(
  'Hello World',
  style: TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    // 不设置fontSize，使用主题默认值
  ),
)

// 特殊情况：明确需要小字体的场景
Text(
  '提示信息',
  style: TextStyle(
    fontSize: 12, // 固定小字体，会被textScaler缩放
    color: Colors.grey,
  ),
)
```

**❌ 错误做法**：
```dart
// 不要基于设备类型或其他条件动态计算字体大小
final fontSize = isCompact ? 12.0 : 14.0;
Text('Content', style: TextStyle(fontSize: fontSize))

// 不要在每个组件中重复设置fontSize
Text('Content', style: TextStyle(fontSize: 16))
```

#### 3. **字体大小分类标准**

| 用途 | 处理方式 | 示例 |
|------|---------|------|
| 主要文本内容 | 不设置fontSize | 聊天消息、标题、按钮文字 |
| 辅助信息文本 | fontSize: 12 | 时间戳、提示文本、状态信息 |
| 图标尺寸 | 固定size值 | Icon(size: 24), 会被textScaler影响 |

#### 4. **配置系统集成**

`AppSettings`中的`fontScale`配置会：
- 自动应用到所有未明确设置fontSize的Text组件
- 影响所有明确设置了fontSize的组件（按比例缩放）
- 影响Icon组件的size属性
- 影响主题中的默认字体大小

#### 5. **迁移检查清单**

从固定字体大小迁移到全局缩放时：

- [ ] 移除组件中不必要的fontSize设置
- [ ] 保留明确需要小字体的场景（如提示文本）
- [ ] 删除基于设备类型的字体大小计算逻辑
- [ ] 确保TextStyle中只保留必要的样式属性
- [ ] 测试不同fontScale值下的显示效果

#### 6. **性能优化效果**

使用全局字体缩放带来的好处：
- **减少代码复杂度**：无需在每个组件中计算字体大小
- **提升性能**：减少运行时字体大小计算
- **增强一致性**：所有文本自动跟随用户设置变化
- **简化维护**：字体相关逻辑集中在一处管理

#### 7. **实际应用示例**

修改前（复杂）：
```dart
final fontSize = isCompact ? 12.0 : 13.0;
Text(message.content, style: TextStyle(fontSize: fontSize))
```

修改后（简洁）：
```dart
Text(message.content, style: TextStyle(color: Colors.black))
```

用户在设置页面调整"字体缩放比例"时，所有文本都会自动按比例缩放，无需重启应用。

**重要提醒**：添加新的文本组件时，优先使用默认字体大小，只在明确需要特殊尺寸时才设置fontSize。
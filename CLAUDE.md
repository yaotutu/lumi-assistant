# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lumi Assistant is a Flutter-based intelligent voice assistant client using a milestone-driven development approach. The project is currently in **Phase 1** (text chat functionality) with 10 planned milestones, each requiring user verification before proceeding.

**Current Status**: Milestone 1 (Project Setup) - Documentation phase completed, ready for Flutter project initialization.

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
```

## Development Commands

### Environment Setup
```bash
# Check Flutter environment
flutter doctor

# Install dependencies
flutter pub get

# Run the app
flutter run
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

**WebSocket**: `ws://localhost:8000/`
**HTTP API**: `http://localhost:8000/api`
**Authentication**: Bearer Token + Device-ID headers

Message types: `hello` (handshake), `chat` (text), `listen` (voice), `image` (vision)

## Milestone-Driven Development

**Critical**: This project follows strict milestone verification:
1. Each milestone must be fully completed before moving to next
2. User verification required after each milestone
3. No feature should be started without completing current milestone
4. All progress tracked in `docs/planning/MILESTONE_TRACKING.md`

**Current Milestone 1 Tasks**:
- Create Flutter project structure
- Configure dependencies (hooks_riverpod, dio, web_socket_channel)
- Setup basic theming
- Verify compilation and hot reload

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
- Root level - Backend API documentation

**Always check milestone status** in `docs/planning/MILESTONE_TRACKING.md` before making changes.

## Quality Standards

- All code must compile without warnings
- Each milestone requires specific verification criteria
- Hot reload must work properly
- Follow the compositional architecture patterns
- Use Hooks for local component state, Riverpod for global state
- Maintain clear separation between presentation, business, and data layers
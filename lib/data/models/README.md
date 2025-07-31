# Data Models 数据模型层

本目录包含应用的所有数据模型，按功能域组织成不同的子目录。

## 目录结构

```
models/
├── chat/          # 聊天相关模型
├── connection/    # 连接状态模型
├── notification/  # 通知系统模型
├── mcp/          # MCP协议模型
├── common/       # 通用模型和异常
└── models.dart   # 统一导出文件
```

## 各目录说明

### 💬 chat/ - 聊天模型
聊天功能相关的数据模型：
- `chat_state.dart` - 聊天状态管理
- `chat_ui_model.dart` - 聊天UI模型
- `message_model.dart` - 消息数据模型

### 🔗 connection/ - 连接模型
网络连接相关的状态模型：
- `connection_state.dart` - 连接状态
- `websocket_state.dart` - WebSocket状态

### 🔔 notification/ - 通知模型
通知系统的数据模型：
- `gotify_models.dart` - Gotify通知模型

### 🔌 mcp/ - MCP模型
Model Context Protocol相关：
- `mcp_call_state.dart` - MCP调用状态

### 🔧 common/ - 通用模型
通用模型和异常定义：
- `exceptions.dart` - 自定义异常类

## 使用方式

### 单独导入
```dart
import 'package:lumi_assistant/data/models/chat/message_model.dart';
import 'package:lumi_assistant/data/models/connection/connection_state.dart';
```

### 统一导入
```dart
import 'package:lumi_assistant/data/models/models.dart';
```

## Freezed 模型说明

本项目使用 [Freezed](https://pub.dev/packages/freezed) 生成不可变数据类。

### 生成文件
- `.freezed.dart` - Freezed生成的代码
- `.g.dart` - JSON序列化代码

### 重新生成
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 添加新模型

1. 确定模型所属的功能域
2. 在对应目录创建模型文件
3. 如果使用Freezed，添加必要的注解
4. 在 `models.dart` 中添加导出
5. 运行代码生成（如果需要）
6. 更新本README文件

## 命名规范

- 模型类名使用 PascalCase
- 文件名使用 snake_case
- Freezed模型以 `@freezed` 注解开始
- 状态类通常以 `State` 结尾
- UI模型以 `Model` 或 `UIModel` 结尾
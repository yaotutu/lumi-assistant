# Core Services 核心服务层

本目录包含应用的所有核心服务，按功能域组织成不同的子目录。

## 目录结构

```
services/
├── audio/          # 音频相关服务
├── config/         # 配置和初始化服务
├── device/         # 设备相关服务
├── mcp/            # MCP (Model Context Protocol) 服务
├── network/        # 网络相关服务
├── notification/   # 通知系统服务
├── photo_sources/  # 照片源适配器
├── websocket/      # WebSocket通信服务
└── services.dart   # 统一导出文件
```

## 各目录说明

### 📢 audio/ - 音频服务
处理所有音频相关功能：
- 音频录制和播放
- Opus编解码
- 实时音频流
- 原生Android音频支持
- 语音中断检测

### ⚙️ config/ - 配置服务
应用配置和初始化：
- 应用初始化流程
- 配置管理
- Web配置服务

### 📱 device/ - 设备服务
设备相关功能：
- 设备信息获取
- 设备控制（音量等）
- 权限管理

### 🔌 mcp/ - MCP服务
Model Context Protocol相关：
- MCP服务器管理
- MCP配置
- 错误处理
- 统一MCP管理器

### 🌐 network/ - 网络服务
网络相关功能：
- 网络连接检查
- WebSocket握手服务

### 🔔 notification/ - 通知服务
通知系统：
- Gotify集成
- 统一通知管理
- 通知源适配

### 🖼️ photo_sources/ - 照片源
壁纸和照片源适配器：
- Bing壁纸
- Unsplash
- 本地资源
- 占位图

### 🔗 websocket/ - WebSocket服务
WebSocket通信：
- 实时双向通信
- 消息处理
- 连接管理

## 使用方式

### 单独导入
```dart
import 'package:lumi_assistant/core/services/audio/audio_playback_service.dart';
import 'package:lumi_assistant/core/services/network/network_checker.dart';
```

### 统一导入
```dart
import 'package:lumi_assistant/core/services/services.dart';
```

## 添加新服务

1. 确定服务所属的功能域
2. 将服务文件放到对应的子目录
3. 在 `services.dart` 中添加导出
4. 更新本 README 文件

## 命名规范

- 服务类名以 `Service` 结尾
- 文件名使用 snake_case
- 每个服务应该是单例或提供静态方法
- 服务之间的依赖应该通过依赖注入管理
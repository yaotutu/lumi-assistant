# 🚀 贡献者快速入门指南

> 5分钟快速了解Lumi Assistant项目并开始贡献

## 📋 项目概览

**Lumi Assistant** 是一个基于Flutter的智能语音助手客户端，采用现代化架构设计，支持实时语音交互和多模态AI功能。

### 🎯 核心特性
- **智能语音交互**: WebSocket实时通信 + Opus音频编码
- **多模态AI**: 支持文字、语音、图像分析
- **IoT设备控制**: 通过MCP协议控制智能设备
- **响应式设计**: 适配不同屏幕尺寸和设备

### 🏗️ 技术栈速览
- **Frontend**: Flutter + Dart
- **状态管理**: hooks_riverpod
- **音频处理**: Android原生AudioTrack + Opus
- **网络通信**: WebSocket + HTTP API
- **后端**: Python异步服务器

## ⚡ 5分钟启动项目

### 1. 环境准备 (2分钟)
```bash
# 克隆项目
git clone <project-url>
cd lumi-assistant

# 检查Flutter环境
flutter doctor

# 安装依赖
flutter pub get
```

### 2. 连接测试设备 (1分钟)
```bash
# 查看可用设备
flutter devices

# 推荐：使用YT3002设备（项目主要测试设备）
flutter run -d 1W11833968
```

### 3. 启动应用 (2分钟)
```bash
# 运行应用
flutter run -d 1W11833968

# 或使用热重载模式
flutter run -d 1W11833968 --hot
```

## 🎯 项目架构一图了解

```
┌─────────────────────────────────────────┐
│  Lumi Assistant Flutter Client          │
├─────────────────────────────────────────┤
│           UI Layer (Flutter)            │
│  📱 HomePage | 💬 ChatPage | ⚙️ Settings  │
├─────────────────────────────────────────┤
│      State Management (Riverpod)        │
│  🔄 ConnectionProvider | 💭 ChatProvider │
├─────────────────────────────────────────┤
│         Service Layer (Dart)            │
│  🌐 WebSocket | 🎤 Audio | 🤝 Handshake  │
├─────────────────────────────────────────┤
│      Native Layer (Android/iOS)         │
│  📢 AudioTrack | 🔊 OpusCodec | 🎙️ Mic   │
└─────────────────────────────────────────┘
             ↕️ WebSocket
┌─────────────────────────────────────────┐
│       Python Backend Server             │
│  🤖 AI Services | 🏠 IoT Control         │
└─────────────────────────────────────────┘
```

## 📂 项目目录导航

快速定位你需要修改的代码：

```
lib/
├── 🏠 presentation/pages/home/          # 主页UI和交互
├── 💬 presentation/pages/chat/          # 聊天界面
├── ⚙️ presentation/pages/settings/      # 设置页面
├── 🔄 presentation/providers/           # 状态管理逻辑
├── 🌐 core/services/websocket_service.dart    # WebSocket通信
├── 🎤 core/services/audio_service_*.dart       # 音频处理
├── 📱 core/utils/app_logger.dart              # 日志系统
└── ⚙️ core/config/app_settings.dart           # 应用配置
```

## 🎯 常见贡献场景

### 🐛 修复Bug
1. **查看Issues**: 选择标记为`bug`的issue
2. **定位代码**: 使用项目日志查找相关代码
3. **本地调试**: 使用`AppLogger`查看详细日志
4. **提交修复**: 遵循代码审查流程

### ✨ 添加新功能
1. **UI功能**: 修改`presentation/pages/`相关页面
2. **业务逻辑**: 在`presentation/providers/`添加状态管理
3. **服务集成**: 在`core/services/`添加新服务
4. **配置管理**: 在`core/config/`添加新配置项

### 🎨 UI优化
1. **页面布局**: 直接修改对应page文件
2. **共享组件**: 在`presentation/widgets/`添加复用组件
3. **响应式设计**: 使用`ScreenUtils`适配不同屏幕
4. **主题样式**: 修改`presentation/themes/`

### 🔧 性能优化
1. **状态管理**: 优化Provider的订阅和更新
2. **音频处理**: 优化Opus编解码性能
3. **网络请求**: 优化WebSocket连接和重连逻辑
4. **内存管理**: 检查资源释放和循环引用

## 🔧 开发工具链

### 必备工具
- **IDE**: Android Studio / VS Code + Flutter插件
- **调试**: Flutter DevTools (`flutter pub global run devtools`)
- **日志查看**: 使用项目内置的`AppLogger`分类日志
- **设备测试**: 主要使用YT3002设备 (`flutter run -d 1W11833968`)

### 调试技巧
```dart
// 使用分类日志快速定位问题
AppLogger.webSocket.info('连接状态变化');
AppLogger.audio.warning('音频权限问题');
AppLogger.chat.info('消息发送成功');
AppLogger.ui.fine('页面渲染完成');
```

### 常用命令
```bash
# 清理重建
flutter clean && flutter pub get && flutter run -d 1W11833968

# 检查代码质量
flutter analyze

# 运行测试
flutter test
```

## 🤝 参与贡献流程

### 1. 选择Issue (1分钟)
- 浏览[Issues页面](链接)
- 选择标有`good first issue`或`help wanted`的issue
- 在issue下评论表示认领

### 2. 创建分支 (30秒)
```bash
git checkout -b feature/issue-description
```

### 3. 开发和测试 (主要时间)
- 按照[开发规范](../contributors/README.md)进行开发
- 使用`AppLogger`添加必要的日志
- 在YT3002设备上测试功能
- 确保代码通过`flutter analyze`

### 4. 提交PR (2分钟)
- 详细描述修改内容
- 添加相关测试截图/日志
- 等待代码审查和反馈

## 📚 深入学习路径

### Level 1: 基础了解 (30分钟)
1. 阅读 [项目架构概览](../architecture/ARCHITECTURE_GUIDE.md)
2. 了解 [状态管理](../technical/RIVERPOD_GUIDE.md) 基础用法
3. 熟悉 [日志系统](../technical/LOGGING_GUIDE.md) 的使用方法

### Level 2: 核心功能 (1小时)
1. 深入理解 [WebSocket通信](../technical/WEBSOCKET_GUIDE.md)
2. 学习音频处理和Opus编码机制
3. 掌握响应式UI设计原则

### Level 3: 高级特性 (2小时)
1. IoT设备控制和MCP协议
2. 多模态AI集成（语音、图像、文本）
3. 性能优化和内存管理

### Level 4: 贡献专家 (持续)
1. 参与架构设计讨论
2. Code Review其他贡献者的PR
3. 编写技术文档和教程

## ❓ 遇到问题？

### 🔍 自助解决
1. **日志查看**: 使用`AppLogger`查看详细日志
2. **文档搜索**: 在docs目录搜索相关技术文档
3. **代码搜索**: 使用IDE全局搜索相关功能实现

### 💬 寻求帮助
1. **GitHub Discussions**: 技术讨论和问题求助
2. **Issue评论**: 在相关issue下提问
3. **代码审查**: 在PR中请求具体帮助

## 🎉 开始贡献！

现在你已经准备好为Lumi Assistant做出贡献了！

**推荐起始任务**：
- 修复UI布局在不同屏幕尺寸下的显示问题
- 改进日志信息的可读性和有用性
- 添加新的设置选项和配置项
- 优化网络连接的错误处理和用户提示

**记住**：每一个小的改进都很有价值！不要害怕提交你的第一个PR。

---

> 💡 **提示**: 这个项目注重代码质量和用户体验。你的每一个贡献都会让Lumi Assistant变得更好！
> 
> 🚀 **加油**: 从小任务开始，逐步深入，很快你就会成为项目的核心贡献者！
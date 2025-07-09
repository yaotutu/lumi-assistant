# 🤖 Lumi Assistant

智能语音助手Flutter客户端 - 第一阶段：文字交互功能

## 📋 项目概述

Lumi Assistant是一个基于Flutter开发的智能语音助手客户端，支持与后端AI服务进行实时交互。项目采用渐进式开发方式，确保每个功能模块都经过充分验证后再进入下一阶段。

### 🎯 当前阶段目标
- ✅ 建立WebSocket连接
- ✅ 实现文字聊天功能
- ✅ 完善错误处理机制
- 🔄 **第一阶段开发中**

### 🚀 后续规划
- 📢 语音交互功能
- 📷 图像分析功能  
- 🎭 Live2D动画集成

## 🛠️ 技术栈

- **框架**: Flutter 3.16+
- **状态管理**: flutter_hooks + hooks_riverpod
- **网络通信**: dio + web_socket_channel
- **架构**: 分层架构 + 声明式状态管理 + 组合式设计
- **平台**: Android（优先支持）

## 📁 项目结构

```
lib/
├── core/                    # 核心功能层
│   ├── constants/          # 常量定义
│   ├── errors/             # 错误处理
│   ├── network/            # 网络配置
│   ├── services/           # 核心服务
│   └── utils/              # 工具类
├── data/                   # 数据层
│   ├── datasources/        # 数据源
│   ├── models/             # 数据模型
│   └── repositories/       # 仓库实现
├── domain/                 # 业务层
│   ├── entities/           # 实体类
│   ├── repositories/       # 仓库接口
│   └── usecases/          # 用例
├── presentation/           # 展示层
│   ├── providers/          # 状态提供者
│   ├── pages/              # 页面
│   ├── widgets/            # 组件
│   └── themes/             # 主题
└── main.dart              # 应用入口
```

## 🚦 快速开始

### 前置要求
- Flutter SDK 3.16+
- Android Studio 或 VS Code
- Android设备或模拟器
- 后端服务运行在 `localhost:8000`

### 安装运行

```bash
# 1. 克隆项目
git clone [项目地址]
cd lumi-assistant

# 2. 检查Flutter环境
flutter doctor

# 3. 安装依赖
flutter pub get

# 4. 运行项目
flutter run
```

## 📊 开发进度

### 里程碑进度
| 里程碑 | 状态 | 描述 |
|--------|------|------|
| 里程碑1 | 🔄 进行中 | 项目基础搭建 |
| 里程碑2 | ⏸️ 等待中 | 网络连接基础 |
| 里程碑3 | ⏸️ 等待中 | Hello握手流程 |
| 里程碑4 | ⏸️ 等待中 | 基础UI框架 |
| 里程碑5 | ⏸️ 等待中 | 聊天界面基础 |
| 里程碑6 | ⏸️ 等待中 | 文字消息发送 |
| 里程碑7 | ⏸️ 等待中 | LLM响应处理 |
| 里程碑8 | ⏸️ 等待中 | 错误处理完善 |
| 里程碑9 | ⏸️ 等待中 | 本地存储和历史记录 |
| 里程碑10 | ⏸️ 等待中 | 性能优化和打包 |

**状态说明**: 🔄 进行中 | ✅ 已完成 | ⏸️ 等待中 | ❌ 失败 | 🔧 修复中

## 🔧 开发指南

### 核心开发原则
1. **渐进式开发**: 每个里程碑独立完成和验证
2. **质量优先**: 先确保功能稳定再添加新特性
3. **用户验证**: 每个里程碑都需要用户确认通过
4. **文档同步**: 开发过程和决策都要记录

### 验证流程
每个里程碑遵循固定的验证流程：
```
开发完成 → 自测验证 → 提交验证 → 用户确认 → 进入下一里程碑
```

### 📚 重要文档

#### 项目规划
- 📋 [项目开发计划](docs/planning/PROJECT_PLAN.md) - 详细的里程碑规划
- 📊 [里程碑跟踪记录](docs/planning/MILESTONE_TRACKING.md) - 开发进度跟踪

#### 技术架构  
- 🏗️ [现代化架构设计](docs/architecture/MODERN_ARCHITECTURE.md) - 核心架构理念和设计
- 🔧 [技术规格说明](docs/architecture/TECH_SPEC.md) - 详细技术实现规格

#### 开发指南
- 📖 [前端开发指南](docs/frontend/DEVELOPMENT_GUIDE.md) - 开发规范和最佳实践

#### 后端接口
- 📡 [API快速参考](docs/API快速参考.md) - 后端接口快速查阅
- 📋 [API接口文档](docs/API接口文档.md) - 详细接口说明
- 🔌 [WebSocket使用示例](docs/WebSocket使用示例.md) - WebSocket集成指南

## 🌐 后端接口

### WebSocket连接
- **地址**: `ws://localhost:8000/`
- **协议**: WebSocket
- **消息格式**: JSON

### HTTP API
- **基础地址**: `http://localhost:8000/api`
- **认证方式**: Bearer Token + Device-ID

### 主要消息类型
- `hello` - 连接握手
- `chat` - 文字聊天
- `listen` - 语音控制
- `image` - 图像处理

详细API文档请参考 `docs/` 目录下的后端文档。

## 🧪 测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/presentation/providers/

# 生成测试覆盖率
flutter test --coverage
```

## 📦 构建部署

```bash
# 构建APK
flutter build apk --release

# 构建App Bundle
flutter build appbundle --release
```

## 🤝 贡献指南

### 开发流程
1. 查看当前里程碑状态
2. 按照验证标准开发功能
3. 完成自测验证
4. 提交代码并等待用户验证
5. 验证通过后进入下一里程碑

### 提交规范
- 使用语义化的提交消息
- 每个里程碑创建独立的分支
- 通过验证后合并到主分支

## 📝 版本历史

### v0.1.0 (开发中)
- 🆕 项目初始化
- 🆕 基础架构搭建
- 🔄 里程碑1开发中

## 📞 联系方式

- **开发者**: Claude
- **项目管理**: 基于里程碑跟踪系统
- **文档**: 项目根目录 `.md` 文件

## 📜 许可证

[许可证信息待定]

---

**项目状态**: 🔄 活跃开发中  
**当前版本**: v0.1.0-dev  
**最后更新**: 2025-07-08
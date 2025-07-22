# 📚 Lumi Assistant 文档中心

> 智能语音助手Flutter客户端的完整文档库

欢迎来到Lumi Assistant文档中心！这里提供了项目的完整技术文档、贡献指南和API参考。无论您是新贡献者还是经验丰富的开发者，都能在这里找到所需的信息。

## 🚀 快速导航

### 🏃‍♂️ 新手入门
如果您是第一次接触这个项目：

1. **[项目概览](PROJECT_OVERVIEW.md)** - 了解项目愿景、技术架构和开发里程碑
2. **[快速开始](getting-started/QUICK_START.md)** - 5分钟启动项目并开始贡献
3. **[贡献者指南](contributors/README.md)** - 详细的贡献流程和开发规范

### 🏗️ 架构设计
深入了解项目的架构设计：

- **[系统架构指南](architecture/ARCHITECTURE_GUIDE.md)** - Clean Architecture设计详解
- **[分支构建策略](../.github/BRANCH_STRATEGY.md)** - GitHub Actions自动化构建

### 🛠️ 技术实现
掌握项目核心技术的使用方法：

- **[Riverpod状态管理](technical/RIVERPOD_GUIDE.md)** - hooks_riverpod完整指南
- **[WebSocket通信](technical/WEBSOCKET_GUIDE.md)** - 实时通信协议和实现
- **[日志系统](technical/LOGGING_GUIDE.md)** - 分类日志和调试技巧

### 👥 贡献指南
参与项目开发的详细指南：

- **[开发环境搭建](contributors/DEVELOPMENT_SETUP.md)** - 完整的开发环境配置
- **[代码审查规范](contributors/CODE_REVIEW.md)** - PR提交和代码审查流程
- **[测试指南](contributors/TESTING.md)** - 单元测试和集成测试

## 📋 文档目录结构

```
docs/
├── 📖 README.md                      # 文档导航入口（当前文件）
├── 🎯 PROJECT_OVERVIEW.md             # 项目概览和愿景
│
├── 🚀 getting-started/                # 新手入门指南
│   └── QUICK_START.md                 # 5分钟快速开始
│
├── 🏗️ architecture/                   # 架构设计文档
│   └── ARCHITECTURE_GUIDE.md          # 系统架构详解
│
├── 🛠️ technical/                      # 技术实现指南
│   ├── RIVERPOD_GUIDE.md              # Riverpod状态管理
│   ├── WEBSOCKET_GUIDE.md             # WebSocket通信
│   └── LOGGING_GUIDE.md               # 日志系统使用
│
├── 👥 contributors/                   # 贡献者资源
│   ├── README.md                      # 贡献者总指南
│   ├── DEVELOPMENT_SETUP.md           # 开发环境配置
│   ├── CODE_REVIEW.md                 # 代码审查流程
│   └── TESTING.md                     # 测试规范
│
├── 🔧 api/                           # API文档（未来）
│   └── (待添加API参考文档)
│
└── 📋 planning/                      # 项目规划文档
    └── MILESTONE_TRACKING.md          # 里程碑跟踪
```

## 🎯 根据角色选择阅读路径

### 🆕 初次贡献者
**推荐阅读顺序** (总计约1小时)：
1. [项目概览](PROJECT_OVERVIEW.md) *(10分钟)*
2. [快速开始指南](getting-started/QUICK_START.md) *(20分钟)*
3. [贡献者指南](contributors/README.md) *(15分钟)*
4. [开发环境搭建](contributors/DEVELOPMENT_SETUP.md) *(15分钟)*

### 🔧 技术贡献者
**深入技术细节** (总计约2-3小时)：
1. [系统架构指南](architecture/ARCHITECTURE_GUIDE.md) *(45分钟)*
2. [Riverpod状态管理](technical/RIVERPOD_GUIDE.md) *(30分钟)*
3. [WebSocket通信指南](technical/WEBSOCKET_GUIDE.md) *(30分钟)*
4. [日志系统指南](technical/LOGGING_GUIDE.md) *(20分钟)*
5. [代码审查规范](contributors/CODE_REVIEW.md) *(15分钟)*

### 🎨 UI/UX贡献者
**关注用户体验**：
1. [项目概览 - UI设计部分](PROJECT_OVERVIEW.md#📱-现代化ui设计)
2. [快速开始 - UI优化场景](getting-started/QUICK_START.md#🎨-ui优化)
3. [架构指南 - 响应式设计](architecture/ARCHITECTURE_GUIDE.md#响应式设计)
4. [贡献者指南](contributors/README.md)

### 📝 文档贡献者
**改进文档质量**：
1. [项目概览](PROJECT_OVERVIEW.md) - 了解全貌
2. [贡献者指南](contributors/README.md) - 贡献流程
3. 当前文档目录 - 发现改进空间
4. [代码审查规范](contributors/CODE_REVIEW.md) - PR流程

### 🐛 Bug修复者
**快速定位问题**：
1. [快速开始指南](getting-started/QUICK_START.md) - 快速启动项目
2. [日志系统指南](technical/LOGGING_GUIDE.md) - 使用日志调试
3. [WebSocket通信](technical/WEBSOCKET_GUIDE.md) - 网络问题排查
4. [测试指南](contributors/TESTING.md) - 验证修复

## 🔍 快速查找

### 按技术栈查找
- **Flutter/Dart**: [架构指南](architecture/ARCHITECTURE_GUIDE.md)、[快速开始](getting-started/QUICK_START.md)
- **状态管理**: [Riverpod指南](technical/RIVERPOD_GUIDE.md)
- **网络通信**: [WebSocket指南](technical/WEBSOCKET_GUIDE.md)
- **音频处理**: [项目概览 - 技术架构](PROJECT_OVERVIEW.md#🏗️-技术架构)
- **原生集成**: [架构指南 - 平台集成](architecture/ARCHITECTURE_GUIDE.md)

### 按功能模块查找
- **聊天功能**: [WebSocket指南](technical/WEBSOCKET_GUIDE.md)、[Riverpod指南](technical/RIVERPOD_GUIDE.md)
- **音频功能**: [项目概览](PROJECT_OVERVIEW.md)、[架构指南](architecture/ARCHITECTURE_GUIDE.md)
- **设置系统**: [架构指南 - 配置管理](architecture/ARCHITECTURE_GUIDE.md)
- **UI组件**: [架构指南 - 组件设计](architecture/ARCHITECTURE_GUIDE.md)

### 按问题类型查找
- **环境配置**: [开发环境搭建](contributors/DEVELOPMENT_SETUP.md)
- **编译问题**: [分支构建策略](../.github/BRANCH_STRATEGY.md)
- **调试技巧**: [日志系统指南](technical/LOGGING_GUIDE.md)
- **性能优化**: [架构指南 - 性能优化](architecture/ARCHITECTURE_GUIDE.md)

## 📈 文档贡献

### 发现问题？
如果您发现文档中的错误、过时信息或不清楚的地方：
1. 在GitHub上创建Issue，标记为`documentation`
2. 直接提交PR修复问题
3. 在相关文档下留言建议

### 想要改进？
文档改进的常见方向：
- **增加代码示例** - 让概念更容易理解
- **添加图表说明** - 可视化复杂的概念
- **完善故障排除** - 帮助其他开发者解决问题
- **更新最新信息** - 确保文档与代码同步

### 贡献新文档
如果您想添加新的文档：
1. 先在Issue中讨论文档需求
2. 确定文档应该放在哪个目录下
3. 遵循现有文档的格式和风格
4. 提交PR并请求审查

## 🤝 获得帮助

### 📝 文档问题
- **GitHub Issues**: 报告文档错误或提出改进建议
- **GitHub Discussions**: 讨论文档组织和改进方向

### 💻 技术问题
- **查看相关技术文档**: 先检查是否已有解决方案
- **Issue求助**: 创建详细的问题描述
- **代码审查**: 在PR中请求具体帮助

### 🚀 项目参与
- **选择感兴趣的领域**: 根据上述角色指南选择入门路径
- **从小任务开始**: 文档改进、UI调整、bug修复等
- **积极参与讨论**: 在Issues和Discussions中分享想法

---

> 💡 **提示**: 这些文档是活的，会随着项目的发展不断更新。建议收藏此页面，随时回来查看最新信息。
> 
> 🌟 **感谢**: 感谢每一位阅读和贡献文档的开发者！你们的参与让这个项目变得更好。
> 
> 🚀 **开始**: 准备好了？从[快速开始指南](getting-started/QUICK_START.md)开始你的Lumi Assistant开发之旅吧！
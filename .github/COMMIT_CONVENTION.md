# Git 提交规范 (Commit Convention)

## 📋 概述

为了确保GitHub Actions能够正确生成Release说明，所有Git提交必须遵循**Conventional Commits**规范。

## 🎯 基本格式

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### 必需元素
- **type**: 提交类型（必须）
- **description**: 简短描述（必须，50字符以内）

### 可选元素
- **scope**: 影响范围（推荐）
- **body**: 详细说明（可选）
- **footer**: 脚注信息（可选）

## 🏷️ 提交类型 (Type)

| 类型 | 图标 | 说明 | Release分类 |
|------|------|------|-------------|
| `feat` | 🚀 | 新功能 | **🚀 Features** |
| `fix` | 🐛 | Bug修复 | **🐛 Bug fixes** |
| `perf` | ⚡ | 性能优化 | **🌟 Enhancements** |
| `refactor` | ♻️ | 代码重构 | **🌟 Enhancements** |
| `style` | 💄 | 代码格式化 | **🌟 Enhancements** |
| `docs` | 📚 | 文档更新 | **📚 Documentation** |
| `test` | 🧪 | 测试相关 | **🧪 Testing** |
| `build` | 🔧 | 构建相关 | **🔧 Build & CI** |
| `ci` | 🔧 | CI配置 | **🔧 Build & CI** |
| `chore` | 🔧 | 其他杂项 | **🔧 Build & CI** |
| `security` | 🔒 | 安全修复 | **🔒 Security** |
| `deps` | 📦 | 依赖更新 | **📦 Dependencies** |
| `i18n` | 🌐 | 国际化 | **🌐 Translations** |
| `remove` | 🗑️ | 移除功能 | **🗑️ Deprecations** |

## 🎯 范围 (Scope)

推荐使用的scope（影响范围）：

### 功能模块
- `ui` - 用户界面
- `audio` - 音频功能
- `network` - 网络连接
- `websocket` - WebSocket相关
- `voice` - 语音处理
- `chat` - 聊天功能
- `settings` - 设置页面
- `animation` - 动画效果

### 技术层面
- `core` - 核心功能
- `api` - API接口
- `db` - 数据库
- `storage` - 存储
- `security` - 安全
- `performance` - 性能

### 平台相关
- `android` - Android平台
- `ios` - iOS平台
- `web` - Web平台

## ✅ 正确示例

### 新功能
```bash
feat(audio): 新增低延迟音频处理功能

- 实现音频缓冲区优化算法
- 添加实时音频流切换支持
- 优化音频播放性能和稳定性
```

### Bug修复
```bash
fix(websocket): 修复连接断开后无法自动重连的问题

修复了网络切换时WebSocket连接丢失，
导致语音助手无响应的问题。

Fixes #123
```

### 性能优化
```bash
perf(ui): 优化聊天界面渲染性能

- 使用虚拟列表减少内存占用
- 优化图片加载和缓存策略
- 减少不必要的UI重绘
```

### 文档更新
```bash
docs(api): 更新WebSocket API文档

添加了新的消息类型说明和示例代码
```

### 重构
```bash
refactor(core): 重构语音服务架构

- 拆分音频录制和播放模块
- 优化服务间通信机制
- 提升代码可维护性
```

## ❌ 错误示例

```bash
# 缺少类型
修复音频bug

# 类型错误
update: 添加新功能

# 描述不清楚
feat: 修改了一些东西

# 描述过长
feat(audio): 新增了一个非常复杂的音频处理功能，包括降噪、回声消除、音频增强等多种算法的实现

# 中英混用
feat(audio): add 音频功能
```

## 🔧 GitHub Actions自动处理

当你按规范提交代码时，GitHub Actions会：

### 1. **自动分类**
- `feat` → 🚀 Features
- `fix` → 🐛 Bug fixes  
- `docs` → 📚 Documentation
- 等等...

### 2. **生成格式**
```markdown
### 🚀 Features
- (audio): 新增低延迟音频处理功能 by [@username] → [🔍 查看代码更改 abc1234]

### 🐛 Bug fixes  
- (websocket): 修复连接断开后无法自动重连的问题 by [@username] → [🔍 查看代码更改 def5678]
```

### 3. **完整Release说明**
- 版本信息和类型标识
- 按类别分组的更改列表
- 贡献者信息
- 完整变更对比链接

## 📝 工具推荐

### 1. **Git Hooks**
创建 `.gitmessage` 模板：
```bash
git config commit.template .gitmessage
```

### 2. **VS Code扩展**
- Conventional Commits
- Git Commit Template

### 3. **命令行工具**
- commitizen (cz-cli)
- gitmoji-cli

## 🚀 快速开始

### 1. **设置提交模板**
```bash
cat > .gitmessage << 'EOF'
# <type>(<scope>): <description>
# 
# 类型 (type):
# feat     新功能
# fix      Bug修复  
# docs     文档更新
# style    代码格式
# refactor 重构
# perf     性能优化
# test     测试
# build    构建
# ci       CI配置
# chore    杂项
#
# 范围 (scope): ui, audio, network, core, etc.
# 描述 (description): 简短清晰的说明
EOF

git config commit.template .gitmessage
```

### 2. **检查提交格式**
推送前检查提交信息是否符合规范：
```bash
git log --oneline -5
```

## 🔍 验证规则

提交前请确认：
- [ ] 包含正确的type
- [ ] 描述简洁清晰（50字符以内）
- [ ] 使用推荐的scope（如果适用）
- [ ] 详细说明放在body中
- [ ] 相关issue用footer引用

## 📚 参考资源

- [Conventional Commits规范](https://conventionalcommits.org/)
- [Angular提交规范](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [Semantic Versioning](https://semver.org/)

---

> 💡 **提示**: 遵循提交规范不仅能生成更好的Release说明，还能提升代码可维护性和团队协作效率！

*最后更新: 2025-07-22*
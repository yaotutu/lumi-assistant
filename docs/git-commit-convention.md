# Git提交规范 (Commit Convention)

## 📋 必须遵循的提交格式

**所有Git提交必须遵循Conventional Commits规范**，以确保GitHub Actions能够正确生成Release说明。

### 基本格式
```
<type>(<scope>): <description>

[optional body]
```

## 🏷️ 提交类型映射表

| 提交类型 | Release分类 | 说明 | 示例 |
|---------|------------|------|------|
| `feat` | 🚀 **Features** | 新功能 | `feat(audio): 新增低延迟音频处理` |
| `fix` | 🐛 **Bug fixes** | Bug修复 | `fix(websocket): 修复连接断开问题` |
| `perf` | 🌟 **Enhancements** | 性能优化 | `perf(ui): 优化聊天界面渲染性能` |
| `refactor` | 🌟 **Enhancements** | 代码重构 | `refactor(core): 重构语音服务架构` |
| `style` | 🌟 **Enhancements** | 代码格式 | `style(ui): 统一组件样式格式` |
| `docs` | 📚 **Documentation** | 文档更新 | `docs(api): 更新WebSocket API文档` |
| `test` | 🧪 **Testing** | 测试相关 | `test(audio): 添加音频处理单元测试` |
| `build` | 🔧 **Build & CI** | 构建相关 | `build: 更新Flutter版本到3.29.3` |
| `ci` | 🔧 **Build & CI** | CI配置 | `ci: 优化GitHub Actions工作流` |
| `chore` | 🔧 **Build & CI** | 杂项任务 | `chore: 更新依赖包版本` |
| `security` | 🔒 **Security** | 安全修复 | `security: 修复API密钥泄露风险` |
| `deps` | 📦 **Dependencies** | 依赖更新 | `deps: 升级riverpod到最新版本` |
| `i18n` | 🌐 **Translations** | 国际化 | `i18n: 添加英文翻译支持` |
| `remove` | 🗑️ **Deprecations** | 移除功能 | `remove: 删除废弃的旧API接口` |

## 🎯 推荐的Scope（影响范围）

### 功能模块
- `ui` - 用户界面
- `audio` - 音频功能  
- `network` - 网络连接
- `websocket` - WebSocket相关
- `voice` - 语音处理
- `chat` - 聊天功能
- `dashboard` - 待机桌面功能
- `calendar` - 日历功能
- `weather` - 天气显示
- `todo` - 待办事项
- `clock` - 时钟显示
- `photos` - 电子相册功能
- `settings` - 设置页面
- `animation` - 动画效果

### 技术层面
- `core` - 核心功能
- `api` - API接口
- `storage` - 存储
- `security` - 安全
- `performance` - 性能

### 平台相关
- `android` - Android平台
- `ios` - iOS平台

## ✅ 正确示例

```bash
# 新功能
feat(audio): 新增低延迟音频处理功能

- 实现音频缓冲区优化算法
- 添加实时音频流切换支持
- 优化音频播放性能和稳定性

# Bug修复
fix(websocket): 修复连接断开后无法自动重连的问题

修复了网络切换时WebSocket连接丢失，
导致语音助手无响应的问题。

# 性能优化
perf(ui): 优化聊天界面渲染性能

- 使用虚拟列表减少内存占用
- 优化图片加载和缓存策略

# 文档更新
docs(api): 更新WebSocket API文档

添加了新的消息类型说明和示例代码
```

## ❌ 错误示例

```bash
# 缺少类型
修复音频bug

# 类型错误  
update: 添加新功能

# 描述不清楚
feat: 修改了一些东西

# 描述过长（超过50字符）
feat(audio): 新增了一个非常复杂的音频处理功能包括降噪回声消除等算法
```

## 🔧 GitHub Actions自动处理效果

当按规范提交时，Release说明会自动生成：

```markdown
## What's Changed

### 🚀 Features
- (audio): 新增低延迟音频处理功能 by [@username] → [🔍 **查看代码更改** abc1234]

### 🐛 Bug fixes  
- (websocket): 修复连接断开后无法自动重连的问题 by [@username] → [🔍 **查看代码更改** def5678]

### 🌟 Enhancements
- (ui): 优化聊天界面渲染性能 by [@username] → [🔍 **查看代码更改** ghi9012]
```

## 📝 提交前检查清单

在每次Git提交前，请确认：
- [ ] 包含正确的type（必须）
- [ ] 描述简洁清晰（50字符以内）
- [ ] 使用推荐的scope（如果适用）
- [ ] 详细说明放在body中（如果需要）
- [ ] 格式符合Conventional Commits规范

## 🚨 重要提醒

**违反提交规范的后果**：
- GitHub Actions可能无法正确分类更改
- Release说明格式混乱
- 影响项目的版本管理和发布流程

**Claude Code必须严格遵循此规范进行所有Git提交操作！**
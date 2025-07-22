# 开发环境设置指南

## 🚀 快速开始

### 1. 设置Git提交模板

为了确保所有提交都符合规范，建议设置Git提交模板：

```bash
# 设置提交模板
git config commit.template .gitmessage

# 验证设置
git config --get commit.template
```

设置后，每次执行 `git commit` 时会自动加载模板。

### 2. 验证提交格式

提交前检查格式是否正确：
```bash
# 查看最近的提交
git log --oneline -5

# 确认提交信息格式符合规范
# ✅ 正确: feat(audio): 新增低延迟音频处理
# ❌ 错误: 修复了一些bug
```

## 📋 GitHub Actions Release生成

### 当前分支策略

| 分支 | 版本格式 | Release类型 | APK命名 |
|------|----------|-------------|---------|
| **main** | `0.1.X` | 🚀 Release | `lumi-assistant-0.1.X-{arch}.apk` |
| **dev** | `0.1.X-pre` | 🧪 Development | `lumi-assistant-0.1.X-pre-{arch}-dev.apk` |

### Release说明自动生成

提交格式 → Release分类：
- `feat:` → 🚀 **Features**
- `fix:` → 🐛 **Bug fixes**
- `perf:` → 🌟 **Enhancements**
- `docs:` → 📚 **Documentation**

### 测试提交示例

```bash
# 功能开发
git commit -m "feat(audio): 新增低延迟音频处理功能

- 实现音频缓冲区优化算法
- 添加实时音频流切换支持"

# Bug修复
git commit -m "fix(websocket): 修复连接断开重连问题

修复网络切换时WebSocket连接丢失问题"

# 性能优化
git commit -m "perf(ui): 优化聊天界面渲染性能

使用虚拟列表减少内存占用"
```

## 🔧 GitHub Actions工作流

### 触发条件
- **push到main**: 创建正式Release
- **push到dev**: 创建开发预发布
- **手动触发**: 支持强制发布

### 构建产物
每次构建生成4种架构APK：
- ARM32 (32位ARM设备)
- ARM64 (64位ARM设备，推荐)
- x64 (x86_64设备/模拟器)
- Universal (通用版本)

### Release页面效果

**main分支**:
```
🚀 Release 0.1.X

## What's Changed

### 🚀 Features
- (audio): 新增低延迟音频处理功能 by [@yaotutu] → [🔍 查看代码更改 abc1234]

### 🐛 Bug fixes
- (websocket): 修复连接断开重连问题 by [@yaotutu] → [🔍 查看代码更改 def5678]
```

**dev分支**:
```
🧪 Development 0.1.X-pre

⚠️ 开发测试版本 - 包含最新功能但可能存在问题

## What's Changed
[同样的格式，但标记为预发布]
```

## 📚 相关文档

- [Git提交规范](.github/COMMIT_CONVENTION.md) - 详细的提交格式说明
- [分支策略说明](.github/BRANCH_STRATEGY.md) - 分支管理和构建策略
- [项目开发指南](CLAUDE.md) - 完整的开发指导

---

> 💡 遵循这些规范将确保项目的自动化Release生成正常工作！
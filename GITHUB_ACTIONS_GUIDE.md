# GitHub Actions 自动构建和发布指南

## 🎯 概述

现在你的Lumi Assistant项目已经配置了完整的GitHub Actions自动构建和发布系统！每次推送代码到main分支时，系统会自动：

1. ✅ 检查代码质量
2. 🔨 构建Android APK
3. 📝 生成版本号（带pre前缀）
4. 🚀 创建GitHub Release
5. 📦 上传APK文件

## 🚀 如何触发构建

### 方法1: 推送代码到main分支（推荐）
```bash
# 正常的开发流程
git add .
git commit -m "feat: 添加新功能"
git push origin main

# ✨ GitHub Actions会自动触发！
```

### 方法2: 手动触发
1. 访问你的GitHub仓库
2. 点击 **Actions** 标签页
3. 选择 "Build and Release Android APK" 工作流
4. 点击 **Run workflow** 按钮
5. 选择分支并确认

### 方法3: 通过Pull Request
- 创建PR到main分支会触发构建测试
- 但不会创建Release（仅构建验证）

## 📋 版本号规则

你的版本号将自动按以下规则生成：

```
格式: 0.1.{提交数}-pre+{时间戳}
示例: 0.1.58-pre+202507221031
```

**组成说明**：
- `0.1` - 基础版本（开发阶段）
- `58` - Git提交计数（自动递增）
- `pre` - 预发布标识（开发版本）
- `202507221031` - 构建时间戳

## 📱 下载和安装APK

### 1. 访问Release页面
- 在GitHub仓库页面点击 **Releases**
- 或直接访问: `https://github.com/你的用户名/lumi-assistant/releases`

### 2. 下载最新版本
- 找到最新的Release（标记为 `Pre-release`）
- 下载附件中的APK文件
- 文件名格式: `lumi-assistant-0.1.x-pre-debug.apk`

### 3. 安装到Android设备
```bash
# 通过ADB安装（开发者）
adb install lumi-assistant-0.1.x-pre-debug.apk

# 或者直接在设备上安装
# 1. 传输APK到设备
# 2. 在设备上打开文件管理器
# 3. 点击APK文件安装
# 4. 允许从未知来源安装应用
```

## 🛠️ 开发工作流建议

### 日常开发
```bash
# 1. 创建功能分支
git checkout -b feature/new-audio-feature

# 2. 开发和测试
# ... 编写代码 ...

# 3. 提交到功能分支
git add .
git commit -m "feat: 实现新的音频功能"
git push origin feature/new-audio-feature

# 4. 创建Pull Request
# 在GitHub上创建PR，系统会自动构建测试

# 5. 合并到main分支
# 合并后，系统自动构建并发布新版本
```

### 紧急修复
```bash
# 1. 直接在main分支修复
git checkout main
git pull origin main

# 2. 快速修复
# ... 修复问题 ...

# 3. 立即提交和推送
git add .
git commit -m "fix: 修复关键音频播放问题"
git push origin main

# ✨ 系统立即自动构建和发布修复版本
```

## 📊 监控构建状态

### 查看构建进度
1. 推送代码后，访问 **Actions** 页面
2. 找到最新的工作流运行
3. 点击查看详细进度和日志

### 构建阶段说明
- **Code Quality Check** (2-3分钟)
  - 代码分析
  - 运行测试
- **Build Android APK** (3-5分钟)
  - 下载依赖
  - 构建APK
  - 生成版本信息
- **Create GitHub Release** (1分钟)
  - 创建Release
  - 上传APK文件
  - 生成发布说明

### 构建失败处理
如果构建失败：
1. 查看详细错误日志
2. 本地修复问题
3. 重新推送代码
4. 系统自动重试构建

## 🧪 测试功能

### 快速测试工作流
如果你想测试GitHub Actions配置：

1. 访问 **Actions** → **Test Build (快速测试)**
2. 点击 **Run workflow**
3. 选择测试类型：
   - `version-only`: 仅测试版本生成
   - `build-only`: 仅测试构建流程
   - `full-build`: 完整测试

### 本地测试脚本
```bash
# 测试版本生成
./.github/scripts/version-generator.sh

# 测试Release生成
./.github/scripts/release-generator.sh
```

## ⚙️ 自定义配置

### 修改Flutter版本
编辑 `.github/workflows/build-and-release.yml`:
```yaml
env:
  FLUTTER_VERSION: '3.24.3'  # 改为你需要的版本
```

### 修改版本规则
编辑 `.github/scripts/version-generator.sh`:
```bash
# 修改基础版本
local BASE_VERSION="0.2"  # 从0.1改为0.2
```

### 修改Release模板
编辑 `.github/release-template.md` 来自定义Release描述格式。

## 🔧 故障排查

### 常见问题

1. **权限错误**
   - 确保仓库启用了Actions
   - 检查GITHUB_TOKEN权限

2. **构建超时**
   - 可能是网络问题
   - 重新运行工作流

3. **APK文件太大**
   - 检查assets目录
   - 考虑使用--split-per-abi

4. **版本号错误**
   - 检查Git历史
   - 本地测试版本脚本

### 获取帮助
- 查看 `.github/README.md` 获取详细技术文档
- 在Actions页面查看构建日志
- 创建GitHub Issue报告问题

## 📈 下一步计划

### 可能的改进
- [ ] 添加iOS构建支持
- [ ] 集成自动化测试
- [ ] 添加代码覆盖率报告
- [ ] 实现多环境部署
- [ ] 添加通知机制（邮件/Slack）

### 生产版本准备
当准备发布生产版本时：
- 修改版本前缀从`pre`到`stable`
- 构建release APK而不是debug
- 添加签名配置
- 增加更严格的测试要求

---

🎉 **恭喜！** 你现在拥有了一个全自动化的Android应用构建和发布系统！

每次推送代码，你都能在几分钟内得到可安装的APK文件，并且版本管理完全自动化。这将大大提高你的开发效率！
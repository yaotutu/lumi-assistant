# 🚀 双分支自动发布策略

## 📋 方案概述

采用 **dev + release 双分支自动发布**策略，实现测试版和正式版的自动化发布。

```
开发流程：

main 分支（开发）
  ├── 日常开发和功能合并
  ├── 自动构建 APK → Artifacts
  ├── 版本号: 1.0.0-dev.42
  └── ❌ 不发布 Release

      ↓ 合并（稳定功能）

dev 分支（测试）
  ├── 测试功能和 Bug 修复
  ├── 自动构建并发布 → Release
  ├── 版本号: 1.0.0-beta.10
  └── ✅ 发布测试版 (Beta)

      ↓ 合并（验证通过）

release 分支（生产）
  ├── 生产就绪的稳定代码
  ├── 自动构建并发布 → Release
  ├── 版本号: 1.0.0
  └── ✅ 发布正式版 (Production)
```

---

## 🎯 三个分支的职责

| 分支 | 用途 | 构建 | 发布 | 版本号 | 标签 |
|------|------|------|------|--------|------|
| **main** | 日常开发 | ✅ Artifacts | ❌ | `1.0.0-dev.42` | 🔧 开发版 |
| **dev** | 功能测试 | ✅ Artifacts + Release | ✅ Beta | `1.0.0-beta.10` | 🧪 测试版 |
| **release** | 正式发布 | ✅ Artifacts + Release | ✅ Production | `1.0.0` | ✅ 正式版 |

---

## 📦 Release 标识

### GitHub Releases 页面显示

#### 测试版 (dev 分支)
```
🧪 Lumi Assistant 1.0.0-beta.10 (Beta)
├── 标签: beta-1.0.0-beta.10
├── 预发布: ✅ Yes (显示为 Pre-release)
└── 警告: ⚠️ 这是测试版本，可能不稳定，仅供测试使用！
```

#### 正式版 (release 分支)
```
✅ Lumi Assistant 1.0.0
├── 标签: v1.0.0
├── 预发布: ❌ No (显示为 Latest)
└── 状态: 稳定的生产版本
```

---

## 🔄 完整工作流程

### 阶段 1: 日常开发 (main 分支)

```bash
# 1. 在 main 分支开发
git checkout main
git add .
git commit -m "feat: 添加新功能"
git push origin main
```

**结果**:
- ✅ 自动构建 APK → Actions Artifacts
- ✅ 版本号: `1.0.0-dev.42`
- ❌ 不创建 Release

---

### 阶段 2: 发布测试版 (dev 分支)

当功能开发完成，准备测试时：

```bash
# 方式 1: 合并 main 到 dev
git checkout main && git pull
git checkout dev && git pull
git merge main
git push origin dev

# 方式 2: 使用 PR (推荐团队协作)
# 在 GitHub 创建 PR: main → dev
# 审查后合并
```

**结果**:
- ✅ 自动构建已签名的 APK
- ✅ **自动创建 GitHub Release (Beta)**
- ✅ 版本号: `1.0.0-beta.10`
- ✅ Tag: `beta-1.0.0-beta.10`
- ✅ 标记为 Pre-release
- ✅ 测试人员可从 Releases 下载

---

### 阶段 3: 发布正式版 (release 分支)

测试通过后，发布正式版：

```bash
# 方式 1: 合并 dev 到 release
git checkout dev && git pull
git checkout release && git pull
git merge dev
git push origin release

# 方式 2: 使用 PR (推荐)
# 在 GitHub 创建 PR: dev → release
# 团队审查后合并
```

**结果**:
- ✅ 自动构建已签名的 APK
- ✅ **自动创建 GitHub Release (Production)**
- ✅ 版本号: `1.0.0`
- ✅ Tag: `v1.0.0`
- ✅ 标记为 Latest release
- ✅ 用户可从 Releases 下载正式版

---

## 🎁 版本号规则

### 自动生成规则

| 分支 | 版本号格式 | 示例 | Tag 前缀 | Pre-release |
|------|----------|------|----------|-------------|
| **release** | `X.Y.Z` | `1.0.0` | `v` | ❌ |
| **dev** | `X.Y.Z-beta.N` | `1.0.0-beta.10` | `beta-` | ✅ |
| **main** | `X.Y.Z-dev.N` | `1.0.0-dev.42` | 无 | N/A (不发布) |
| **feature/xxx** | `X.Y.Z-feature-xxx.N` | `1.0.0-feature-login.5` | 无 | N/A (不发布) |

### Version Code

所有分支使用相同的 Version Code 生成规则：
```
格式: YYYYMMDDNNN
示例: 20250125042 (2025年1月25日第42次构建)
```

---

## 🎯 使用场景

### 场景 1: 快速迭代测试

```bash
# 1. 开发功能
git checkout main
# ... 开发 ...
git push origin main

# 2. 发布测试版供测试人员测试
git checkout dev
git merge main
git push origin dev  # 自动发布 Beta

# 3. 收集反馈，在 main 修复
git checkout main
# ... 修复 ...
git push origin main

# 4. 再次发布测试版
git checkout dev
git merge main
git push origin dev  # 自动发布新的 Beta
```

---

### 场景 2: 正式发布新版本

```bash
# 1. 确保 dev 分支测试通过
git checkout dev
git pull

# 2. 合并到 release 发布正式版
git checkout release
git merge dev
git push origin release  # 自动发布 Production

# 3. 可选：合并回 main 保持同步
git checkout main
git merge release
git push origin main
```

---

### 场景 3: 紧急修复 (Hotfix)

```bash
# 1. 在 release 分支直接修复
git checkout release
# ... 修复紧急 bug ...
git commit -m "hotfix: 修复关键问题"
git push origin release  # 发布修复版

# 2. 合并回 dev 和 main
git checkout dev && git merge release && git push
git checkout main && git merge release && git push
```

---

## 📊 Release 页面展示

### 正常情况下的 Releases 列表

```
GitHub Releases 页面

Latest:
✅ Lumi Assistant 1.0.0                    v1.0.0      2天前

Pre-releases:
🧪 Lumi Assistant 1.0.0-beta.15 (Beta)     beta-...    1小时前
🧪 Lumi Assistant 1.0.0-beta.14 (Beta)     beta-...    2小时前
🧪 Lumi Assistant 1.0.0-beta.13 (Beta)     beta-...    5小时前
```

**说明**:
- `Latest` = 最新正式版 (release 分支)
- `Pre-release` = 测试版 (dev 分支)
- 用户默认看到的是 Latest 版本
- 测试人员可以选择下载 Pre-release

---

## 🎨 Release Notes 区别

### 测试版 (dev 分支)

```markdown
## 📱 Lumi Assistant 1.0.0-beta.10

### 🏷️ 版本类型
🧪 测试版 (Beta)

⚠️ **这是测试版本，可能不稳定，仅供测试使用！**

### 📦 下载 APK
...

### 🔖 版本信息
- Version Name: 1.0.0-beta.10
- Version Code: 20250125010
- Build Date: 2025-01-25 10:30
- Commit: abc1234
- 支持架构: ARM64-v8a, ARMv7

### 📝 更新内容
- feat: 添加新功能 X
- fix: 修复 bug Y
- refactor: 重构模块 Z
```

### 正式版 (release 分支)

```markdown
## 📱 Lumi Assistant 1.0.0

### 🏷️ 版本类型
✅ 正式版 (Production)

### 📦 下载 APK
...

### 🔖 版本信息
- Version Name: 1.0.0
- Version Code: 20250125020
- Build Date: 2025-01-25 14:00
- Commit: def5678
- 支持架构: ARM64-v8a, ARMv7

### 📝 更新内容
- 新增功能 A
- 优化性能 B
- 修复已知问题 C
```

---

## 🔍 如何下载不同版本？

### 普通用户下载正式版

```
1. 访问 GitHub Releases 页面
2. 默认显示 "Latest" 版本
3. 下载 APK 安装
```

### 测试人员下载测试版

```
1. 访问 GitHub Releases 页面
2. 向下滚动查看 "Pre-releases"
3. 选择最新的 Beta 版本
4. 下载 APK 测试
```

### 开发者下载构建产物

```
1. 前往 Actions → Android Build
2. 选择分支筛选
3. 下载 Artifacts (所有分支都有)
```

---

## ⚙️ 配置说明

### 修改基础版本号

编辑 `.github/scripts/version-generator.sh`:
```bash
BASE_VERSION="2.0.0"  # 修改这里
```

### 手动触发发布

在 GitHub Actions 页面：
```
Actions → Release Build → Run workflow
├── 选择分支: dev 或 release
├── 输入版本号: 1.0.0
└── 选择环境: beta 或 production
```

---

## 🛡️ 分支保护建议

### 保护 dev 分支

```
Settings → Branches → Add rule: dev
✅ Require a pull request before merging
✅ Require approvals (1)
```

**理由**: 确保进入测试的代码经过审查

### 保护 release 分支

```
Settings → Branches → Add rule: release
✅ Require a pull request before merging
✅ Require approvals (2)  # 更严格
✅ Require status checks to pass
```

**理由**: 正式版发布需要更严格的审查

---

## 📊 对比单分支方案

| 特性 | 单分支 (release) | **双分支 (dev + release)** |
|------|-----------------|---------------------------|
| 测试版发布 | 不支持 | ✅ 自动发布 Beta |
| 正式版发布 | ✅ 支持 | ✅ 支持 |
| 版本区分 | 较模糊 | ✅ 清晰 (Beta vs Production) |
| 测试流程 | 手动 | ✅ 自动化 |
| 回滚风险 | 较高 | ✅ 较低（有 dev 缓冲） |
| 学习曲线 | 简单 | 中等 |
| 团队协作 | 一般 | ✅ 优秀 |

---

## ❓ 常见问题

### Q1: dev 分支应该多久发布一次？

**A**: 根据需要，建议：
- 新功能完成后立即发布测试版
- 每天/每周定期发布
- 紧急修复后立即发布

### Q2: 测试版和正式版可以共存吗？

**A**: 可以！
- 测试版标记为 `Pre-release`
- 正式版标记为 `Latest`
- GitHub 会同时显示两者

### Q3: 如何回滚到之前的版本？

**方式 1**: 从 Releases 下载旧版本 APK

**方式 2**: Git 回滚
```bash
git checkout release
git reset --hard <commit-sha>
git push origin release --force
```

### Q4: 普通用户会下载到测试版吗？

**A**: 不会！
- GitHub 默认显示 `Latest` (正式版)
- 测试版需要手动展开 `Pre-releases` 才能看到

### Q5: 能否跳过 dev 直接发布到 release？

**A**: 技术上可以，但**不推荐**：
- 失去了测试阶段
- 增加生产环境风险
- 建议至少在 dev 分支测试一轮

---

## 🎯 快速参考

### 发布测试版
```bash
git checkout dev && git pull
git merge main
git push origin dev  # 自动发布 Beta
```

### 发布正式版
```bash
git checkout release && git pull
git merge dev
git push origin release  # 自动发布 Production
```

### 查看 Releases
```
https://github.com/{你的用户名}/lumi-assistant/releases
```

### 紧急修复
```bash
git checkout release
# 修复...
git push origin release
git checkout dev && git merge release && git push
git checkout main && git merge release && git push
```

---

## 📚 相关文档

- [版本号规则详解](.github/RELEASE_WORKFLOW.md)
- [下载指南](HOW_TO_DOWNLOAD.md)
- [架构说明](.github/ABI_ARCHITECTURE.md)
- [快速上手](GITHUB_ACTIONS_QUICKSTART.md)

---

**方案版本**: 2.0
**更新日期**: 2025-01-25
**推荐度**: ⭐⭐⭐⭐⭐

这是一个非常适合团队协作的发布方案！🎉

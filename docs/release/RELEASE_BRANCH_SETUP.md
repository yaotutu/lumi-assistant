# ✅ Release 分支自动发布方案 - 配置完成

## 🎯 方案概述

已成功配置 **release 分支自动发布** 方案！

```
开发流程：
┌─────────────────────────────────────────────────────────┐
│  main 分支（开发）                                       │
│  ├── 日常开发和功能合并                                  │
│  ├── 自动构建 APK → Artifacts                           │
│  ├── 版本号: 1.0.0-main.42                              │
│  └── ❌ 不发布 Release                                  │
└─────────────────────────────────────────────────────────┘
                    ↓ 合并（稳定版本）
┌─────────────────────────────────────────────────────────┐
│  release 分支（发布）                                    │
│  ├── 只接受经过测试的稳定代码                            │
│  ├── 自动构建 APK → Release                             │
│  ├── 版本号: 1.0.0                                      │
│  └── ✅ 自动发布到 GitHub Releases                      │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 已完成的配置

### 1. **修改的文件**

#### `.github/workflows/release.yml`
```yaml
on:
  push:
    branches:
      - release  # ✅ 新增：推送到 release 分支触发
    tags:
      - 'v*'     # 保留：Tag 触发
```

#### `.github/scripts/version-generator.sh`
```bash
# ✅ 新增分支版本号逻辑
if [[ "$CURRENT_BRANCH" == "release" ]]; then
    VERSION_NAME="1.0.0"  # 正式版本号
else
    VERSION_NAME="1.0.0-${CURRENT_BRANCH}.${BUILD_NUMBER}"  # 带分支后缀
fi
```

### 2. **新增的文件**

- ✅ `.github/RELEASE_WORKFLOW.md` - 完整发布流程文档
- ✅ `.github/scripts/release.sh` - 一键发布脚本
- ✅ `RELEASE_BRANCH_SETUP.md` - 本文件

---

## 🚀 使用方法

### 方式 1: 一键发布脚本（推荐）⭐

```bash
.github/scripts/release.sh
```

**脚本功能**:
- ✅ 检查工作区状态
- ✅ 自动更新 main 和 release 分支
- ✅ 合并 main 到 release
- ✅ 交互式确认
- ✅ 推送并触发自动发布
- ✅ 显示查看链接

---

### 方式 2: 手动操作

```bash
# 1. 更新 main 分支
git checkout main
git pull origin main

# 2. 切换到 release 分支
git checkout release  # 如果不存在：git checkout -b release

# 3. 合并 main 分支
git merge main

# 4. 推送（触发自动发布）
git push origin release
```

---

### 方式 3: 使用 Pull Request（推荐团队协作）

1. 在 GitHub 上创建 PR: `main` → `release`
2. 团队成员审查代码
3. 合并 PR → 自动触发发布

---

## 📊 版本号规则

| 场景 | 版本号 | 示例 | 说明 |
|------|--------|------|------|
| **release 分支** | `X.Y.Z` | `1.0.0` | 正式版本号 |
| **main 分支** | `X.Y.Z-main.N` | `1.0.0-main.42` | 开发版本 |
| **Tag (v*)** | `X.Y.Z` | `1.0.0` | 使用 Tag 版本 |
| **其他分支** | `X.Y.Z-分支名.N` | `1.0.0-feature.10` | 功能分支版本 |

**Version Code**: `YYYYMMDDNNN` (如 `20250125042`)

---

## 🔄 完整工作流程示例

### 日常开发 (main 分支)

```bash
# 1. 在 main 分支开发
git checkout main
git add .
git commit -m "feat: 添加新功能"
git push origin main

# 2. GitHub Actions 自动构建
# ✅ 构建 APK → Artifacts
# ✅ 版本号: 1.0.0-main.42
# ❌ 不创建 Release

# 3. 从 Artifacts 下载测试
# 前往 Actions → 下载 APK → 测试
```

---

### 发布新版本 (release 分支)

```bash
# 方式 1: 使用脚本（最简单）
.github/scripts/release.sh

# 方式 2: 手动操作
git checkout main && git pull
git checkout release && git pull
git merge main
git push origin release

# GitHub Actions 自动发布：
# ✅ 构建 3 个架构 APK
# ✅ 创建 GitHub Release
# ✅ 自动生成 Release Notes
# ✅ 上传 APK + 校验和
```

---

### 紧急修复 (Hotfix)

```bash
# 1. 直接在 release 分支修复
git checkout release
# ... 修复 bug ...
git add . && git commit -m "fix: 紧急修复"
git push origin release

# 2. 自动发布新版本

# 3. 合并回 main 分支
git checkout main
git merge release
git push origin main
```

---

## 🎁 方案优势

### ✅ 对比传统 Tag 方式

| 特性 | Tag 方式 | **release 分支方式** |
|------|---------|---------------------|
| 发布触发 | 手动打 Tag | 推送到 release 分支 |
| 版本控制 | Tag 管理 | 分支 + 自动版本号 |
| 代码审查 | 无 | 支持 PR 审查 |
| 回滚 | 删除 Tag | 回退提交 |
| 学习曲线 | 中等 | 低 |
| 团队协作 | 一般 | 优秀 |

### ✅ 实际优势

1. **清晰的发布流程**
   - main 用于开发
   - release 用于发布
   - 职责明确，不易出错

2. **自动化程度高**
   - 推送即发布
   - 自动生成版本号
   - 自动创建 Release

3. **便于团队协作**
   - 支持 PR 审查
   - 发布前可讨论
   - 历史记录清晰

4. **易于回滚**
   - 回退 release 分支提交
   - 无需删除 Tag
   - 支持 Hotfix

5. **测试友好**
   - main 分支持续集成
   - release 前充分测试
   - Artifacts 可供下载测试

---

## 🔒 分支保护建议

建议在 GitHub 设置中保护 `release` 分支：

1. 前往 `Settings` → `Branches` → `Add rule`
2. 分支名称模式：`release`
3. 启用以下保护：
   - ✅ Require a pull request before merging（需要 PR）
   - ✅ Require approvals（需要审批）
   - ✅ Require status checks to pass（需要通过检查）
   - ✅ Require conversation resolution（需要解决讨论）

**好处**:
- 防止意外推送
- 确保代码审查
- 提高发布质量

---

## 📚 相关文档

- [详细发布流程](.github/RELEASE_WORKFLOW.md) - 完整的发布指南
- [快速上手](GITHUB_ACTIONS_QUICKSTART.md) - 快速配置指南
- [架构说明](.github/ABI_ARCHITECTURE.md) - APK 架构文档

---

## 🧪 测试发布流程

### 首次使用前测试

```bash
# 1. 创建 release 分支
git checkout -b release
git push origin release

# 2. 推送一个测试提交
echo "# Test" >> README.md
git add README.md
git commit -m "test: 测试 release 发布"
git push origin release

# 3. 查看 GitHub Actions
# 前往 Actions 查看构建和发布进度

# 4. 查看 Release
# 前往 Releases 页面确认自动创建

# 5. 回滚测试（可选）
git reset --hard HEAD~1
git push origin release --force
```

---

## ❓ 常见问题

### Q1: 首次使用如何创建 release 分支？

```bash
git checkout main
git checkout -b release
git push origin release
```

### Q2: 如何修改基础版本号？

编辑 `.github/scripts/version-generator.sh`:
```bash
BASE_VERSION="2.0.0"  # 修改这里
```

### Q3: 如何禁用自动发布？

方式 1: 临时禁用（推荐）
```yaml
# 在 .github/workflows/release.yml 开头添加
if: false
```

方式 2: 永久禁用
```bash
# 删除或重命名文件
mv .github/workflows/release.yml .github/workflows/release.yml.disabled
```

### Q4: 如何手动指定版本号？

方式 1: 使用 Tag
```bash
git checkout release
git tag v1.5.0
git push origin v1.5.0
```

方式 2: 手动触发 Workflow
- 前往 Actions → Release Build
- Run workflow → 输入版本号

### Q5: 如果合并有冲突怎么办？

```bash
git checkout release
git merge main

# 如果有冲突，手动解决
# ... 编辑冲突文件 ...

git add .
git commit
git push origin release
```

---

## 🎊 快速参考卡片

### 发布新版本
```bash
.github/scripts/release.sh
```

### 查看构建状态
```
https://github.com/{你的用户名}/{仓库名}/actions
```

### 查看 Release
```
https://github.com/{你的用户名}/{仓库名}/releases
```

### 紧急修复
```bash
git checkout release
# 修复...
git add . && git commit -m "fix: 紧急修复"
git push origin release
git checkout main && git merge release && git push
```

---

## ✅ 配置检查清单

- [x] 修改 `release.yml` 添加 release 分支触发
- [x] 更新 `version-generator.sh` 支持分支版本号
- [x] 创建 `RELEASE_WORKFLOW.md` 文档
- [x] 创建 `release.sh` 一键发布脚本
- [x] 更新 `GITHUB_ACTIONS_QUICKSTART.md`
- [ ] **下一步**: 配置 GitHub Secrets（如果还没配置）
- [ ] **下一步**: 创建 release 分支
- [ ] **下一步**: 测试首次发布

---

## 🚀 开始使用

一切就绪！现在你可以：

1. **提交当前更改**
   ```bash
   git add .
   git commit -m "feat: 添加 release 分支自动发布配置"
   git push origin main
   ```

2. **创建 release 分支**（如果还没有）
   ```bash
   git checkout -b release
   git push origin release
   ```

3. **测试发布流程**
   ```bash
   .github/scripts/release.sh
   ```

---

**配置完成时间**: 2025-01-25
**方案版本**: 1.0
**推荐度**: ⭐⭐⭐⭐⭐

祝发布顺利！🎉

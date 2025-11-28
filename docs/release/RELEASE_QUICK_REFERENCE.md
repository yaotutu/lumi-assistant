# 🚀 发布快速参考卡

## 📊 三分支策略一览

```
┌─────────────┬──────────────┬─────────────┬───────────┐
│    分支     │   发布位置   │   版本号    │   标签    │
├─────────────┼──────────────┼─────────────┼───────────┤
│ main        │ Artifacts    │ 1.0.0-dev.N │ 🔧 开发版 │
│ dev         │ Release Beta │ 1.0.0-beta.N│ 🧪 测试版 │
│ release     │ Release      │ 1.0.0       │ ✅ 正式版 │
└─────────────┴──────────────┴─────────────┴───────────┘
```

---

## ⚡ 快速命令

### 📦 发布测试版

```bash
git checkout main && git pull
git checkout dev && git merge main && git push origin dev
```

### ✅ 发布正式版

```bash
git checkout dev && git pull
git checkout release && git merge dev && git push origin release
```

### 🔧 日常开发

```bash
git checkout main
git add . && git commit -m "feat: 新功能"
git push origin main  # 只构建，不发布
```

---

## 🎯 使用场景速查

| 场景 | 操作 | 结果 |
|------|------|------|
| 开发新功能 | Push to `main` | Artifacts only |
| 内部测试 | Merge `main` → `dev` | Beta Release |
| 正式发布 | Merge `dev` → `release` | Production Release |
| 紧急修复 | Fix in `release` → merge back | Hotfix Release |

---

## 📥 下载方式

### 普通用户（下载正式版）
```
GitHub Releases → Latest Release → 下载 APK
```

### 测试人员（下载测试版）
```
GitHub Releases → 展开 Pre-releases → 下载 Beta APK
```

### 开发者（下载任意版本）
```
GitHub Actions → 选择分支 → 下载 Artifacts
```

---

## 🏷️ 版本号格式

| 分支 | 格式 | 示例 | Tag |
|------|------|------|-----|
| release | X.Y.Z | `1.0.0` | `v1.0.0` |
| dev | X.Y.Z-beta.N | `1.0.0-beta.10` | `beta-1.0.0-beta.10` |
| main | X.Y.Z-dev.N | `1.0.0-dev.42` | (无) |
| feature | X.Y.Z-name.N | `1.0.0-login.5` | (无) |

---

## ⚠️ 注意事项

### ✅ 推荐做法

- ✅ main → dev → release（顺序合并）
- ✅ 在 dev 充分测试后再合并到 release
- ✅ 使用 PR 进行代码审查
- ✅ release 分支只接受 dev 的合并

### ❌ 避免做法

- ❌ 直接在 release 分支开发
- ❌ 跳过 dev 直接合并到 release
- ❌ 随意 force push 到 dev/release
- ❌ 不测试就发布正式版

---

## 🔄 完整流程图

```
开发 → 测试 → 发布

Step 1: 在 main 开发
  git checkout main
  # ... 开发 ...
  git push origin main
  └─> ✅ Artifacts

Step 2: 发布测试版
  git checkout dev
  git merge main
  git push origin dev
  └─> ✅ Beta Release (Pre-release)

Step 3: 测试人员测试
  从 GitHub Releases 下载 Beta APK
  └─> 发现问题 → 回到 Step 1
  └─> 测试通过 → 进入 Step 4

Step 4: 发布正式版
  git checkout release
  git merge dev
  git push origin release
  └─> ✅ Production Release (Latest)
```

---

## 📞 紧急修复流程

```bash
# 1. 在 release 直接修复
git checkout release
# ... 修复 ...
git commit -m "hotfix: 修复关键问题"
git push origin release  # 自动发布新版本

# 2. 同步回 dev 和 main
git checkout dev && git merge release && git push
git checkout main && git merge release && git push
```

---

## 🎨 GitHub Releases 展示

```
Releases 页面

Latest:
  ✅ Lumi Assistant 1.0.0           v1.0.0      (正式版)

Pre-releases:
  🧪 Lumi Assistant 1.0.0-beta.15   beta-...    (测试版)
  🧪 Lumi Assistant 1.0.0-beta.14   beta-...
  🧪 Lumi Assistant 1.0.0-beta.13   beta-...
```

---

## 🔗 相关链接

- 📖 [完整文档](DUAL_BRANCH_RELEASE.md)
- 🚀 [快速上手](GITHUB_ACTIONS_QUICKSTART.md)
- 📥 [下载指南](HOW_TO_DOWNLOAD.md)
- 🏗️ [架构说明](.github/ABI_ARCHITECTURE.md)

---

## 🆘 快速问题解决

### Q: 如何查看当前分支？
```bash
git branch --show-current
```

### Q: 忘记在哪个分支了？
```bash
git status
```

### Q: 合并有冲突怎么办？
```bash
git merge main
# 如果有冲突，编辑冲突文件
git add .
git commit
git push
```

### Q: 想撤销刚才的 push？
```bash
# ⚠️ 谨慎使用！
git reset --hard HEAD~1
git push origin <branch> --force
```

### Q: 如何修改基础版本号？
编辑 `.github/scripts/version-generator.sh`:
```bash
BASE_VERSION="2.0.0"  # 改这里
```

---

**打印此页作为快速参考！** 📄

---

**最后更新**: 2025-01-25

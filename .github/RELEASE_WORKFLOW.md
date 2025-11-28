# 🚀 Release 分支发布流程

## 📋 分支策略

本项目采用 **双分支发布策略**：

```
main (开发分支)
  ├── 日常开发
  ├── 功能开发和合并
  ├── 自动构建测试
  └── 不发布 Release

release (发布分支)
  ├── 从 main 合并稳定版本
  ├── 自动构建并发布 Release
  ├── 自动生成版本号
  └── 发布到 GitHub Releases
```

---

## 🔄 完整发布流程

### 步骤 1: 在 main 分支开发和测试

```bash
# 正常开发流程
git checkout main
git add .
git commit -m "feat: 添加新功能"
git push origin main
```

**结果**:
- ✅ 自动触发 `android-build.yml`
- ✅ 构建 Debug + Release APK
- ✅ 上传到 Artifacts (保留 90 天)
- ❌ **不创建 Release**

---

### 步骤 2: 充分测试

从 Artifacts 下载 APK 进行测试：

1. 前往 GitHub Actions 页面
2. 点击最新的构建记录
3. 下载 Artifacts 中的 APK
4. 在真机上测试功能

---

### 步骤 3: 准备发布

当确认版本稳定，准备发布时：

```bash
# 1. 确保 main 分支是最新的
git checkout main
git pull origin main

# 2. 切换到 release 分支（如果不存在则创建）
git checkout release || git checkout -b release

# 3. 合并 main 分支到 release
git merge main

# 4. 推送到远程仓库（触发自动发布）
git push origin release
```

**结果**:
- ✅ 自动触发 `release.yml` 工作流
- ✅ 构建已签名的 Release APK (3个架构)
- ✅ **自动创建 GitHub Release**
- ✅ 自动生成版本号
- ✅ 上传 APK 到 Release 页面
- ✅ 生成 Release Notes

---

### 步骤 4: 验证发布

1. 前往 GitHub Releases 页面
2. 确认新版本已发布
3. 下载 APK 进行最终验证

---

## 🏷️ 版本号规则

### 自动生成规则

| 分支 | 版本号格式 | 示例 | 说明 |
|------|----------|------|------|
| **release** | `X.Y.Z` | `1.0.0` | 正式版本号 |
| **main** | `X.Y.Z-main.N` | `1.0.0-main.42` | 开发版本 |
| **develop** | `X.Y.Z-develop.N` | `1.0.0-develop.10` | 开发版本 |
| **Tag (v*)** | `X.Y.Z` | `1.0.0` | 使用 Tag 版本号 |

### 版本号组成

- **Version Name**: 用户可见的版本号（如 `1.0.0`）
- **Version Code**: 应用内部版本号（如 `20250125042`）
  - 格式：`YYYYMMDDNNN`
  - 示例：`20250125042` = 2025年1月25日第42次构建

---

## 🎯 使用场景

### 场景 1: 快速修复 Bug (Hotfix)

```bash
# 1. 直接在 release 分支修复
git checkout release
git pull origin release

# 2. 修复 bug
# ... 编辑文件 ...

# 3. 提交并推送（触发自动发布）
git add .
git commit -m "fix: 修复关键 bug"
git push origin release

# 4. 合并回 main 分支
git checkout main
git merge release
git push origin main
```

---

### 场景 2: 定期发布新版本

```bash
# 每周或每月发布一次

# 1. 切换到 main 分支
git checkout main
git pull origin main

# 2. 切换到 release 分支并合并
git checkout release
git pull origin release
git merge main

# 3. 推送触发发布
git push origin release
```

---

### 场景 3: 使用 Tag 控制版本号

如果你想手动指定版本号：

```bash
# 1. 在 release 分支打 Tag
git checkout release
git tag v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0

# 这将使用 1.2.0 作为版本号发布
```

---

## 🔍 查看构建状态

### 查看 main 分支构建

1. 前往 `Actions` 标签
2. 选择 `Android Build` 工作流
3. 查看最新的构建记录

### 查看 Release 发布

1. 前往 `Actions` 标签
2. 选择 `Release Build` 工作流
3. 查看发布进度和日志

---

## 📦 Release 包含内容

每次自动发布包含：

### APK 文件 (3个)
```
lumi-assistant-{版本号}-universal.apk      (通用版，推荐)
lumi-assistant-{版本号}-arm64-v8a.apk      (64位优化)
lumi-assistant-{版本号}-armeabi-v7a.apk    (32位兼容)
```

### 校验文件
```
checksums.txt  (SHA256 校验和)
```

### Release Notes
自动生成，包含：
- 版本信息
- 更新内容（基于 git log）
- 下载说明
- 架构选择指南
- 安全校验信息

---

## ⚙️ 高级配置

### 修改基础版本号

编辑 `.github/scripts/version-generator.sh`：

```bash
# 修改此行
BASE_VERSION="2.0.0"  # 改为新的基础版本号
```

### 自定义版本号

如果需要更精确的版本控制，可以：

1. **方式 1**: 在 release 分支打 Tag
   ```bash
   git tag v1.5.2
   git push origin v1.5.2
   ```

2. **方式 2**: 手动触发 Workflow
   - 前往 Actions → Release Build
   - 点击 "Run workflow"
   - 输入版本号（如 `1.5.2`）

---

## 🛡️ 保护 release 分支

建议在 GitHub 设置中保护 release 分支：

1. 前往 `Settings` → `Branches`
2. 添加分支保护规则：`release`
3. 启用以下选项：
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date

**好处**:
- 防止意外推送到 release
- 确保代码经过审查
- 所有 release 都有记录

---

## 📊 分支对比

| 特性 | main 分支 | release 分支 |
|------|----------|-------------|
| **用途** | 日常开发 | 正式发布 |
| **构建** | 自动构建 | 自动构建 |
| **Artifacts** | ✅ (90天) | ✅ (永久) |
| **Release** | ❌ | ✅ |
| **版本号** | 带分支后缀 | 正式版本号 |
| **频率** | 频繁提交 | 定期发布 |

---

## ❓ 常见问题

### Q1: 如何创建 release 分支？

第一次使用时：
```bash
git checkout main
git checkout -b release
git push origin release
```

### Q2: 如果不小心推送到 release 怎么办？

```bash
# 回滚到上一个提交
git checkout release
git reset --hard HEAD~1
git push origin release --force

# ⚠️ 注意：这会触发新的 Release 构建
```

### Q3: 如何停止自动发布？

临时禁用：
- 在 `.github/workflows/release.yml` 文件开头添加：
  ```yaml
  # 暂时禁用此工作流
  if: false
  ```

永久禁用：
- 删除或重命名 `release.yml` 文件

### Q4: 如何测试 release 流程？

可以创建一个测试分支模拟：
```bash
git checkout -b release-test
git push origin release-test

# 修改 release.yml 触发条件：
# branches:
#   - release-test
```

---

## 🎉 快速参考

### 发布新版本（推荐流程）

```bash
# 一键发布脚本
git checkout main && \
git pull origin main && \
git checkout release && \
git pull origin release && \
git merge main && \
git push origin release

# 完成！前往 GitHub Releases 查看发布结果
```

### 紧急修复发布

```bash
git checkout release
# 修复 bug...
git add . && git commit -m "fix: 紧急修复"
git push origin release

# 记得合并回 main
git checkout main && git merge release && git push origin main
```

---

## 📚 相关文档

- [GitHub Actions 配置](./README.md)
- [架构说明](./ABI_ARCHITECTURE.md)
- [快速上手](../GITHUB_ACTIONS_QUICKSTART.md)

---

**流程版本**: 1.0
**更新日期**: 2025-01-25
**维护者**: Lumi Assistant Team

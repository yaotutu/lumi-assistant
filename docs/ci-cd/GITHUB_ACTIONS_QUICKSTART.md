# ⚡ GitHub Actions 自动构建快速上手指南

## ✅ 配置完成清单

已为你配置完成：

- [x] 生成 Release 签名密钥 (`lumi-release-key.jks`)
- [x] 配置 Gradle 支持自动版本号和签名
- [x] 创建版本号自动生成脚本
- [x] 创建主构建 Workflow (android-build.yml)
- [x] 创建发布 Workflow (release.yml)
- [x] 更新 .gitignore 保护签名密钥

## 🎯 下一步操作

### 1️⃣ 配置 GitHub Secrets (必须)

前往你的 GitHub 仓库配置 Secrets，否则 Release 构建会失败：

**路径**: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

需要添加的 4 个 Secrets：

| 名称 | 值 | 在哪里找 |
|------|-----|----------|
| `RELEASE_KEYSTORE_BASE64` | Base64 编码的密钥 | 运行: `cat lumi-release-key.jks.base64` |
| `RELEASE_KEYSTORE_PASSWORD` | `android123` | 默认密码 |
| `RELEASE_KEY_ALIAS` | `lumi` | 密钥别名 |
| `RELEASE_KEY_PASSWORD` | `android123` | 默认密码 |

**获取 RELEASE_KEYSTORE_BASE64 的值**:

```bash
# 复制这个文件的全部内容
cat lumi-release-key.jks.base64
```

⚠️ **重要**: 将整个文件内容（包括所有行）复制粘贴到 GitHub Secret 中。

---

### 2️⃣ 测试自动构建

提交并推送到 GitHub：

```bash
# 添加新文件
git add .github/ app/build.gradle.kts .gitignore

# 提交
git commit -m "feat: 添加 GitHub Actions 自动构建配置

- 配置 Release 签名支持
- 添加自动版本号生成
- 创建主构建和发布 Workflow
- 支持自动创建 GitHub Release"

# 推送到远程（触发自动构建）
git push origin main
```

**查看构建结果**:
1. 前往 GitHub 仓库
2. 点击 `Actions` 标签
3. 查看 "Android Build" 工作流

---

### 3️⃣ 创建第一个正式发布

配置完成并测试成功后，可以创建第一个正式 Release。

#### 🎯 推荐方式：双分支自动发布

本项目采用 **dev + release 双分支自动发布** 策略：

##### 发布测试版 (dev 分支)

```bash
# 合并 main 到 dev
git checkout dev || git checkout -b dev
git merge main
git push origin dev  # 自动发布测试版
```

##### 发布正式版 (release 分支)

```bash
# 合并 dev 到 release
git checkout release || git checkout -b release
git merge dev
git push origin release  # 自动发布正式版
```

**查看发布结果**:
- 前往仓库的 `Releases` 页面
- 测试版: 标记为 `Pre-release` 🧪
- 正式版: 标记为 `Latest` ✅

#### 📋 发布策略说明

| 分支 | 行为 | 版本号 | 标签 | 用途 |
|------|------|--------|------|------|
| `main` | 构建 → Artifacts | `1.0.0-dev.N` | 🔧 | 日常开发 |
| `dev` | 构建 → **Release (Beta)** | `1.0.0-beta.N` | 🧪 | **测试版** |
| `release` | 构建 → **Release** | `1.0.0` | ✅ | **正式版** |

💡 **详细发布流程**: 查看 [DUAL_BRANCH_RELEASE.md](DUAL_BRANCH_RELEASE.md)

---

## 📋 工作流说明

### 主构建流程 (android-build.yml)

**触发时机**:
- ✅ 推送到 `main`/`master`/`develop` 分支
- ✅ 创建 Pull Request
- ✅ 手动触发

**构建内容**:
- Debug APK (所有分支)
- Release APK (仅 main/master 分支，需配置 Secrets)

**产物位置**: Actions → 构建记录 → Artifacts

---

### 发布流程 (release.yml)

**触发时机**:
- ✅ 推送 Tag (格式: `v*`)
- ✅ 手动触发

**执行内容**:
- 构建已签名的 Release APK
- 生成 SHA256 校验和
- 创建 GitHub Release
- 上传 APK 文件

**产物位置**: 仓库的 Releases 页面

---

## 🔍 常见问题

### Q: 如何验证签名密钥是否正确？

```bash
# 查看密钥信息
keytool -list -v -keystore lumi-release-key.jks -alias lumi
# 密码: android123
```

### Q: 如何在本地测试构建？

```bash
# 测试 Debug 构建
./gradlew assembleDebug

# 测试 Release 构建（带签名）
export RELEASE_KEYSTORE_PATH=./lumi-release-key.jks
export RELEASE_KEYSTORE_PASSWORD=android123
export RELEASE_KEY_ALIAS=lumi
export RELEASE_KEY_PASSWORD=android123
export VERSION_CODE=1
export VERSION_NAME=1.0.0-test
./gradlew assembleRelease
```

### Q: 构建失败怎么办？

1. **检查 Secrets 配置**: 确保 4 个 Secret 都已正确配置
2. **查看构建日志**: Actions → 点击失败的构建 → 展开失败的步骤
3. **常见错误**:
   - `Keystore was tampered with`: Base64 编码不完整或损坏
   - `Could not find signing config`: Secrets 未配置或分支不是 main/master

### Q: 如何更改版本号？

**自动版本号** (推荐):
- 格式: `1.0.0-build.{构建号}`
- 无需手动操作，每次构建自动递增

**Tag 版本号**:
```bash
# 推送 Tag 时使用的版本号
git tag v1.2.3
git push origin v1.2.3
```

**修改基础版本号**:
编辑 `.github/scripts/version-generator.sh`:
```bash
BASE_VERSION="2.0.0"  # 改为你想要的版本
```

---

## 🔒 安全提示

### ⚠️ 必须做

1. **备份签名密钥**
   ```bash
   # 将这两个文件备份到安全位置
   cp lumi-release-key.jks ~/Documents/secure-backup/
   cp lumi-release-key.jks.base64 ~/Documents/secure-backup/
   ```

2. **不要提交密钥到 Git**
   - 已在 `.gitignore` 中排除
   - 但仍需确认未提交

### 🔐 生产环境建议

1. **更改默认密码**
   ```bash
   keytool -storepasswd -keystore lumi-release-key.jks
   keytool -keypasswd -alias lumi -keystore lumi-release-key.jks
   ```

   修改后需更新 GitHub Secrets

2. **启用代码混淆**
   编辑 `app/build.gradle.kts`:
   ```kotlin
   release {
       isMinifyEnabled = true  // 改为 true
       isShrinkResources = true
   }
   ```

---

## 📚 详细文档

更多高级配置请查看：
- [完整配置指南](.github/SETUP_GUIDE.md)
- [工作流配置](.github/workflows/)
- [版本生成脚本](.github/scripts/version-generator.sh)

---

## 🎉 完成！

现在你的项目已经配置好了完整的 CI/CD 流程：

✅ 推送代码 → 自动构建 APK
✅ 创建 Tag → 自动发布 Release
✅ 版本号管理 → 完全自动化
✅ 签名配置 → 安全可靠

祝开发顺利！🚀

---

**配置时间**: 2025-01-25
**签名密钥有效期**: 至 2052 年 (27年)
**默认密码**: android123 (建议修改)

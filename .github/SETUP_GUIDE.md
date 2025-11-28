# GitHub Actions 自动构建配置指南

本项目已配置 GitHub Actions 自动构建，推送到 main 分支时会自动构建 Debug 和 Release APK。

## 📋 配置清单

### 1. GitHub Secrets 配置

为了使 Release 版本正常构建并签名，需要在 GitHub 仓库中配置以下 Secrets：

**前往**: `仓库 Settings` → `Secrets and variables` → `Actions` → `New repository secret`

添加以下 4 个 Secrets：

| Secret 名称 | 值 | 说明 |
|------------|-----|------|
| `RELEASE_KEYSTORE_BASE64` | (见下方说明) | 签名密钥文件的 Base64 编码 |
| `RELEASE_KEYSTORE_PASSWORD` | `android123` | Keystore 密码 |
| `RELEASE_KEY_ALIAS` | `lumi` | 密钥别名 |
| `RELEASE_KEY_PASSWORD` | `android123` | 密钥密码 |

---

### 2. 获取 RELEASE_KEYSTORE_BASE64 的值

项目根目录已生成签名密钥文件：`lumi-release-key.jks.base64`

**步骤 1**: 读取 Base64 编码内容

```bash
cat lumi-release-key.jks.base64
```

**步骤 2**: 将整个文件内容复制，粘贴到 GitHub Secret 中

⚠️ **注意**:
- 务必复制完整内容，不要遗漏任何字符
- 不要在内容中添加换行或空格
- 该文件包含敏感信息，请妥善保管原始 `.jks` 文件

---

### 3. 签名密钥信息

当前生成的签名密钥信息如下：

```
密钥文件: lumi-release-key.jks
Keystore 密码: android123
密钥别名: lumi
密钥密码: android123
有效期: 10000 天 (约 27 年)
签名算法: RSA 2048
```

**⚠️ 重要提示**：
- 请将 `lumi-release-key.jks` 文件**备份**到安全位置
- 该文件不应提交到 Git 仓库（已在 .gitignore 中排除）
- 如果密钥丢失，将无法更新已发布的应用

---

## 🔄 工作流说明

### 工作流 1: `android-build.yml` (主构建流程)

**触发条件**:
- 推送到 `main` / `master` / `develop` 分支
- 创建 Pull Request 到 `main` / `master`
- 手动触发

**构建内容**:
- ✅ Debug APK (所有分支)
- ✅ Release APK (仅 main/master 分支)

**构建产物**:
- Artifacts 保存在 GitHub Actions 中
- Debug APK 保留 30 天
- Release APK 保留 90 天

**版本命名**:
- 格式: `1.0.0-build.{构建号}`
- 示例: `1.0.0-build.42`

---

### 工作流 2: `release.yml` (正式发布流程)

**触发条件**:
- 推送 Tag (格式: `v*`, 如 `v1.0.0`)
- 手动触发（可指定版本号）

**执行内容**:
1. 构建 Release APK
2. 生成 SHA256 校验和
3. 创建 GitHub Release
4. 自动生成 Release Notes
5. 上传 APK 文件到 Release

**创建 Release 的步骤**:

```bash
# 方式 1: 使用 Git Tag (推荐)
git tag v1.0.0
git push origin v1.0.0

# 方式 2: 手动触发
# 前往 GitHub Actions → Release Build → Run workflow
# 输入版本号 (如: 1.0.0)
```

---

## 📦 下载构建产物

### 从 Actions Artifacts 下载

1. 前往 `Actions` 标签
2. 点击最新的构建记录
3. 滚动到底部 `Artifacts` 区域
4. 下载对应的 APK 文件

### 从 Releases 下载

1. 前往仓库的 `Releases` 页面
2. 找到对应版本
3. 下载 APK 文件
4. 验证 SHA256 校验和（可选）

```bash
# 验证校验和
sha256sum lumi-assistant-1.0.0.apk
```

---

## 🔧 版本号管理

### 自动版本号规则

**Version Code** (用于应用内版本比较):
- 格式: `YYYYMMDDNNN`
- 示例: `20250125042` (2025年1月25日第42次构建)

**Version Name** (用户可见版本):
- 开发构建: `1.0.0-build.{构建号}`
- 正式发布: 使用 Git Tag 的版本号 (如 `1.0.0`)

### 手动修改基础版本号

编辑文件: `.github/scripts/version-generator.sh`

```bash
# 修改此行
BASE_VERSION="1.0.0"  # 改为你想要的版本号
```

---

## 🧪 本地测试构建

### 测试版本号生成

```bash
# 模拟 GitHub Actions 环境
export GITHUB_RUN_NUMBER=42
export GITHUB_SHA=$(git rev-parse HEAD)
.github/scripts/version-generator.sh
```

### 本地构建 Release APK (无签名)

```bash
./gradlew assembleRelease
```

### 本地构建 Release APK (带签名)

```bash
export RELEASE_KEYSTORE_PATH=./lumi-release-key.jks
export RELEASE_KEYSTORE_PASSWORD=android123
export RELEASE_KEY_ALIAS=lumi
export RELEASE_KEY_PASSWORD=android123
export VERSION_CODE=20250125001
export VERSION_NAME=1.0.0

./gradlew assembleRelease
```

---

## 🔒 安全建议

### 生产环境配置

如果要用于生产环境，建议：

1. **更改密钥密码**
   ```bash
   keytool -storepasswd -keystore lumi-release-key.jks
   keytool -keypasswd -alias lumi -keystore lumi-release-key.jks
   ```

2. **启用代码混淆**
   编辑 `app/build.gradle.kts`:
   ```kotlin
   buildTypes {
       release {
           isMinifyEnabled = true  // 改为 true
           isShrinkResources = true
           proguardFiles(...)
       }
   }
   ```

3. **配置 ProGuard 规则**
   编辑 `app/proguard-rules.pro`，添加项目特定的混淆规则

4. **保护敏感配置**
   - 不要在代码中硬编码 API 密钥
   - 使用 `local.properties` 或环境变量存储敏感信息
   - 确保 `.gitignore` 包含所有敏感文件

---

## ❓ 常见问题

### Q1: 构建失败，提示签名错误

**A**: 检查 GitHub Secrets 配置是否正确：
- `RELEASE_KEYSTORE_BASE64` 是否完整
- 密码和别名是否匹配

### Q2: 如何重新生成签名密钥？

**A**:
```bash
rm lumi-release-key.jks*
keytool -genkey -v -keystore lumi-release-key.jks ...
base64 -i lumi-release-key.jks -o lumi-release-key.jks.base64
# 重新配置 GitHub Secrets
```

⚠️ **警告**: 重新生成后无法更新已发布的应用！

### Q3: 如何查看构建日志？

**A**:
1. 前往 GitHub Actions 标签
2. 点击构建记录
3. 展开失败的步骤查看详细日志

### Q4: 版本号不对怎么办？

**A**: 检查 `.github/scripts/version-generator.sh` 脚本，确保：
- 脚本有执行权限 (`chmod +x`)
- `BASE_VERSION` 设置正确
- 环境变量正确传递

---

## 📚 相关文档

- [GitHub Actions 文档](https://docs.github.com/actions)
- [Android 应用签名](https://developer.android.com/studio/publish/app-signing)
- [Gradle 构建配置](https://developer.android.com/build)

---

**📅 配置日期**: 2025-01-25
**🔧 维护者**: Lumi Assistant Team

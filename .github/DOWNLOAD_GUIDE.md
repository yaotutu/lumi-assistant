# 📥 APK 下载指南

## 📋 不同分支的下载方式

| 分支类型 | 下载位置 | 保留时间 | 版本号格式 |
|---------|---------|---------|-----------|
| **release** | GitHub Releases | 永久 | `1.0.0` |
| **main / develop** | GitHub Actions Artifacts | 90天 | `1.0.0-main.42` |
| **feature / 其他** | GitHub Actions Artifacts | 30天 | `1.0.0-feature.10` |

---

## 🚀 方法 1: 从 GitHub Releases 下载（release 分支）

### 适用场景
- ✅ 下载正式发布版本
- ✅ 需要稳定的生产版本
- ✅ 对外分发

### 步骤

1. **访问 Releases 页面**
   ```
   https://github.com/{用户名}/{仓库名}/releases

   或点击：仓库主页 → 右侧 "Releases" 链接
   ```

2. **选择版本**
   - 最新版本在最上方
   - 点击展开版本详情

3. **下载 APK**

   根据设备选择对应架构：

   | 文件 | 说明 | 推荐 |
   |------|------|------|
   | `lumi-assistant-X.Y.Z-universal.apk` | 通用版，所有设备 | ⭐ **不确定选这个** |
   | `lumi-assistant-X.Y.Z-arm64-v8a.apk` | 64位，现代手机 | 体积更小 |
   | `lumi-assistant-X.Y.Z-armeabi-v7a.apk` | 32位，老旧设备 | 老设备专用 |

4. **验证校验和（可选）**
   ```bash
   # 下载 checksums.txt
   # 验证 APK 完整性
   sha256sum lumi-assistant-1.0.0-universal.apk
   ```

---

## 🔧 方法 2: 从 Artifacts 下载（开发版本）

### 适用场景
- ✅ 测试最新功能
- ✅ 下载特定分支的构建
- ✅ 内部测试和开发

### 步骤详解

#### 第 1 步：进入 Actions 页面

```
仓库主页 → 点击顶部 "Actions" 标签
```

或直接访问：
```
https://github.com/{用户名}/{仓库名}/actions
```

#### 第 2 步：选择工作流

左侧边栏选择：
- **Android Build** - 查看所有分支的构建

#### 第 3 步：筛选构建记录

**按分支筛选**:
- 点击 "Branch" 下拉菜单
- 选择目标分支（如 `main`、`develop`、`feature/xxx`）

**按状态筛选**:
- ✅ 绿色勾：构建成功
- ❌ 红色叉：构建失败
- 🔵 蓝色圈：构建中

#### 第 4 步：打开构建详情

点击任意构建记录，进入详情页。

显示信息：
```
构建记录 #42
分支: main
提交: feat: 添加新功能 (abc1234)
触发者: @username
时间: 2025-01-25 10:30
```

#### 第 5 步：下载 Artifacts

**滚动到页面底部**，找到 `Artifacts` 区域：

```
Artifacts
└── lumi-assistant-debug-1.0.0-main.42
    📦 Size: 12.5 MB
    ⏰ Expires in 90 days
    ⬇️ Download
```

**点击下载**：
- 下载的是 `.zip` 压缩包
- 解压后包含 APK 文件

#### Debug vs Release

| Artifact 名称 | 包含内容 | 何时可用 |
|--------------|---------|---------|
| `lumi-assistant-debug-...` | 1个 Debug APK | 所有分支 |
| `lumi-assistant-release-...` | 3个 Release APK | 仅 main/master 分支 |

---

## 🖥️ 方法 3: 使用 GitHub CLI（命令行）

### 前提条件

安装 GitHub CLI：
```bash
# macOS
brew install gh

# Windows
winget install GitHub.cli

# Linux
sudo apt install gh
```

登录：
```bash
gh auth login
```

### 下载最新构建

```bash
# 1. 进入项目目录
cd lumi-assistant

# 2. 查看最近的构建
gh run list --workflow="android-build.yml" --limit 5

# 输出示例：
# ✓  feat: 添加新功能  Android Build  main  123456  42m ago

# 3. 下载最新的构建产物
gh run download $(gh run list --workflow="android-build.yml" --limit 1 --json databaseId --jq '.[0].databaseId')

# 4. 查看下载的文件
ls -la lumi-assistant-*/
```

### 下载特定分支的构建

```bash
# 下载 develop 分支的最新构建
gh run list --workflow="android-build.yml" --branch develop --limit 1
gh run download <RUN_ID>
```

### 下载特定构建号

```bash
# 如果知道构建号（如 #42）
gh run list --workflow="android-build.yml" | grep "#42"
gh run download <RUN_ID>
```

---

## 📱 方法 4: 通过 API 下载（高级）

### 获取 Artifacts 列表

```bash
# 设置变量
OWNER="yaotutu"
REPO="lumi-assistant"
TOKEN="ghp_xxxxxxxxxxxx"  # GitHub Personal Access Token

# 获取最新的工作流运行
curl -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs?per_page=1" \
  | jq '.workflow_runs[0].id'

# 获取 Artifacts 列表
RUN_ID=123456
curl -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs/$RUN_ID/artifacts" \
  | jq '.artifacts[] | {name, size_in_bytes, archive_download_url}'
```

### 下载 Artifact

```bash
# 下载 Artifact
ARTIFACT_ID=789012
curl -L -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID/zip" \
  -o artifact.zip

# 解压
unzip artifact.zip
```

---

## 🔍 如何找到特定版本？

### 按日期查找

```
Actions → 使用右上角日期筛选器
```

### 按提交消息查找

```
在构建列表中搜索提交消息关键词
例如：搜索 "fix: 修复登录"
```

### 按提交 SHA 查找

```
在 Actions 页面搜索框输入提交 SHA（前7位）
例如：abc1234
```

### 按 PR 查找

```
打开对应的 Pull Request
→ 点击 "Checks" 标签
→ 查看 "Android Build" 结果
→ 点击 "Details" 进入构建页面
→ 下载 Artifacts
```

---

## 📊 不同场景下的推荐方式

| 场景 | 推荐方式 | 原因 |
|------|---------|------|
| **普通用户下载稳定版** | GitHub Releases | 最简单，永久保存 |
| **测试最新开发版本** | Actions Artifacts | 包含最新功能 |
| **测试特定功能分支** | Actions Artifacts (按分支筛选) | 可选择特定分支 |
| **自动化下载** | GitHub CLI / API | 适合 CI/CD |
| **团队内部测试** | Actions Artifacts | 支持多分支 |

---

## ⏰ Artifacts 保留时间

| 分支类型 | 保留时间 | 配置位置 |
|---------|---------|---------|
| **Debug APK** | 30 天 | `retention-days: 30` |
| **Release APK** | 90 天 | `retention-days: 90` |
| **GitHub Release** | 永久 | N/A |

**注意**:
- Artifacts 过期后会自动删除
- 正式版本请发布到 Releases

---

## 🛠️ 解压和安装

### 解压 Artifacts

```bash
# macOS / Linux
unzip lumi-assistant-debug-1.0.0-main.42.zip

# Windows
右键 → 解压到...
```

### 安装到 Android 设备

**方法 1: ADB 安装**
```bash
adb install -r app-debug.apk
```

**方法 2: 手机直接安装**
1. 将 APK 传输到手机
2. 打开文件管理器
3. 点击 APK 文件安装

**方法 3: Release APK (多架构)**
```bash
# 选择对应架构安装
adb install -r app-arm64-v8a-release.apk
```

---

## 🔐 安全验证

### 验证签名（Release APK）

```bash
# 查看 APK 签名信息
keytool -printcert -jarfile app-release.apk

# 应该显示：
# Owner: CN=Lumi Assistant, OU=Development...
```

### 验证 SHA256 校验和

```bash
# 计算 APK 的 SHA256
sha256sum lumi-assistant-1.0.0-universal.apk

# 对比 checksums.txt 中的值
cat checksums.txt
```

---

## ❓ 常见问题

### Q1: 为什么找不到 Release APK？

**A**: Release APK 仅在以下情况生成：
- 推送到 `main` 或 `master` 分支
- 推送到 `release` 分支
- 已配置 GitHub Secrets 签名密钥

其他分支只生成 Debug APK。

### Q2: Artifacts 下载需要登录吗？

**A**: 是的，需要：
- GitHub 账号登录
- 对仓库有访问权限（公开仓库或私有仓库成员）

### Q3: 如何下载别人 Fork 的构建？

**A**:
```
前往 Fork 的仓库 → Actions → 选择构建 → 下载
```

### Q4: 可以直接分享 Artifact 下载链接吗？

**A**: 不推荐，因为：
- Artifact 链接需要登录
- 有过期时间
- 不是公开链接

**推荐**:
- 正式版本发布到 Releases
- 测试版本手动下载后通过其他方式分享

### Q5: 如何批量下载多个构建？

**A**: 使用 GitHub CLI：
```bash
# 下载最近 5 次构建
for run_id in $(gh run list --workflow="android-build.yml" --limit 5 --json databaseId --jq '.[].databaseId'); do
  gh run download $run_id
done
```

---

## 📚 相关文档

- [Release 发布流程](.github/RELEASE_WORKFLOW.md)
- [快速上手指南](../GITHUB_ACTIONS_QUICKSTART.md)
- [架构说明](.github/ABI_ARCHITECTURE.md)

---

## 🎯 快速参考

### 下载正式版本
```
仓库主页 → Releases → 下载 APK
```

### 下载开发版本
```
仓库主页 → Actions → Android Build → 选择构建 →
滚动到底部 → Artifacts → 下载
```

### 命令行下载
```bash
gh run download $(gh run list --workflow="android-build.yml" --limit 1 --json databaseId --jq '.[0].databaseId')
```

---

**文档版本**: 1.0
**更新日期**: 2025-01-25
**维护者**: Lumi Assistant Team

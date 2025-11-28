# GitHub Actions CI/CD 配置

本目录包含 Lumi Assistant 项目的持续集成和持续部署配置。

## 📁 目录结构

```
.github/
├── workflows/
│   ├── android-build.yml    # 主构建流程 (推送触发)
│   └── release.yml          # 发布流程 (Tag 触发)
├── scripts/
│   └── version-generator.sh # 版本号自动生成脚本
├── SETUP_GUIDE.md          # 详细配置指南
└── README.md               # 本文件
```

## 🚀 快速开始

### 1. 配置 GitHub Secrets

前往 `Settings` → `Secrets and variables` → `Actions`，添加以下 Secrets：

```
RELEASE_KEYSTORE_BASE64     # 签名密钥文件 (Base64 编码)
RELEASE_KEYSTORE_PASSWORD   # android123
RELEASE_KEY_ALIAS           # lumi
RELEASE_KEY_PASSWORD        # android123
```

**获取 Base64 密钥内容**:
```bash
cat lumi-release-key.jks.base64
```

### 2. 触发构建

**自动触发**: 推送到 main/master 分支
```bash
git push origin main
```

**创建 Release**: 推送 Tag
```bash
git tag v1.0.0
git push origin v1.0.0
```

## 📦 构建产物

### Debug APK
- **保留时间**: 30 天
- **命名**: `lumi-assistant-debug-{版本号}`
- **触发**: 所有分支

### Release APK
- **保留时间**: 90 天
- **命名**: `lumi-assistant-release-{版本号}`
- **触发**: main/master 分支 + 有效签名配置

### Release Package (Tag 触发)
- **保留时间**: 永久
- **命名**: `lumi-assistant-{版本号}.apk`
- **包含**: APK + SHA256 校验和

## 🔧 版本号规则

| 类型 | 格式 | 示例 |
|------|------|------|
| Version Code | `YYYYMMDDNNN` | `20250125042` |
| Version Name (开发) | `X.Y.Z-build.N` | `1.0.0-build.42` |
| Version Name (发布) | `X.Y.Z` | `1.0.0` |

## 📚 详细文档

完整配置说明请查看: [SETUP_GUIDE.md](./SETUP_GUIDE.md)

## ⚡ 常用操作

### 查看构建状态
前往 GitHub 仓库的 `Actions` 标签页

### 下载构建产物
1. Actions → 选择构建记录
2. 滚动到 Artifacts 区域
3. 点击下载

### 手动触发构建
1. Actions → 选择 Workflow
2. Run workflow → 选择分支
3. Run

### 创建正式发布
```bash
# 确保在 main 分支且代码已同步
git checkout main
git pull

# 创建并推送 Tag
git tag v1.0.0
git push origin v1.0.0

# 自动触发 Release 流程
```

## 🛡️ 安全提示

- ✅ 签名密钥已添加到 `.gitignore`
- ✅ 敏感信息存储在 GitHub Secrets
- ⚠️ 请妥善备份 `lumi-release-key.jks` 文件
- ⚠️ 生产环境建议修改默认密码

## 📝 更新日志

查看 [仓库 Releases](../../releases) 获取版本更新历史。

---

**维护者**: Lumi Assistant Team
**最后更新**: 2025-01-25

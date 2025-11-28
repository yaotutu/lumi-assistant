# 📱 Lumi Assistant {{VERSION}}

## 🏷️ 版本信息
- **版本号**: {{VERSION}}
- **构建号**: {{BUILD_NUMBER}}
- **构建时间**: {{BUILD_TIME}}
- **Git 提交**: [`{{COMMIT_SHA}}`]({{COMMIT_URL}})
- **构建分支**: {{BRANCH}}

## 🔧 技术栈
- **Gradle 版本**: {{GRADLE_VERSION}}
- **Kotlin 版本**: {{KOTLIN_VERSION}}
- **Android Gradle Plugin**: {{AGP_VERSION}}

## 📦 下载 APK

根据你的设备选择对应架构下载（不确定就选 Universal）：

| 文件 | 架构 | 适用设备 | 大小 |
|------|------|---------|------|
| `lumi-assistant-{{VERSION}}-universal.apk` | 通用版 | **所有 ARM 设备（推荐）** | ~较大 |
| `lumi-assistant-{{VERSION}}-arm64-v8a.apk` | 64位 | 2019年后的现代手机 | ~较小 |
| `lumi-assistant-{{VERSION}}-armeabi-v7a.apk` | 32位 | 老旧设备 | ~较小 |

> 💡 **选择建议**:
> - 不确定？下载 **universal** 版本（兼容所有设备）
> - 想要更小体积？根据设备架构选择对应版本

## 📝 更新内容
**提交信息**: {{COMMIT_MESSAGE}}
**提交作者**: {{COMMIT_AUTHOR}}
**提交时间**: {{COMMIT_DATE}}

<details>
<summary>查看详细的变更记录</summary>

```bash
git log --pretty=format:"- %s" [last-tag]..HEAD
```

</details>

## 🔐 安全校验
下载后可验证 SHA256 校验和来确保文件完整性：

```
# 在终端中验证
sha256sum 下载的文件名.apk
```

## ⚙️ 系统要求
- **最低版本**: Android 7.0 (API 24)
- **推荐版本**: Android 12+ (支持 Material You 动态配色)
- **支持架构**: ARM 设备（不支持 x86 模拟器）
- **存储空间**: 建议预留 200MB

## 🚀 安装说明

### 方式一：直接安装 APK
1. 下载对应架构的 APK 文件
2. 在手机设置中启用"未知来源应用"安装
3. 点击 APK 文件进行安装

### 方式二：使用 ADB（开发者）
```bash
adb install lumi-assistant-{{VERSION}}-universal.apk
```

## 🎯 主要功能
- 🎤 **语音唤醒**: 离线唤醒，支持自定义唤醒词
- 🤖 **AI 对话**: 流式对话，实时响应
- 🔊 **TTS 播放**: 高质量语音合成
- 📱 **Material 3**: 现代化界面设计，支持动态配色
- 🎨 **深色模式**: 完整的深色主题支持

## ⚠️ 注意事项
- 首次使用需要授予录音权限和设备信息权限
- 语音唤醒功能需要网络连接进行 AI 对话
- 建议在 Wi-Fi 环境下首次使用以下载必要资源

## 🐛 反馈问题
如果遇到问题，请通过以下方式反馈：
- **GitHub Issues**: [提交新问题]({{ISSUES_URL}})
- **查看已知问题**: [Issues 列表]({{ISSUES_URL}})

---
*由 GitHub Actions 自动生成*
*构建时间: {{BUILD_TIME}} UTC*
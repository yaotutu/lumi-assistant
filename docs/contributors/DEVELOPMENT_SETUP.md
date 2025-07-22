# 🔧 开发环境搭建

> 完整的开发环境配置指南

## 🎯 环境要求

### 系统要求
- 💻 **操作系统**: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+)
- 🧠 **内存**: 8GB+ RAM (推荐16GB)
- 💾 **存储**: 10GB+ 可用空间
- 🌐 **网络**: 稳定的互联网连接

### 开发工具版本
- 🎯 **Flutter**: 3.29.3+
- ☕ **Java**: JDK 17+
- 🤖 **Android SDK**: API 23+ (Android 6.0+)
- 📱 **目标设备**: Android 6.0+ (API 23+)

## 📦 安装步骤

### 1. Flutter SDK安装

#### macOS/Linux
```bash
# 下载Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# 永久添加到PATH (添加到 ~/.bashrc 或 ~/.zshrc)
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

#### Windows
```powershell
# 下载并解压Flutter SDK到 C:\flutter
# 添加 C:\flutter\bin 到系统PATH环境变量
```

### 2. 验证Flutter安装
```bash
flutter doctor
```

期望输出示例：
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.29.3)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] IntelliJ IDEA Ultimate Edition
[✓] VS Code
[✓] Connected device (2 available)
[✓] Network resources
```

### 3. Android开发环境

#### 安装Android Studio
1. 📥 下载 [Android Studio](https://developer.android.com/studio)
2. 🔧 安装Android SDK (API 23+)
3. ⚙️ 配置Android SDK路径

#### 配置环境变量
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### 4. 设备准备

#### 使用真机调试（推荐）
```bash
# 启用开发者选项
# 1. 设置 > 关于手机 > 连续点击版本号7次
# 2. 设置 > 开发者选项 > USB调试（开启）
# 3. 连接USB线到电脑

# 验证设备连接
flutter devices
```

#### 使用模拟器
```bash
# 创建AVD (Android Virtual Device)
flutter emulators --create --name test_device

# 启动模拟器
flutter emulators --launch test_device
```

### 5. 项目配置

#### 克隆项目
```bash
# Fork项目后克隆你的Fork
git clone https://github.com/YOUR_USERNAME/lumi-assistant.git
cd lumi-assistant

# 添加上游仓库
git remote add upstream https://github.com/yaotutu/lumi-assistant.git
```

#### 安装依赖
```bash
# 获取项目依赖
flutter pub get

# 验证项目配置
flutter doctor
flutter analyze
```

#### 首次运行
```bash
# 运行到连接的设备
flutter run

# 指定设备运行（推荐使用YT3002）
flutter run -d 1W11833968

# 热重载开发
flutter run --hot
```

## 🛠️ 开发工具配置

### VS Code配置
推荐插件：
```json
{
  "recommendations": [
    "dart-code.flutter",
    "dart-code.dart-code",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss",
    "github.copilot"
  ]
}
```

VS Code设置：
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 120,
  "dart.insertArgumentPlaceholders": false,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

### Android Studio配置
1. 🔌 安装Flutter和Dart插件
2. ⚙️ 配置Flutter SDK路径
3. 🎨 设置代码风格为Dart标准
4. 🔍 启用代码检查和自动格式化

## 🎯 目标设备配置

### YT3002设备（主要测试设备）
```bash
# 设备信息
Device ID: 1W11833968
Platform: Android 7.0 (API 24)
Architecture: android-arm64
Screen: 1280x736 (Landscape)

# 专用运行命令
flutter run -d 1W11833968
flutter run -d 1W11833968 --hot
flutter build apk --target-platform=android-arm64
```

### 多设备测试
```bash
# 查看所有连接的设备
flutter devices

# 同时运行到多个设备
flutter run -d all
```

## 🔍 开发工作流

### 日常开发循环
```bash
# 1. 同步最新代码
git checkout dev
git pull upstream dev

# 2. 创建功能分支
git checkout -b feature/new-feature

# 3. 热重载开发
flutter run --hot

# 4. 代码检查
flutter analyze
flutter test

# 5. 提交代码
git add .
git commit -m "feat(scope): 功能描述"
git push origin feature/new-feature
```

### 调试技巧
```bash
# 调试模式运行
flutter run --debug

# 性能分析
flutter run --profile

# 发布模式测试
flutter run --release

# 查看日志
flutter logs

# 清理构建缓存
flutter clean
flutter pub get
```

## 🔧 常见问题解决

### Flutter问题
```bash
# Flutter版本问题
flutter channel stable
flutter upgrade

# 依赖冲突
flutter clean
rm pubspec.lock
flutter pub get

# 设备连接问题
flutter doctor
adb devices
adb kill-server && adb start-server
```

### Android构建问题
```bash
# Gradle问题
cd android
./gradlew clean

# SDK许可问题
flutter doctor --android-licenses

# 模拟器问题
flutter emulators
flutter emulators --create
```

### 网络问题
```bash
# 国内网络优化
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 代理设置
flutter config --enable-web
```

## 📊 性能优化

### 开发环境优化
```bash
# 启用Web支持（可选）
flutter config --enable-web

# Dart分析缓存
export DART_VM_OPTIONS="--max-heap-size=2048m"

# 构建优化
flutter build apk --split-per-abi
```

### 设备性能优化
- 🔋 连接电源适配器
- 📱 关闭不必要的应用
- 🌡️ 保持设备温度适宜
- 💾 确保充足的存储空间

## ✅ 验证清单

完成环境搭建后，确认以下项目：

- [ ] `flutter doctor` 无重要错误
- [ ] 项目可以成功运行 `flutter run`
- [ ] 代码检查通过 `flutter analyze`
- [ ] 测试运行成功 `flutter test`
- [ ] 可以构建APK `flutter build apk`
- [ ] 设备调试正常工作
- [ ] Git配置正确，可以提交代码
- [ ] IDE/编辑器插件工作正常

## 📚 学习资源

### 官方文档
- [Flutter官方文档](https://flutter.dev/docs)
- [Dart语言指南](https://dart.dev/guides)
- [Android开发指南](https://developer.android.com/guide)

### 项目相关
- [Riverpod状态管理](https://riverpod.dev/)
- [WebSocket通信](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
- [Opus音频编解码](https://opus-codec.org/)

---

**环境搭建完成，开始你的开发之旅 🚀**
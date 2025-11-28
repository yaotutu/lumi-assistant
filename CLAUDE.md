# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Lumi Assistant 是一个使用 Jetpack Compose 和 Material Design 3 构建的 Android 应用。

- **包名**: com.lumi.assistant
- **最小 SDK**: 24 (Android 7.0)
- **目标 SDK**: 35 (Android 15)

## 常用命令

```bash
# 构建
./gradlew assembleDebug          # 构建 debug APK
./gradlew assembleRelease        # 构建 release APK
./gradlew clean                  # 清理构建

# 安装和运行
./gradlew installDebug           # 安装到设备

# 测试
./gradlew test                   # 运行单元测试
./gradlew connectedAndroidTest   # 运行仪器测试
./gradlew :app:testDebugUnitTest --tests "com.lumi.assistant.ExampleUnitTest"  # 运行单个测试

# 依赖检查
./gradlew dependencies           # 查看依赖树
```

## 架构

采用 **MVVM + Hilt + Navigation Compose** 架构，技术栈：

- **UI 框架**: Jetpack Compose + Material 3
- **依赖注入**: Hilt 2.51.1
- **导航**: Navigation Compose 2.7.7
- **数据持久化**: DataStore Preferences
- **网络通信**: OkHttp3 WebSocket
- **音频处理**: Opus 编码 (16kHz, VOIP 模式)
- **语音唤醒**: AIKit SDK
- **构建系统**: Gradle 8.11.1 + Kotlin DSL
- **Kotlin**: 2.0.21
- **AGP**: 8.10.1

### 代码结构

```
app/src/main/java/com/lumi/assistant/
├── LumiApplication.kt          # @HiltAndroidApp 应用入口
├── MainActivity.kt              # @AndroidEntryPoint, 权限请求
│
├── di/                          # Hilt 依赖注入模块
│   ├── AppModule.kt             # 应用级单例 (AudioPlayer, WebSocketManager, Repository)
│   └── WakeupModule.kt          # 唤醒管理器注入
│
├── navigation/                  # Navigation Compose
│   ├── Routes.kt                # 路由常量 (ASSISTANT, SETTINGS)
│   └── NavGraph.kt              # 导航图配置
│
├── viewmodel/                   # ViewModel 层 (Hilt 注入)
│   ├── VoiceAssistantViewModel.kt   # 主业务逻辑，状态机管理
│   └── SettingsViewModel.kt         # 设置页面逻辑
│
├── repository/                  # 数据层
│   └── SettingsRepository.kt    # DataStore 持久化
│
├── network/                     # 网络层
│   └── WebSocketManager.kt      # WebSocket 连接管理，自动重连
│
├── wakeup/                      # 语音唤醒模块
│   ├── WakeupManager.kt         # AIKit SDK 管理
│   ├── WakeupListener.kt        # 唤醒回调接口
│   └── WakeupConfig.kt          # 唤醒配置
│
├── audio/                       # 音频处理
│   ├── AudioRecorder.kt         # 录音 + Opus 编码
│   └── AudioPlayer.kt           # 音频播放
│
├── config/                      # 配置数据模型
│   └── AppSettings.kt           # VAD/Server/Wakeup 配置
│
├── model/                       # 数据模型
│   └── Message.kt               # 消息数据类
│
└── ui/                          # UI 层 (Compose)
    ├── VoiceAssistantScreen.kt  # 主界面
    ├── SettingsScreen.kt        # 设置界面
    ├── components/
    │   └── AudioWaveform.kt      # 波形视图组件
    └── theme/
        ├── Color.kt             # Material 3 颜色
        ├── Theme.kt             # 主题配置 (动态颜色支持)
        └── Type.kt              # 排版系统
```

### 核心架构模式

#### 1. Hilt 依赖注入
- **应用入口**: `LumiApplication.kt` 使用 `@HiltAndroidApp`
- **模块配置**: `di/AppModule.kt` 提供单例 (AudioPlayer, WebSocketManager, SettingsRepository)
- **ViewModel 注入**: 使用 `@HiltViewModel` + `@Inject constructor`
- **Activity 注入**: `MainActivity.kt` 使用 `@AndroidEntryPoint` + `hiltViewModel()`

#### 2. Navigation Compose
- **路由定义**: `navigation/Routes.kt` 定义路由常量
- **导航图**: `navigation/NavGraph.kt` 配置 NavHost
- **导航流程**: MainActivity → NavGraph → VoiceAssistantScreen/SettingsScreen
- **ViewModel 作用域**: 主界面 ViewModel 在 MainActivity 注入，设置页面 ViewModel 在路由中注入

#### 3. MVVM 数据流
- **ViewModel**: 管理 UI 状态 (StateFlow) 和业务逻辑
- **Repository**: 封装数据访问 (DataStore)
- **WebSocketManager**: 网络通信单例，回调驱动
- **状态订阅**: UI 使用 `collectAsState()` 订阅 StateFlow

#### 4. 状态机设计 (VoiceAssistantViewModel)
```
IDLE (待机) → RECORDING (录音) → PLAYING (播放) → IDLE
    ↑             ↓                  ↓
  唤醒成功      VAD检测          AI播放完成
```

- **IDLE**: 等待唤醒词，WakeupManager 监听中
- **RECORDING**: 用户说话，AudioRecorder 录音 + VAD 检测静音
- **PLAYING**: AI 回复，AudioPlayer 播放缓冲的音频

#### 5. 音频处理链路
```
用户说话 → AudioRecorder (PCM 16kHz) → Opus编码 → WebSocket → 服务器
服务器 → WebSocket (二进制) → AudioPlayer → Opus解码 → 扬声器
```

#### 6. VAD (语音活动检测)
- **静音阈值**: 默认 2000ms (可在设置中调整)
- **音量阈值**: 默认 900 (可在设置中调整)
- **检测周期**: 每 500ms 检查一次
- **触发条件**: 检测到连续静音超过阈值 → 停止录音 → 发送 audioEnd

## 依赖管理

依赖版本集中管理在 `gradle/libs.versions.toml`。

主要依赖：
- **Compose**: BOM 2024.09.00
- **Hilt**: 2.51.1 (依赖注入)
- **Navigation Compose**: 2.7.7
- **DataStore**: 1.0.0 (持久化)
- **OkHttp3**: 4.12.0 (WebSocket)
- **Opus**: JNA 绑定 (音频编码)
- **AIKit**: 离线语音唤醒 SDK (已集成在 libs/)

## 构建配置

### APK 架构分割
项目配置了 APK 架构分割，构建 release 版本会生成 3 个 APK：
```bash
./gradlew assembleRelease
# 输出:
# - app-arm64-v8a-release.apk      (64位 ARM)
# - app-armeabi-v7a-release.apk    (32位 ARM)
# - app-universal-release.apk      (通用版本)
```

### 签名配置
Release 签名通过环境变量配置：
- `RELEASE_KEYSTORE_PATH`: 密钥库路径
- `RELEASE_KEYSTORE_PASSWORD`: 密钥库密码
- `RELEASE_KEY_ALIAS`: 密钥别名
- `RELEASE_KEY_PASSWORD`: 密钥密码

### NDK 架构
项目仅支持 ARM 架构（语音 SDK 限制）：
- arm64-v8a (64位)
- armeabi-v7a (32位)

## 测试

- 单元测试: `app/src/test/java/`
- 仪器测试: `app/src/androidTest/java/`
- 测试框架: JUnit 4 + Espresso + Compose UI Test

## 重要注意事项

### 权限要求
应用需要以下运行时权限 (在 MainActivity 中请求):
- `RECORD_AUDIO`: 录音功能
- `READ_PHONE_STATE`: AIKit SDK 授权需要 (获取设备 IMEI)

### 语音唤醒 SDK
- SDK 文件位置: `app/libs/` (AIKit AAR 和 SO 库)
- 需要授权文件: `aikit_auth.dat` (放在 assets/ 目录)
- 唤醒词配置: 在设置页面中修改 (默认: "你好天天")
- SDK 日志: 输出到应用私有目录 `files/wakeup/logs/`

### WebSocket 通信协议
- **连接**: 发送 `initialize` → 服务器返回 `server_ready`
- **开始监听**: 发送 `listen_start`
- **音频传输**: 发送 Opus 编码的二进制数据
- **结束监听**: 发送 `listen_stop` + `audio_end`
- **文本消息**: 发送 JSON `{type: "text_message", text: "..."}`
- **中止**: 发送 `abort`

服务器消息类型:
- `stt_result`: 语音识别结果
- `llm_response`: LLM 流式响应
- `tts_state`: TTS 播放状态 (true/false)
- `emotion`: 情感表情 (emoji)
- `tts_sentence`: TTS 句子
- 二进制消息: AI 回复的音频数据 (Opus 编码)

### 开发调试技巧
1. **查看 Hilt 生成的代码**: `app/build/generated/source/kapt/debug/`
2. **调试 WebSocket**: 在 `WebSocketManager.kt` 中添加日志
3. **调试唤醒**: 检查 `files/wakeup/logs/` 目录下的日志
4. **调试 VAD**: 在 `VoiceAssistantViewModel.kt` 的 `checkVad()` 中添加日志
5. **测试不同架构**: 使用 `--include arm64-v8a` 或 `--include armeabi-v7a` 过滤 APK

/// 应用统一配置管理
/// 
/// 所有配置项按功能模块分组存放，代码中统一从此处读取
/// 支持配置页面动态修改，减少运行时判断，提升性能
class AppConfig {
  // ==================== UI 配置 ====================
  static const UI ui = UI();
  
  // ==================== 动画配置 ====================
  static const Animation animation = Animation();
  
  // ==================== 性能配置 ====================
  static const Performance performance = Performance();
  
  // ==================== 网络配置 ====================
  static const Network network = Network();
  
  // ==================== 音频配置 ====================
  static const Audio audio = Audio();
  
  // ==================== 调试配置 ====================
  static const Debug debug = Debug();
}

/// UI相关配置
class UI {
  const UI();
  
  // 悬浮聊天窗口配置
  static const FloatingChat floatingChat = FloatingChat();
  
  // 主题配置
  static const Theme theme = Theme();
  
  // 输入组件配置
  static const Input input = Input();
}

/// 悬浮聊天窗口配置
class FloatingChat {
  const FloatingChat();
  
  /// 收缩状态尺寸
  static const double collapsedSize = 80.0;
  
  /// 收缩状态字体大小
  static const double collapsedFontSize = 40.0; // collapsedSize * 0.5
  
  /// 展开状态宽度比例
  static const double expandedWidthRatio = 0.9;
  
  /// 展开状态高度比例  
  static const double expandedHeightRatio = 0.7;
  
  /// 是否启用背景模糊
  static const bool enableBackgroundBlur = false;
  
  /// 虚拟人物区域字体大小
  static const double characterFontSize = 64.0;
  
  /// 边距设置
  static const double positionMarginX = 20.0;
  static const double positionMarginY = 100.0;
  
  /// 安全边距
  static const double safeMargin = 20.0;
}

/// 动画配置
class Animation {
  const Animation();
  
  /// 悬浮窗动画时长
  static const int floatingChatDurationMs = 200;
  
  /// 页面切换动画时长
  static const int pageTransitionDurationMs = 0; // 0表示无动画
  
  /// 滚动动画时长
  static const int scrollDurationMs = 300;
  
  /// 是否启用Material动画
  static const bool enableMaterialAnimations = false;
  
  /// 是否启用波纹效果
  static const bool enableRippleEffect = false;
}

/// 主题配置
class Theme {
  const Theme();
  
  /// 是否使用Material3
  static const bool useMaterial3 = false;
  
  /// 是否启用阴影效果
  static const bool enableShadows = true;
  
  /// 是否启用高亮效果
  static const bool enableHighlight = false;
  
  /// 是否启用飞溅效果
  static const bool enableSplash = false;
}

/// 输入组件配置
class Input {
  const Input();
  
  /// 输入框圆角半径
  static const double borderRadius = 24.0;
  
  /// 紧凑模式圆角半径
  static const double compactBorderRadius = 20.0;
  
  /// 边框宽度
  static const double borderWidth = 1.5;
  
  /// 内边距
  static const double padding = 12.0;
  
  /// 紧凑模式内边距
  static const double compactPadding = 10.0;
}

/// 性能配置
class Performance {
  const Performance();
  
  /// 是否启用性能监控
  static const bool enableMonitoring = false;
  
  /// 最大并发音频处理数
  static const int maxConcurrentAudio = 1;
  
  /// 图像质量 (0.0-1.0)
  static const double imageQuality = 0.7;
  
  /// 内存缓存限制 (MB)
  static const int memoryCacheLimitMB = 50;
  
  /// 磁盘缓存限制 (MB)
  static const int diskCacheLimitMB = 100;
}

/// 网络配置
class Network {
  const Network();
  
  /// WebSocket连接超时 (秒)
  static const int connectionTimeoutSec = 10;
  
  /// 重连间隔 (秒)
  static const int reconnectIntervalSec = 5;
  
  /// 最大重连次数
  static const int maxRetryCount = 3;
  
  /// 心跳间隔 (秒)
  static const int heartbeatIntervalSec = 30;
}

/// 音频配置
class Audio {
  const Audio();
  
  /// 采样率
  static const int sampleRate = 16000;
  
  /// 声道数
  static const int channels = 1;
  
  /// 帧时长 (毫秒)
  static const int frameDurationMs = 60;
  
  /// 音频格式
  static const String format = 'opus';
  
  /// STT处理超时 (秒)
  static const int sttTimeoutSec = 5;
}

/// 调试配置
class Debug {
  const Debug();
  
  /// 是否启用调试日志
  static const bool enableLogging = false;
  
  /// 是否启用网络日志
  static const bool enableNetworkLogging = false;
  
  /// 是否启用音频日志
  static const bool enableAudioLogging = false;
  
  /// 是否启用UI日志
  static const bool enableUILogging = false;
  
  /// 是否显示调试信息
  static const bool showDebugInfo = false;
}

/// 配置工具类
class ConfigUtils {
  /// 获取优化后的动画时长
  static Duration getAnimationDuration(int milliseconds) {
    return Duration(milliseconds: milliseconds);
  }
  
  /// 获取设备相关的尺寸
  static double getDeviceAdjustedSize(double baseSize, double screenWidth) {
    // 根据屏幕宽度动态调整，但保持基础值作为参考
    if (screenWidth < 400) return baseSize * 0.8;
    if (screenWidth > 800) return baseSize * 1.2;
    return baseSize;
  }
  
  /// 检查是否启用某个功能
  static bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'ripple':
        return Animation.enableRippleEffect;
      case 'shadows':
        return Theme.enableShadows;
      case 'blur':
        return FloatingChat.enableBackgroundBlur;
      case 'debug':
        return Debug.enableLogging;
      default:
        return false;
    }
  }
}
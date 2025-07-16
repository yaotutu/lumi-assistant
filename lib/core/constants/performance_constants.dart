/// 简化的性能配置
class PerformanceConstants {
  /// 关闭所有调试日志
  static const bool enableDebugLogging = false;
  
  /// 关闭Material波纹效果
  static const bool enableRippleEffect = false;
  
  /// 关闭性能监控
  static const bool enablePerformanceMonitoring = false;
}

/// 简化的日志工具
class PerformanceLogger {
  /// 统一日志输出
  static void log(String message) {
    if (PerformanceConstants.enableDebugLogging) {
      print(message);
    }
  }
}
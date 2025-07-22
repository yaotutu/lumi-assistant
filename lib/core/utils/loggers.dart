import 'package:logging/logging.dart';
import 'app_logger.dart';

/// 模块专用Logger集合
/// 
/// 为项目中的各个模块提供预配置的Logger实例
/// 使用统一的命名规范和配置
class Loggers {
  // 私有构造函数，防止实例化
  Loggers._();
  
  /// WebSocket通信日志
  static final Logger websocket = AppLogger.getLogger(LoggerModule.websocket);
  
  /// MCP服务器通信日志
  static final Logger mcp = AppLogger.getLogger(LoggerModule.mcp);
  
  /// 音频处理日志
  static final Logger audio = AppLogger.getLogger(LoggerModule.audio);
  
  /// 聊天功能日志
  static final Logger chat = AppLogger.getLogger(LoggerModule.chat);
  
  /// UI界面日志
  static final Logger ui = AppLogger.getLogger(LoggerModule.ui);
  
  /// 设置管理日志
  static final Logger settings = AppLogger.getLogger(LoggerModule.settings);
  
  /// 错误处理日志
  static final Logger error = AppLogger.getLogger(LoggerModule.error);
  
  /// 系统级日志
  static final Logger system = AppLogger.getLogger(LoggerModule.system);
  
  /// 获取所有可用的Logger
  static List<Logger> getAllLoggers() {
    return [
      websocket,
      mcp,
      audio,
      chat,
      ui,
      settings,
      error,
      system,
    ];
  }
  
  /// 获取Logger名称映射
  static Map<String, Logger> getLoggerMap() {
    return {
      LoggerModule.websocket: websocket,
      LoggerModule.mcp: mcp,
      LoggerModule.audio: audio,
      LoggerModule.chat: chat,
      LoggerModule.ui: ui,
      LoggerModule.settings: settings,
      LoggerModule.error: error,
      LoggerModule.system: system,
    };
  }
}

/// Logger扩展方法
extension LoggerExtensions on Logger {
  /// 记录方法进入
  void entering(String methodName, [Object? params]) {
    fine('→ $methodName${params != null ? '($params)' : '()'}');
  }
  
  /// 记录方法退出
  void exiting(String methodName, [Object? result]) {
    fine('← $methodName${result != null ? ' → $result' : ''}');
  }
  
  /// 记录性能指标
  void performance(String operation, Duration duration, [Map<String, Object>? metrics]) {
    final message = '$operation completed in ${duration.inMilliseconds}ms';
    if (metrics != null && metrics.isNotEmpty) {
      final metricsStr = metrics.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      fine('⚡ $message ($metricsStr)');
    } else {
      fine('⚡ $message');
    }
  }
  
  /// 记录网络请求
  void network(String method, String url, {int? statusCode, Duration? duration}) {
    final parts = <String>[method.toUpperCase(), url];
    if (statusCode != null) parts.add('Status: $statusCode');
    if (duration != null) parts.add('${duration.inMilliseconds}ms');
    info('🌐 ${parts.join(' | ')}');
  }
  
  /// 记录用户操作
  void userAction(String action, [Map<String, Object>? context]) {
    final message = '👤 用户操作: $action';
    if (context != null && context.isNotEmpty) {
      final contextStr = context.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      info('$message ($contextStr)');
    } else {
      info(message);
    }
  }
  
  /// 记录状态变化
  void stateChange(String from, String to, [String? reason]) {
    final message = '🔄 状态变化: $from → $to';
    if (reason != null) {
      info('$message (原因: $reason)');
    } else {
      info(message);
    }
  }
  
  /// 记录错误但不抛出异常
  void errorNonFatal(String message, [Object? error, StackTrace? stackTrace]) {
    severe('💥 非致命错误: $message', error, stackTrace);
  }
  
  /// 记录警告
  void warn(String message, [Object? context]) {
    if (context != null) {
      warning('⚠️ $message (上下文: $context)');
    } else {
      warning('⚠️ $message');
    }
  }
  
  /// 记录成功操作
  void success(String message, [Duration? duration]) {
    if (duration != null) {
      info('✅ $message (耗时: ${duration.inMilliseconds}ms)');
    } else {
      info('✅ $message');
    }
  }
}
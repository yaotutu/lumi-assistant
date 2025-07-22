import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// 应用日志管理器
/// 
/// 基于官方logging包的统一日志系统，支持：
/// - 分等级日志输出
/// - 模块化日志管理
/// - 环境感知配置
/// - 运行时动态调整
class AppLogger {
  static bool _initialized = false;
  static final Map<String, Logger> _loggers = {};
  
  /// 全局日志等级
  static Level _globalLevel = Level.INFO;
  
  /// 模块日志等级配置
  static final Map<String, Level> _moduleConfig = {};
  
  /// 初始化日志系统
  static void initialize({
    Level? globalLevel,
    Map<String, Level>? moduleConfig,
  }) {
    if (_initialized) return;
    
    // 启用分层日志记录 - 这是必需的！
    hierarchicalLoggingEnabled = true;
    
    // 设置全局配置
    _globalLevel = globalLevel ?? _getDefaultLevel();
    if (moduleConfig != null) {
      _moduleConfig.addAll(moduleConfig);
    }
    
    // 配置根日志记录器
    Logger.root.level = Level.ALL; // 允许所有等级通过，由我们的逻辑控制
    Logger.root.onRecord.listen(_handleLogRecord);
    
    _initialized = true;
    
    // 输出初始化信息 - 延迟到最后，确保系统已完全初始化
    final systemLogger = getLogger('System');
    systemLogger.info('日志系统已初始化');
    systemLogger.info('全局等级: ${_globalLevel.name}');
    systemLogger.info('运行模式: ${_getEnvironmentInfo()}');
  }
  
  /// 获取指定模块的Logger
  static Logger getLogger(String module) {
    if (!_initialized) {
      initialize(); // 自动初始化
    }
    
    return _loggers.putIfAbsent(module, () {
      final logger = Logger(module);
      // 只有在分层日志已启用时才设置模块特定的日志等级
      if (hierarchicalLoggingEnabled) {
        final moduleLevel = _moduleConfig[module] ?? _globalLevel;
        logger.level = moduleLevel;
      }
      return logger;
    });
  }
  
  /// 设置全局日志等级
  static void setGlobalLevel(Level level) {
    _globalLevel = level;
    // 更新所有没有特定配置的Logger
    for (final entry in _loggers.entries) {
      if (!_moduleConfig.containsKey(entry.key)) {
        entry.value.level = level;
      }
    }
  }
  
  /// 设置模块日志等级
  static void setModuleLevel(String module, Level level) {
    _moduleConfig[module] = level;
    _loggers[module]?.level = level;
  }
  
  /// 禁用模块日志
  static void disableModule(String module) {
    setModuleLevel(module, Level.OFF);
  }
  
  /// 启用模块日志
  static void enableModule(String module, [Level? level]) {
    setModuleLevel(module, level ?? _globalLevel);
  }
  
  /// 获取当前配置信息
  static Map<String, dynamic> getConfig() {
    return {
      'globalLevel': _globalLevel.name,
      'moduleConfig': _moduleConfig.map((k, v) => MapEntry(k, v.name)),
      'activeLoggers': _loggers.keys.toList(),
      'environment': _getEnvironmentInfo(),
    };
  }
  
  /// 处理日志记录
  static void _handleLogRecord(LogRecord record) {
    // 检查是否应该输出此日志
    if (!_shouldLog(record)) return;
    
    // 格式化日志消息
    final formatted = _formatLogMessage(record);
    
    // 输出日志
    _outputLog(record, formatted);
  }
  
  /// 判断是否应该输出日志
  static bool _shouldLog(LogRecord record) {
    // 检查全局等级
    if (record.level.value < _globalLevel.value) return false;
    
    // 检查模块特定等级
    final moduleName = record.loggerName;
    final moduleLevel = _moduleConfig[moduleName];
    if (moduleLevel != null && record.level.value < moduleLevel.value) {
      return false;
    }
    
    return true;
  }
  
  /// 格式化日志消息
  static String _formatLogMessage(LogRecord record) {
    final timestamp = _formatTimestamp(record.time);
    final level = _formatLevel(record.level);
    final module = _formatModule(record.loggerName);
    final message = record.message;
    
    var formatted = '$timestamp $level $module $message';
    
    // 添加错误信息
    if (record.error != null) {
      formatted += '\n  错误: ${record.error}';
    }
    
    // 添加堆栈跟踪（仅对严重错误）
    if (record.stackTrace != null && record.level >= Level.SEVERE) {
      final stackTrace = record.stackTrace.toString();
      final lines = stackTrace.split('\n').take(5); // 只显示前5行
      formatted += '\n  堆栈: ${lines.join('\n    ')}';
    }
    
    return formatted;
  }
  
  /// 格式化时间戳
  static String _formatTimestamp(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}.'
           '${time.millisecond.toString().padLeft(3, '0')}';
  }
  
  /// 格式化日志等级
  static String _formatLevel(Level level) {
    final name = level.name;
    switch (level) {
      case Level.FINE:
        return '🔍 $name'.padRight(8);
      case Level.INFO:
        return 'ℹ️  $name'.padRight(8);
      case Level.WARNING:
        return '⚠️  $name'.padRight(8);
      case Level.SEVERE:
        return '❌ $name'.padRight(8);
      default:
        return name.padRight(8);
    }
  }
  
  /// 格式化模块名
  static String _formatModule(String module) {
    return '[$module]'.padRight(12);
  }
  
  /// 输出日志
  static void _outputLog(LogRecord record, String formatted) {
    // 根据日志等级选择输出方式
    if (record.level >= Level.SEVERE) {
      // 错误日志输出到stderr
      if (kDebugMode || Platform.environment.containsKey('FLUTTER_TEST')) {
        // ignore: avoid_print
        print(formatted); // 在调试模式下仍使用print以便IDE显示
      } else {
        stderr.writeln(formatted);
      }
    } else {
      // 普通日志输出到stdout
      // ignore: avoid_print
      print(formatted);
    }
  }
  
  /// 获取默认日志等级
  static Level _getDefaultLevel() {
    if (kDebugMode) {
      return Level.FINE; // 调试模式显示所有日志
    } else if (kProfileMode) {
      return Level.INFO; // Profile模式显示信息级别以上
    } else {
      return Level.WARNING; // 发布模式只显示警告和错误
    }
  }
  
  /// 获取环境信息
  static String _getEnvironmentInfo() {
    if (kDebugMode) return 'Debug';
    if (kProfileMode) return 'Profile';
    if (kReleaseMode) return 'Release';
    return 'Unknown';
  }
}

/// 预定义的模块Logger常量
class LoggerModule {
  static const String websocket = 'WebSocket';
  static const String mcp = 'MCP';
  static const String audio = 'Audio';
  static const String chat = 'Chat';
  static const String ui = 'UI';
  static const String settings = 'Settings';
  static const String error = 'Error';
  static const String system = 'System';
}

/// 便捷的Logger获取器
extension LoggerExtension on String {
  Logger get logger => AppLogger.getLogger(this);
}
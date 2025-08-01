import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

import '../utils/app_logger.dart';
import 'background_config.dart';
import 'wallpaper_config.dart';

/// 应用设置管理
/// 
/// 双层架构：
/// 1. 静态默认值（性能优化，写死在代码中）
/// 2. 用户动态设置（可在设置页面修改，覆盖默认值）
class AppSettings extends ChangeNotifier {
  // ==================== 单例模式 ====================
  static AppSettings? _instance;
  
  AppSettings._internal();
  
  static AppSettings get instance {
    _instance ??= AppSettings._internal();
    return _instance!;
  }
  
  // ==================== 静态默认配置 ====================
  // 这些是写死的默认值，保证性能，减少运行时判断
  
  /// UI默认配置
  static const _defaultFloatingChatSize = 80.0;
  static const _defaultFloatingChatWidthRatio = 0.9;
  static const _defaultFloatingChatHeightRatio = 0.7;
  static const _defaultFontScale = 1.0;
  static const _defaultAnimationDuration = 200;
  static const _defaultTopBarDistance = 0.0; // 顶部操作栏距离状态栏的额外距离，默认紧贴状态栏下方
  
  /// 网络默认配置
  static const _defaultServerUrl = 'ws://YOUR_SERVER_IP:8000';
  static const _defaultApiUrl = 'http://YOUR_SERVER_IP:8000/api';
  static const _defaultConnectionTimeout = 10;
  
  /// Gotify 默认配置
  static const _defaultGotifyServerUrl = '';
  static const _defaultGotifyClientToken = '';
  
  
  /// 背景默认配置
  static final _defaultBackgroundConfig = BackgroundConfig();
  
  /// 壁纸默认配置 - 使用内置壁纸，默认为动态星空
  static const _defaultWallpaperMode = WallpaperMode.builtinWallpaper;
  static const _defaultBuiltinWallpaperType = BuiltinWallpaperType.animatedStarfield;
  static const String? _defaultCustomWallpaperPath = null;
  static const _defaultEnableWallpaperOverlay = false; // 默认不启用遮罩，保持图片清晰
  
  /// 天气默认配置
  static const _defaultWeatherEnabled = true;
  static const _defaultWeatherServiceType = 'mock'; // 默认使用模拟数据
  static const _defaultWeatherLocation = '101010100'; // 北京的城市ID
  static const _defaultWeatherUpdateInterval = 30; // 分钟
  static const _defaultQweatherApiKey = '';
  static const _defaultOpenweatherApiKey = '';
  
  // ==================== 用户动态设置 ====================
  // 用户可以在设置页面修改这些值，如果为null则使用默认值
  
  double? _userFloatingChatSize;
  double? _userFloatingChatWidthRatio;
  double? _userFloatingChatHeightRatio;
  double? _userFontScale;
  int? _userAnimationDuration;
  double? _userTopBarDistance; // 用户设置的顶部操作栏距离
  
  String? _userServerUrl;
  String? _userApiUrl;
  int? _userConnectionTimeout;
  
  String? _userGotifyServerUrl;
  String? _userGotifyClientToken;
  
  
  BackgroundConfig? _userBackgroundConfig;
  
  /// 壁纸用户设置
  WallpaperMode? _userWallpaperMode;
  BuiltinWallpaperType? _userBuiltinWallpaperType;
  String? _userCustomWallpaperPath;
  bool? _userEnableWallpaperOverlay;
  
  /// 天气用户设置
  bool? _userWeatherEnabled;
  String? _userWeatherServiceType;
  String? _userWeatherLocation;
  int? _userWeatherUpdateInterval;
  String? _userQweatherApiKey;
  String? _userOpenweatherApiKey;
  
  // ==================== 日志设置 ====================
  
  /// 日志等级配置
  String? _userLogLevel; // 全局日志等级
  
  /// 模块日志开关
  bool _debugEnableWebSocketLogging = true;
  bool _debugEnableMcpLogging = true;
  bool _debugEnableAudioLogging = true;
  bool _debugEnableChatLogging = true;
  bool _debugEnableUILogging = false;
  bool _debugEnableSettingsLogging = false;
  bool _debugEnableErrorLogging = true;
  bool _debugEnableSystemLogging = true;
  
  /// 日志详细程度
  bool _debugEnableVerboseLogging = false;  // 是否启用FINE级别日志
  bool _debugEnablePerformanceLogging = false;  // 是否启用性能日志
  
  // ==================== 公共接口 ====================
  // 这些getter会自动选择用户设置或默认值
  
  /// UI设置
  double get floatingChatSize => _userFloatingChatSize ?? _defaultFloatingChatSize;
  double get floatingChatWidthRatio => _userFloatingChatWidthRatio ?? _defaultFloatingChatWidthRatio;
  double get floatingChatHeightRatio => _userFloatingChatHeightRatio ?? _defaultFloatingChatHeightRatio;
  double get fontScale => _userFontScale ?? _defaultFontScale;
  int get animationDuration => _userAnimationDuration ?? _defaultAnimationDuration;
  double get topBarDistance => _userTopBarDistance ?? _defaultTopBarDistance;
  
  // 计算属性
  double get floatingChatCollapsedFontSize => floatingChatSize * 0.5;
  double get floatingChatCharacterFontSize => 64.0 * fontScale;
  Duration get animationDurationMs => Duration(milliseconds: animationDuration);
  
  /// 网络设置
  String get serverUrl => _userServerUrl ?? _defaultServerUrl;
  String get apiUrl => _userApiUrl ?? _defaultApiUrl;
  int get connectionTimeout => _userConnectionTimeout ?? _defaultConnectionTimeout;
  
  /// Gotify 设置
  String get gotifyServerUrl => _userGotifyServerUrl ?? _defaultGotifyServerUrl;
  String get gotifyClientToken => _userGotifyClientToken ?? _defaultGotifyClientToken;
  
  
  /// 背景设置
  BackgroundConfig get backgroundConfig => _userBackgroundConfig ?? _defaultBackgroundConfig;
  
  /// 壁纸设置
  WallpaperMode get wallpaperMode => _userWallpaperMode ?? _defaultWallpaperMode;
  BuiltinWallpaperType get builtinWallpaperType => _userBuiltinWallpaperType ?? _defaultBuiltinWallpaperType;
  String? get customWallpaperPath => _userCustomWallpaperPath ?? _defaultCustomWallpaperPath;
  bool get enableWallpaperOverlay => _userEnableWallpaperOverlay ?? _defaultEnableWallpaperOverlay;
  
  /// 天气设置
  bool get weatherEnabled => _userWeatherEnabled ?? _defaultWeatherEnabled;
  String get weatherServiceType => _userWeatherServiceType ?? _defaultWeatherServiceType;
  String get weatherLocation => _userWeatherLocation ?? _defaultWeatherLocation;
  int get weatherUpdateInterval => _userWeatherUpdateInterval ?? _defaultWeatherUpdateInterval;
  String get qweatherApiKey => _userQweatherApiKey ?? _defaultQweatherApiKey;
  String get openweatherApiKey => _userOpenweatherApiKey ?? _defaultOpenweatherApiKey;
  
  /// 日志设置
  Level get logLevel {
    if (_userLogLevel == null) {
      // 根据构建模式设置默认等级
      if (kDebugMode) return Level.FINE;
      if (kProfileMode) return Level.INFO;
      return Level.WARNING;
    }
    return Level.LEVELS.firstWhere(
      (level) => level.name == _userLogLevel,
      orElse: () => Level.INFO,
    );
  }
  
  bool get debugEnableVerboseLogging => _debugEnableVerboseLogging;
  bool get debugEnablePerformanceLogging => _debugEnablePerformanceLogging;
  
  /// 模块日志开关
  bool get debugEnableWebSocketLogging => _debugEnableWebSocketLogging;
  bool get debugEnableMcpLogging => _debugEnableMcpLogging;
  bool get debugEnableAudioLogging => _debugEnableAudioLogging;
  bool get debugEnableChatLogging => _debugEnableChatLogging;
  bool get debugEnableUILogging => _debugEnableUILogging;
  bool get debugEnableSettingsLogging => _debugEnableSettingsLogging;
  bool get debugEnableErrorLogging => _debugEnableErrorLogging;
  bool get debugEnableSystemLogging => _debugEnableSystemLogging;
  
  // ==================== 用户设置修改接口 ====================
  
  /// 更新UI设置
  Future<void> updateFloatingChatSize(double value) async {
    _userFloatingChatSize = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateFloatingChatWidthRatio(double value) async {
    _userFloatingChatWidthRatio = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateFloatingChatHeightRatio(double value) async {
    _userFloatingChatHeightRatio = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateFontScale(double value) async {
    _userFontScale = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateAnimationDuration(int value) async {
    _userAnimationDuration = value;
    notifyListeners();
    await _saveSettings();
  }

  /// 更新顶部操作栏距离
  Future<void> updateTopBarDistance(double value) async {
    _userTopBarDistance = value;
    notifyListeners();
    await _saveSettings();
  }
  
  /// 更新网络设置
  Future<void> updateServerUrl(String value) async {
    _userServerUrl = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateApiUrl(String value) async {
    _userApiUrl = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateConnectionTimeout(int value) async {
    _userConnectionTimeout = value;
    notifyListeners();
    await _saveSettings();
  }
  
  /// 更新 Gotify 设置
  Future<void> updateGotifyServerUrl(String value) async {
    _userGotifyServerUrl = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateGotifyClientToken(String value) async {
    _userGotifyClientToken = value;
    notifyListeners();
    await _saveSettings();
  }
  

  /// 更新背景设置
  Future<void> updateBackgroundConfig(BackgroundConfig config) async {
    _userBackgroundConfig = config;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> resetBackgroundConfig() async {
    _userBackgroundConfig = null;
    notifyListeners();
    await _saveSettings();
  }
  
  /// 更新壁纸设置
  Future<void> updateWallpaperMode(WallpaperMode mode) async {
    _userWallpaperMode = mode;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateBuiltinWallpaperType(BuiltinWallpaperType type) async {
    _userBuiltinWallpaperType = type;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateCustomWallpaperPath(String? path) async {
    _userCustomWallpaperPath = path;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateEnableWallpaperOverlay(bool enable) async {
    _userEnableWallpaperOverlay = enable;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> resetWallpaperSettings() async {
    _userWallpaperMode = null;
    _userBuiltinWallpaperType = null;
    _userCustomWallpaperPath = null;
    _userEnableWallpaperOverlay = null;
    notifyListeners();
    await _saveSettings();
  }
  
  /// 更新天气设置
  Future<void> updateWeatherEnabled(bool value) async {
    _userWeatherEnabled = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateWeatherServiceType(String value) async {
    _userWeatherServiceType = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateWeatherLocation(String value) async {
    _userWeatherLocation = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateWeatherUpdateInterval(int value) async {
    _userWeatherUpdateInterval = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateQweatherApiKey(String value) async {
    _userQweatherApiKey = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateOpenweatherApiKey(String value) async {
    _userOpenweatherApiKey = value;
    notifyListeners();
    await _saveSettings();
  }

  /// 更新日志设置
  Future<void> updateLogLevel(Level level) async {
    _userLogLevel = level.name;
    notifyListeners();
    await _saveSettings();
    // 立即应用新的日志等级
    AppLogger.setGlobalLevel(level);
  }

  Future<void> updateDebugEnableVerboseLogging(bool value) async {
    _debugEnableVerboseLogging = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateDebugEnablePerformanceLogging(bool value) async {
    _debugEnablePerformanceLogging = value;
    notifyListeners();
    await _saveSettings();
  }

  /// 模块日志开关更新方法
  Future<void> updateDebugEnableWebSocketLogging(bool value) async {
    _debugEnableWebSocketLogging = value;
    notifyListeners();
    await _saveSettings();
    _applyModuleLogLevel(LoggerModule.websocket, value);
  }

  Future<void> updateDebugEnableMcpLogging(bool value) async {
    _debugEnableMcpLogging = value;
    notifyListeners();
    await _saveSettings();
    _applyModuleLogLevel(LoggerModule.mcp, value);
  }

  Future<void> updateDebugEnableAudioLogging(bool value) async {
    _debugEnableAudioLogging = value;
    notifyListeners();
    await _saveSettings();
    _applyModuleLogLevel(LoggerModule.audio, value);
  }

  Future<void> updateDebugEnableChatLogging(bool value) async {
    _debugEnableChatLogging = value;
    notifyListeners();
    await _saveSettings();
    _applyModuleLogLevel(LoggerModule.chat, value);
  }

  Future<void> updateDebugEnableUILogging(bool value) async {
    _debugEnableUILogging = value;
    notifyListeners();
    await _saveSettings();
    _applyModuleLogLevel(LoggerModule.ui, value);
  }

  Future<void> updateDebugEnableSettingsLogging(bool value) async {
    _debugEnableSettingsLogging = value;
    notifyListeners();
    await _saveSettings();
    _applyModuleLogLevel(LoggerModule.settings, value);
  }

  Future<void> updateDebugEnableErrorLogging(bool value) async {
    _debugEnableErrorLogging = value;
    notifyListeners();
    await _saveSettings();
    _applyModuleLogLevel(LoggerModule.error, value);
  }

  Future<void> updateDebugEnableSystemLogging(bool value) async {
    _debugEnableSystemLogging = value;
    notifyListeners();
    await _saveSettings();
    _applyModuleLogLevel(LoggerModule.system, value);
  }

  /// 应用模块日志等级
  void _applyModuleLogLevel(String module, bool enabled) {
    if (enabled) {
      AppLogger.enableModule(module);
    } else {
      AppLogger.disableModule(module);
    }
  }

  /// 获取模块日志配置映射
  Map<String, Level> getModuleLogConfig() {
    final config = <String, Level>{};
    
    if (!_debugEnableWebSocketLogging) config[LoggerModule.websocket] = Level.OFF;
    if (!_debugEnableMcpLogging) config[LoggerModule.mcp] = Level.OFF;
    if (!_debugEnableAudioLogging) config[LoggerModule.audio] = Level.OFF;
    if (!_debugEnableChatLogging) config[LoggerModule.chat] = Level.OFF;
    if (!_debugEnableUILogging) config[LoggerModule.ui] = Level.OFF;
    if (!_debugEnableSettingsLogging) config[LoggerModule.settings] = Level.OFF;
    if (!_debugEnableErrorLogging) config[LoggerModule.error] = Level.OFF;
    if (!_debugEnableSystemLogging) config[LoggerModule.system] = Level.OFF;
    
    return config;
  }
  
  // ==================== 工具方法 ====================
  
  /// 检查是否为默认值（用于设置页面显示）
  bool isDefaultFloatingChatSize() => _userFloatingChatSize == null;
  bool isDefaultServerUrl() => _userServerUrl == null;
  bool isDefaultFontScale() => _userFontScale == null;
  bool isDefaultTopBarDistance() => _userTopBarDistance == null;
  
  /// 重置单个设置为默认值
  Future<void> resetFloatingChatSize() async {
    _userFloatingChatSize = null;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> resetServerUrl() async {
    _userServerUrl = null;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> resetFontScale() async {
    _userFontScale = null;
    notifyListeners();
    await _saveSettings();
  }

  /// 重置顶部操作栏距离
  Future<void> resetTopBarDistance() async {
    _userTopBarDistance = null;
    notifyListeners();
    await _saveSettings();
  }
  
  /// 重置所有设置为默认值
  Future<void> resetAllSettings() async {
    _userFloatingChatSize = null;
    _userFloatingChatWidthRatio = null;
    _userFloatingChatHeightRatio = null;
    _userFontScale = null;
    _userAnimationDuration = null;
    _userTopBarDistance = null;
    
    _userServerUrl = null;
    _userApiUrl = null;
    _userConnectionTimeout = null;
    
    
    _userBackgroundConfig = null;
    _userWallpaperMode = null;
    _userBuiltinWallpaperType = null;
    _userCustomWallpaperPath = null;
    _userEnableWallpaperOverlay = null;
    
    _userWeatherEnabled = null;
    _userWeatherServiceType = null;
    _userWeatherLocation = null;
    _userWeatherUpdateInterval = null;
    _userQweatherApiKey = null;
    _userOpenweatherApiKey = null;
    
    _userLogLevel = null;
    _debugEnableVerboseLogging = false;
    _debugEnablePerformanceLogging = false;
    _debugEnableWebSocketLogging = true;
    _debugEnableMcpLogging = true;
    _debugEnableAudioLogging = true;
    _debugEnableChatLogging = true;
    _debugEnableUILogging = false;
    _debugEnableSettingsLogging = false;
    _debugEnableErrorLogging = true;
    _debugEnableSystemLogging = true;
    
    notifyListeners();
    await _saveSettings();
  }
  
  // ==================== 持久化存储 ====================
  
  /// 从本地存储加载用户设置
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // UI设置
    _userFloatingChatSize = prefs.getDouble('user_floating_chat_size');
    _userFloatingChatWidthRatio = prefs.getDouble('user_floating_chat_width_ratio');
    _userFloatingChatHeightRatio = prefs.getDouble('user_floating_chat_height_ratio');
    _userFontScale = prefs.getDouble('user_font_scale');
    _userAnimationDuration = prefs.getInt('user_animation_duration');
    _userTopBarDistance = prefs.getDouble('user_top_bar_distance');
    
    // 网络设置
    _userServerUrl = prefs.getString('user_server_url');
    _userApiUrl = prefs.getString('user_api_url');
    _userConnectionTimeout = prefs.getInt('user_connection_timeout');
    
    // Gotify 设置
    _userGotifyServerUrl = prefs.getString('user_gotify_server_url');
    _userGotifyClientToken = prefs.getString('user_gotify_client_token');
    
    
    // 背景设置
    final backgroundConfigJson = prefs.getString('user_background_config');
    if (backgroundConfigJson != null) {
      try {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          jsonDecode(backgroundConfigJson) as Map
        );
        _userBackgroundConfig = BackgroundConfig.fromJson(json);
      } catch (e) {
        // 如果解析失败，使用默认配置
        _userBackgroundConfig = null;
      }
    }
    
    // 壁纸设置
    final wallpaperModeString = prefs.getString('user_wallpaper_mode');
    if (wallpaperModeString != null) {
      try {
        _userWallpaperMode = WallpaperMode.values.firstWhere(
          (mode) => mode.name == wallpaperModeString,
        );
      } catch (e) {
        // 如果解析失败，使用默认模式
        _userWallpaperMode = null;
      }
    }
    
    final builtinWallpaperTypeString = prefs.getString('user_builtin_wallpaper_type');
    if (builtinWallpaperTypeString != null) {
      try {
        _userBuiltinWallpaperType = BuiltinWallpaperType.values.firstWhere(
          (type) => type.name == builtinWallpaperTypeString,
        );
      } catch (e) {
        // 如果解析失败，使用默认类型
        _userBuiltinWallpaperType = null;
      }
    }
    
    _userCustomWallpaperPath = prefs.getString('user_custom_wallpaper_path');
    _userEnableWallpaperOverlay = prefs.getBool('user_enable_wallpaper_overlay');
    
    // 天气设置
    _userWeatherEnabled = prefs.getBool('user_weather_enabled');
    _userWeatherServiceType = prefs.getString('user_weather_service_type');
    _userWeatherLocation = prefs.getString('user_weather_location');
    _userWeatherUpdateInterval = prefs.getInt('user_weather_update_interval');
    _userQweatherApiKey = prefs.getString('user_qweather_api_key');
    _userOpenweatherApiKey = prefs.getString('user_openweather_api_key');
    
    // 日志设置
    _userLogLevel = prefs.getString('user_log_level');
    _debugEnableVerboseLogging = prefs.getBool('debug_enable_verbose_logging') ?? false;
    _debugEnablePerformanceLogging = prefs.getBool('debug_enable_performance_logging') ?? false;
    
    // 模块日志开关
    _debugEnableWebSocketLogging = prefs.getBool('debug_enable_websocket_logging') ?? true;
    _debugEnableMcpLogging = prefs.getBool('debug_enable_mcp_logging') ?? true;
    _debugEnableAudioLogging = prefs.getBool('debug_enable_audio_logging') ?? true;
    _debugEnableChatLogging = prefs.getBool('debug_enable_chat_logging') ?? true;
    _debugEnableUILogging = prefs.getBool('debug_enable_ui_logging') ?? false;
    _debugEnableSettingsLogging = prefs.getBool('debug_enable_settings_logging') ?? false;
    _debugEnableErrorLogging = prefs.getBool('debug_enable_error_logging') ?? true;
    _debugEnableSystemLogging = prefs.getBool('debug_enable_system_logging') ?? true;
    
    notifyListeners();
  }
  
  /// 保存用户设置到本地存储
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // UI设置
    if (_userFloatingChatSize != null) {
      await prefs.setDouble('user_floating_chat_size', _userFloatingChatSize!);
    } else {
      await prefs.remove('user_floating_chat_size');
    }
    
    if (_userFloatingChatWidthRatio != null) {
      await prefs.setDouble('user_floating_chat_width_ratio', _userFloatingChatWidthRatio!);
    } else {
      await prefs.remove('user_floating_chat_width_ratio');
    }
    
    if (_userFloatingChatHeightRatio != null) {
      await prefs.setDouble('user_floating_chat_height_ratio', _userFloatingChatHeightRatio!);
    } else {
      await prefs.remove('user_floating_chat_height_ratio');
    }
    
    if (_userFontScale != null) {
      await prefs.setDouble('user_font_scale', _userFontScale!);
    } else {
      await prefs.remove('user_font_scale');
    }
    
    if (_userAnimationDuration != null) {
      await prefs.setInt('user_animation_duration', _userAnimationDuration!);
    } else {
      await prefs.remove('user_animation_duration');
    }
    
    if (_userTopBarDistance != null) {
      await prefs.setDouble('user_top_bar_distance', _userTopBarDistance!);
    } else {
      await prefs.remove('user_top_bar_distance');
    }
    
    // 网络设置
    if (_userServerUrl != null) {
      await prefs.setString('user_server_url', _userServerUrl!);
    } else {
      await prefs.remove('user_server_url');
    }
    
    if (_userApiUrl != null) {
      await prefs.setString('user_api_url', _userApiUrl!);
    } else {
      await prefs.remove('user_api_url');
    }
    
    if (_userConnectionTimeout != null) {
      await prefs.setInt('user_connection_timeout', _userConnectionTimeout!);
    } else {
      await prefs.remove('user_connection_timeout');
    }
    
    // Gotify 设置
    if (_userGotifyServerUrl != null) {
      await prefs.setString('user_gotify_server_url', _userGotifyServerUrl!);
    } else {
      await prefs.remove('user_gotify_server_url');
    }
    
    if (_userGotifyClientToken != null) {
      await prefs.setString('user_gotify_client_token', _userGotifyClientToken!);
    } else {
      await prefs.remove('user_gotify_client_token');
    }
    
    
    // 背景设置
    if (_userBackgroundConfig != null) {
      await prefs.setString('user_background_config', jsonEncode(_userBackgroundConfig!.toJson()));
    } else {
      await prefs.remove('user_background_config');
    }
    
    // 壁纸设置
    if (_userWallpaperMode != null) {
      await prefs.setString('user_wallpaper_mode', _userWallpaperMode!.name);
    } else {
      await prefs.remove('user_wallpaper_mode');
    }
    
    if (_userBuiltinWallpaperType != null) {
      await prefs.setString('user_builtin_wallpaper_type', _userBuiltinWallpaperType!.name);
    } else {
      await prefs.remove('user_builtin_wallpaper_type');
    }
    
    if (_userCustomWallpaperPath != null) {
      await prefs.setString('user_custom_wallpaper_path', _userCustomWallpaperPath!);
    } else {
      await prefs.remove('user_custom_wallpaper_path');
    }
    
    if (_userEnableWallpaperOverlay != null) {
      await prefs.setBool('user_enable_wallpaper_overlay', _userEnableWallpaperOverlay!);
    } else {
      await prefs.remove('user_enable_wallpaper_overlay');
    }
    
    // 天气设置
    if (_userWeatherEnabled != null) {
      await prefs.setBool('user_weather_enabled', _userWeatherEnabled!);
    } else {
      await prefs.remove('user_weather_enabled');
    }
    
    if (_userWeatherServiceType != null) {
      await prefs.setString('user_weather_service_type', _userWeatherServiceType!);
    } else {
      await prefs.remove('user_weather_service_type');
    }
    
    if (_userWeatherLocation != null) {
      await prefs.setString('user_weather_location', _userWeatherLocation!);
    } else {
      await prefs.remove('user_weather_location');
    }
    
    if (_userWeatherUpdateInterval != null) {
      await prefs.setInt('user_weather_update_interval', _userWeatherUpdateInterval!);
    } else {
      await prefs.remove('user_weather_update_interval');
    }
    
    if (_userQweatherApiKey != null) {
      await prefs.setString('user_qweather_api_key', _userQweatherApiKey!);
    } else {
      await prefs.remove('user_qweather_api_key');
    }
    
    if (_userOpenweatherApiKey != null) {
      await prefs.setString('user_openweather_api_key', _userOpenweatherApiKey!);
    } else {
      await prefs.remove('user_openweather_api_key');
    }
    
    
    // 日志设置
    if (_userLogLevel != null) {
      await prefs.setString('user_log_level', _userLogLevel!);
    } else {
      await prefs.remove('user_log_level');
    }
    
    await prefs.setBool('debug_enable_verbose_logging', _debugEnableVerboseLogging);
    await prefs.setBool('debug_enable_performance_logging', _debugEnablePerformanceLogging);
    
    // 模块日志开关
    await prefs.setBool('debug_enable_websocket_logging', _debugEnableWebSocketLogging);
    await prefs.setBool('debug_enable_mcp_logging', _debugEnableMcpLogging);
    await prefs.setBool('debug_enable_audio_logging', _debugEnableAudioLogging);
    await prefs.setBool('debug_enable_chat_logging', _debugEnableChatLogging);
    await prefs.setBool('debug_enable_ui_logging', _debugEnableUILogging);
    await prefs.setBool('debug_enable_settings_logging', _debugEnableSettingsLogging);
    await prefs.setBool('debug_enable_error_logging', _debugEnableErrorLogging);
    await prefs.setBool('debug_enable_system_logging', _debugEnableSystemLogging);
  }
  
  // ==================== 静态配置访问（用于代码中的直接访问） ====================
  
  /// 获取静态默认值（性能优化场景）
  static double get defaultFloatingChatSize => _defaultFloatingChatSize;
  static double get defaultFloatingChatWidthRatio => _defaultFloatingChatWidthRatio;
  static double get defaultFloatingChatHeightRatio => _defaultFloatingChatHeightRatio;
  static String get defaultServerUrl => _defaultServerUrl;
  static String get defaultApiUrl => _defaultApiUrl;
  static int get defaultAnimationDuration => _defaultAnimationDuration;
}

/// 应用设置Provider
final appSettingsProvider = ChangeNotifierProvider<AppSettings>((ref) {
  final settings = AppSettings.instance;
  // 异步加载用户设置
  settings.loadSettings();
  return settings;
});
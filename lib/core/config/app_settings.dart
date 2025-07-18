import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用设置管理
/// 
/// 双层架构：
/// 1. 静态默认值（性能优化，写死在代码中）
/// 2. 用户动态设置（可在设置页面修改，覆盖默认值）
class AppSettings extends ChangeNotifier {
  // ==================== 静态默认配置 ====================
  // 这些是写死的默认值，保证性能，减少运行时判断
  
  /// UI默认配置
  static const _defaultFloatingChatSize = 80.0;
  static const _defaultFloatingChatWidthRatio = 0.9;
  static const _defaultFloatingChatHeightRatio = 0.7;
  static const _defaultFontScale = 1.0;
  static const _defaultAnimationDuration = 200;
  
  /// 网络默认配置
  static const _defaultServerUrl = 'ws://192.168.110.199:8000';
  static const _defaultApiUrl = 'http://192.168.110.199:8000/api';
  static const _defaultConnectionTimeout = 10;
  
  /// 音频默认配置
  static const _defaultSampleRate = 16000;
  static const _defaultChannels = 1;
  static const _defaultFrameDuration = 60;
  
  /// 主题默认配置
  static const _defaultUseMaterial3 = false;
  static const _defaultEnableAnimations = false;
  static const _defaultEnableRipple = false;
  
  // ==================== 用户动态设置 ====================
  // 用户可以在设置页面修改这些值，如果为null则使用默认值
  
  double? _userFloatingChatSize;
  double? _userFloatingChatWidthRatio;
  double? _userFloatingChatHeightRatio;
  double? _userFontScale;
  int? _userAnimationDuration;
  
  String? _userServerUrl;
  String? _userApiUrl;
  int? _userConnectionTimeout;
  
  int? _userSampleRate;
  int? _userChannels;
  int? _userFrameDuration;
  
  bool? _userUseMaterial3;
  bool? _userEnableAnimations;
  bool? _userEnableRipple;
  
  // 调试设置
  bool _debugEnableLogging = false;
  bool _debugEnableNetworkLogging = false;
  bool _debugEnableAudioLogging = false;
  
  // ==================== 公共接口 ====================
  // 这些getter会自动选择用户设置或默认值
  
  /// UI设置
  double get floatingChatSize => _userFloatingChatSize ?? _defaultFloatingChatSize;
  double get floatingChatWidthRatio => _userFloatingChatWidthRatio ?? _defaultFloatingChatWidthRatio;
  double get floatingChatHeightRatio => _userFloatingChatHeightRatio ?? _defaultFloatingChatHeightRatio;
  double get fontScale => _userFontScale ?? _defaultFontScale;
  int get animationDuration => _userAnimationDuration ?? _defaultAnimationDuration;
  
  // 计算属性
  double get floatingChatCollapsedFontSize => floatingChatSize * 0.5;
  double get floatingChatCharacterFontSize => 64.0 * fontScale;
  Duration get animationDurationMs => Duration(milliseconds: animationDuration);
  
  /// 网络设置
  String get serverUrl => _userServerUrl ?? _defaultServerUrl;
  String get apiUrl => _userApiUrl ?? _defaultApiUrl;
  int get connectionTimeout => _userConnectionTimeout ?? _defaultConnectionTimeout;
  
  /// 音频设置
  int get sampleRate => _userSampleRate ?? _defaultSampleRate;
  int get channels => _userChannels ?? _defaultChannels;
  int get frameDuration => _userFrameDuration ?? _defaultFrameDuration;
  
  /// 主题设置
  bool get useMaterial3 => _userUseMaterial3 ?? _defaultUseMaterial3;
  bool get enableAnimations => _userEnableAnimations ?? _defaultEnableAnimations;
  bool get enableRipple => _userEnableRipple ?? _defaultEnableRipple;
  
  /// 调试设置
  bool get debugEnableLogging => _debugEnableLogging;
  bool get debugEnableNetworkLogging => _debugEnableNetworkLogging;
  bool get debugEnableAudioLogging => _debugEnableAudioLogging;
  
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
  
  /// 更新主题设置
  Future<void> updateUseMaterial3(bool value) async {
    _userUseMaterial3 = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateEnableAnimations(bool value) async {
    _userEnableAnimations = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateEnableRipple(bool value) async {
    _userEnableRipple = value;
    notifyListeners();
    await _saveSettings();
  }
  
  /// 更新音频设置
  Future<void> updateSampleRate(int value) async {
    _userSampleRate = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateChannels(int value) async {
    _userChannels = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateFrameDuration(int value) async {
    _userFrameDuration = value;
    notifyListeners();
    await _saveSettings();
  }
  
  /// 更新调试设置
  Future<void> updateDebugEnableLogging(bool value) async {
    _debugEnableLogging = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateDebugEnableNetworkLogging(bool value) async {
    _debugEnableNetworkLogging = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> updateDebugEnableAudioLogging(bool value) async {
    _debugEnableAudioLogging = value;
    notifyListeners();
    await _saveSettings();
  }
  
  // ==================== 工具方法 ====================
  
  /// 检查是否为默认值（用于设置页面显示）
  bool isDefaultFloatingChatSize() => _userFloatingChatSize == null;
  bool isDefaultServerUrl() => _userServerUrl == null;
  bool isDefaultFontScale() => _userFontScale == null;
  
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
  
  /// 重置所有设置为默认值
  Future<void> resetAllSettings() async {
    _userFloatingChatSize = null;
    _userFloatingChatWidthRatio = null;
    _userFloatingChatHeightRatio = null;
    _userFontScale = null;
    _userAnimationDuration = null;
    
    _userServerUrl = null;
    _userApiUrl = null;
    _userConnectionTimeout = null;
    
    _userSampleRate = null;
    _userChannels = null;
    _userFrameDuration = null;
    
    _userUseMaterial3 = null;
    _userEnableAnimations = null;
    _userEnableRipple = null;
    
    _debugEnableLogging = false;
    _debugEnableNetworkLogging = false;
    _debugEnableAudioLogging = false;
    
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
    
    // 网络设置
    _userServerUrl = prefs.getString('user_server_url');
    _userApiUrl = prefs.getString('user_api_url');
    _userConnectionTimeout = prefs.getInt('user_connection_timeout');
    
    // 音频设置
    _userSampleRate = prefs.getInt('user_sample_rate');
    _userChannels = prefs.getInt('user_channels');
    _userFrameDuration = prefs.getInt('user_frame_duration');
    
    // 主题设置
    _userUseMaterial3 = prefs.getBool('user_use_material3');
    _userEnableAnimations = prefs.getBool('user_enable_animations');
    _userEnableRipple = prefs.getBool('user_enable_ripple');
    
    // 调试设置
    _debugEnableLogging = prefs.getBool('debug_enable_logging') ?? false;
    _debugEnableNetworkLogging = prefs.getBool('debug_enable_network_logging') ?? false;
    _debugEnableAudioLogging = prefs.getBool('debug_enable_audio_logging') ?? false;
    
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
    
    // 主题设置
    if (_userUseMaterial3 != null) {
      await prefs.setBool('user_use_material3', _userUseMaterial3!);
    } else {
      await prefs.remove('user_use_material3');
    }
    
    if (_userEnableAnimations != null) {
      await prefs.setBool('user_enable_animations', _userEnableAnimations!);
    } else {
      await prefs.remove('user_enable_animations');
    }
    
    if (_userEnableRipple != null) {
      await prefs.setBool('user_enable_ripple', _userEnableRipple!);
    } else {
      await prefs.remove('user_enable_ripple');
    }
    
    // 音频设置
    if (_userSampleRate != null) {
      await prefs.setInt('user_sample_rate', _userSampleRate!);
    } else {
      await prefs.remove('user_sample_rate');
    }
    
    if (_userChannels != null) {
      await prefs.setInt('user_channels', _userChannels!);
    } else {
      await prefs.remove('user_channels');
    }
    
    if (_userFrameDuration != null) {
      await prefs.setInt('user_frame_duration', _userFrameDuration!);
    } else {
      await prefs.remove('user_frame_duration');
    }
    
    // 调试设置
    await prefs.setBool('debug_enable_logging', _debugEnableLogging);
    await prefs.setBool('debug_enable_network_logging', _debugEnableNetworkLogging);
    await prefs.setBool('debug_enable_audio_logging', _debugEnableAudioLogging);
  }
  
  // ==================== 静态配置访问（用于代码中的直接访问） ====================
  
  /// 获取静态默认值（性能优化场景）
  static double get defaultFloatingChatSize => _defaultFloatingChatSize;
  static double get defaultFloatingChatWidthRatio => _defaultFloatingChatWidthRatio;
  static double get defaultFloatingChatHeightRatio => _defaultFloatingChatHeightRatio;
  static String get defaultServerUrl => _defaultServerUrl;
  static String get defaultApiUrl => _defaultApiUrl;
  static bool get defaultUseMaterial3 => _defaultUseMaterial3;
  static bool get defaultEnableAnimations => _defaultEnableAnimations;
  static bool get defaultEnableRipple => _defaultEnableRipple;
  static int get defaultAnimationDuration => _defaultAnimationDuration;
}

/// 应用设置Provider
final appSettingsProvider = ChangeNotifierProvider<AppSettings>((ref) {
  final settings = AppSettings();
  // 异步加载用户设置
  settings.loadSettings();
  return settings;
});
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 动态配置管理
/// 
/// 用户可以在设置页面修改这些配置，应用立即生效
/// 配置会持久化存储到本地
class DynamicConfig extends ChangeNotifier {
  // ==================== UI 配置 ====================
  
  /// 悬浮聊天窗口配置
  double _floatingChatCollapsedSize = 80.0;
  double _floatingChatExpandedWidthRatio = 0.9;
  double _floatingChatExpandedHeightRatio = 0.7;
  bool _floatingChatEnableBackgroundBlur = false;
  double _floatingChatCharacterFontSize = 64.0;
  final double _floatingChatPositionMarginX = 20.0;
  final double _floatingChatPositionMarginY = 100.0;
  
  /// 输入组件配置
  final double _inputBorderRadius = 24.0;
  final double _inputCompactBorderRadius = 20.0;
  final double _inputBorderWidth = 1.5;
  final double _inputPadding = 12.0;
  final double _inputCompactPadding = 10.0;
  
  // ==================== 动画配置 ====================
  
  int _animationFloatingChatDurationMs = 200;
  final int _animationPageTransitionDurationMs = 0;
  final int _animationScrollDurationMs = 300;
  bool _animationEnableMaterialAnimations = false;
  bool _animationEnableRippleEffect = false;
  
  // ==================== 主题配置 ====================
  
  bool _themeUseMaterial3 = false;
  bool _themeEnableShadows = true;
  final bool _themeEnableHighlight = false;
  final bool _themeEnableSplash = false;
  
  // ==================== 性能配置 ====================
  
  bool _performanceEnableMonitoring = false;
  final int _performanceMaxConcurrentAudio = 1;
  double _performanceImageQuality = 0.7;
  final int _performanceMemoryCacheLimitMB = 50;
  final int _performanceDiskCacheLimitMB = 100;
  
  // ==================== 网络配置 ====================
  
  final int _networkConnectionTimeoutSec = 10;
  final int _networkReconnectIntervalSec = 5;
  final int _networkMaxRetryCount = 3;
  final int _networkHeartbeatIntervalSec = 30;
  
  // ==================== 音频配置 ====================
  
  final int _audioSampleRate = 16000;
  final int _audioChannels = 1;
  final int _audioFrameDurationMs = 60;
  final String _audioFormat = 'opus';
  final int _audioSttTimeoutSec = 5;
  
  // ==================== 调试配置 ====================
  
  bool _debugEnableLogging = false;
  bool _debugEnableNetworkLogging = false;
  bool _debugEnableAudioLogging = false;
  final bool _debugEnableUILogging = false;
  final bool _debugShowDebugInfo = false;
  
  // ==================== Getters ====================
  
  // UI配置
  double get floatingChatCollapsedSize => _floatingChatCollapsedSize;
  double get floatingChatExpandedWidthRatio => _floatingChatExpandedWidthRatio;
  double get floatingChatExpandedHeightRatio => _floatingChatExpandedHeightRatio;
  bool get floatingChatEnableBackgroundBlur => _floatingChatEnableBackgroundBlur;
  double get floatingChatCharacterFontSize => _floatingChatCharacterFontSize;
  double get floatingChatPositionMarginX => _floatingChatPositionMarginX;
  double get floatingChatPositionMarginY => _floatingChatPositionMarginY;
  double get floatingChatCollapsedFontSize => _floatingChatCollapsedSize * 0.5;
  double get floatingChatSafeMargin => 20.0; // 保持固定值
  
  double get inputBorderRadius => _inputBorderRadius;
  double get inputCompactBorderRadius => _inputCompactBorderRadius;
  double get inputBorderWidth => _inputBorderWidth;
  double get inputPadding => _inputPadding;
  double get inputCompactPadding => _inputCompactPadding;
  
  // 动画配置
  int get animationFloatingChatDurationMs => _animationFloatingChatDurationMs;
  int get animationPageTransitionDurationMs => _animationPageTransitionDurationMs;
  int get animationScrollDurationMs => _animationScrollDurationMs;
  bool get animationEnableMaterialAnimations => _animationEnableMaterialAnimations;
  bool get animationEnableRippleEffect => _animationEnableRippleEffect;
  
  // 主题配置
  bool get themeUseMaterial3 => _themeUseMaterial3;
  bool get themeEnableShadows => _themeEnableShadows;
  bool get themeEnableHighlight => _themeEnableHighlight;
  bool get themeEnableSplash => _themeEnableSplash;
  
  // 性能配置
  bool get performanceEnableMonitoring => _performanceEnableMonitoring;
  int get performanceMaxConcurrentAudio => _performanceMaxConcurrentAudio;
  double get performanceImageQuality => _performanceImageQuality;
  int get performanceMemoryCacheLimitMB => _performanceMemoryCacheLimitMB;
  int get performanceDiskCacheLimitMB => _performanceDiskCacheLimitMB;
  
  // 网络配置
  int get networkConnectionTimeoutSec => _networkConnectionTimeoutSec;
  int get networkReconnectIntervalSec => _networkReconnectIntervalSec;
  int get networkMaxRetryCount => _networkMaxRetryCount;
  int get networkHeartbeatIntervalSec => _networkHeartbeatIntervalSec;
  
  // 音频配置
  int get audioSampleRate => _audioSampleRate;
  int get audioChannels => _audioChannels;
  int get audioFrameDurationMs => _audioFrameDurationMs;
  String get audioFormat => _audioFormat;
  int get audioSttTimeoutSec => _audioSttTimeoutSec;
  
  // 调试配置
  bool get debugEnableLogging => _debugEnableLogging;
  bool get debugEnableNetworkLogging => _debugEnableNetworkLogging;
  bool get debugEnableAudioLogging => _debugEnableAudioLogging;
  bool get debugEnableUILogging => _debugEnableUILogging;
  bool get debugShowDebugInfo => _debugShowDebugInfo;
  
  // ==================== Setters ====================
  
  // UI配置 Setters
  void setFloatingChatCollapsedSize(double value) {
    _floatingChatCollapsedSize = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setFloatingChatExpandedWidthRatio(double value) {
    _floatingChatExpandedWidthRatio = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setFloatingChatExpandedHeightRatio(double value) {
    _floatingChatExpandedHeightRatio = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setFloatingChatEnableBackgroundBlur(bool value) {
    _floatingChatEnableBackgroundBlur = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setFloatingChatCharacterFontSize(double value) {
    _floatingChatCharacterFontSize = value;
    notifyListeners();
    _saveToStorage();
  }
  
  // 动画配置 Setters
  void setAnimationFloatingChatDurationMs(int value) {
    _animationFloatingChatDurationMs = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setAnimationEnableRippleEffect(bool value) {
    _animationEnableRippleEffect = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setAnimationEnableMaterialAnimations(bool value) {
    _animationEnableMaterialAnimations = value;
    notifyListeners();
    _saveToStorage();
  }
  
  // 主题配置 Setters
  void setThemeUseMaterial3(bool value) {
    _themeUseMaterial3 = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setThemeEnableShadows(bool value) {
    _themeEnableShadows = value;
    notifyListeners();
    _saveToStorage();
  }
  
  // 性能配置 Setters
  void setPerformanceEnableMonitoring(bool value) {
    _performanceEnableMonitoring = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setPerformanceImageQuality(double value) {
    _performanceImageQuality = value;
    notifyListeners();
    _saveToStorage();
  }
  
  // 调试配置 Setters
  void setDebugEnableLogging(bool value) {
    _debugEnableLogging = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setDebugEnableNetworkLogging(bool value) {
    _debugEnableNetworkLogging = value;
    notifyListeners();
    _saveToStorage();
  }
  
  void setDebugEnableAudioLogging(bool value) {
    _debugEnableAudioLogging = value;
    notifyListeners();
    _saveToStorage();
  }
  
  // ==================== 工具方法 ====================
  
  /// 获取优化后的动画时长
  Duration getAnimationDuration(int milliseconds) {
    return Duration(milliseconds: milliseconds);
  }
  
  /// 检查是否启用某个功能
  bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'ripple':
        return animationEnableRippleEffect;
      case 'shadows':
        return themeEnableShadows;
      case 'blur':
        return floatingChatEnableBackgroundBlur;
      case 'debug':
        return debugEnableLogging;
      default:
        return false;
    }
  }
  
  // ==================== 持久化存储 ====================
  
  /// 从本地存储加载配置
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // UI配置
    _floatingChatCollapsedSize = prefs.getDouble('floatingChatCollapsedSize') ?? 80.0;
    _floatingChatExpandedWidthRatio = prefs.getDouble('floatingChatExpandedWidthRatio') ?? 0.9;
    _floatingChatExpandedHeightRatio = prefs.getDouble('floatingChatExpandedHeightRatio') ?? 0.7;
    _floatingChatEnableBackgroundBlur = prefs.getBool('floatingChatEnableBackgroundBlur') ?? false;
    _floatingChatCharacterFontSize = prefs.getDouble('floatingChatCharacterFontSize') ?? 64.0;
    
    // 动画配置
    _animationFloatingChatDurationMs = prefs.getInt('animationFloatingChatDurationMs') ?? 200;
    _animationEnableRippleEffect = prefs.getBool('animationEnableRippleEffect') ?? false;
    _animationEnableMaterialAnimations = prefs.getBool('animationEnableMaterialAnimations') ?? false;
    
    // 主题配置
    _themeUseMaterial3 = prefs.getBool('themeUseMaterial3') ?? false;
    _themeEnableShadows = prefs.getBool('themeEnableShadows') ?? true;
    
    // 性能配置
    _performanceEnableMonitoring = prefs.getBool('performanceEnableMonitoring') ?? false;
    _performanceImageQuality = prefs.getDouble('performanceImageQuality') ?? 0.7;
    
    // 调试配置
    _debugEnableLogging = prefs.getBool('debugEnableLogging') ?? false;
    _debugEnableNetworkLogging = prefs.getBool('debugEnableNetworkLogging') ?? false;
    _debugEnableAudioLogging = prefs.getBool('debugEnableAudioLogging') ?? false;
    
    notifyListeners();
  }
  
  /// 保存配置到本地存储
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // UI配置
    await prefs.setDouble('floatingChatCollapsedSize', _floatingChatCollapsedSize);
    await prefs.setDouble('floatingChatExpandedWidthRatio', _floatingChatExpandedWidthRatio);
    await prefs.setDouble('floatingChatExpandedHeightRatio', _floatingChatExpandedHeightRatio);
    await prefs.setBool('floatingChatEnableBackgroundBlur', _floatingChatEnableBackgroundBlur);
    await prefs.setDouble('floatingChatCharacterFontSize', _floatingChatCharacterFontSize);
    
    // 动画配置
    await prefs.setInt('animationFloatingChatDurationMs', _animationFloatingChatDurationMs);
    await prefs.setBool('animationEnableRippleEffect', _animationEnableRippleEffect);
    await prefs.setBool('animationEnableMaterialAnimations', _animationEnableMaterialAnimations);
    
    // 主题配置
    await prefs.setBool('themeUseMaterial3', _themeUseMaterial3);
    await prefs.setBool('themeEnableShadows', _themeEnableShadows);
    
    // 性能配置
    await prefs.setBool('performanceEnableMonitoring', _performanceEnableMonitoring);
    await prefs.setDouble('performanceImageQuality', _performanceImageQuality);
    
    // 调试配置
    await prefs.setBool('debugEnableLogging', _debugEnableLogging);
    await prefs.setBool('debugEnableNetworkLogging', _debugEnableNetworkLogging);
    await prefs.setBool('debugEnableAudioLogging', _debugEnableAudioLogging);
  }
  
  /// 重置所有配置为默认值
  Future<void> resetToDefaults() async {
    // 恢复默认值
    _floatingChatCollapsedSize = 80.0;
    _floatingChatExpandedWidthRatio = 0.9;
    _floatingChatExpandedHeightRatio = 0.7;
    _floatingChatEnableBackgroundBlur = false;
    _floatingChatCharacterFontSize = 64.0;
    
    _animationFloatingChatDurationMs = 200;
    _animationEnableRippleEffect = false;
    _animationEnableMaterialAnimations = false;
    
    _themeUseMaterial3 = false;
    _themeEnableShadows = true;
    
    _performanceEnableMonitoring = false;
    _performanceImageQuality = 0.7;
    
    _debugEnableLogging = false;
    _debugEnableNetworkLogging = false;
    _debugEnableAudioLogging = false;
    
    notifyListeners();
    await _saveToStorage();
  }
}

/// 动态配置Provider
final dynamicConfigProvider = ChangeNotifierProvider<DynamicConfig>((ref) {
  final config = DynamicConfig();
  // 异步加载配置
  config.loadFromStorage();
  return config;
});
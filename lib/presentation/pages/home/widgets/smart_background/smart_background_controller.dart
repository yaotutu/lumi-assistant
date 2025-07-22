import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 智能背景模式枚举
/// 
/// 定义背景可以显示的不同功能模式
enum SmartBackgroundMode {
  /// 电子相册模式 - 显示用户照片轮播
  photoAlbum('电子相册', Icons.photo_library, '显示用户照片轮播'),
  
  /// 信息面板模式 - 显示系统信息和状态
  infoPanel('信息面板', Icons.info, '显示系统信息和设备状态'),
  
  /// 日历模式 - 显示日历和日程安排
  calendar('日历', Icons.calendar_today, '显示日历和日程安排'),
  
  /// 时钟模式 - 大字体时间显示
  clock('时钟', Icons.access_time, '大字体时间和日期显示'),
  
  /// 天气模式 - 天气信息和预报
  weather('天气', Icons.wb_sunny, '显示天气信息和预报'),
  
  /// 极简模式 - 纯净的渐变背景
  minimal('极简', Icons.minimize, '纯净的渐变背景');

  /// 构造函数
  const SmartBackgroundMode(this.displayName, this.icon, this.description);
  
  /// 显示名称
  final String displayName;
  
  /// 图标
  final IconData icon;
  
  /// 功能描述
  final String description;
}

/// 智能背景状态
/// 
/// 管理背景的当前模式和相关设置
class SmartBackgroundState {
  /// 构造函数
  const SmartBackgroundState({
    this.currentMode = SmartBackgroundMode.clock,
    this.autoSwitchEnabled = false,
    this.autoSwitchInterval = const Duration(minutes: 5),
    this.lastSwitchTime,
  });
  
  /// 当前显示模式
  final SmartBackgroundMode currentMode;
  
  /// 是否启用自动切换
  final bool autoSwitchEnabled;
  
  /// 自动切换间隔
  final Duration autoSwitchInterval;
  
  /// 上次切换时间
  final DateTime? lastSwitchTime;
  
  /// 复制并修改状态
  SmartBackgroundState copyWith({
    SmartBackgroundMode? currentMode,
    bool? autoSwitchEnabled,
    Duration? autoSwitchInterval,
    DateTime? lastSwitchTime,
  }) {
    return SmartBackgroundState(
      currentMode: currentMode ?? this.currentMode,
      autoSwitchEnabled: autoSwitchEnabled ?? this.autoSwitchEnabled,
      autoSwitchInterval: autoSwitchInterval ?? this.autoSwitchInterval,
      lastSwitchTime: lastSwitchTime ?? this.lastSwitchTime,
    );
  }
}

/// 智能背景控制器
/// 
/// 职责：管理背景模式切换、自动切换逻辑、状态持久化
/// 依赖：无外部依赖，纯状态管理
/// 使用场景：控制主页面背景的显示模式和切换行为
class SmartBackgroundNotifier extends StateNotifier<SmartBackgroundState> {
  /// 构造函数
  SmartBackgroundNotifier() : super(const SmartBackgroundState()) {
    // 启动时检查是否需要开始自动切换
    _checkAutoSwitch();
  }
  
  /// 切换到指定模式
  /// 
  /// 参数：
  /// - [mode] 目标背景模式
  /// 
  /// 功能：
  /// - 更新当前模式
  /// - 记录切换时间
  /// - 重新开始自动切换计时器
  void switchToMode(SmartBackgroundMode mode) {
    // 如果已经是当前模式，不需要切换
    if (state.currentMode == mode) {
      return;
    }
    
    // 更新状态，记录切换时间
    state = state.copyWith(
      currentMode: mode,
      lastSwitchTime: DateTime.now(),
    );
    
    // 如果启用了自动切换，重新开始计时
    if (state.autoSwitchEnabled) {
      _startAutoSwitchTimer();
    }
  }
  
  /// 切换到下一个模式
  /// 
  /// 循环遍历所有可用模式
  void switchToNextMode() {
    // 获取所有模式
    final allModes = SmartBackgroundMode.values;
    
    // 找到当前模式的索引
    final currentIndex = allModes.indexOf(state.currentMode);
    
    // 计算下一个模式的索引（循环）
    final nextIndex = (currentIndex + 1) % allModes.length;
    
    // 切换到下一个模式
    switchToMode(allModes[nextIndex]);
  }
  
  /// 设置自动切换开关
  /// 
  /// 参数：
  /// - [enabled] 是否启用自动切换
  void setAutoSwitchEnabled(bool enabled) {
    // 更新状态
    state = state.copyWith(autoSwitchEnabled: enabled);
    
    // 根据新状态启动或停止自动切换
    if (enabled) {
      _startAutoSwitchTimer();
    } else {
      _stopAutoSwitchTimer();
    }
  }
  
  /// 设置自动切换间隔
  /// 
  /// 参数：
  /// - [interval] 切换间隔时长
  void setAutoSwitchInterval(Duration interval) {
    // 更新状态
    state = state.copyWith(autoSwitchInterval: interval);
    
    // 如果自动切换已启用，重新开始计时器
    if (state.autoSwitchEnabled) {
      _startAutoSwitchTimer();
    }
  }
  
  /// 获取当前模式的显示信息
  /// 
  /// 返回：包含名称、图标、描述的映射
  Map<String, dynamic> getCurrentModeInfo() {
    final mode = state.currentMode;
    return {
      'name': mode.displayName,
      'icon': mode.icon,
      'description': mode.description,
      'isAutoSwitch': state.autoSwitchEnabled,
      'interval': state.autoSwitchInterval.inMinutes,
    };
  }
  
  // 自动切换定时器
  Timer? _autoSwitchTimer;
  
  /// 检查并启动自动切换
  /// 
  /// 在控制器初始化时调用，恢复自动切换状态
  void _checkAutoSwitch() {
    if (state.autoSwitchEnabled) {
      _startAutoSwitchTimer();
    }
  }
  
  /// 启动自动切换定时器
  /// 
  /// 根据设定的间隔时间自动切换背景模式
  void _startAutoSwitchTimer() {
    // 先停止现有的定时器
    _stopAutoSwitchTimer();
    
    // 创建新的定时器
    _autoSwitchTimer = Timer.periodic(state.autoSwitchInterval, (_) {
      // 自动切换到下一个模式
      switchToNextMode();
    });
  }
  
  /// 停止自动切换定时器
  void _stopAutoSwitchTimer() {
    _autoSwitchTimer?.cancel();
    _autoSwitchTimer = null;
  }
  
  /// 资源清理
  /// 
  /// StateNotifier销毁时调用，清理定时器资源
  @override
  void dispose() {
    _stopAutoSwitchTimer();
    super.dispose();
  }
}

/// 智能背景状态Provider
/// 
/// 提供全局的智能背景状态管理
final smartBackgroundProvider = StateNotifierProvider<SmartBackgroundNotifier, SmartBackgroundState>((ref) {
  return SmartBackgroundNotifier();
});

/// 当前背景模式Provider
/// 
/// 方便组件订阅当前背景模式的变化
final currentBackgroundModeProvider = Provider<SmartBackgroundMode>((ref) {
  return ref.watch(smartBackgroundProvider).currentMode;
});
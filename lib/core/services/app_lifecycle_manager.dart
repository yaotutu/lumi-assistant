import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../utils/app_logger.dart';
import 'wakelock_service.dart';

/// 应用生命周期管理器
/// 
/// 职责：监听应用生命周期变化，管理相关服务
/// 功能：
/// 1. 监听应用前台/后台状态
/// 2. 自动管理屏幕常亮状态
/// 3. 处理应用暂停/恢复事件
class AppLifecycleManager extends WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  static const String _logTag = 'Lifecycle';
  
  /// 屏幕常亮服务
  final WakelockService _wakelockService = WakelockService();
  
  /// 是否已初始化
  bool _isInitialized = false;
  
  /// 当前应用状态
  AppLifecycleState? _currentState;

  /// 初始化生命周期管理器
  void initialize() {
    if (_isInitialized) {
      AppLogger.getLogger(_logTag).warning('⚠️ 生命周期管理器已初始化');
      return;
    }

    // 注册生命周期观察者
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    
    AppLogger.getLogger(_logTag).info('✅ 应用生命周期管理器已初始化');
  }

  /// 清理资源
  void dispose() {
    if (!_isInitialized) return;

    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    
    AppLogger.getLogger(_logTag).info('🧹 应用生命周期管理器已清理');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    _currentState = state;
    AppLogger.getLogger(_logTag).info('🔄 应用生命周期状态变化: ${state.name}');

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  /// 应用恢复到前台
  void _onAppResumed() {
    AppLogger.getLogger(_logTag).info('📱 应用已恢复到前台');
    
    // 恢复屏幕常亮（根据用户设置）
    _wakelockService.autoManage(
      isActive: true,
      isDisplayMode: true, // 桌面信息展示模式
    );
  }

  /// 应用暂停到后台
  void _onAppPaused() {
    AppLogger.getLogger(_logTag).info('📱 应用已暂停到后台');
    
    // 禁用屏幕常亮以节省电量
    _wakelockService.autoManage(
      isActive: false,
      isDisplayMode: false,
    );
  }

  /// 应用变为非活跃状态
  void _onAppInactive() {
    AppLogger.getLogger(_logTag).info('📱 应用状态：非活跃');
    
    // 保持当前屏幕常亮状态，但可能会被系统管理
  }

  /// 应用被隐藏
  void _onAppHidden() {
    AppLogger.getLogger(_logTag).info('📱 应用状态：隐藏');
    
    // 禁用屏幕常亮
    _wakelockService.autoManage(
      isActive: false,
      isDisplayMode: false,
    );
  }

  /// 应用即将销毁
  void _onAppDetached() {
    AppLogger.getLogger(_logTag).info('📱 应用即将销毁');
    
    // 清理屏幕常亮服务
    _wakelockService.dispose();
    
    // 清理生命周期管理器
    dispose();
  }

  /// 获取当前应用状态
  AppLifecycleState? get currentState => _currentState;
  
  /// 应用是否在前台
  bool get isInForeground => _currentState == AppLifecycleState.resumed;
  
  /// 应用是否在后台
  bool get isInBackground => _currentState == AppLifecycleState.paused;
}

/// Riverpod Provider for AppLifecycleManager
final appLifecycleManagerProvider = Provider<AppLifecycleManager>((ref) {
  final manager = AppLifecycleManager();
  manager.initialize();
  
  // 当Provider被销毁时清理资源
  ref.onDispose(() {
    manager.dispose();
  });
  
  return manager;
});
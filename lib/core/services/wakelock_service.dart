import 'package:wakelock_plus/wakelock_plus.dart';
import '../utils/app_logger.dart';
import '../config/app_settings.dart';

/// 屏幕常亮管理服务
/// 
/// 职责：管理应用的屏幕常亮状态
/// 功能：
/// 1. 启用/禁用屏幕常亮
/// 2. 检查当前常亮状态
/// 3. 根据应用状态自动管理
class WakelockService {
  static final WakelockService _instance = WakelockService._internal();
  factory WakelockService() => _instance;
  WakelockService._internal();

  static const String _logTag = 'Wakelock';
  
  /// 是否已启用屏幕常亮
  bool _isEnabled = false;
  
  /// 获取当前屏幕常亮状态
  bool get isEnabled => _isEnabled;

  /// 启用屏幕常亮
  /// 
  /// 适用场景：
  /// - 应用作为桌面信息展示终端
  /// - 语音交互过程中
  /// - 观看电子相册时
  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
      _isEnabled = true;
      AppLogger.getLogger(_logTag).info('✅ 屏幕常亮已启用');
    } catch (e) {
      AppLogger.getLogger(_logTag).severe('❌ 启用屏幕常亮失败: $e');
      _isEnabled = false;
    }
  }

  /// 禁用屏幕常亮
  /// 
  /// 适用场景：
  /// - 应用进入后台
  /// - 用户手动关闭常亮功能
  /// - 省电模式下
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
      _isEnabled = false;
      AppLogger.getLogger(_logTag).info('✅ 屏幕常亮已禁用');
    } catch (e) {
      AppLogger.getLogger(_logTag).severe('❌ 禁用屏幕常亮失败: $e');
    }
  }

  /// 检查系统是否支持屏幕常亮
  Future<bool> isSupported() async {
    try {
      // wakelock_plus 在 Android/iOS 上都支持
      return true;
    } catch (e) {
      AppLogger.getLogger(_logTag).warning('⚠️ 检查屏幕常亮支持失败: $e');
      return false;
    }
  }

  /// 检查当前系统的屏幕常亮状态
  Future<bool> isCurrentlyEnabled() async {
    try {
      final enabled = await WakelockPlus.enabled;
      _isEnabled = enabled;
      return enabled;
    } catch (e) {
      AppLogger.getLogger(_logTag).warning('⚠️ 检查屏幕常亮状态失败: $e');
      return false;
    }
  }

  /// 切换屏幕常亮状态
  Future<void> toggle() async {
    if (_isEnabled) {
      await disable();
    } else {
      await enable();
    }
  }

  /// 根据应用状态和用户设置自动管理屏幕常亮
  /// 
  /// 参数：
  /// - [isActive] 应用是否处于活跃状态
  /// - [isDisplayMode] 是否为展示模式（桌面信息展示）
  /// - [userEnabled] 用户是否启用了屏幕常亮功能
  Future<void> autoManage({
    required bool isActive,
    bool isDisplayMode = true,
    bool? userEnabled,
  }) async {
    // 检查用户设置
    final shouldKeepOn = userEnabled ?? AppSettings.instance.keepScreenOn;
    
    if (isActive && isDisplayMode && shouldKeepOn) {
      // 应用活跃、展示模式且用户启用时启用常亮
      if (!_isEnabled) {
        await enable();
      }
    } else {
      // 其他情况禁用常亮
      if (_isEnabled) {
        await disable();
      }
    }
  }

  /// 初始化屏幕常亮服务
  /// 
  /// 在应用启动时调用，设置默认状态
  Future<void> initialize() async {
    AppLogger.getLogger(_logTag).info('🔄 初始化屏幕常亮服务...');
    
    // 检查系统支持
    final supported = await isSupported();
    if (!supported) {
      AppLogger.getLogger(_logTag).warning('⚠️ 当前系统不支持屏幕常亮功能');
      return;
    }

    // 检查当前状态
    await isCurrentlyEnabled();
    
    // 根据用户设置决定是否启用屏幕常亮
    final userEnabled = AppSettings.instance.keepScreenOn;
    if (userEnabled) {
      await enable();
    } else {
      await disable();
    }
    
    AppLogger.getLogger(_logTag).info('✅ 屏幕常亮服务初始化完成');
  }

  /// 清理资源
  /// 
  /// 在应用退出时调用
  Future<void> dispose() async {
    AppLogger.getLogger(_logTag).info('🧹 屏幕常亮服务清理中...');
    
    // 禁用屏幕常亮
    await disable();
    
    AppLogger.getLogger(_logTag).info('✅ 屏幕常亮服务已清理');
  }
}
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/app_settings.dart';
import '../../constants/app_constants.dart';
import '../../../presentation/themes/app_theme.dart';
import '../../../presentation/providers/audio_stream_provider.dart';
import '../../utils/loggers.dart';

/// 应用配置服务
/// 
/// 职责：统一管理MaterialApp的配置和应用级别的设置
/// 依赖：AppSettings（配置管理）、AppTheme（主题系统）
/// 使用场景：为MaterialApp提供统一的配置管理
class AppConfiguration {
  // 私有构造函数，防止外部直接实例化
  AppConfiguration._();
  
  /// 单例实例
  static final AppConfiguration _instance = AppConfiguration._();
  static AppConfiguration get instance => _instance;
  
  /// 获取MaterialApp的完整配置
  /// 
  /// 参数：
  /// - [settings] 应用设置实例，用于获取用户配置
  /// - [child] MaterialApp的子组件，通常是HomePage
  /// 
  /// 返回：配置好的MaterialApp实例
  MaterialApp getMaterialApp({
    required AppSettings settings,
    required Widget child,
  }) {
    return MaterialApp(
      // 应用基础配置
      title: AppConstants.appName,           // 应用名称，显示在任务管理器中
      debugShowCheckedModeBanner: false,    // 移除右上角的debug标识
      
      // 性能调试配置 - 生产环境全部关闭
      showPerformanceOverlay: false,         // 不显示性能覆盖层
      checkerboardRasterCacheImages: false,  // 不显示光栅缓存检查板
      checkerboardOffscreenLayers: false,   // 不显示离屏层检查板
      showSemanticsDebugger: false,         // 不显示语义调试器
      
      // 全局字体缩放配置
      builder: (context, child) => _buildAppWithGlobalSettings(
        context: context,
        child: child!,
        settings: settings,
      ),
      
      // 主题配置
      theme: AppTheme.getLightTheme(),       // 浅色主题
      darkTheme: AppTheme.getDarkTheme(),    // 深色主题
      themeMode: _getThemeMode(settings),    // 主题模式：根据设置或系统
      
      // 主页面
      home: child,
    );
  }
  
  /// 构建带有全局设置的应用包装器
  /// 
  /// 功能：
  /// - 应用全局字体缩放设置
  /// - 预初始化关键服务
  /// - 提供全局错误处理上下文
  /// 
  /// 参数：
  /// - [context] 构建上下文
  /// - [child] 子组件
  /// - [settings] 应用设置
  Widget _buildAppWithGlobalSettings({
    required BuildContext context,
    required Widget child,
    required AppSettings settings,
  }) {
    return MediaQuery(
      // 应用全局字体缩放
      data: MediaQuery.of(context).copyWith(
        // 使用配置系统的字体缩放比例，支持无障碍访问
        textScaler: TextScaler.linear(settings.fontScale),
      ),
      child: child,
    );
  }
  
  /// 根据设置确定主题模式
  /// 
  /// 优先级：
  /// 1. 用户明确设置的主题偏好
  /// 2. 跟随系统主题设置
  /// 
  /// 参数：
  /// - [settings] 应用设置实例
  /// 
  /// 返回：ThemeMode枚举值
  ThemeMode _getThemeMode(AppSettings settings) {
    // TODO: 未来可以从settings中获取用户的主题偏好
    // 目前默认跟随系统设置
    return ThemeMode.system;
  }
}

/// 应用预初始化服务
/// 
/// 职责：在应用启动后预初始化关键服务，提升用户体验
/// 使用场景：解决首次使用某些功能时的延迟问题
class AppPreInitializer {
  // 私有构造函数
  AppPreInitializer._();
  
  /// 单例实例
  static final AppPreInitializer _instance = AppPreInitializer._();
  static AppPreInitializer get instance => _instance;
  
  // 预初始化状态标记
  bool _isPreInitialized = false;
  
  /// 获取预初始化状态
  bool get isPreInitialized => _isPreInitialized;
  
  /// 执行应用预初始化
  /// 
  /// 预初始化服务列表：
  /// - 音频流服务：解决首次录音时的初始化延迟
  /// - 其他可能的延迟服务
  /// 
  /// 参数：
  /// - [ref] Riverpod引用，用于访问Provider
  /// 
  /// 注意：这是一个异步操作，不阻塞UI渲染
  Future<void> preInitialize(WidgetRef ref) async {
    // 防止重复预初始化
    if (_isPreInitialized) {
      return;
    }
    
    try {
      Loggers.system.info('🎯 开始应用预初始化...');
      
      // 预初始化音频流服务
      await _preInitializeAudioService(ref);
      
      // TODO: 添加其他需要预初始化的服务
      // 例如：网络连接池、缓存系统、推送服务等
      
      // 标记预初始化完成
      _isPreInitialized = true;
      
      Loggers.system.info('✅ 应用预初始化完成');
      
    } catch (error, stackTrace) {
      // 预初始化失败不影响应用运行，只记录警告
      Loggers.system.warning('⚠️ 应用预初始化部分失败: $error', error, stackTrace);
    }
  }
  
  /// 预初始化音频流服务
  /// 
  /// 目的：解决用户首次点击录音按钮时的卡顿问题
  /// 原理：提前初始化音频流相关资源
  /// 
  /// 参数：
  /// - [ref] Riverpod引用，用于访问audioStreamProvider
  Future<void> _preInitializeAudioService(WidgetRef ref) async {
    try {
      // 获取音频流状态管理器
      final audioNotifier = ref.read(audioStreamProvider.notifier);
      
      // 预初始化音频流（不开始实际录音）
      await audioNotifier.initializeStreaming();
      
      Loggers.audio.info('🎤 音频流服务预初始化完成');
      
    } catch (error) {
      // 音频服务预初始化失败，记录但不抛出异常
      Loggers.audio.warning('⚠️ 音频流服务预初始化失败: $error');
    }
  }
  
  /// 重置预初始化状态
  /// 
  /// 用途：测试环境或特殊情况下需要重新预初始化
  void reset() {
    _isPreInitialized = false;
    Loggers.system.info('🔄 应用预初始化状态已重置');
  }
}
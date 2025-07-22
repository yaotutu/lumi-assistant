import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:opus_dart/opus_dart.dart';

import '../config/app_settings.dart';
import '../utils/app_logger.dart';
import '../utils/loggers.dart';

/// 应用初始化服务
/// 
/// 职责：统一管理应用启动时的所有初始化逻辑
/// 依赖：AppSettings（配置管理）、AppLogger（日志系统）
/// 使用场景：应用启动时的一次性初始化操作
class AppInitializer {
  // 私有构造函数，防止外部直接实例化
  AppInitializer._();
  
  /// 单例实例
  static final AppInitializer _instance = AppInitializer._();
  static AppInitializer get instance => _instance;
  
  // 初始化状态标记，防止重复初始化
  bool _isInitialized = false;
  
  /// 获取初始化状态
  bool get isInitialized => _isInitialized;
  
  /// 执行完整的应用初始化流程
  /// 
  /// 初始化顺序：
  /// 1. 日志系统初始化（最先，便于后续记录日志）
  /// 2. 性能优化设置（系统级配置）
  /// 3. 异步初始化Opus库（不阻塞应用启动）
  /// 
  /// 返回：Future void 初始化完成时resolve
  /// 
  /// 抛出：
  /// - Exception：任何初始化步骤失败时抛出
  Future<void> initialize() async {
    // 防止重复初始化
    if (_isInitialized) {
      Loggers.system.warning('⚠️ 应用已经初始化，跳过重复初始化');
      return;
    }
    
    try {
      // 记录初始化开始
      print('🚀 开始应用初始化流程...');
      
      // 步骤1：初始化日志系统
      await _initializeLogging();
      
      // 步骤2：应用性能优化设置
      await _applyPerformanceOptimizations();
      
      // 步骤3：异步初始化Opus库（不等待完成）
      _initializeOpusAsync();
      
      // 标记初始化完成
      _isInitialized = true;
      
      // 记录初始化完成
      Loggers.system.info('✅ 应用初始化流程完成');
      
    } catch (error, stackTrace) {
      // 初始化失败时记录详细错误信息
      Loggers.system.severe('❌ 应用初始化失败: $error', error, stackTrace);
      
      // 重新抛出异常，让调用者知道初始化失败
      throw Exception('应用初始化失败: $error');
    }
  }
  
  /// 初始化日志系统
  /// 
  /// 流程：
  /// 1. 加载应用设置中的日志配置
  /// 2. 使用配置初始化AppLogger
  /// 3. 记录启动信息和日志配置
  /// 
  /// 注意：这是第一个初始化的组件，因为后续所有操作都需要日志记录
  Future<void> _initializeLogging() async {
    try {
      // 获取应用设置实例
      final settings = AppSettings.instance;
      
      // 加载用户配置的日志设置
      await settings.loadSettings();
      
      // 使用配置初始化日志系统
      AppLogger.initialize(
        globalLevel: settings.logLevel,           // 全局日志级别
        moduleConfig: settings.getModuleLogConfig(), // 各模块的日志配置
      );
      
      // 记录启动信息，确认日志系统工作正常
      Loggers.system.info('🚀 Lumi Assistant 启动中...');
      Loggers.system.info('📊 日志配置已加载: ${AppLogger.getConfig()}');
      
    } catch (error) {
      // 日志系统初始化失败是严重错误，使用print输出
      print('❌ 日志系统初始化失败: $error');
      rethrow;
    }
  }
  
  /// 应用性能优化设置
  /// 
  /// 配置项：
  /// - 系统UI样式：状态栏和导航栏透明
  /// - 状态栏图标：使用浅色图标适配深色背景
  /// 
  /// 注意：这些设置影响整个应用的视觉效果
  Future<void> _applyPerformanceOptimizations() async {
    try {
      // 配置系统UI覆盖层样式
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,        // 状态栏透明
          statusBarIconBrightness: Brightness.light, // 状态栏图标使用浅色
          systemNavigationBarColor: Colors.transparent, // 导航栏透明
        ),
      );
      
      // 记录性能优化配置完成
      Loggers.system.info('⚡ 系统UI性能优化配置已应用');
      
    } catch (error) {
      // 性能优化设置失败记录警告，但不影响应用启动
      Loggers.system.warning('⚠️ 性能优化配置失败: $error');
    }
  }
  
  /// 异步初始化Opus音频编解码库
  /// 
  /// 设计思路：
  /// - 异步执行，不阻塞应用启动
  /// - 失败时记录错误，但不影响应用运行
  /// - 为后续音频功能做准备
  /// 
  /// 注意：这是一个Fire-and-forget操作，不等待完成
  void _initializeOpusAsync() {
    // 在后台异步执行Opus初始化
    Future(() async {
      try {
        // 加载Opus Flutter插件
        final opusLib = await opus_flutter.load();
        
        // 初始化Opus库
        initOpus(opusLib);
        
        // 获取并记录Opus版本信息
        final version = getOpusVersion();
        Loggers.audio.info('🎵 Opus音频库初始化成功，版本: $version');
        
      } catch (error, stackTrace) {
        // Opus初始化失败记录错误，但不中断应用
        Loggers.audio.severe('❌ Opus音频库初始化失败: $error', error, stackTrace);
        
        // TODO: 可以在这里实现降级处理或重试机制
        // 例如：使用平台默认音频处理，或延迟重试初始化
      }
    });
  }
  
  /// 重置初始化状态
  /// 
  /// 用途：测试环境或特殊情况下需要重新初始化
  /// 注意：正常使用中不应该调用此方法
  void reset() {
    _isInitialized = false;
    Loggers.system.info('🔄 应用初始化状态已重置');
  }
}
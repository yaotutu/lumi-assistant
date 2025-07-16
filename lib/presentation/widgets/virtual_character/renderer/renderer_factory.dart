/// 虚拟人物渲染器工厂类
/// 
/// 实现工厂模式，用于创建和管理不同类型的虚拟人物渲染器
/// 支持动态切换渲染器类型，便于后期升级到高级动画
library;

import 'package:flutter/material.dart';
import 'virtual_character_renderer.dart';
import 'text_character_renderer.dart';
import '../models/character_enums.dart';

/// 虚拟人物渲染器工厂类
/// 
/// 提供统一的接口创建和管理虚拟人物渲染器
/// 支持渲染器类型的动态切换和配置管理
class VirtualCharacterRendererFactory {
  /// 当前激活的渲染器实例
  static VirtualCharacterRenderer? _currentRenderer;
  
  /// 当前渲染器类型
  static RendererType _currentType = RendererType.text;
  
  /// 渲染器配置缓存
  static final Map<RendererType, Map<String, dynamic>> _rendererConfigs = {};
  
  /// 创建指定类型的渲染器
  /// 
  /// 参数：
  /// - [type] 渲染器类型
  /// - [vsync] 动画控制器需要的TickerProvider（文字渲染器需要）
  /// - [config] 渲染器配置（可选）
  /// 
  /// 返回：
  /// - 创建的渲染器实例
  /// 
  /// 异常：
  /// - [UnsupportedError] 如果请求的渲染器类型尚未实现
  static VirtualCharacterRenderer createRenderer(
    RendererType type, {
    TickerProvider? vsync,
    Map<String, dynamic>? config,
  }) {
    // 保存配置
    if (config != null) {
      _rendererConfigs[type] = config;
    }
    
    // 根据类型创建对应的渲染器
    switch (type) {
      case RendererType.text:
        return _createTextRenderer(vsync, config);
        
      case RendererType.image:
        return _createImageRenderer(config);
        
      case RendererType.gif:
        return _createGifRenderer(config);
        
      case RendererType.rive:
        return _createRiveRenderer(config);
        
      case RendererType.live2d:
        return _createLive2DRenderer(config);
    }
  }
  
  /// 获取当前激活的渲染器
  /// 
  /// 返回：
  /// - 当前激活的渲染器实例，如果未创建则返回null
  static VirtualCharacterRenderer? getCurrentRenderer() {
    return _currentRenderer;
  }
  
  /// 设置当前激活的渲染器
  /// 
  /// 参数：
  /// - [type] 渲染器类型
  /// - [vsync] 动画控制器需要的TickerProvider（文字渲染器需要）
  /// - [config] 渲染器配置（可选）
  /// 
  /// 返回：
  /// - 设置的渲染器实例
  static VirtualCharacterRenderer setCurrentRenderer(
    RendererType type, {
    TickerProvider? vsync,
    Map<String, dynamic>? config,
  }) {
    // 如果类型相同且已有实例，直接返回
    if (_currentType == type && _currentRenderer != null) {
      return _currentRenderer!;
    }
    
    // 释放旧的渲染器资源
    if (_currentRenderer != null) {
      _currentRenderer!.dispose();
    }
    
    // 创建新的渲染器
    _currentRenderer = createRenderer(type, vsync: vsync, config: config);
    _currentType = type;
    
    return _currentRenderer!;
  }
  
  /// 获取当前渲染器类型
  /// 
  /// 返回：
  /// - 当前渲染器类型
  static RendererType getCurrentType() {
    return _currentType;
  }
  
  /// 检查指定类型的渲染器是否可用
  /// 
  /// 参数：
  /// - [type] 渲染器类型
  /// 
  /// 返回：
  /// - true 如果渲染器可用
  /// - false 如果渲染器不可用
  static bool isRendererAvailable(RendererType type) {
    switch (type) {
      case RendererType.text:
        return true; // 文字渲染器总是可用
        
      case RendererType.image:
        return false; // 图片渲染器尚未实现
        
      case RendererType.gif:
        return false; // GIF渲染器尚未实现
        
      case RendererType.rive:
        return false; // Rive渲染器尚未实现
        
      case RendererType.live2d:
        return false; // Live2D渲染器尚未实现
    }
  }
  
  /// 获取所有可用的渲染器类型
  /// 
  /// 返回：
  /// - 可用的渲染器类型列表
  static List<RendererType> getAvailableRendererTypes() {
    return RendererType.values
        .where((type) => isRendererAvailable(type))
        .toList();
  }
  
  /// 获取指定类型渲染器的配置
  /// 
  /// 参数：
  /// - [type] 渲染器类型
  /// 
  /// 返回：
  /// - 渲染器配置Map
  static Map<String, dynamic> getRendererConfig(RendererType type) {
    return _rendererConfigs[type] ?? {};
  }
  
  /// 设置指定类型渲染器的配置
  /// 
  /// 参数：
  /// - [type] 渲染器类型
  /// - [config] 渲染器配置
  static void setRendererConfig(RendererType type, Map<String, dynamic> config) {
    _rendererConfigs[type] = config;
    
    // 如果是当前激活的渲染器，更新其配置
    if (_currentType == type && _currentRenderer != null) {
      _currentRenderer!.setConfiguration(config);
    }
  }
  
  /// 清理所有渲染器资源
  /// 
  /// 释放当前渲染器并清空配置缓存
  static void cleanup() {
    if (_currentRenderer != null) {
      _currentRenderer!.dispose();
      _currentRenderer = null;
    }
    _rendererConfigs.clear();
  }
  
  /// 预加载所有可用渲染器的资源
  /// 
  /// 返回：
  /// - Future`<void>` 异步加载完成的标识
  static Future<void> preloadAllRenderers() async {
    final availableTypes = getAvailableRendererTypes();
    
    for (final type in availableTypes) {
      try {
        final renderer = createRenderer(type);
        await renderer.preloadResources();
        renderer.dispose();
      } catch (e) {
        // 忽略预加载失败的渲染器
        print('Failed to preload renderer $type: $e');
      }
    }
  }
  
  // 私有方法：创建文字渲染器
  static VirtualCharacterRenderer _createTextRenderer(
    TickerProvider? vsync, 
    Map<String, dynamic>? config
  ) {
    if (vsync == null) {
      throw ArgumentError('TextCharacterRenderer requires a TickerProvider');
    }
    
    return TextCharacterRenderer(
      vsync: vsync,
      config: config,
    );
  }
  
  // 私有方法：创建图片渲染器
  static VirtualCharacterRenderer _createImageRenderer(Map<String, dynamic>? config) {
    throw UnsupportedError('ImageCharacterRenderer is not implemented yet');
  }
  
  // 私有方法：创建GIF渲染器
  static VirtualCharacterRenderer _createGifRenderer(Map<String, dynamic>? config) {
    throw UnsupportedError('GifCharacterRenderer is not implemented yet');
  }
  
  // 私有方法：创建Rive渲染器
  static VirtualCharacterRenderer _createRiveRenderer(Map<String, dynamic>? config) {
    throw UnsupportedError('RiveCharacterRenderer is not implemented yet');
  }
  
  // 私有方法：创建Live2D渲染器
  static VirtualCharacterRenderer _createLive2DRenderer(Map<String, dynamic>? config) {
    throw UnsupportedError('Live2DCharacterRenderer is not implemented yet');
  }
}
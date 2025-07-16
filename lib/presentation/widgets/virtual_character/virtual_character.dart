/// 统一虚拟人物组件
/// 
/// 提供统一的虚拟人物界面，支持动态切换不同的渲染器
/// 封装渲染器管理、状态同步、交互处理等功能
library;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'renderer/renderer_factory.dart';
import 'models/character_enums.dart';
import '../../providers/virtual_character_provider.dart';

/// 统一虚拟人物组件
/// 
/// 主要功能：
/// - 支持动态切换渲染器类型
/// - 统一的状态管理和更新
/// - 点击交互处理
/// - 自动资源管理
class VirtualCharacter extends HookConsumerWidget {
  /// 渲染器类型
  final RendererType rendererType;
  
  /// 渲染器配置
  final Map<String, dynamic>? rendererConfig;
  
  /// 是否可点击
  final bool clickable;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 长按回调
  final VoidCallback? onLongPress;
  
  /// 自定义约束
  final BoxConstraints? constraints;
  
  /// 外边距
  final EdgeInsets? margin;
  
  /// 内边距
  final EdgeInsets? padding;
  
  /// 背景装饰
  final Decoration? decoration;
  
  /// 构造函数
  const VirtualCharacter({
    super.key,
    this.rendererType = RendererType.text,
    this.rendererConfig,
    this.clickable = true,
    this.onTap,
    this.onLongPress,
    this.constraints,
    this.margin,
    this.padding,
    this.decoration,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取当前状态
    final characterState = ref.watch(virtualCharacterProvider);
    
    // 获取TickerProvider
    final tickerProvider = useSingleTickerProvider();
    
    // 创建和管理渲染器
    final renderer = useMemoized(() {
      try {
        // TickerProvider由useSingleTickerProvider()提供，不会为null
        
        return VirtualCharacterRendererFactory.createRenderer(
          rendererType,
          vsync: tickerProvider,
          config: rendererConfig,
        );
      } catch (e) {
        print('Failed to create renderer: $e');
        print('RendererType: $rendererType');
        print('TickerProvider: $tickerProvider');
        print('Config: $rendererConfig');
        return null;
      }
    }, [rendererType, rendererConfig, tickerProvider]);
    
    // 监听状态变化并更新渲染器
    useEffect(() {
      if (renderer != null) {
        // 注意：不需要调用updateEmotion和updateStatus
        // 因为render方法会接收最新的characterState
        print('Character state changed: ${characterState.emotion}, ${characterState.status}');
      }
      return null;
    }, [characterState.emotion, characterState.status, renderer]);
    
    // 组件销毁时释放资源
    useEffect(() {
      return () {
        renderer?.dispose();
      };
    }, [renderer]);
    
    return Container(
      constraints: constraints,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: clickable ? _handleTap(context, ref) : null,
          onLongPress: clickable ? _handleLongPress(context, ref) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(8),
            child: renderer != null
                ? renderer.render(characterState)
                : _buildErrorWidget(context),
          ),
        ),
      ),
    );
  }
  
  /// 处理点击事件
  VoidCallback? _handleTap(BuildContext context, WidgetRef ref) {
    return onTap ?? () {
      // 默认点击行为：触发状态切换动画
      final notifier = ref.read(virtualCharacterProvider.notifier);
      notifier.triggerAnimation();
    };
  }
  
  /// 处理长按事件
  VoidCallback? _handleLongPress(BuildContext context, WidgetRef ref) {
    return onLongPress ?? () {
      // 默认长按行为：显示状态信息
      _showCharacterInfo(context, ref);
    };
  }
  
  /// 构建错误显示组件
  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 80,
        minHeight: 80,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 32,
            color: Colors.red.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 4),
          Text(
            '渲染器加载失败',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// 显示虚拟人物信息对话框
  void _showCharacterInfo(BuildContext context, WidgetRef ref) {
    final characterState = ref.read(virtualCharacterProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('虚拟人物信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('渲染器类型', rendererType.displayName),
            _buildInfoRow('当前表情', characterState.emotion),
            _buildInfoRow('当前状态', characterState.status.statusText),
            _buildInfoRow('缩放比例', characterState.scale.toStringAsFixed(1)),
            _buildInfoRow('动画状态', characterState.isAnimating ? '进行中' : '已停止'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// 虚拟人物预设配置
class VirtualCharacterPresets {
  /// 默认配置
  static const Map<String, dynamic> defaultConfig = {
    'fontSize': 48.0,
    'statusFontSize': 12.0,
    'textColor': Colors.white,
    'statusTextColor': Colors.white70,
    'animationDuration': 300,
    'pulseEnabled': true,
    'scaleEnabled': true,
    'hapticFeedback': true,
  };
  
  /// 小尺寸配置
  static const Map<String, dynamic> smallConfig = {
    'fontSize': 32.0,
    'statusFontSize': 10.0,
    'textColor': Colors.white,
    'statusTextColor': Colors.white70,
    'animationDuration': 250,
    'pulseEnabled': true,
    'scaleEnabled': true,
    'hapticFeedback': true,
  };
  
  /// 大尺寸配置
  static const Map<String, dynamic> largeConfig = {
    'fontSize': 64.0,
    'statusFontSize': 14.0,
    'textColor': Colors.white,
    'statusTextColor': Colors.white70,
    'animationDuration': 350,
    'pulseEnabled': true,
    'scaleEnabled': true,
    'hapticFeedback': true,
  };
  
  /// 性能优化配置（禁用部分动画）
  static const Map<String, dynamic> performanceConfig = {
    'fontSize': 48.0,
    'statusFontSize': 12.0,
    'textColor': Colors.white,
    'statusTextColor': Colors.white70,
    'animationDuration': 200,
    'pulseEnabled': false,
    'scaleEnabled': false,
    'hapticFeedback': false,
  };
  
  /// 获取预设配置
  static Map<String, dynamic> getPreset(String name) {
    switch (name) {
      case 'small':
        return Map<String, dynamic>.from(smallConfig);
      case 'large':
        return Map<String, dynamic>.from(largeConfig);
      case 'performance':
        return Map<String, dynamic>.from(performanceConfig);
      default:
        return Map<String, dynamic>.from(defaultConfig);
    }
  }
}

/// 虚拟人物便利构造器
class VirtualCharacterBuilder {
  RendererType _rendererType = RendererType.text;
  Map<String, dynamic>? _config;
  bool _clickable = true;
  VoidCallback? _onTap;
  VoidCallback? _onLongPress;
  BoxConstraints? _constraints;
  EdgeInsets? _margin;
  EdgeInsets? _padding;
  Decoration? _decoration;
  
  /// 设置渲染器类型
  VirtualCharacterBuilder renderer(RendererType type) {
    _rendererType = type;
    return this;
  }
  
  /// 设置配置
  VirtualCharacterBuilder config(Map<String, dynamic> config) {
    _config = config;
    return this;
  }
  
  /// 设置预设配置
  VirtualCharacterBuilder preset(String name) {
    _config = VirtualCharacterPresets.getPreset(name);
    return this;
  }
  
  /// 设置点击处理
  VirtualCharacterBuilder clickable(bool clickable) {
    _clickable = clickable;
    return this;
  }
  
  /// 设置点击回调
  VirtualCharacterBuilder onTap(VoidCallback? callback) {
    _onTap = callback;
    return this;
  }
  
  /// 设置长按回调
  VirtualCharacterBuilder onLongPress(VoidCallback? callback) {
    _onLongPress = callback;
    return this;
  }
  
  /// 设置约束
  VirtualCharacterBuilder constraints(BoxConstraints? constraints) {
    _constraints = constraints;
    return this;
  }
  
  /// 设置边距
  VirtualCharacterBuilder margin(EdgeInsets? margin) {
    _margin = margin;
    return this;
  }
  
  /// 设置内边距
  VirtualCharacterBuilder padding(EdgeInsets? padding) {
    _padding = padding;
    return this;
  }
  
  /// 设置装饰
  VirtualCharacterBuilder decoration(Decoration? decoration) {
    _decoration = decoration;
    return this;
  }
  
  /// 构建组件
  VirtualCharacter build() {
    return VirtualCharacter(
      rendererType: _rendererType,
      rendererConfig: _config,
      clickable: _clickable,
      onTap: _onTap,
      onLongPress: _onLongPress,
      constraints: _constraints,
      margin: _margin,
      padding: _padding,
      decoration: _decoration,
    );
  }
}
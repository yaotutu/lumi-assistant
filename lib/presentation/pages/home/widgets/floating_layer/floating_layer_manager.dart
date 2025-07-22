import 'package:flutter/material.dart';

/// 浮动层管理器
/// 
/// 职责：
/// - 管理浮动在背景之上的所有UI元素
/// - 控制浮动元素的层级关系和显示状态
/// - 提供统一的浮动层接口
/// 
/// 设计理念：
/// - 将所有浮动元素从背景中分离出来
/// - 实现清晰的层级架构（背景层 < 浮动层 < 弹窗层）
/// - 支持不同的浮动元素类型和位置管理
class FloatingLayerManager extends StatelessWidget {
  /// 浮动层元素列表
  final List<FloatingElement> elements;
  
  /// 是否启用调试模式（显示层级边框等）
  final bool debugMode;
  
  /// 构造函数
  const FloatingLayerManager({
    super.key,
    required this.elements,
    this.debugMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 按层级排序，确保正确的显示顺序
        ...elements
            .where((element) => element.isVisible)
            .map((element) => _buildFloatingElement(element)),
        
        // 调试信息层（最上层）
        if (debugMode) _buildDebugOverlay(),
      ],
    );
  }
  
  /// 构建单个浮动元素
  Widget _buildFloatingElement(FloatingElement element) {
    Widget child = element.child;
    
    // 添加调试边框
    if (debugMode) {
      child = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _getDebugColor(element.layer),
            width: 1.0,
          ),
        ),
        child: child,
      );
    }
    
    // 根据定位类型包装元素
    return _wrapWithPositioning(element, child);
  }
  
  /// 根据定位类型包装元素
  Widget _wrapWithPositioning(FloatingElement element, Widget child) {
    switch (element.positioning.type) {
      case FloatingPositionType.positioned:
        final pos = element.positioning as PositionedFloatingPosition;
        return Positioned(
          top: pos.top,
          bottom: pos.bottom,
          left: pos.left,
          right: pos.right,
          width: pos.width,
          height: pos.height,
          child: child,
        );
      
      case FloatingPositionType.aligned:
        final pos = element.positioning as AlignedFloatingPosition;
        return Align(
          alignment: pos.alignment,
          child: Padding(
            padding: pos.padding,
            child: child,
          ),
        );
      
      case FloatingPositionType.safeArea:
        final pos = element.positioning as SafeAreaFloatingPosition;
        return SafeArea(
          top: pos.top,
          bottom: pos.bottom,
          left: pos.left,
          right: pos.right,
          child: Padding(
            padding: pos.padding,
            child: child,
          ),
        );
      
      case FloatingPositionType.fullScreen:
        return child;
    }
  }
  
  /// 获取调试颜色
  Color _getDebugColor(FloatingLayer layer) {
    switch (layer) {
      case FloatingLayer.background:
        return Colors.blue;
      case FloatingLayer.content:
        return Colors.green;
      case FloatingLayer.overlay:
        return Colors.orange;
      case FloatingLayer.modal:
        return Colors.red;
      case FloatingLayer.system:
        return Colors.purple;
    }
  }
  
  /// 构建调试信息覆盖层
  Widget _buildDebugOverlay() {
    return Positioned(
      top: 100,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FloatingLayer Debug',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Elements: ${elements.where((e) => e.isVisible).length}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
            ...FloatingLayer.values.map((layer) {
              final count = elements.where((e) => e.layer == layer && e.isVisible).length;
              return Text(
                '${layer.name}: $count',
                style: TextStyle(
                  color: _getDebugColor(layer).withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 浮动元素定义
class FloatingElement {
  /// 元素的唯一标识
  final String id;
  
  /// 元素的层级
  final FloatingLayer layer;
  
  /// 元素的定位信息
  final FloatingPosition positioning;
  
  /// 元素的子组件
  final Widget child;
  
  /// 是否可见
  final bool isVisible;
  
  /// 元素的优先级（同层级内的排序）
  final int priority;
  
  /// 构造函数
  const FloatingElement({
    required this.id,
    required this.layer,
    required this.positioning,
    required this.child,
    this.isVisible = true,
    this.priority = 0,
  });
  
  /// 复制并修改可见性
  FloatingElement copyWith({
    bool? isVisible,
    int? priority,
    Widget? child,
  }) {
    return FloatingElement(
      id: id,
      layer: layer,
      positioning: positioning,
      child: child ?? this.child,
      isVisible: isVisible ?? this.isVisible,
      priority: priority ?? this.priority,
    );
  }
}

/// 浮动层级枚举
/// 
/// 定义不同类型浮动元素的层级关系
enum FloatingLayer {
  /// 背景层 - 最底层（实际上背景不在浮动层管理器中）
  background,
  
  /// 内容层 - 主要UI元素（如状态栏、时间显示等）
  content,
  
  /// 悬浮层 - 悬浮组件（如聊天窗口、通知等）
  overlay,
  
  /// 弹窗层 - 模态弹窗和对话框
  modal,
  
  /// 系统层 - 系统级UI（如加载指示器、错误提示等）
  system,
}

/// 浮动定位类型
enum FloatingPositionType {
  /// 使用Positioned定位
  positioned,
  
  /// 使用Align对齐
  aligned,
  
  /// 使用SafeArea安全区域
  safeArea,
  
  /// 全屏显示
  fullScreen,
}

/// 浮动定位基类
abstract class FloatingPosition {
  /// 定位类型
  final FloatingPositionType type;
  
  /// 构造函数
  const FloatingPosition(this.type);
}

/// 精确定位 - 使用Positioned
class PositionedFloatingPosition extends FloatingPosition {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? width;
  final double? height;
  
  const PositionedFloatingPosition({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.width,
    this.height,
  }) : super(FloatingPositionType.positioned);
}

/// 对齐定位 - 使用Align
class AlignedFloatingPosition extends FloatingPosition {
  final Alignment alignment;
  final EdgeInsets padding;
  
  const AlignedFloatingPosition({
    required this.alignment,
    this.padding = EdgeInsets.zero,
  }) : super(FloatingPositionType.aligned);
}

/// 安全区域定位 - 使用SafeArea
class SafeAreaFloatingPosition extends FloatingPosition {
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets padding;
  
  const SafeAreaFloatingPosition({
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.padding = EdgeInsets.zero,
  }) : super(FloatingPositionType.safeArea);
}

/// 全屏定位
class FullScreenFloatingPosition extends FloatingPosition {
  const FullScreenFloatingPosition() : super(FloatingPositionType.fullScreen);
}

/// 浮动层管理器构建器
/// 
/// 提供便捷的方法来创建和管理浮动元素
class FloatingLayerBuilder {
  final List<FloatingElement> _elements = [];
  
  /// 添加状态栏元素
  FloatingLayerBuilder addStatusBar({
    required String id,
    required Widget child,
    bool isVisible = true,
  }) {
    _elements.add(FloatingElement(
      id: id,
      layer: FloatingLayer.content,
      positioning: const SafeAreaFloatingPosition(
        bottom: false,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: child,
      isVisible: isVisible,
      priority: 100, // 高优先级，确保在顶部
    ));
    return this;
  }
  
  /// 添加中心内容元素
  FloatingLayerBuilder addCenterContent({
    required String id,
    required Widget child,
    Alignment alignment = Alignment.center,
    EdgeInsets padding = EdgeInsets.zero,
    bool isVisible = true,
  }) {
    _elements.add(FloatingElement(
      id: id,
      layer: FloatingLayer.content,
      positioning: AlignedFloatingPosition(
        alignment: alignment,
        padding: padding,
      ),
      child: child,
      isVisible: isVisible,
      priority: 50, // 中等优先级
    ));
    return this;
  }
  
  /// 添加悬浮组件
  FloatingLayerBuilder addFloatingWidget({
    required String id,
    required Widget child,
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool isVisible = true,
  }) {
    _elements.add(FloatingElement(
      id: id,
      layer: FloatingLayer.overlay,
      positioning: PositionedFloatingPosition(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
      ),
      child: child,
      isVisible: isVisible,
      priority: 0, // 默认优先级
    ));
    return this;
  }
  
  /// 添加全屏悬浮元素
  FloatingLayerBuilder addFullScreenOverlay({
    required String id,
    required Widget child,
    bool isVisible = true,
  }) {
    _elements.add(FloatingElement(
      id: id,
      layer: FloatingLayer.overlay,
      positioning: const FullScreenFloatingPosition(),
      child: child,
      isVisible: isVisible,
      priority: -10, // 低优先级，在其他悬浮元素下方
    ));
    return this;
  }
  
  /// 添加系统级元素（如MCP状态显示）
  FloatingLayerBuilder addSystemOverlay({
    required String id,
    required Widget child,
    Alignment alignment = Alignment.bottomCenter,
    EdgeInsets padding = const EdgeInsets.all(20),
    bool isVisible = true,
  }) {
    _elements.add(FloatingElement(
      id: id,
      layer: FloatingLayer.system,
      positioning: AlignedFloatingPosition(
        alignment: alignment,
        padding: padding,
      ),
      child: child,
      isVisible: isVisible,
      priority: 200, // 最高优先级，确保在最上层
    ));
    return this;
  }
  
  /// 构建浮动层管理器
  FloatingLayerManager build({bool debugMode = false}) {
    // 按层级和优先级排序
    _elements.sort((a, b) {
      final layerComparison = a.layer.index.compareTo(b.layer.index);
      if (layerComparison != 0) return layerComparison;
      return b.priority.compareTo(a.priority); // 高优先级在前
    });
    
    return FloatingLayerManager(
      elements: List.unmodifiable(_elements),
      debugMode: debugMode,
    );
  }
  
  /// 清空所有元素
  void clear() {
    _elements.clear();
  }
  
  /// 移除指定ID的元素
  void removeElement(String id) {
    _elements.removeWhere((element) => element.id == id);
  }
  
  /// 更新指定ID的元素可见性
  void updateElementVisibility(String id, bool isVisible) {
    final index = _elements.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _elements[index] = _elements[index].copyWith(isVisible: isVisible);
    }
  }
}
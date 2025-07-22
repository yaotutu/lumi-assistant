import 'package:flutter/material.dart';

/// 三层架构管理器
/// 
/// 核心架构理念：
/// 1. **纯背景层** - 只负责视觉展示，完全不可点击（渐变、图片、装饰等）
/// 2. **交互功能层** - 可点击的功能组件（日历操作、天气设置、信息面板交互等）  
/// 3. **聊天窗口层** - 浮动聊天界面，始终在最上层
/// 
/// 设计原则：
/// - 纯背景层：纯展示内容，absorb所有点击事件
/// - 交互功能层：具体的业务功能，可以响应用户交互
/// - 聊天窗口层：独立的聊天界面，不受其他层影响
/// 
/// 层级关系：背景层 < 交互功能层 < 聊天窗口层
class ThreeLayerManager extends StatelessWidget {
  /// 纯背景层组件 - 只负责视觉展示
  final Widget backgroundLayer;
  
  /// 交互功能层组件 - 可点击的功能元素
  final Widget interactiveLayer;
  
  /// 聊天窗口层组件 - 浮动聊天界面
  final Widget chatLayer;
  
  /// 是否启用调试模式（显示层级边框等）
  final bool debugMode;
  
  /// 构造函数
  const ThreeLayerManager({
    super.key,
    required this.backgroundLayer,
    required this.interactiveLayer,
    required this.chatLayer,
    this.debugMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 第一层：纯背景层 - 完全不可点击
        _buildPureBackgroundLayer(),
        
        // 第二层：交互功能层 - 可点击的功能组件
        _buildInteractiveLayer(),
        
        // 第三层：聊天窗口层 - 浮动聊天界面
        _buildChatLayer(),
        
        // 调试信息层（如果启用）
        if (debugMode) _buildDebugOverlay(),
      ],
    );
  }
  
  /// 构建纯背景层
  /// 
  /// 特点：
  /// - 使用AbsorbPointer确保完全不可点击
  /// - 只负责视觉展示（渐变、图片、装饰动画等）
  /// - 不包含任何交互元素
  Widget _buildPureBackgroundLayer() {
    Widget layer = backgroundLayer;
    
    // 添加调试边框
    if (debugMode) {
      layer = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.5),
            width: 2.0,
          ),
        ),
        child: Stack(
          children: [
            layer,
            // 调试标签
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '纯背景层',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // 确保背景层完全不可点击
    return AbsorbPointer(
      absorbing: true,
      child: layer,
    );
  }
  
  /// 构建交互功能层
  /// 
  /// 特点：
  /// - 包含可点击的功能组件
  /// - 处理用户交互（日历操作、天气设置、信息面板等）
  /// - 透明区域不阻挡下层显示
  Widget _buildInteractiveLayer() {
    Widget layer = interactiveLayer;
    
    // 添加调试边框
    if (debugMode) {
      layer = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.5),
            width: 2.0,
          ),
        ),
        child: Stack(
          children: [
            layer,
            // 调试标签
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '交互功能层',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return layer;
  }
  
  /// 构建聊天窗口层
  /// 
  /// 特点：
  /// - 浮动聊天界面
  /// - 始终在最上层
  /// - 独立的交互逻辑
  Widget _buildChatLayer() {
    Widget layer = chatLayer;
    
    // 添加调试边框
    if (debugMode) {
      layer = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.5),
            width: 2.0,
          ),
        ),
        child: Stack(
          children: [
            layer,
            // 调试标签
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '聊天窗口层',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return layer;
  }
  
  /// 构建调试信息覆盖层
  Widget _buildDebugOverlay() {
    return Positioned(
      top: 80,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🏗️ 三层架构调试',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDebugLayerInfo('1️⃣ 纯背景层', '只展示，不可点击', Colors.blue),
            const SizedBox(height: 4),
            _buildDebugLayerInfo('2️⃣ 交互功能层', '可点击功能组件', Colors.green),
            const SizedBox(height: 4),
            _buildDebugLayerInfo('3️⃣ 聊天窗口层', '浮动聊天界面', Colors.orange),
            const SizedBox(height: 8),
            Text(
              '点击状态检测：',
              style: TextStyle(
                color: Colors.yellow.withValues(alpha: 0.9),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '✅ 交互层可点击',
              style: TextStyle(
                color: Colors.green.withValues(alpha: 0.8),
                fontSize: 9,
              ),
            ),
            Text(
              '🚫 背景层已阻止',
              style: TextStyle(
                color: Colors.blue.withValues(alpha: 0.8),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建调试层信息项
  Widget _buildDebugLayerInfo(String title, String description, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 三层架构构建器
/// 
/// 提供便捷的方法来构建三层架构管理器
class ThreeLayerBuilder {
  Widget? _backgroundLayer;
  Widget? _interactiveLayer;
  Widget? _chatLayer;
  bool _debugMode = false;
  
  /// 设置纯背景层
  ThreeLayerBuilder setBackgroundLayer(Widget background) {
    _backgroundLayer = background;
    return this;
  }
  
  /// 设置交互功能层
  ThreeLayerBuilder setInteractiveLayer(Widget interactive) {
    _interactiveLayer = interactive;
    return this;
  }
  
  /// 设置聊天窗口层
  ThreeLayerBuilder setChatLayer(Widget chat) {
    _chatLayer = chat;
    return this;
  }
  
  /// 启用调试模式
  ThreeLayerBuilder enableDebug([bool enable = true]) {
    _debugMode = enable;
    return this;
  }
  
  /// 构建三层架构管理器
  ThreeLayerManager build() {
    assert(_backgroundLayer != null, '必须设置背景层');
    assert(_interactiveLayer != null, '必须设置交互功能层');
    assert(_chatLayer != null, '必须设置聊天窗口层');
    
    return ThreeLayerManager(
      backgroundLayer: _backgroundLayer!,
      interactiveLayer: _interactiveLayer!,
      chatLayer: _chatLayer!,
      debugMode: _debugMode,
    );
  }
}
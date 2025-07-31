import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../background_system/simple_wallpaper_manager.dart';
import '../status_bar/status_bar_widget.dart';
import '../actions/actions_widget.dart';
import '../floating_chat/floating_chat_widget.dart';
import '../../../../widgets/mcp/mcp_call_status_widget.dart';
import '../../../../widgets/notification_bubble.dart';

/// 主页布局管理器
/// 
/// 管理四大区域的布局和层级关系：
/// 1. **背景区域** - 最底层，纯视觉展示，不可交互
/// 2. **状态栏区域** - 始终在屏幕顶部，显示应用状态和设置入口
/// 3. **操作区域** - 可放置在任意位置，提供各种功能操作
/// 4. **浮动聊天区域** - 最顶层，聊天界面和系统组件
/// 
/// 设计理念：
/// - 清晰的层级分离，每个区域职责明确
/// - 高度可配置，支持不同的布局需求
/// - 易于扩展，可以轻松添加新的功能区域
class HomeLayoutManager extends ConsumerWidget {
  /// 是否显示操作区域
  final bool showActions;
  
  /// 操作区域位置
  final ActionsPosition actionsPosition;
  
  /// 是否显示扩展操作
  final bool showExtendedActions;
  
  /// 是否启用调试模式
  final bool enableDebug;
  
  /// 构造函数
  const HomeLayoutManager({
    super.key,
    this.showActions = false,
    this.actionsPosition = ActionsPosition.center,
    this.showExtendedActions = false,
    this.enableDebug = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 第一层：背景区域（最底层，不可交互）
        _buildBackgroundLayer(),
        
        // 第二层：状态栏区域（顶部固定）
        _buildStatusBarLayer(),
        
        // 第三层：操作区域（可选，位置可配置）
        if (showActions) _buildActionsLayer(),
        
        // 第四层：浮动聊天区域（最顶层）
        _buildFloatingChatLayer(),
        
        // 通知气泡层
        _buildNotificationLayer(),
        
        // 调试信息层（开发时使用）
        if (enableDebug) _buildDebugInfoLayer(),
      ],
    );
  }
  
  /// 构建背景层
  Widget _buildBackgroundLayer() {
    return const AbsorbPointer(
      child: SimpleWallpaperManager(),
    );
  }
  
  /// 构建状态栏层
  Widget _buildStatusBarLayer() {
    return const StatusBarWidget();
  }
  
  /// 构建操作层
  Widget _buildActionsLayer() {
    return ActionsWidget(
      position: actionsPosition,
      showExtendedActions: showExtendedActions,
    );
  }
  
  /// 构建浮动聊天层
  Widget _buildFloatingChatLayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 主要聊天界面
        const FloatingChatWidget(
          initialState: FloatingChatState.collapsed,
        ),
        
        // MCP调用状态显示
        const McpCallStatusWidget(),
      ],
    );
  }
  
  /// 构建通知气泡层
  Widget _buildNotificationLayer() {
    return ListenableBuilder(
      listenable: NotificationBubbleManager.instance,
      builder: (context, child) {
        // 计算与右侧聊天气泡对称的位置
        final screenSize = MediaQuery.of(context).size;
        final bubbleSize = 80.0;
        final bottomMargin = 80.0; // 与右侧保持一致
        final verticalPosition = screenSize.height - bubbleSize - bottomMargin;
        
        return Positioned(
          left: 16,  // 距离左边 16 像素
          top: verticalPosition,
          child: const NotificationBubble(
            alignment: Alignment.topLeft,  // 使用 Positioned，所以改为 topLeft
            size: 80,  // 与右侧语音助手按钮保持一致
            margin: EdgeInsets.zero,  // 使用 Positioned 定位，不需要 margin
          ),
        );
      },
    );
  }
  
  /// 构建调试信息层
  Widget _buildDebugInfoLayer() {
    return Positioned(
      top: 80,
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
              'Debug Info',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Layout: HomeLayoutManager',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Background: Managed by SimpleWallpaperManager',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Actions: ${showActions ? 'Shown' : 'Hidden'}',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

/// 布局管理器建造者模式
/// 
/// 提供链式调用API，方便配置复杂的布局
class HomeLayoutBuilder {
  bool _showActions = false;
  ActionsPosition _actionsPosition = ActionsPosition.center;
  bool _showExtendedActions = false;
  bool _enableDebug = false;
  
  /// 启用操作区域
  HomeLayoutBuilder enableActions({
    ActionsPosition position = ActionsPosition.center,
    bool showExtended = false,
  }) {
    _showActions = true;
    _actionsPosition = position;
    _showExtendedActions = showExtended;
    return this;
  }
  
  /// 禁用操作区域
  HomeLayoutBuilder disableActions() {
    _showActions = false;
    return this;
  }
  
  /// 启用调试模式
  HomeLayoutBuilder enableDebug() {
    _enableDebug = true;
    return this;
  }
  
  /// 构建布局管理器
  HomeLayoutManager build() {
    return HomeLayoutManager(
      showActions: _showActions,
      actionsPosition: _actionsPosition,
      showExtendedActions: _showExtendedActions,
      enableDebug: _enableDebug,
    );
  }
}

/// 快捷构建方法
extension HomeLayoutManagerExtensions on HomeLayoutManager {
  /// 创建默认布局
  static HomeLayoutManager createDefault() {
    return HomeLayoutBuilder()
        .disableActions()
        .build();
  }
  
  /// 创建带操作区域的布局
  static HomeLayoutManager createWithActions({
    ActionsPosition position = ActionsPosition.center,
    bool showExtended = false,
  }) {
    return HomeLayoutBuilder()
        .enableActions(position: position, showExtended: showExtended)
        .build();
  }
  
  /// 创建电子相册布局（背景由SimpleWallpaperManager统一管理）
  static HomeLayoutManager createPhotoAlbum() {
    return HomeLayoutBuilder()
        .disableActions()
        .build();
  }
  
  /// 创建开发调试布局
  static HomeLayoutManager createDebug() {
    return HomeLayoutBuilder()
        .enableActions(position: ActionsPosition.bottom, showExtended: true)
        .enableDebug()
        .build();
  }
}
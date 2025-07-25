import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/unified_mcp_manager.dart';
import '../../widgets/mcp/mcp_change_notification.dart';
import 'widgets/layout/home_layout_manager.dart';

/// 应用主页 - 四区域架构设计
/// 
/// 核心架构理念：
/// 1. **背景区域** - 最底层，纯视觉展示，完全不可交互
/// 2. **状态栏区域** - 始终在屏幕顶部，显示应用状态和设置入口
/// 3. **操作区域** - 可放置在任意位置，提供各种功能操作
/// 4. **浮动聊天区域** - 最顶层，聊天界面和系统组件
/// 
/// 层级关系：背景区域 < 状态栏区域 < 操作区域 < 浮动聊天区域
/// 
/// 特点：
/// - 完全分离的四区域结构，各区域职责清晰
/// - 背景区域完全不可交互，仅负责视觉效果
/// - 状态栏区域固定在顶部，提供核心功能入口
/// - 操作区域位置灵活，可根据需要配置
/// - 浮动聊天区域独立管理，不受其他区域影响
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 设置MCP变化通知回调
    useEffect(() {
      final mcpManager = ref.read(unifiedMcpManagerProvider);
      mcpManager.setUserNotificationCallback((title, message) {
        McpChangeNotification.show(context, title, message);
      });
      return null;
    }, []);

    return Scaffold(
      body: _buildHomeLayout(context, ref),
    );
  }
  
  /// 构建主页布局
  /// 
  /// 使用HomeLayoutManager管理四个功能区域
  Widget _buildHomeLayout(BuildContext context, WidgetRef ref) {
    return HomeLayoutManagerExtensions.createPhotoAlbum();
  }
}

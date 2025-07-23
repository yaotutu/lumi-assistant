import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/unified_mcp_manager.dart';
import '../../widgets/floating_chat/floating_chat_widget.dart';
import '../../widgets/mcp/mcp_call_status_widget.dart';
import '../../widgets/mcp/mcp_change_notification.dart';
import 'widgets/three_layer/three_layer_manager.dart';
import 'widgets/three_layer/simple_interactive_layer.dart';
import 'widgets/background_system/background_system_manager.dart';

/// 应用主页 - 三层架构设计
/// 
/// 核心架构理念：
/// 1. **纯背景层** - 只负责视觉展示，完全不可点击（渐变、图片、时间显示等）
/// 2. **交互功能层** - 可点击的功能组件（设置、wifi状态、各种功能按钮等）  
/// 3. **聊天窗口层** - 浮动聊天界面，始终在最上层
/// 
/// 层级关系：背景层 < 交互功能层 < 聊天窗口层
/// 
/// 特点：
/// - 完全分离的三层结构，各层职责清晰
/// - 背景层使用AbsorbPointer确保不可点击
/// - 交互层处理所有用户交互操作
/// - 聊天层独立浮动，不受其他层影响
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
      body: _buildThreeLayerArchitecture(context, ref),
    );
  }
  
  /// 构建三层架构
  /// 
  /// 使用ThreeLayerBuilder来构建清晰分离的三层结构
  Widget _buildThreeLayerArchitecture(BuildContext context, WidgetRef ref) {
    return ThreeLayerBuilder()
        // 第一层：纯背景层 - 只负责视觉展示，完全不可点击
        .setBackgroundLayer(
          _buildPureBackground(context),
        )
        
        // 第二层：交互功能层 - 只包含顶部设置区域
        .setInteractiveLayer(
          const SimpleInteractiveLayer(),
        )
        
        // 第三层：聊天窗口层 - 浮动聊天界面
        .setChatLayer(
          _buildChatLayer(context, ref),
        )
        
        // 启用调试模式（开发环境可以设置为true）
        .enableDebug(false) // 生产环境设置为false
        
        // 构建最终的三层架构管理器
        .build();
  }
  
  /// 构建纯背景层
  /// 
  /// 使用专业的背景系统管理器，支持复杂的背景功能
  Widget _buildPureBackground(BuildContext context) {
    return const BackgroundSystemManager(
      mode: BackgroundSystemMode.minimal, // 当前使用极简模式
      config: BackgroundSystemConfig.defaultConfig,
    );
  }
  
  /// 构建聊天窗口层
  /// 
  /// 只包含聊天窗口和必要的系统组件
  Widget _buildChatLayer(BuildContext context, WidgetRef ref) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 悬浮聊天窗口 - 主要功能
        const FloatingChatWidget(
          initialState: FloatingChatState.collapsed,
        ),
        
        // MCP调用状态显示 - 系统必要组件
        const McpCallStatusOverlay(),
      ],
    );
  }

  // 三层架构实现完成
  // 
  // 架构总结：
  // 1. 纯背景层 - 渐变背景 + 时间显示 + 装饰效果（完全不可点击）
  // 2. 交互功能层 - 状态栏 + 各种功能按钮（可点击交互）
  // 3. 聊天窗口层 - 聊天界面 + 系统组件（独立浮动）
  // 
  // 优势：
  // - 职责清晰分离，易于维护
  // - 背景纯展示，交互层专门处理用户操作
  // - 聊天窗口独立，不受其他层影响
  // - 支持灵活的功能扩展
}

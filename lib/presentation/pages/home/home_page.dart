import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/connection_status_widget.dart';
import '../../widgets/handshake_status_widget.dart';
import '../chat/chat_page.dart';
import 'widgets/background_layer.dart';
import 'widgets/app_status_bar.dart';
import 'widgets/time_panel.dart';
import 'widgets/interaction_layer.dart';
import 'widgets/floating_actions.dart';

/// 应用主页 - 里程碑4：基础UI框架（重构后）
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // 底层：背景图片和基础装饰
          const BackgroundLayer(),
          
          // 底层：固定UI元素（时间、状态等）
          _buildBaseUILayer(context, ref),
          
          // 中间层：主要交互区域（为聊天、语音等预留）
          const InteractionLayer(),
          
          // 顶层：浮动操作按钮
          FloatingActions(
            onSettingsTap: () => _showSettings(context),
            onMainActionTap: () => _startChat(context),
          ),
        ],
      ),
    );
  }

  /// 构建底层固定UI元素
  Widget _buildBaseUILayer(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          // 顶部状态栏（轻量化）
          AppStatusBar(
            onConnectionTap: () => _showConnectionDetails(context),
            onHandshakeTap: () => _showHandshakeDetails(context),
          ),
          
          const Spacer(),
          
          // 底部时间信息（固定在底部）
          const TimePanel(),
        ],
      ),
    );
  }
  
  /// 显示连接详情对话框
  void _showConnectionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: const ConnectionStatusCard(),
        ),
      ),
    );
  }

  /// 显示握手详情对话框
  void _showHandshakeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: const HandshakeStatusCard(),
        ),
      ),
    );
  }

  /// 显示设置界面
  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('设置功能将在后续里程碑中实现'),
        action: SnackBarAction(
          label: '确定',
          onPressed: () {},
        ),
      ),
    );
  }

  /// 开始聊天
  void _startChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatPage(),
      ),
    );
  }
}


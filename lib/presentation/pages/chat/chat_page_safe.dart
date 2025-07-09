import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/connection_status_widget.dart';
import '../../widgets/handshake_status_widget.dart';
import '../../providers/chat_provider.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_background.dart';

/// 安全区域聊天页面 - 防止UI溢出
class ChatPageSafe extends HookConsumerWidget {
  const ChatPageSafe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputController = useTextEditingController();
    final scrollController = useScrollController();
    final focusNode = useFocusNode();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 背景层
          const ChatBackground(),
          
          // 主要内容层 - 使用SafeArea + 滚动视图保护
          SafeArea(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // 顶部应用栏 - 使用SliverAppBar确保不溢出
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: 0,
                  toolbarHeight: 60,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: _buildAppBarContent(context),
                  ),
                ),
                
                // 消息列表区域 - 使用SliverFillRemaining
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      // 消息列表 - 使用Expanded确保占用剩余空间
                      Expanded(
                        child: ChatMessageList(
                          scrollController: scrollController,
                        ),
                      ),
                      
                      // 底部输入区域 - 固定在底部
                      Container(
                        constraints: const BoxConstraints(
                          minHeight: 60,
                          maxHeight: 200,
                        ),
                        child: ChatInputBar(
                          controller: inputController,
                          focusNode: focusNode,
                          scrollController: scrollController,
                          onSendMessage: (message) => _sendMessage(context, ref, message),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建应用栏内容
  Widget _buildAppBarContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white.withValues(alpha: 0.9),
              size: 20,
            ),
            tooltip: '返回',
          ),
          
          const SizedBox(width: 8),
          
          // 应用信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.assistant,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Lumi Assistant',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '智能语音助手',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 连接状态指示器
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConnectionStatusWidget(
                showDetails: false,
                onTap: () => _showConnectionDetails(context),
              ),
              const SizedBox(width: 6),
              HandshakeStatusWidget(
                showDetails: false,
                onTap: () => _showHandshakeDetails(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  /// 发送消息
  void _sendMessage(BuildContext context, WidgetRef ref, String message) {
    if (message.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(message);
  }

  /// 显示连接详情对话框
  void _showConnectionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: const HandshakeStatusCard(),
        ),
      ),
    );
  }
}
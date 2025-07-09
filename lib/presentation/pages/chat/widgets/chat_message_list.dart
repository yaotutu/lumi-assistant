import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../data/models/chat_ui_model.dart';
import '../../../providers/chat_provider.dart';
import 'chat_message_item.dart';

/// 聊天消息列表组件
class ChatMessageList extends HookConsumerWidget {
  final ScrollController scrollController;
  final bool isCompact;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用聊天状态管理
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;

    // 自动滚动到底部（当有新消息时）
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      return null;
    }, [messages.length]);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8.0 : 16.0,
        vertical: isCompact ? 4.0 : 8.0,
      ),
      child: messages.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isLastMessage = index == messages.length - 1;
                final nextMessage = index < messages.length - 1 
                    ? messages[index + 1] 
                    : null;
                
                return ChatMessageItem(
                  message: message,
                  isLastMessage: isLastMessage,
                  showAvatar: _shouldShowAvatar(message, nextMessage),
                  isCompact: isCompact,
                  onResend: message.canResend 
                      ? () => _resendMessage(context, ref, message)
                      : null,
                );
              },
            ),
    );
  }

  /// 构建空状态界面
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '开始对话',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '发送消息开始与助手对话',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 判断是否显示头像
  bool _shouldShowAvatar(ChatUIMessage current, ChatUIMessage? next) {
    if (current.isUser) return false; // 用户消息不显示头像
    if (next == null) return true; // 最后一条消息显示头像
    
    // 如果下一条消息是不同发送者，显示头像
    return current.sender != next.sender;
  }

  /// 重新发送消息
  void _resendMessage(BuildContext context, WidgetRef ref, ChatUIMessage message) {
    // 使用聊天状态管理重新发送消息
    ref.read(chatProvider.notifier).resendMessage(message.id);
  }
}
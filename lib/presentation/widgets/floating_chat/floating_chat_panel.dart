/// 悬浮聊天面板
/// 
/// 聊天界面的主要内容区域
/// 包含消息列表、输入框、控制按钮等
library;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../providers/virtual_character_provider.dart';
import '../virtual_character/models/character_enums.dart';
import '../../../data/models/chat_state.dart';
import '../../../data/models/chat_ui_model.dart';

/// 悬浮聊天面板
/// 
/// 功能特性：
/// - 消息列表显示
/// - 文本输入和发送
/// - 虚拟人物状态同步
/// - 响应式布局适配
/// - 关闭按钮
class FloatingChatPanel extends HookConsumerWidget {
  /// 关闭回调
  final VoidCallback? onClose;
  
  /// 是否为横屏模式
  final bool isLandscape;
  
  /// 构造函数
  const FloatingChatPanel({
    super.key,
    this.onClose,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取聊天状态
    final chatState = ref.watch(chatProvider);
    final characterNotifier = ref.read(virtualCharacterProvider.notifier);
    
    // 滚动控制器
    final scrollController = useScrollController();
    
    
    // 监听聊天状态变化，同步虚拟人物状态
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.isBusy != next.isBusy) {
        if (next.isBusy) {
          characterNotifier.updateStatus(CharacterStatus.thinking);
        } else {
          characterNotifier.updateStatus(CharacterStatus.idle);
        }
      }
    });
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 顶部标题栏
          _buildTitleBar(context, ref),
          
          const SizedBox(height: 12),
          
          // 消息列表
          Expanded(
            child: _buildMessageList(context, ref, chatState, scrollController),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  /// 构建标题栏
  Widget _buildTitleBar(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // 标题
        const Expanded(
          child: Text(
            '聊天助手',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        
        // 关闭按钮
        if (onClose != null)
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
            tooltip: '关闭',
          ),
      ],
    );
  }
  
  /// 构建消息列表
  Widget _buildMessageList(
    BuildContext context,
    WidgetRef ref,
    ChatState chatState,
    ScrollController scrollController,
  ) {
    if (chatState.messages.isEmpty && !chatState.isBusy) {
      return _buildEmptyState(context);
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chatState.messages.length + (chatState.isBusy ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == chatState.messages.length) {
            // 加载指示器
            return _buildLoadingIndicator(context);
          }
          
          final message = chatState.messages[index];
          return _buildMessageItem(context, message, index);
        },
      ),
    );
  }
  
  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '开始对话吧！',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '输入消息与AI助手聊天',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建加载指示器
  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '正在思考...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建消息项
  Widget _buildMessageItem(BuildContext context, ChatUIMessage message, int index) {
    final isUser = message.isUser;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // AI头像
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          // 消息内容
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue.shade500 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 13,
                  color: isUser ? Colors.white : Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 12),
            // 用户头像
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
}
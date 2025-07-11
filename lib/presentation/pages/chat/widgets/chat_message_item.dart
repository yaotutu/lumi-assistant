import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/chat_ui_model.dart';

/// 聊天消息项组件
class ChatMessageItem extends StatelessWidget {
  final ChatUIMessage message;
  final bool isLastMessage;
  final bool showAvatar;
  final bool isCompact;
  final VoidCallback? onResend;

  const ChatMessageItem({
    super.key,
    required this.message,
    this.isLastMessage = false,
    this.showAvatar = true,
    this.isCompact = false,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isLastMessage ? (isCompact ? 8 : 16) : (isCompact ? 4 : 8),
        top: message.isSystem ? (isCompact ? 8 : 16) : 0,
      ),
      child: message.isSystem
          ? _buildSystemMessage(context)
          : _buildChatMessage(context),
    );
  }

  /// 构建系统消息
  Widget _buildSystemMessage(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isCompact ? 240 : 280,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF455A64).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          message.content,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.4,
            fontSize: isCompact ? 11 : null,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 构建聊天消息
  Widget _buildChatMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: message.isUser 
          ? MainAxisAlignment.end 
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 助手头像
        if (message.isAssistant && showAvatar) ...[
          _buildAvatar(),
          const SizedBox(width: 8),
        ],
        
        // 消息内容
        Flexible(
          child: Column(
            crossAxisAlignment: message.isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              _buildMessageBubble(context),
              
              // 消息状态和时间
              const SizedBox(height: 4),
              _buildMessageInfo(context),
            ],
          ),
        ),
        
        // 用户头像占位
        if (message.isUser) ...[
          const SizedBox(width: 8),
          _buildUserAvatar(),
        ],
      ],
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF37474F).withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.assistant,
        color: Colors.white.withValues(alpha: 0.9),
        size: 16,
      ),
    );
  }

  /// 构建用户头像
  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2).withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getBubbleColor(),
          borderRadius: _getBubbleRadius(),
          border: Border.all(
            color: _getBorderColor(),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 语音输入标识
            if (_isVoiceInput())
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mic,
                      size: 14,
                      color: _getTextColor().withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '语音输入',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getTextColor().withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            
            // 消息内容
            Text(
              message.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getTextColor(),
                height: 1.4,
              ),
            ),
            
            // 错误信息
            if (message.isError && message.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                message.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red[300],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            // 失败重发按钮
            if (message.canResend && onResend != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onResend,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重新发送'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建消息信息
  Widget _buildMessageInfo(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 时间
        Text(
          _formatTime(message.timestamp),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
        
        // 状态
        if (message.isProcessing) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
        
        // 失败状态
        if (message.status == ChatMessageStatus.failed) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.error_outline,
            size: 12,
            color: Colors.red[300],
          ),
        ],
      ],
    );
  }

  /// 获取气泡颜色
  Color _getBubbleColor() {
    if (message.isError) {
      return Colors.red.withValues(alpha: 0.2);
    } else if (message.isUser) {
      // 用户消息 - 更深的蓝色背景
      return const Color(0xFF1976D2).withValues(alpha: 0.8);
    } else {
      // 助手消息 - 更深的灰色背景
      return const Color(0xFF37474F).withValues(alpha: 0.9);
    }
  }

  /// 获取边框颜色
  Color _getBorderColor() {
    if (message.isError) {
      return Colors.red.withValues(alpha: 0.5);
    } else if (message.isUser) {
      return const Color(0xFF1976D2).withValues(alpha: 0.4);
    } else {
      return const Color(0xFF37474F).withValues(alpha: 0.3);
    }
  }

  /// 获取文字颜色
  Color _getTextColor() {
    if (message.isError) {
      return Colors.red[200] ?? Colors.red;
    } else if (message.isUser) {
      // 用户消息 - 白色文字
      return Colors.white;
    } else {
      // 助手消息 - 白色文字
      return Colors.white.withValues(alpha: 0.95);
    }
  }

  /// 获取气泡圆角
  BorderRadius _getBubbleRadius() {
    const double radius = 16;
    if (message.isUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 检查是否为语音输入
  bool _isVoiceInput() {
    return message.metadata?['isVoiceInput'] == true;
  }

  /// 显示消息选项
  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.white),
              title: const Text('复制', style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              },
            ),
            if (message.canResend && onResend != null)
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.white),
                title: const Text('重新发送', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  onResend!();
                },
              ),
          ],
        ),
      ),
    );
  }
}
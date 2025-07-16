import 'package:flutter/material.dart';
import '../../../data/models/chat_ui_model.dart';

/// 聊天消息项组件
/// 
/// 支持用户消息和AI消息的不同显示样式
/// 根据紧凑模式调整尺寸和间距
class ChatMessageItem extends StatelessWidget {
  /// 消息数据
  final ChatUIMessage message;
  
  /// 是否为紧凑模式
  final bool isCompact;
  
  /// 构造函数
  const ChatMessageItem({
    super.key,
    required this.message,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    // 性能优化：预计算尺寸值，减少运行时计算
    final avatarSize = isCompact ? 24.0 : 32.0;
    final padding = isCompact ? 12.0 : 16.0;
    final verticalPadding = isCompact ? 6.0 : 8.0;
    final messagePadding = isCompact ? 8.0 : 12.0;
    final avatarSpacing = isCompact ? 8.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding, 
        vertical: verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // AI头像
            _buildAvatar(
              backgroundColor: Colors.blue.shade100,
              icon: Icons.smart_toy,
              iconColor: Colors.blue,
              size: avatarSize,
            ),
            SizedBox(width: avatarSpacing),
          ],
          
          // 消息内容
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: messagePadding, 
                vertical: messagePadding,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue.shade500 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 消息文本
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  
                  // 如果有元数据，显示额外信息
                  if (message.metadata != null && message.metadata!.isNotEmpty)
                    _buildMetadata(context, isUser),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            SizedBox(width: avatarSpacing),
            // 用户头像
            _buildAvatar(
              backgroundColor: Colors.grey.shade300,
              icon: Icons.person,
              iconColor: Colors.grey,
              size: avatarSize,
            ),
          ],
        ],
      ),
    );
  }
  
  /// 构建头像
  Widget _buildAvatar({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.5,
          color: iconColor,
        ),
      ),
    );
  }
  
  /// 构建元数据信息
  Widget _buildMetadata(BuildContext context, bool isUser) {
    final metadata = message.metadata!;
    final isVoiceInput = metadata['isVoiceInput'] as bool? ?? false;
    
    if (!isVoiceInput) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic,
            size: 12.0, // 使用固定小尺寸，会被全局fontScale缩放
            color: isUser 
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            '语音输入',
            style: TextStyle(
              fontSize: 10.0, // 使用固定小字体，会被全局fontScale缩放
              color: isUser 
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
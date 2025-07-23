import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 简化的浮动聊天组件
/// 
/// 临时替代复杂的FloatingChatWidget，避免导入路径问题
/// 后续可以逐步完善功能
class SimpleFloatingChat extends ConsumerWidget {
  const SimpleFloatingChat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: _buildFloatingButton(context),
    );
  }
  
  /// 构建浮动按钮
  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleChatTap(context),
          borderRadius: BorderRadius.circular(40),
          child: const Center(
            child: Text(
              '🙂',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 处理聊天按钮点击
  void _handleChatTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💬 聊天功能（简化版本）'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
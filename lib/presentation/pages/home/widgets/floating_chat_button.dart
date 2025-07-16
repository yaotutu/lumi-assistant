/// 浮动聊天按钮组件
/// 
/// 在首页右下角显示的聊天入口按钮
/// 与悬浮聊天图标保持一致的设计风格
library;

import 'package:flutter/material.dart';

/// 浮动聊天按钮组件
class FloatingChatButton extends StatelessWidget {
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 按钮大小
  final double size;
  
  /// 按钮图标
  final IconData icon;
  
  /// 按钮标签
  final String? label;
  
  /// 构造函数
  const FloatingChatButton({
    super.key,
    this.onTap,
    this.size = 64.0,
    this.icon = Icons.chat_bubble_outline,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400.withValues(alpha: 0.9),
            Colors.purple.shade400.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: size * 0.4,
                  color: Colors.white,
                ),
                if (label != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    label!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
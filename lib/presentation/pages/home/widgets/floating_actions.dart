import 'package:flutter/material.dart';

/// 浮动操作按钮组件 - 右下角的操作按钮
class FloatingActions extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onMainActionTap;
  final String mainActionLabel;
  final IconData mainActionIcon;

  const FloatingActions({
    super.key,
    this.onSettingsTap,
    this.onMainActionTap,
    this.mainActionLabel = '开始对话',
    this.mainActionIcon = Icons.chat_bubble_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140, // 留出底部时间面板的空间
      right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 设置按钮（更小更精致）
          FloatingActionButton.small(
            heroTag: "settings",
            onPressed: onSettingsTap,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            foregroundColor: Colors.white,
            child: const Icon(Icons.settings, size: 20),
          ),
          const SizedBox(height: 12),
          
          // 主要操作按钮（更现代的设计）
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              heroTag: "main_action",
              onPressed: onMainActionTap,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              icon: Icon(mainActionIcon),
              label: Text(
                mainActionLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
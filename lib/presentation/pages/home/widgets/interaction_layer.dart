import 'package:flutter/material.dart';

/// 交互层组件 - 主要交互区域，为聊天/语音功能预留空间
class InteractionLayer extends StatelessWidget {
  final Widget? child;

  const InteractionLayer({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // 顶部预留区域（可用于语音波形、状态提示等）
            const SizedBox(height: 80), // 为状态栏预留空间
            
            // 中央主要交互区域
            Expanded(
              child: Container(
                width: double.infinity,
                // 这里将是聊天消息列表或语音交互界面的容器
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05), // 非常淡的背景
                  borderRadius: BorderRadius.circular(20),
                ),
                child: child ?? _buildPlaceholderContent(context),
              ),
            ),
            
            // 底部预留区域（可用于输入框、语音按钮等）
            const SizedBox(height: 120), // 为底部时间面板和按钮预留空间
          ],
        ),
      ),
    );
  }

  /// 构建占位内容（当前里程碑进度显示）
  Widget _buildPlaceholderContent(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 里程碑图标
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.white.withValues(alpha: 0.8),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            
            // 完成提示
            Text(
              '里程碑4：基础UI框架',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            Text(
              '已完成 ✓',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.green[300],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // 说明文字
            Text(
              '界面布局已优化为分层结构\n准备就绪，等待下一个里程碑',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
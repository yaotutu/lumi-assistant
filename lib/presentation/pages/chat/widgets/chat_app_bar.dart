import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../widgets/connection_status_widget.dart';
import '../../../widgets/handshake_status_widget.dart';

/// 聊天页面顶部应用栏
class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onConnectionTap;
  final VoidCallback? onHandshakeTap;

  const ChatAppBar({
    super.key,
    this.onBackPressed,
    this.onConnectionTap,
    this.onHandshakeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 返回按钮
            IconButton(
              onPressed: onBackPressed,
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
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
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
                  onTap: onConnectionTap,
                ),
                const SizedBox(width: 6),
                HandshakeStatusWidget(
                  showDetails: false,
                  onTap: onHandshakeTap,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../widgets/connection_status_widget.dart';
import '../../../widgets/handshake_status_widget.dart';

/// 应用状态栏组件 - 显示应用名称和连接状态
class AppStatusBar extends ConsumerWidget {
  final VoidCallback? onConnectionTap;
  final VoidCallback? onHandshakeTap;

  const AppStatusBar({
    super.key,
    this.onConnectionTap,
    this.onHandshakeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          // 简化的应用标识
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assistant,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 精简的连接状态指示器
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConnectionStatusWidget(
                showDetails: false, // 简化显示
                onTap: onConnectionTap,
              ),
              const SizedBox(width: 6),
              HandshakeStatusWidget(
                showDetails: false, // 简化显示
                onTap: onHandshakeTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
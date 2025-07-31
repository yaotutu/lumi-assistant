import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/network/handshake_service.dart';
import '../providers/connection_provider.dart';

/// 握手状态组件
class HandshakeStatusWidget extends ConsumerWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const HandshakeStatusWidget({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handshakeResult = ref.watch(handshakeServiceProvider);
    final isConnected = ref.watch(isConnectedProvider);

    // 只有在WebSocket连接成功时才显示握手状态
    if (!isConnected) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(handshakeResult.state).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(handshakeResult.state),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 状态图标
            _buildStatusIcon(handshakeResult.state),
            const SizedBox(width: 6),
            
            // 状态文本
            Text(
              _getStatusText(handshakeResult.state),
              style: TextStyle(
                color: _getStatusColor(handshakeResult.state),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            if (showDetails) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: _getStatusColor(handshakeResult.state),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建状态图标
  Widget _buildStatusIcon(HandshakeState state) {
    switch (state) {
      case HandshakeState.idle:
        return Icon(
          Icons.pause_circle_outline,
          size: 14,
          color: _getStatusColor(state),
        );
      case HandshakeState.handshaking:
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_getStatusColor(state)),
          ),
        );
      case HandshakeState.completed:
        return Icon(
          Icons.check_circle,
          size: 14,
          color: _getStatusColor(state),
        );
      case HandshakeState.failed:
      case HandshakeState.timeout:
        return Icon(
          Icons.error_outline,
          size: 14,
          color: _getStatusColor(state),
        );
    }
  }

  /// 获取状态文本
  String _getStatusText(HandshakeState state) {
    switch (state) {
      case HandshakeState.idle:
        return '未握手';
      case HandshakeState.handshaking:
        return '握手中';
      case HandshakeState.completed:
        return '已握手';
      case HandshakeState.failed:
        return '握手失败';
      case HandshakeState.timeout:
        return '握手超时';
    }
  }

  /// 获取状态颜色
  Color _getStatusColor(HandshakeState state) {
    switch (state) {
      case HandshakeState.idle:
        return Colors.grey;
      case HandshakeState.handshaking:
        return Colors.blue;
      case HandshakeState.completed:
        return Colors.green;
      case HandshakeState.failed:
      case HandshakeState.timeout:
        return Colors.red;
    }
  }
}

/// 握手状态详情卡片
class HandshakeStatusCard extends ConsumerWidget {
  const HandshakeStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handshakeResult = ref.watch(handshakeServiceProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.handshake,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '握手状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 握手状态
            _buildSimpleStatusRow(
              context,
              '握手状态',
              _getStatusText(handshakeResult.state),
              _getStatusColor(handshakeResult.state),
            ),
            
            if (handshakeResult.sessionId != null) ...[
              const SizedBox(height: 8),
              _buildSimpleInfoRow(
                context,
                '会话ID',
                '${handshakeResult.sessionId!.substring(0, 8)}...',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建简化状态行
  Widget _buildSimpleStatusRow(
    BuildContext context,
    String label,
    String status,
    Color statusColor,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建简化信息行
  Widget _buildSimpleInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 获取状态文本
  String _getStatusText(HandshakeState state) {
    switch (state) {
      case HandshakeState.idle:
        return '未握手';
      case HandshakeState.handshaking:
        return '握手中';
      case HandshakeState.completed:
        return '已握手';
      case HandshakeState.failed:
        return '握手失败';
      case HandshakeState.timeout:
        return '握手超时';
    }
  }

  /// 获取状态颜色
  Color _getStatusColor(HandshakeState state) {
    switch (state) {
      case HandshakeState.idle:
        return Colors.grey;
      case HandshakeState.handshaking:
        return Colors.blue;
      case HandshakeState.completed:
        return Colors.green;
      case HandshakeState.failed:
      case HandshakeState.timeout:
        return Colors.red;
    }
  }
}
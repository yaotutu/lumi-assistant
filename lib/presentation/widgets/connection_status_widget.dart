import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/connection_provider.dart';
import '../../core/services/websocket_service.dart';
import '../../core/services/network_checker.dart';
import '../../data/models/websocket_state.dart';

/// 连接状态显示组件
class ConnectionStatusWidget extends HookConsumerWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const ConnectionStatusWidget({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionManagerProvider);
    final connectionStatus = ref.watch(connectionStatusProvider);
    final isConnected = ref.watch(isConnectedProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor(connectionState.webSocketState.connectionState).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor(connectionState.webSocketState.connectionState),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 状态指示点
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(connectionState.webSocketState.connectionState),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            
            // 状态文本
            Text(
              connectionStatus,
              style: TextStyle(
                color: _getStatusColor(connectionState.webSocketState.connectionState),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            if (showDetails) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: _getStatusColor(connectionState.webSocketState.connectionState),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(WebSocketConnectionState state) {
    switch (state) {
      case WebSocketConnectionState.connected:
        return Colors.green;
      case WebSocketConnectionState.connecting:
      case WebSocketConnectionState.reconnecting:
        return Colors.orange;
      case WebSocketConnectionState.failed:
        return Colors.red;
      case WebSocketConnectionState.disconnected:
        return Colors.grey;
    }
  }
}

/// 连接状态详情卡片
class ConnectionStatusCard extends HookConsumerWidget {
  const ConnectionStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionManagerProvider);
    final connectionManager = ref.read(connectionManagerProvider.notifier);

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
                  Icons.network_check,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '连接状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // WebSocket状态
            _buildSimpleStatusRow(
              context,
              'WebSocket',
              _getWebSocketStatusText(connectionState.webSocketState.connectionState),
              _getStatusColor(connectionState.webSocketState.connectionState),
            ),
            
            const SizedBox(height: 16),
            
            // 简化的操作按钮
            if (!connectionState.webSocketState.isConnected)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: connectionState.webSocketState.isConnecting 
                      ? null 
                      : () => connectionManager.reconnect(),
                  icon: connectionState.webSocketState.isConnecting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(connectionState.webSocketState.isConnecting ? '连接中...' : '重新连接'),
                ),
              ),
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
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
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

  /// 获取WebSocket状态文本
  String _getWebSocketStatusText(WebSocketConnectionState state) {
    switch (state) {
      case WebSocketConnectionState.connected:
        return '已连接';
      case WebSocketConnectionState.connecting:
        return '连接中';
      case WebSocketConnectionState.reconnecting:
        return '重连中';
      case WebSocketConnectionState.failed:
        return '连接失败';
      case WebSocketConnectionState.disconnected:
        return '未连接';
    }
  }

  /// 获取状态颜色
  Color _getStatusColor(WebSocketConnectionState state) {
    switch (state) {
      case WebSocketConnectionState.connected:
        return Colors.green;
      case WebSocketConnectionState.connecting:
      case WebSocketConnectionState.reconnecting:
        return Colors.orange;
      case WebSocketConnectionState.failed:
        return Colors.red;
      case WebSocketConnectionState.disconnected:
        return Colors.grey;
    }
  }
}
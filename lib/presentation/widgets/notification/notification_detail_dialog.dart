import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_bubble.dart';

/// 通知详情对话框
/// 
/// 用于显示通知的完整内容，特别是长消息
class NotificationDetailDialog extends StatelessWidget {
  final BubbleNotification notification;
  final VoidCallback? onClose;
  
  const NotificationDetailDialog({
    super.key,
    required this.notification,
    this.onClose,
  });
  
  /// 显示通知详情对话框
  /// 
  /// 使用 Overlay 确保对话框显示在最顶层
  static void show(BuildContext context, BubbleNotification notification) {
    // 创建 OverlayEntry
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54, // 半透明背景
        child: Stack(
          children: [
            // 点击背景关闭对话框
            Positioned.fill(
              child: GestureDetector(
                onTap: () => overlayEntry.remove(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // 居中显示对话框
            Center(
              child: NotificationDetailDialog(
                notification: notification,
                onClose: () => overlayEntry.remove(),
              ),
            ),
          ],
        ),
      ),
    );
    
    // 插入到 Overlay
    Overlay.of(context).insert(overlayEntry);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 600,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            _buildHeader(context),
            
            // 分隔线
            const Divider(height: 1),
            
            // 消息内容区域
            Flexible(
              child: _buildContent(context),
            ),
            
            // 操作按钮
            _buildActions(context),
          ],
        ),
      ),
    );
  }
  
  /// 构建标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: notification.iconConfig.build(
              24,
              color: notification.color,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 标题和时间
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.title != null)
                  Text(
                    notification.title!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                Text(
                  _formatDetailTime(notification.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 关闭按钮
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose ?? () => Navigator.of(context).pop(),
            tooltip: '关闭',
          ),
        ],
      ),
    );
  }
  
  /// 构建内容区域
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 消息内容
          SelectableText(
            notification.message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          // 元数据（如果有）
          if (notification.source != null) ...[
            const SizedBox(height: 24),
            _buildMetadata(context),
          ],
        ],
      ),
    );
  }
  
  /// 构建元数据信息
  Widget _buildMetadata(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetadataRow('来源', notification.source!.name),
          _buildMetadataRow('类型', notification.type.toString().split('.').last),
          _buildMetadataRow('级别', notification.level.toString().split('.').last),
        ],
      ),
    );
  }
  
  /// 构建元数据行
  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label：',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建操作按钮
  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 复制按钮
          TextButton.icon(
            onPressed: () {
              // 复制消息内容到剪贴板
              final text = StringBuffer();
              if (notification.title != null) {
                text.writeln(notification.title);
              }
              text.write(notification.message);
              
              Clipboard.setData(ClipboardData(text: text.toString()));
              
              // 显示提示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已复制到剪贴板'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('复制'),
          ),
          
          const SizedBox(width: 8),
          
          // 标记已读按钮（如果未读）
          if (!notification.isRead) ...[
            TextButton.icon(
              onPressed: () {
                NotificationBubbleManager.instance.markAsRead(notification.id);
                if (onClose != null) {
                  onClose!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.done, size: 16),
              label: const Text('标记已读'),
            ),
            const SizedBox(width: 8),
          ],
          
          // 删除按钮
          TextButton.icon(
            onPressed: () {
              NotificationBubbleManager.instance.removeNotification(notification.id);
              if (onClose != null) {
                onClose!();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('删除'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
  
  /// 格式化详细时间显示
  String _formatDetailTime(DateTime time) {
    final now = DateTime.now();
    final isToday = time.year == now.year && 
                    time.month == now.month && 
                    time.day == now.day;
    
    if (isToday) {
      return '今天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.year}/${time.month.toString().padLeft(2, '0')}/${time.day.toString().padLeft(2, '0')} '
             '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
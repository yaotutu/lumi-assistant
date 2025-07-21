import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// MCP变化通知组件
/// 
/// 当MCP服务器发生变化时显示用户通知，告知用户系统正在重新连接
class McpChangeNotification {
  static OverlayEntry? _currentOverlay;
  
  /// 显示MCP变化通知（简单Toast风格）
  static void show(
    BuildContext context,
    String title,
    String message,
  ) {
    // 移除之前的通知
    hide();
    
    // 对于MCP错误，使用简单的Toast通知而不是大弹窗
    if (title.contains('操作超时') || title.contains('操作失败') || title.contains('错误')) {
      _showSimpleToast(context, title, message);
      return;
    }
    
    // 对于其他MCP通知（如服务更新），继续使用原来的样式
    _currentOverlay = OverlayEntry(
      builder: (context) => _McpChangeDialog(
        title: title,
        message: message,
        onDismiss: hide,
      ),
    );
    
    Overlay.of(context).insert(_currentOverlay!);
    
    // 3秒后自动隐藏
    Future.delayed(Duration(seconds: 3), () {
      hide();
    });
  }
  
  /// 显示简单的Toast通知
  static void _showSimpleToast(
    BuildContext context,
    String title,
    String message,
  ) {
    _currentOverlay = OverlayEntry(
      builder: (context) => _SimpleToast(
        title: title,
        message: message,
        onDismiss: hide,
      ),
    );
    
    Overlay.of(context).insert(_currentOverlay!);
    
    // 2秒后自动隐藏
    Future.delayed(Duration(seconds: 2), () {
      hide();
    });
  }
  
  /// 隐藏通知
  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

/// MCP变化对话框
class _McpChangeDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;

  const _McpChangeDialog({
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题和图标
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onDismiss,
                      icon: Icon(Icons.close, size: 20),
                      constraints: BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // 消息内容
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // 提示信息
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '重新连接完成后，AI助手将能使用最新的功能',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 简单的Toast通知组件
class _SimpleToast extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;

  const _SimpleToast({
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    final screenSize = MediaQuery.of(context).size;
    
    return Positioned(
      // 在屏幕底部显示，避免遮挡主要内容
      bottom: 80,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.15, // 最大高度不超过屏幕的15%
          ),
          decoration: BoxDecoration(
            color: Colors.grey[850]?.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 错误图标
                Icon(
                  Icons.error_outline,
                  color: Colors.orange[300],
                  size: 20,
                ),
                SizedBox(width: 12),
                
                // 消息内容
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (message.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          // 简化错误消息，只显示关键信息
                          _simplifyErrorMessage(message),
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // 关闭按钮
                GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 简化错误消息，提取关键信息
  String _simplifyErrorMessage(String message) {
    // 移除多余的换行和格式
    String simplified = message.replaceAll('\n\n', ' ').replaceAll('\n', ' ');
    
    // 提取关键信息
    if (simplified.contains('设备响应超时')) {
      return '设备响应较慢，请稍后重试';
    } else if (simplified.contains('外部服务响应超时')) {
      return '网络服务响应超时';
    } else if (simplified.contains('工具调用失败')) {
      return '操作失败，请重试';
    } else if (simplified.contains('网络连接')) {
      return '网络连接异常';
    }
    
    // 如果消息太长，截取前50个字符
    if (simplified.length > 50) {
      return simplified.substring(0, 47) + '...';
    }
    
    return simplified;
  }
}

/// MCP变化通知Provider
/// 用于在应用的任何地方显示MCP变化通知
final mcpChangeNotificationProvider = Provider<void Function(String, String)>((ref) {
  return (String title, String message) {
    // 这里需要在有BuildContext的地方调用
    // 实际的显示逻辑会在main app中设置
  };
});
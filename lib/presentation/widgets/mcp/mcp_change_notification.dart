import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// MCP变化通知组件
/// 
/// 当MCP服务器发生变化时显示用户通知，告知用户系统正在重新连接
class McpChangeNotification {
  static OverlayEntry? _currentOverlay;
  
  /// 显示MCP变化通知
  static void show(
    BuildContext context,
    String title,
    String message,
  ) {
    // 移除之前的通知
    hide();
    
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

/// MCP变化通知Provider
/// 用于在应用的任何地方显示MCP变化通知
final mcpChangeNotificationProvider = Provider<void Function(String, String)>((ref) {
  return (String title, String message) {
    // 这里需要在有BuildContext的地方调用
    // 实际的显示逻辑会在main app中设置
  };
});
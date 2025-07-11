import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/errors/exceptions.dart';

/// 错误提示横幅组件
/// 
/// 用于显示用户友好的错误信息，包括：
/// - 错误类型图标
/// - 错误消息
/// - 重试按钮
/// - 关闭按钮
/// - 自动消失机制
class ErrorBanner extends HookConsumerWidget {
  final String errorMessage;
  final AppException? exception;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final bool showRetryButton;
  final bool showCloseButton;
  final bool autoHide;
  final Duration autoHideDuration;
  final IconData? customIcon;
  final Color? backgroundColor;
  final Color? textColor;

  const ErrorBanner({
    super.key,
    required this.errorMessage,
    this.exception,
    this.onRetry,
    this.onClose,
    this.showRetryButton = true,
    this.showCloseButton = true,
    this.autoHide = false,
    this.autoHideDuration = const Duration(seconds: 5),
    this.customIcon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final severity = exception?.severity ?? ErrorSeverity.medium;
    final canRetry = exception?.canRetry ?? false;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? _getBackgroundColor(severity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(severity),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 错误标题行
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 错误图标
              Icon(
                customIcon ?? _getIcon(severity),
                color: _getIconColor(severity),
                size: 24,
              ),
              const SizedBox(width: 12),
              
              // 错误信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(severity),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: textColor ?? Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor ?? Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 关闭按钮
              if (showCloseButton && onClose != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  color: textColor ?? Colors.white.withValues(alpha: 0.7),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          
          // 错误详情和建议
          if (exception != null) ...[
            const SizedBox(height: 12),
            _buildErrorDetails(context, exception!),
          ],
          
          // 操作按钮
          if ((showRetryButton && canRetry && onRetry != null) || 
              _shouldShowNetworkSettings(exception)) ...[
            const SizedBox(height: 16),
            _buildActionButtons(context, canRetry),
          ],
        ],
      ),
    );
  }

  /// 构建错误详情
  Widget _buildErrorDetails(BuildContext context, AppException exception) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 错误建议
          if (_getErrorSuggestion(exception).isNotEmpty) ...[
            Text(
              '建议解决方案：',
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor ?? Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getErrorSuggestion(exception),
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor ?? Colors.white.withValues(alpha: 0.8),
                height: 1.3,
              ),
            ),
          ],
          
          // 错误代码
          if (exception.errorCode != null) ...[
            const SizedBox(height: 8),
            Text(
              '错误代码: ${exception.errorCode}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor ?? Colors.white.withValues(alpha: 0.6),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context, bool canRetry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 网络设置按钮
        if (_shouldShowNetworkSettings(exception)) ...[
          TextButton.icon(
            onPressed: () => _openNetworkSettings(context),
            icon: const Icon(Icons.settings, size: 16),
            label: const Text('网络设置'),
            style: TextButton.styleFrom(
              foregroundColor: textColor ?? Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // 重试按钮
        if (showRetryButton && canRetry && onRetry != null) ...[
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: textColor ?? Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ],
    );
  }

  /// 获取错误严重程度的背景颜色
  Color _getBackgroundColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.blue.withValues(alpha: 0.8);
      case ErrorSeverity.medium:
        return Colors.orange.withValues(alpha: 0.8);
      case ErrorSeverity.high:
        return Colors.red.withValues(alpha: 0.8);
      case ErrorSeverity.critical:
        return Colors.red.withValues(alpha: 0.9);
    }
  }

  /// 获取错误严重程度的边框颜色
  Color _getBorderColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.blue;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.withValues(alpha: 0.8);
    }
  }

  /// 获取错误严重程度的图标
  IconData _getIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.info_outline;
      case ErrorSeverity.medium:
        return Icons.warning_amber;
      case ErrorSeverity.high:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  /// 获取错误严重程度的图标颜色
  Color _getIconColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.blue[100]!;
      case ErrorSeverity.medium:
        return Colors.orange[100]!;
      case ErrorSeverity.high:
        return Colors.red[100]!;
      case ErrorSeverity.critical:
        return Colors.red[200]!;
    }
  }

  /// 获取错误标题
  String _getTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return '提示';
      case ErrorSeverity.medium:
        return '警告';
      case ErrorSeverity.high:
        return '错误';
      case ErrorSeverity.critical:
        return '严重错误';
    }
  }

  /// 获取错误建议
  String _getErrorSuggestion(AppException exception) {
    return exception.when(
      network: (message, code, statusCode, url, details) {
        if (code == 'CONNECTION_REFUSED') {
          return '请检查服务器是否运行在 ws://192.168.110.199:8000/，或联系系统管理员';
        } else if (code == 'CONNECTION_TIMEOUT') {
          return '请检查网络连接，或尝试连接到更稳定的网络';
        } else if (code == 'HOST_UNREACHABLE') {
          return '请检查网络设置，确保可以访问外部网络';
        }
        return '请检查网络连接，稍后重试';
      },
      webSocket: (message, code, connectionState, reconnectAttempts, details) {
        if (reconnectAttempts > 0) {
          return '正在尝试重新连接，请稍候...';
        }
        return '请检查网络连接和服务器状态';
      },
      server: (message, code, statusCode, serverErrorType, details) {
        if (code == 'HANDSHAKE_TIMEOUT') {
          return '服务器响应超时，请检查服务器状态或稍后重试';
        } else if (code == 'MESSAGE_SEND_TIMEOUT') {
          return '消息发送超时，请检查网络连接';
        }
        return '服务器暂时不可用，请稍后重试';
      },
      cache: (message, code, storageType, operationType, details) => '请清理应用缓存后重试',
      auth: (message, code, authType, requiresReauth, details) => '请检查认证信息或重新登录',
      validation: (message, code, field, rule, details) => '请检查输入数据的格式和内容',
      business: (message, code, businessType, details) => '请联系技术支持',
      system: (message, code, component, details) => '请重启应用或联系技术支持',
      unknown: (message, code, originalException, details) => '请重试或联系技术支持',
    );
  }

  /// 判断是否显示网络设置按钮
  bool _shouldShowNetworkSettings(AppException? exception) {
    if (exception == null) return false;
    
    return exception.when(
      network: (message, code, statusCode, url, details) => true,
      webSocket: (message, code, connectionState, reconnectAttempts, details) => true,
      server: (message, code, statusCode, serverErrorType, details) => false,
      cache: (message, code, storageType, operationType, details) => false,
      auth: (message, code, authType, requiresReauth, details) => false,
      validation: (message, code, field, rule, details) => false,
      business: (message, code, businessType, details) => false,
      system: (message, code, component, details) => false,
      unknown: (message, code, originalException, details) => false,
    );
  }

  /// 打开网络设置
  void _openNetworkSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('网络设置'),
        content: const Text('请检查以下网络设置：\n\n'
            '1. 确保连接到稳定的Wi-Fi网络\n'
            '2. 检查防火墙设置\n'
            '3. 确认服务器地址正确\n'
            '4. 联系网络管理员'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 错误横幅扩展方法
extension ErrorBannerExtension on Widget {
  /// 显示错误横幅
  static void showErrorBanner(
    BuildContext context, {
    required String errorMessage,
    AppException? exception,
    VoidCallback? onRetry,
    Duration? duration,
  }) {
    final canRetry = exception?.canRetry ?? false;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorBanner(
          errorMessage: errorMessage,
          exception: exception,
          onRetry: onRetry,
          showCloseButton: false,
          backgroundColor: Colors.transparent,
          textColor: Colors.white,
        ),
        duration: duration ?? const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        action: canRetry && onRetry != null ? SnackBarAction(
          label: '重试',
          onPressed: onRetry,
        ) : null,
      ),
    );
  }
}
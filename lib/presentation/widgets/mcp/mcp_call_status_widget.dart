import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/mcp_call_state.dart';
import '../../providers/mcp_call_provider.dart';

/// MCP调用状态显示组件
class McpCallStatusWidget extends HookConsumerWidget {
  /// 是否显示在底部（如作为SnackBar）
  final bool isBottomDisplay;
  
  /// 自定义样式
  final McpCallStatusStyle? style;
  
  /// 是否自动隐藏空闲状态
  final bool autoHideIdle;

  const McpCallStatusWidget({
    super.key,
    this.isBottomDisplay = false,
    this.style,
    this.autoHideIdle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mcpCallState = ref.watch(mcpCallProvider);
    final mcpActions = ref.watch(mcpCallActionsProvider);
    
    // 自动隐藏空闲状态
    if (autoHideIdle && mcpCallState.status == McpCallStatus.idle) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final effectiveStyle = style ?? McpCallStatusStyle.defaultStyle(theme);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: effectiveStyle.elevation,
        color: effectiveStyle.backgroundColor,
        margin: EdgeInsets.all(effectiveStyle.margin),
        child: Padding(
          padding: EdgeInsets.all(effectiveStyle.padding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 状态图标和动画
              _buildStatusIcon(mcpCallState, effectiveStyle),
              
              const SizedBox(width: 12),
              
              // 状态信息
              Expanded(
                child: _buildStatusInfo(mcpCallState, effectiveStyle),
              ),
              
              // 操作按钮
              if (mcpCallState.status != McpCallStatus.idle)
                _buildActionButtons(mcpCallState, mcpActions, effectiveStyle),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建状态图标
  Widget _buildStatusIcon(McpCallState state, McpCallStatusStyle style) {
    final color = _getStatusColor(state.status);
    
    switch (state.status) {
      case McpCallStatus.calling:
      case McpCallStatus.retrying:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      
      case McpCallStatus.success:
        return Icon(
          Icons.check_circle,
          color: color,
          size: 20,
        );
      
      case McpCallStatus.failed:
        return Icon(
          Icons.error,
          color: color,
          size: 20,
        );
      
      case McpCallStatus.idle:
        return Icon(
          Icons.radio_button_unchecked,
          color: color,
          size: 20,
        );
    }
  }

  /// 构建状态信息
  Widget _buildStatusInfo(McpCallState state, McpCallStatusStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 主要状态信息
        Text(
          state.userFriendlyMessage ?? _getDefaultStatusMessage(state),
          style: style.primaryTextStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        // 附加信息
        if (_shouldShowSecondaryInfo(state)) ...[
          const SizedBox(height: 4),
          Text(
            _getSecondaryInfo(state),
            style: style.secondaryTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(
    McpCallState state, 
    McpCallActions actions,
    McpCallStatusStyle style,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 重试按钮
        if (state.canRetry)
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () => _handleRetry(actions),
            tooltip: '重试',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        
        // 取消按钮
        if (state.isExecuting)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => _handleCancel(actions),
            tooltip: '取消',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        
        // 清除按钮
        if (state.isCompleted)
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => _handleClear(actions),
            tooltip: '清除',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
      ],
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(McpCallStatus status) {
    switch (status) {
      case McpCallStatus.idle:
        return Colors.grey;
      case McpCallStatus.calling:
      case McpCallStatus.retrying:
        return Colors.blue;
      case McpCallStatus.success:
        return Colors.green;
      case McpCallStatus.failed:
        return Colors.red;
    }
  }

  /// 获取默认状态消息
  String _getDefaultStatusMessage(McpCallState state) {
    switch (state.status) {
      case McpCallStatus.idle:
        return '就绪';
      case McpCallStatus.calling:
        return '正在执行操作...';
      case McpCallStatus.retrying:
        return '重试中...';
      case McpCallStatus.success:
        return '操作成功';
      case McpCallStatus.failed:
        return '操作失败';
    }
  }

  /// 是否显示次要信息
  bool _shouldShowSecondaryInfo(McpCallState state) {
    return state.currentTool != null || 
           state.retryCount > 0 || 
           state.duration != null;
  }

  /// 获取次要信息
  String _getSecondaryInfo(McpCallState state) {
    final parts = <String>[];
    
    if (state.currentTool != null) {
      parts.add('工具: ${state.currentTool}');
    }
    
    if (state.retryCount > 0) {
      parts.add('重试: ${state.retryCount}/${state.maxRetries}');
    }
    
    if (state.duration != null) {
      final seconds = state.duration!.inSeconds;
      parts.add('耗时: ${seconds}s');
    }
    
    return parts.join(' | ');
  }

  /// 处理重试
  void _handleRetry(McpCallActions actions) async {
    try {
      await actions.retry();
    } catch (e) {
      // 错误已经由Provider处理
      print('[McpCallStatusWidget] 重试失败: $e');
    }
  }

  /// 处理取消
  void _handleCancel(McpCallActions actions) {
    actions.cancel();
  }

  /// 处理清除
  void _handleClear(McpCallActions actions) {
    actions.clear();
  }
}

/// MCP调用状态样式配置
class McpCallStatusStyle {
  final double elevation;
  final Color? backgroundColor;
  final double margin;
  final double padding;
  final TextStyle primaryTextStyle;
  final TextStyle secondaryTextStyle;

  const McpCallStatusStyle({
    required this.elevation,
    this.backgroundColor,
    required this.margin,
    required this.padding,
    required this.primaryTextStyle,
    required this.secondaryTextStyle,
  });

  factory McpCallStatusStyle.defaultStyle(ThemeData theme) {
    return McpCallStatusStyle(
      elevation: 2,
      backgroundColor: theme.cardColor,
      margin: 8,
      padding: 12,
      primaryTextStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
      secondaryTextStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
      ) ?? const TextStyle(),
    );
  }

  factory McpCallStatusStyle.compact(ThemeData theme) {
    return McpCallStatusStyle(
      elevation: 1,
      backgroundColor: theme.cardColor,
      margin: 4,
      padding: 8,
      primaryTextStyle: theme.textTheme.bodySmall ?? const TextStyle(),
      secondaryTextStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.textTheme.labelSmall?.color?.withValues(alpha: 0.6),
      ) ?? const TextStyle(),
    );
  }
}

/// MCP调用状态悬浮显示组件（类似SnackBar）
class McpCallStatusOverlay extends HookConsumerWidget {
  const McpCallStatusOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mcpCallState = ref.watch(mcpCallProvider);
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: mcpCallState.status == McpCallStatus.idle ? -100 : 20,
      left: 20,
      right: 20,
      child: McpCallStatusWidget(
        isBottomDisplay: true,
        autoHideIdle: false,
        style: McpCallStatusStyle.defaultStyle(Theme.of(context)).copyWith(
          elevation: 6,
          backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}

extension on McpCallStatusStyle {
  McpCallStatusStyle copyWith({
    double? elevation,
    Color? backgroundColor,
    double? margin,
    double? padding,
    TextStyle? primaryTextStyle,
    TextStyle? secondaryTextStyle,
  }) {
    return McpCallStatusStyle(
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      primaryTextStyle: primaryTextStyle ?? this.primaryTextStyle,
      secondaryTextStyle: secondaryTextStyle ?? this.secondaryTextStyle,
    );
  }
}
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';

import '../../data/models/mcp/mcp_call_state.dart';
import '../../core/services/mcp/unified_mcp_manager.dart';
import '../../core/utils/loggers.dart';

/// MCP调用状态管理
class McpCallNotifier extends StateNotifier<McpCallState> {
  final UnifiedMcpManager _mcpManager;
  Timer? _timeoutTimer;
  Timer? _retryTimer;

  McpCallNotifier(this._mcpManager) : super(McpCallState.idle());

  /// 调用MCP工具
  Future<Map<String, dynamic>?> callTool(
    String toolName, 
    Map<String, dynamic> arguments, {
    int maxRetries = 2,
    Duration timeout = const Duration(seconds: 30),
    String? userMessage,
  }) async {
    Loggers.mcp.userAction('开始调用工具: $toolName');
    
    // 设置调用中状态
    state = McpCallState.calling(
      toolName: toolName,
      arguments: arguments,
      userMessage: userMessage,
    );

    // 设置超时定时器
    _startTimeoutTimer(timeout, toolName);

    int retryCount = 0;
    Map<String, dynamic>? result;

    while (retryCount <= maxRetries) {
      try {
        if (retryCount > 0) {
          // 显示重试状态
          state = McpCallState.retrying(
            toolName: toolName,
            retryCount: retryCount,
            maxRetries: maxRetries,
          );
          
          Loggers.mcp.info('重试调用工具: $toolName (第$retryCount次重试)');
          // 重试前等待一段时间
          await Future.delayed(Duration(seconds: retryCount * 2));
        }

        // 执行工具调用
        result = await _mcpManager.callTool(toolName, arguments);
        
        // 调用成功
        _cancelTimeoutTimer();
        state = McpCallState.success(
          toolName: toolName,
          result: result,
          userMessage: userMessage,
        );
        
        Loggers.mcp.info('工具调用成功: $toolName');
        
        // 3秒后自动重置状态
        _autoResetState();
        
        return result;
        
      } catch (e) {
        Loggers.mcp.warning('工具调用失败 (尝试 ${retryCount + 1}/${maxRetries + 1}): $toolName', e);
        
        retryCount++;
        
        if (retryCount > maxRetries) {
          // 所有重试都失败了
          _cancelTimeoutTimer();
          state = McpCallState.failed(
            toolName: toolName,
            error: e.toString(),
            retryCount: retryCount - 1,
            maxRetries: maxRetries,
            userMessage: userMessage,
          );
          
          Loggers.mcp.severe('工具调用最终失败: $toolName', e);
          
          // 显示错误5秒后重置状态
          _autoResetState(delay: Duration(seconds: 5));
          
          // 抛出异常让上层处理
          rethrow;
        }
      }
    }
    
    return result;
  }

  /// 手动重试当前失败的调用
  Future<Map<String, dynamic>?> retryCurrentCall() async {
    if (state.status != McpCallStatus.failed || state.currentTool == null) {
      throw Exception('当前没有可重试的调用');
    }

    return callTool(
      state.currentTool!,
      state.arguments ?? {},
      maxRetries: state.maxRetries,
    );
  }

  /// 取消当前调用
  void cancelCurrentCall() {
    _cancelTimeoutTimer();
    _cancelRetryTimer();
    
    if (state.isExecuting) {
      state = McpCallState.failed(
        toolName: state.currentTool ?? 'unknown',
        error: '用户取消操作',
        userMessage: '操作已取消',
      );
      
      _autoResetState();
    }
  }

  /// 清除状态
  void clearState() {
    _cancelTimeoutTimer();
    _cancelRetryTimer();
    state = McpCallState.idle();
  }

  /// 启动超时定时器
  void _startTimeoutTimer(Duration timeout, String toolName) {
    _cancelTimeoutTimer();
    
    _timeoutTimer = Timer(timeout, () {
      if (state.isExecuting) {
        state = McpCallState.failed(
          toolName: toolName,
          error: '操作超时',
          userMessage: '操作超时，请稍后再试',
        );
        
        _autoResetState();
      }
    });
  }

  /// 取消超时定时器
  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// 取消重试定时器
  void _cancelRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// 自动重置状态
  void _autoResetState({Duration delay = const Duration(seconds: 3)}) {
    _cancelRetryTimer();
    
    _retryTimer = Timer(delay, () {
      if (mounted) {
        state = McpCallState.idle();
      }
    });
  }

  @override
  void dispose() {
    _cancelTimeoutTimer();
    _cancelRetryTimer();
    super.dispose();
  }
}

/// MCP调用状态Provider
final mcpCallProvider = StateNotifierProvider<McpCallNotifier, McpCallState>((ref) {
  final mcpManager = ref.watch(unifiedMcpManagerProvider);
  return McpCallNotifier(mcpManager);
});

/// MCP调用操作Provider（用于执行操作）
final mcpCallActionsProvider = Provider<McpCallActions>((ref) {
  final notifier = ref.read(mcpCallProvider.notifier);
  return McpCallActions(notifier);
});

/// MCP调用操作类
class McpCallActions {
  final McpCallNotifier _notifier;

  McpCallActions(this._notifier);

  /// 调用工具
  Future<Map<String, dynamic>?> callTool(
    String toolName, 
    Map<String, dynamic> arguments, {
    String? userMessage,
  }) {
    return _notifier.callTool(
      toolName, 
      arguments, 
      userMessage: userMessage,
    );
  }

  /// 重试当前调用
  Future<Map<String, dynamic>?> retry() {
    return _notifier.retryCurrentCall();
  }

  /// 取消当前调用
  void cancel() {
    _notifier.cancelCurrentCall();
  }

  /// 清除状态
  void clear() {
    _notifier.clearState();
  }
}
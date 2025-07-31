/// MCP错误处理器
/// 
/// 职责：统一处理MCP相关的错误和异常
/// 使用场景：MCP工具调用失败、连接错误、协议错误等
class McpErrorHandler {
  /// 处理MCP错误并返回用户友好的错误信息
  static String handleError(dynamic error) {
    if (error == null) {
      return '未知错误';
    }
    
    // 处理特定的MCP错误类型
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('connection')) {
      return 'MCP服务器连接失败';
    } else if (errorStr.contains('timeout')) {
      return 'MCP调用超时';
    } else if (errorStr.contains('not found')) {
      return 'MCP工具未找到';
    } else if (errorStr.contains('permission')) {
      return 'MCP权限不足';
    } else if (errorStr.contains('invalid')) {
      return 'MCP参数无效';
    }
    
    // 返回原始错误信息
    return error.toString();
  }
  
  /// 判断是否是可重试的错误
  static bool isRetryableError(dynamic error) {
    if (error == null) return false;
    
    final errorStr = error.toString().toLowerCase();
    
    // 网络错误和超时错误通常可以重试
    return errorStr.contains('connection') || 
           errorStr.contains('timeout') ||
           errorStr.contains('network');
  }
  
  /// 生成用户友好的错误信息
  static String generateUserFriendlyMessage({
    required dynamic error,
    String? operation,
    String? serverName,
    String? serverType,
  }) {
    final baseMessage = handleError(error);
    final parts = <String>[];
    
    if (operation != null) {
      parts.add('操作: $operation');
    }
    if (serverName != null) {
      parts.add('服务器: $serverName');
    }
    if (serverType != null) {
      parts.add('类型: $serverType');
    }
    
    if (parts.isEmpty) {
      return baseMessage;
    }
    
    return '$baseMessage (${parts.join(', ')})';
  }
  
  /// 生成错误代码
  static int generateErrorCode(dynamic error, [String? operation]) {
    // 基础错误代码
    int baseCode = -32000;
    
    if (error == null) return baseCode;
    
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('connection')) {
      baseCode = -32001;
    } else if (errorStr.contains('timeout')) {
      baseCode = -32002;
    } else if (errorStr.contains('not found')) {
      baseCode = -32601;
    } else if (errorStr.contains('permission')) {
      baseCode = -32003;
    } else if (errorStr.contains('invalid')) {
      baseCode = -32602;
    }
    
    // 根据操作类型调整错误代码
    if (operation != null) {
      switch (operation) {
        case 'tool_call':
          return baseCode - 100;
        case 'list_tools':
          return baseCode - 200;
        default:
          return baseCode;
      }
    }
    
    return baseCode;
  }
  
  /// 生成用户通知
  static Map<String, String> generateUserNotification({
    required dynamic error,
    String? operation,
    String? serverName,
  }) {
    final errorMessage = handleError(error);
    String title = 'MCP错误';
    String message = errorMessage;
    
    // 根据错误类型定制标题
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('timeout')) {
      title = '操作超时';
    } else if (errorStr.contains('connection')) {
      title = '连接失败';
    } else if (errorStr.contains('not found')) {
      title = '未找到工具';
    }
    
    // 添加服务器信息
    if (serverName != null) {
      message = '$serverName: $message';
    }
    
    // 添加操作信息
    if (operation != null) {
      final operationText = _getOperationText(operation);
      if (operationText != null) {
        message = '$operationText失败 - $message';
      }
    }
    
    return {
      'title': title,
      'message': message,
    };
  }
  
  /// 获取操作的中文描述
  static String? _getOperationText(String operation) {
    switch (operation) {
      case 'tool_call':
        return '工具调用';
      case 'list_tools':
        return '获取工具列表';
      case 'initialize':
        return '初始化';
      default:
        return null;
    }
  }
}
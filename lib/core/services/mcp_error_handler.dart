/// MCP错误处理工具
/// 
/// 提供统一的MCP错误处理和用户友好的错误信息生成
class McpErrorHandler {
  /// 生成用户友好的错误信息
  /// 
  /// [error] 原始错误对象
  /// [operation] 失败的操作类型（如：'tool_call', 'list_tools', 'connect'等）
  /// [serverType] 服务器类型（'embedded', 'external', 'http'等）
  /// [serverName] 服务器名称
  static String generateUserFriendlyMessage({
    required dynamic error,
    required String operation,
    String? serverType,
    String? serverName,
  }) {
    final errorString = error.toString().toLowerCase();
    final serverInfo = serverName != null ? ' ($serverName)' : '';
    
    // 超时错误 - 根据服务器类型和操作提供精确的错误信息
    if (errorString.contains('超时') || errorString.contains('timeout')) {
      return _generateTimeoutMessage(errorString, operation, serverType, serverInfo);
    }
    
    // 网络连接错误
    if (errorString.contains('connection') || 
        errorString.contains('network') ||
        errorString.contains('socket')) {
      return _generateNetworkMessage(operation, serverInfo);
    }
    
    // 权限错误
    if (errorString.contains('permission') || 
        errorString.contains('access denied') ||
        errorString.contains('unauthorized')) {
      return _generatePermissionMessage(operation, serverInfo);
    }
    
    // 服务不可用
    if (errorString.contains('not found') || 
        errorString.contains('unavailable') ||
        errorString.contains('offline') ||
        errorString.contains('disconnected')) {
      return _generateUnavailableMessage(operation, serverType, serverInfo);
    }
    
    // 配置错误
    if (errorString.contains('config') || 
        errorString.contains('invalid') ||
        errorString.contains('parameter')) {
      return _generateConfigMessage(operation, serverInfo);
    }
    
    // 通用错误
    return _generateGenericMessage(operation, serverInfo);
  }
  
  /// 生成超时错误信息
  static String _generateTimeoutMessage(String errorString, String operation, String? serverType, String serverInfo) {
    switch (operation) {
      case 'tool_call':
        if (serverType == 'embedded') {
          return '设备响应超时(15秒)$serverInfo\n\n设备可能正在处理复杂操作或系统繁忙。\n建议稍后重试或检查设备状态。';
        } else if (serverType == 'external') {
          return '外部服务响应超时(25秒)$serverInfo\n\n可能是网络较慢或服务器繁忙。\n建议检查网络连接或稍后重试。';
        } else {
          return 'MCP工具调用超时(30秒)$serverInfo\n\n操作可能需要更多时间完成。\n建议稍后重试或检查服务状态。';
        }
        
      case 'list_tools':
        return '获取工具列表超时$serverInfo\n\nMCP服务可能繁忙或网络较慢。\n建议稍后重试。';
        
      case 'connect':
        if (serverType == 'http') {
          return 'HTTP连接超时(20秒)$serverInfo\n\n网络连接较慢或服务器无响应。\n请检查网络状态或稍后重试。';
        } else {
          return '服务连接超时$serverInfo\n\n可能是网络问题或服务启动较慢。\n建议检查网络或稍后重试。';
        }
        
      case 'initialize':
        return 'MCP协议初始化超时$serverInfo\n\n服务器初始化时间较长。\n建议检查网络连接或重新启动应用。';
        
      default:
        return 'MCP操作超时$serverInfo\n\n服务可能繁忙，请稍后重试。';
    }
  }
  
  /// 生成网络错误信息
  static String _generateNetworkMessage(String operation, String serverInfo) {
    switch (operation) {
      case 'tool_call':
        return '网络连接异常$serverInfo\n\n无法完成设备操作。\n请检查网络连接后重试。';
      case 'connect':
        return '网络连接失败$serverInfo\n\n请检查网络设置和连接状态。';
      default:
        return '网络连接出现问题$serverInfo\n\n请检查设备网络连接状态。';
    }
  }
  
  /// 生成权限错误信息
  static String _generatePermissionMessage(String operation, String serverInfo) {
    switch (operation) {
      case 'tool_call':
        return '权限不足$serverInfo\n\n无法执行此设备操作。\n请检查应用权限设置。';
      default:
        return '权限不足$serverInfo\n\n无法执行此操作，请检查权限设置。';
    }
  }
  
  /// 生成服务不可用错误信息
  static String _generateUnavailableMessage(String operation, String? serverType, String serverInfo) {
    switch (operation) {
      case 'tool_call':
        if (serverType == 'embedded') {
          return '设备服务不可用$serverInfo\n\n内置设备功能暂时无法使用。\n请重新启动应用或检查设备状态。';
        } else {
          return '外部服务不可用$serverInfo\n\n服务可能已停止或网络中断。\n请检查服务状态或网络连接。';
        }
      case 'connect':
        return '服务暂时不可用$serverInfo\n\n服务可能已停止或正在维护。\n请稍后重试。';
      default:
        return '服务暂时不可用$serverInfo\n\n请稍后重试或联系管理员。';
    }
  }
  
  /// 生成配置错误信息
  static String _generateConfigMessage(String operation, String serverInfo) {
    switch (operation) {
      case 'connect':
        return 'MCP服务配置错误$serverInfo\n\n服务器配置可能有误。\n请检查配置设置。';
      case 'tool_call':
        return '工具参数配置错误$serverInfo\n\n请检查操作参数是否正确。';
      default:
        return '配置错误$serverInfo\n\n请检查相关配置设置。';
    }
  }
  
  /// 生成通用错误信息
  static String _generateGenericMessage(String operation, String serverInfo) {
    switch (operation) {
      case 'tool_call':
        return '设备操作失败$serverInfo\n\n请稍后重试或检查设备状态。';
      case 'list_tools':
        return '无法获取可用功能列表$serverInfo\n\n请稍后重试。';
      case 'connect':
        return '服务连接失败$serverInfo\n\n请检查服务状态后重试。';
      default:
        return '操作执行失败$serverInfo\n\n请稍后重试。';
    }
  }
  
  /// 生成错误代码（用于JSON-RPC响应）
  /// 
  /// [error] 原始错误对象
  /// [operation] 失败的操作类型
  static int generateErrorCode(dynamic error, String operation) {
    final errorString = error.toString().toLowerCase();
    
    // 超时错误的细分代码
    if (errorString.contains('超时') || errorString.contains('timeout')) {
      if (errorString.contains('内置mcp') || errorString.contains('embedded')) {
        return -32011; // 内置MCP服务超时
      } else if (errorString.contains('外部mcp') || errorString.contains('external')) {
        return -32012; // 外部MCP服务超时
      } else if (errorString.contains('http') || errorString.contains('连接')) {
        return -32013; // HTTP连接超时
      } else {
        return -32001; // 通用超时错误
      }
    }
    
    // 标准JSON-RPC错误代码
    if (errorString.contains('invalid request')) {
      return -32600;
    } else if (errorString.contains('method not found')) {
      return -32601;
    } else if (errorString.contains('invalid params')) {
      return -32602;
    } else if (errorString.contains('parse error')) {
      return -32700;
    } else if (errorString.contains('permission')) {
      return -32002; // 权限错误
    } else if (errorString.contains('not found')) {
      return -32003; // 资源未找到错误
    } else if (errorString.contains('mcp')) {
      return -32004; // MCP服务错误
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return -32005; // 网络错误
    } else {
      return -32603; // 内部错误
    }
  }
  
  /// 创建用于通知用户的标题和消息
  /// 
  /// [error] 原始错误对象
  /// [operation] 失败的操作类型
  /// [serverName] 服务器名称
  static Map<String, String> generateUserNotification({
    required dynamic error,
    required String operation,
    String? serverName,
  }) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('超时') || errorString.contains('timeout')) {
      return {
        'title': '操作超时',
        'message': generateUserFriendlyMessage(
          error: error, 
          operation: operation, 
          serverName: serverName,
        ),
      };
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return {
        'title': '网络连接异常',
        'message': generateUserFriendlyMessage(
          error: error, 
          operation: operation, 
          serverName: serverName,
        ),
      };
    } else if (errorString.contains('permission')) {
      return {
        'title': '权限不足',
        'message': generateUserFriendlyMessage(
          error: error, 
          operation: operation, 
          serverName: serverName,
        ),
      };
    } else {
      return {
        'title': '操作失败',
        'message': generateUserFriendlyMessage(
          error: error, 
          operation: operation, 
          serverName: serverName,
        ),
      };
    }
  }
  
  /// 检查是否为可重试的错误
  /// 
  /// [error] 错误对象
  static bool isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // 可重试的错误类型
    return errorString.contains('timeout') ||
           errorString.contains('超时') ||
           errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('server') ||
           errorString.contains('service') ||
           errorString.contains('busy') ||
           errorString.contains('繁忙');
  }
  
  /// 获取建议的重试延迟时间（毫秒）
  /// 
  /// [error] 错误对象
  /// [attemptCount] 当前重试次数
  static int getRetryDelay(dynamic error, int attemptCount) {
    final errorString = error.toString().toLowerCase();
    
    // 基础延迟时间
    int baseDelay = 1000; // 1秒
    
    // 根据错误类型调整延迟
    if (errorString.contains('timeout') || errorString.contains('超时')) {
      baseDelay = 3000; // 超时错误等待3秒
    } else if (errorString.contains('network')) {
      baseDelay = 2000; // 网络错误等待2秒
    }
    
    // 指数退避：每次重试延迟翻倍，最大不超过30秒
    final delay = baseDelay * (1 << (attemptCount - 1));
    return delay > 30000 ? 30000 : delay;
  }
}
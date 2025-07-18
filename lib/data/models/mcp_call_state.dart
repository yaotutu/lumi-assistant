/// MCP调用状态枚举
enum McpCallStatus {
  /// 空闲状态
  idle,
  /// 调用中
  calling,
  /// 调用成功
  success,
  /// 调用失败
  failed,
  /// 重试中
  retrying,
}

/// MCP调用状态模型
class McpCallState {
  /// 调用状态
  final McpCallStatus status;
  
  /// 当前调用的工具名称
  final String? currentTool;
  
  /// 调用参数
  final Map<String, dynamic>? arguments;
  
  /// 调用开始时间
  final DateTime? startTime;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 重试次数
  final int retryCount;
  
  /// 最大重试次数
  final int maxRetries;
  
  /// 调用结果
  final Map<String, dynamic>? result;
  
  /// 用户友好的状态描述
  final String? userFriendlyMessage;

  const McpCallState({
    this.status = McpCallStatus.idle,
    this.currentTool,
    this.arguments,
    this.startTime,
    this.errorMessage,
    this.retryCount = 0,
    this.maxRetries = 2,
    this.result,
    this.userFriendlyMessage,
  });

  /// 创建空闲状态
  factory McpCallState.idle() => const McpCallState();

  /// 创建调用中状态
  factory McpCallState.calling({
    required String toolName,
    Map<String, dynamic>? arguments,
    String? userMessage,
  }) {
    return McpCallState(
      status: McpCallStatus.calling,
      currentTool: toolName,
      arguments: arguments,
      startTime: DateTime.now(),
      userFriendlyMessage: userMessage ?? _getCallingMessage(toolName),
    );
  }

  /// 创建成功状态
  factory McpCallState.success({
    required String toolName,
    Map<String, dynamic>? result,
    String? userMessage,
  }) {
    return McpCallState(
      status: McpCallStatus.success,
      currentTool: toolName,
      result: result,
      userFriendlyMessage: userMessage ?? _getSuccessMessage(toolName),
    );
  }

  /// 创建失败状态
  factory McpCallState.failed({
    required String toolName,
    required String error,
    int retryCount = 0,
    int maxRetries = 2,
    String? userMessage,
  }) {
    return McpCallState(
      status: McpCallStatus.failed,
      currentTool: toolName,
      errorMessage: error,
      retryCount: retryCount,
      maxRetries: maxRetries,
      userFriendlyMessage: userMessage ?? _getFailedMessage(toolName, error),
    );
  }

  /// 创建重试状态
  factory McpCallState.retrying({
    required String toolName,
    required int retryCount,
    int maxRetries = 2,
    String? userMessage,
  }) {
    return McpCallState(
      status: McpCallStatus.retrying,
      currentTool: toolName,
      retryCount: retryCount,
      maxRetries: maxRetries,
      userFriendlyMessage: userMessage ?? _getRetryingMessage(toolName, retryCount),
    );
  }

  /// 复制并更新状态
  McpCallState copyWith({
    McpCallStatus? status,
    String? currentTool,
    Map<String, dynamic>? arguments,
    DateTime? startTime,
    String? errorMessage,
    int? retryCount,
    int? maxRetries,
    Map<String, dynamic>? result,
    String? userFriendlyMessage,
  }) {
    return McpCallState(
      status: status ?? this.status,
      currentTool: currentTool ?? this.currentTool,
      arguments: arguments ?? this.arguments,
      startTime: startTime ?? this.startTime,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      result: result ?? this.result,
      userFriendlyMessage: userFriendlyMessage ?? this.userFriendlyMessage,
    );
  }

  /// 获取状态持续时间
  Duration? get duration {
    if (startTime == null) return null;
    return DateTime.now().difference(startTime!);
  }

  /// 是否正在执行中
  bool get isExecuting => 
    status == McpCallStatus.calling || status == McpCallStatus.retrying;

  /// 是否已完成（成功或失败）
  bool get isCompleted => 
    status == McpCallStatus.success || status == McpCallStatus.failed;

  /// 是否可以重试
  bool get canRetry => 
    status == McpCallStatus.failed && retryCount < maxRetries;

  /// 获取状态颜色（用于UI显示）
  String get statusColor {
    switch (status) {
      case McpCallStatus.idle:
        return '#6B7280'; // 灰色
      case McpCallStatus.calling:
      case McpCallStatus.retrying:
        return '#3B82F6'; // 蓝色
      case McpCallStatus.success:
        return '#10B981'; // 绿色
      case McpCallStatus.failed:
        return '#EF4444'; // 红色
    }
  }

  /// 获取状态图标
  String get statusIcon {
    switch (status) {
      case McpCallStatus.idle:
        return '⚪';
      case McpCallStatus.calling:
        return '🔄';
      case McpCallStatus.retrying:
        return '⏳';
      case McpCallStatus.success:
        return '✅';
      case McpCallStatus.failed:
        return '❌';
    }
  }

  @override
  String toString() {
    return 'McpCallState(status: $status, tool: $currentTool, message: $userFriendlyMessage)';
  }

  /// 生成用户友好的调用中消息
  static String _getCallingMessage(String toolName) {
    final messages = {
      'get_printer_status': '正在查看打印机状态...',
      'start_print_job': '正在启动打印任务...',
      'pause_print_job': '正在暂停打印...',
      'resume_print_job': '正在恢复打印...',
      'cancel_print_job': '正在取消打印任务...',
      'set_brightness': '正在调节屏幕亮度...',
      'adjust_volume': '正在调节音量...',
      'get_weather': '正在获取天气信息...',
      'play_music': '正在播放音乐...',
    };
    
    return messages[toolName] ?? '正在执行 $toolName...';
  }

  /// 生成用户友好的成功消息
  static String _getSuccessMessage(String toolName) {
    final messages = {
      'get_printer_status': '打印机状态获取成功',
      'start_print_job': '打印任务已启动',
      'pause_print_job': '打印已暂停',
      'resume_print_job': '打印已恢复',
      'cancel_print_job': '打印任务已取消',
      'set_brightness': '屏幕亮度调节完成',
      'adjust_volume': '音量调节完成',
      'get_weather': '天气信息获取成功',
      'play_music': '音乐播放成功',
    };
    
    return messages[toolName] ?? '$toolName 执行成功';
  }

  /// 生成用户友好的失败消息
  static String _getFailedMessage(String toolName, String error) {
    // 将技术性错误转换为用户友好的描述
    if (error.contains('Connection refused') || error.contains('timeout')) {
      return '设备连接失败，请检查网络连接';
    } else if (error.contains('权限') || error.contains('permission')) {
      return '权限不足，无法执行此操作';
    } else if (error.contains('未找到') || error.contains('not found')) {
      return '功能暂时不可用，请稍后再试';
    }
    
    final messages = {
      'get_printer_status': '无法获取打印机状态',
      'start_print_job': '启动打印失败',
      'pause_print_job': '暂停打印失败',
      'resume_print_job': '恢复打印失败',
      'cancel_print_job': '取消打印失败',
      'set_brightness': '亮度调节失败',
      'adjust_volume': '音量调节失败',
      'get_weather': '天气信息获取失败',
      'play_music': '音乐播放失败',
    };
    
    return messages[toolName] ?? '$toolName 执行失败';
  }

  /// 生成用户友好的重试消息
  static String _getRetryingMessage(String toolName, int retryCount) {
    return '第${retryCount}次重试 ${_getCallingMessage(toolName)}';
  }
}
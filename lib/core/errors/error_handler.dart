import 'exceptions.dart';

/// 统一错误处理器
class ErrorHandler {
  /// 获取用户友好的错误信息
  static String getErrorMessage(Exception error) {
    if (error is NetworkException) {
      return '网络连接失败，请检查网络设置';
    } else if (error is WebSocketException) {
      return 'WebSocket连接异常，正在尝试重连';
    } else if (error is ServerException) {
      return '服务器响应异常，请稍后重试';
    } else if (error is CacheException) {
      return '本地数据读取失败';
    } else {
      return '发生未知错误，请稍后重试';
    }
  }
  
  /// 记录错误日志
  static void logError(Exception error, StackTrace stackTrace) {
    // TODO: 实现日志记录逻辑，可以集成crashlytics等
    print('Error: $error');
    print('StackTrace: $stackTrace');
  }
  
  /// 处理错误并返回用户消息
  static String handleError(Exception error, StackTrace stackTrace) {
    logError(error, stackTrace);
    return getErrorMessage(error);
  }
}
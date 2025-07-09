import 'dart:io';

import 'exceptions.dart';

/// 统一错误处理器
class ErrorHandler {
  /// 获取用户友好的错误信息
  static String getErrorMessage(Exception error) {
    if (error is AppException) {
      return error.userFriendlyMessage;
    } else {
      return '发生未知错误，请稍后重试';
    }
  }

  
  /// 处理网络相关错误
  static AppException handleNetworkError(dynamic error) {
    if (error is SocketException) {
      if (error.osError?.errorCode == 111) {
        return AppExceptionFactory.createNetworkException(
          '服务器拒绝连接，请检查服务器是否启动',
          code: 'CONNECTION_REFUSED',
        );
      } else if (error.osError?.errorCode == 113) {
        return AppExceptionFactory.createNetworkException(
          '无法连接到服务器，请检查网络设置',
          code: 'HOST_UNREACHABLE',
        );
      } else {
        return AppExceptionFactory.createNetworkException(
          '网络连接错误: ${error.message}',
          code: 'SOCKET_ERROR',
        );
      }
    } else if (error is HandshakeException) {
      return AppExceptionFactory.createNetworkException(
        'SSL握手失败，请检查证书配置',
        code: 'SSL_HANDSHAKE_ERROR',
      );
    } else if (error is HttpException) {
      return AppExceptionFactory.createNetworkException(
        'HTTP请求错误: ${error.message}',
        code: 'HTTP_ERROR',
      );
    } else {
      return AppExceptionFactory.createNetworkException(
        '网络错误: $error',
        code: 'UNKNOWN_NETWORK_ERROR',
      );
    }
  }

  /// 处理WebSocket相关错误
  static AppException handleWebSocketError(dynamic error) {
    if (error is AppException) {
      return error;
    } else if (error is SocketException) {
      return AppExceptionFactory.createWebSocketException(
        'WebSocket连接失败: ${error.message}',
        code: 'WEBSOCKET_CONNECTION_ERROR',
      );
    } else if (error.toString().contains('Connection refused')) {
      return AppExceptionFactory.createWebSocketException(
        'WebSocket服务器拒绝连接，请确认服务器运行在 ws://localhost:8000/',
        code: 'WEBSOCKET_REFUSED',
      );
    } else if (error.toString().contains('timeout')) {
      return AppExceptionFactory.createWebSocketException(
        'WebSocket连接超时，请检查网络或服务器状态',
        code: 'WEBSOCKET_TIMEOUT',
      );
    } else {
      return AppExceptionFactory.createWebSocketException(
        'WebSocket错误: $error',
        code: 'UNKNOWN_WEBSOCKET_ERROR',
      );
    }
  }

  /// 判断错误是否可以重试
  static bool isRetryableError(AppException exception) {
    return exception.canRetry;
  }

  /// 获取重试延迟时间（毫秒）
  static int getRetryDelay(AppException exception, int attemptNumber) {
    return exception.retryDelay;
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
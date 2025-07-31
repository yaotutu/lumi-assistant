import 'dart:io';
import 'dart:async';

import 'exceptions.dart';
import '../utils/loggers.dart';

/// 统一错误处理器
/// 
/// 提供应用级别的错误处理机制，包括：
/// - 错误类型识别和转换
/// - 用户友好的错误消息
/// - 重试机制支持
/// - 错误日志记录
/// - 超时处理
/// - 网络错误处理
/// - WebSocket错误处理
class ErrorHandler {
  /// 获取用户友好的错误信息
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.userFriendlyMessage;
    } else if (error is Exception) {
      return AppExceptionFactory.fromException(error).userFriendlyMessage;
    } else {
      return '发生未知错误，请稍后重试';
    }
  }

  /// 处理网络相关错误
  static AppException handleNetworkError(dynamic error) {
    if (error is AppException) {
      return error;
    } else if (error is SocketException) {
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
      } else if (error.osError?.errorCode == 110) {
        return AppExceptionFactory.createNetworkException(
          '连接超时，请检查网络连接',
          code: 'CONNECTION_TIMEOUT',
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
    } else if (error is TimeoutException) {
      return AppExceptionFactory.createNetworkException(
        '请求超时，请检查网络连接',
        code: 'REQUEST_TIMEOUT',
      );
    } else {
      return AppExceptionFactory.createNetworkException(
        '网络错误: $error',
        code: 'UNKNOWN_NETWORK_ERROR',
      );
    }
  }

  /// 处理WebSocket相关错误
  static AppException handleWebSocketError(dynamic error, {int reconnectAttempts = 0}) {
    if (error is AppException) {
      return error;
    } else if (error is SocketException) {
      return AppExceptionFactory.createWebSocketException(
        'WebSocket连接失败: ${error.message}',
        code: 'WEBSOCKET_CONNECTION_ERROR',
        reconnectAttempts: reconnectAttempts,
      );
    } else if (error.toString().contains('Connection refused')) {
      return AppExceptionFactory.createWebSocketException(
        'WebSocket服务器拒绝连接，请确认服务器运行在 ws://YOUR_SERVER_IP:8000/',
        code: 'WEBSOCKET_REFUSED',
        reconnectAttempts: reconnectAttempts,
      );
    } else if (error.toString().contains('timeout')) {
      return AppExceptionFactory.createWebSocketException(
        'WebSocket连接超时，请检查网络或服务器状态',
        code: 'WEBSOCKET_TIMEOUT',
        reconnectAttempts: reconnectAttempts,
      );
    } else if (error.toString().contains('Connection closed')) {
      return AppExceptionFactory.createWebSocketException(
        'WebSocket连接已断开',
        code: 'WEBSOCKET_CLOSED',
        reconnectAttempts: reconnectAttempts,
      );
    } else {
      return AppExceptionFactory.createWebSocketException(
        'WebSocket错误: $error',
        code: 'UNKNOWN_WEBSOCKET_ERROR',
        reconnectAttempts: reconnectAttempts,
      );
    }
  }

  /// 处理握手相关错误
  static AppException handleHandshakeError(dynamic error, {String? sessionId}) {
    if (error is AppException) {
      return error;
    } else if (error is TimeoutException) {
      return AppExceptionFactory.createServerException(
        '握手超时，请检查服务器状态',
        code: 'HANDSHAKE_TIMEOUT',
        details: {'sessionId': sessionId},
      );
    } else {
      return AppExceptionFactory.createServerException(
        '握手失败: $error',
        code: 'HANDSHAKE_ERROR',
        details: {'sessionId': sessionId},
      );
    }
  }

  /// 处理消息发送错误
  static AppException handleMessageSendError(dynamic error, {String? messageId}) {
    if (error is AppException) {
      return error;
    } else if (error is TimeoutException) {
      return AppExceptionFactory.createServerException(
        '消息发送超时，请检查网络连接',
        code: 'MESSAGE_SEND_TIMEOUT',
        details: {'messageId': messageId},
      );
    } else {
      return AppExceptionFactory.createServerException(
        '消息发送失败: $error',
        code: 'MESSAGE_SEND_ERROR',
        details: {'messageId': messageId},
      );
    }
  }

  /// 处理消息解析错误
  static AppException handleMessageParseError(dynamic error, {Map<String, dynamic>? rawMessage}) {
    if (error is AppException) {
      return error;
    } else {
      return AppExceptionFactory.createServerException(
        '消息解析失败: $error',
        code: 'MESSAGE_PARSE_ERROR',
        details: {'rawMessage': rawMessage},
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

  /// 获取最大重试次数
  static int getMaxRetries(AppException exception) {
    return exception.when(
      network: (message, code, statusCode, url, details) => 3,
      webSocket: (message, code, connectionState, reconnectAttempts, details) => 5,
      server: (message, code, statusCode, serverErrorType, details) => 3,
      cache: (message, code, storageType, operationType, details) => 2,
      auth: (message, code, authType, requiresReauth, details) => 0,
      validation: (message, code, field, rule, details) => 0,
      business: (message, code, businessType, details) => 0,
      system: (message, code, component, details) => 2,
      unknown: (message, code, originalException, details) => 1,
    );
  }

  /// 记录错误日志
  static void logError(dynamic error, StackTrace? stackTrace, {Map<String, dynamic>? context}) {
    final timestamp = DateTime.now().toIso8601String();
    final errorInfo = <String, dynamic>{
      'timestamp': timestamp,
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
    };

    if (error is AppException) {
      errorInfo.addAll(error.fullErrorInfo);
    }

    // 使用统一日志系统记录错误
    Loggers.error.severe('错误日志: $error', error, stackTrace);
    
    if (context != null) {
      Loggers.error.fine('错误上下文: $context');
    }

    // TODO: 实现日志记录逻辑，可以集成crashlytics等
    // 可以集成以下服务：
    // - Firebase Crashlytics
    // - Sentry
    // - 自定义日志服务
  }

  /// 处理错误并返回用户消息
  static String handleError(dynamic error, StackTrace? stackTrace, {Map<String, dynamic>? context}) {
    logError(error, stackTrace, context: context);
    return getErrorMessage(error);
  }

  /// 创建带有重试机制的Future
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? retryIf,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await operation();
      } catch (error) {
        attempt++;
        
        final appException = error is AppException 
            ? error 
            : AppExceptionFactory.fromException(error as Exception);
        
        final shouldRetry = retryIf?.call(error) ?? appException.canRetry;
        
        if (attempt >= maxAttempts || !shouldRetry) {
          Loggers.error.severe('重试操作失败', error, StackTrace.current);
          Loggers.error.fine('重试上下文: maxAttempts=$maxAttempts, attempt=$attempt, retryable=$shouldRetry');
          rethrow;
        }
        
        final retryDelay = Duration(milliseconds: appException.retryDelay);
        await Future.delayed(retryDelay);
      }
    }
  }

  /// 创建带有超时的Future
  static Future<T> withTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
    String? timeoutMessage,
  }) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException catch (e) {
      final message = timeoutMessage ?? '操作超时';
      final timeoutError = AppExceptionFactory.createServerException(
        message,
        code: 'OPERATION_TIMEOUT',
        details: {'timeout': timeout.inMilliseconds},
      );
      
      Loggers.error.severe('操作超时', timeoutError, StackTrace.current);
      Loggers.error.fine('超时上下文: originalTimeout=${e.duration?.inMilliseconds}, timeoutMessage=$timeoutMessage');
      
      throw timeoutError;
    }
  }

  /// 安全执行操作，捕获所有异常
  static Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    bool logErrors = true,
    Map<String, dynamic>? context,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      if (logErrors) {
        Loggers.error.warning('安全执行操作异常', error, stackTrace);
        if (context != null) {
          Loggers.error.fine('安全执行上下文: $context');
        }
      }
      return defaultValue;
    }
  }
}
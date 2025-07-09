import 'dart:io';

import 'exceptions.dart';

/// 统一错误处理器
class ErrorHandler {
  /// 获取用户友好的错误信息
  static String getErrorMessage(Exception error) {
    if (error is NetworkException) {
      return _getNetworkErrorMessage(error);
    } else if (error is WebSocketException) {
      return _getWebSocketErrorMessage(error);
    } else if (error is ServerException) {
      return _getServerErrorMessage(error);
    } else if (error is CacheException) {
      return '本地数据读取失败';
    } else {
      return '发生未知错误，请稍后重试';
    }
  }

  /// 获取网络错误信息
  static String _getNetworkErrorMessage(NetworkException error) {
    switch (error.code) {
      case 'CONNECTION_REFUSED':
        return '服务器拒绝连接，请检查服务器是否启动';
      case 'HOST_UNREACHABLE':
        return '网络不可达，请检查网络连接';
      case 'SOCKET_ERROR':
        return '网络连接异常，请稍后重试';
      case 'SSL_HANDSHAKE_ERROR':
        return 'SSL连接失败，请检查网络配置';
      default:
        return '网络连接失败，请检查网络设置';
    }
  }

  /// 获取WebSocket错误信息
  static String _getWebSocketErrorMessage(WebSocketException error) {
    switch (error.code) {
      case 'WEBSOCKET_REFUSED':
        return 'WebSocket服务器未启动，请启动后端服务';
      case 'WEBSOCKET_TIMEOUT':
        return '连接超时，请稍后重试';
      case 'WEBSOCKET_CONNECTION_ERROR':
        return 'WebSocket连接失败，正在尝试重连';
      default:
        return 'WebSocket连接异常，正在尝试重连';
    }
  }

  /// 获取服务器错误信息
  static String _getServerErrorMessage(ServerException error) {
    switch (error.code) {
      case 'BAD_REQUEST':
        return '请求格式错误，请重试';
      case 'UNAUTHORIZED':
        return '需要重新登录';
      case 'FORBIDDEN':
        return '权限不足';
      case 'NOT_FOUND':
        return '请求的资源不存在';
      case 'INTERNAL_SERVER_ERROR':
        return '服务器暂时不可用，请稍后重试';
      case 'SERVICE_UNAVAILABLE':
        return '服务暂时不可用，请稍后重试';
      default:
        return '服务器响应异常，请稍后重试';
    }
  }
  
  /// 处理网络相关错误
  static NetworkException handleNetworkError(dynamic error) {
    if (error is SocketException) {
      if (error.osError?.errorCode == 111) {
        return const NetworkException('服务器拒绝连接，请检查服务器是否启动', code: 'CONNECTION_REFUSED');
      } else if (error.osError?.errorCode == 113) {
        return const NetworkException('无法连接到服务器，请检查网络设置', code: 'HOST_UNREACHABLE');
      } else {
        return NetworkException('网络连接错误: ${error.message}', code: 'SOCKET_ERROR');
      }
    } else if (error is HandshakeException) {
      return const NetworkException('SSL握手失败，请检查证书配置', code: 'SSL_HANDSHAKE_ERROR');
    } else if (error is HttpException) {
      return NetworkException('HTTP请求错误: ${error.message}', code: 'HTTP_ERROR');
    } else {
      return NetworkException('网络错误: $error', code: 'UNKNOWN_NETWORK_ERROR');
    }
  }

  /// 处理WebSocket相关错误
  static WebSocketException handleWebSocketError(dynamic error) {
    if (error is WebSocketException) {
      return WebSocketException(error.message, code: 'WEBSOCKET_ERROR');
    } else if (error is SocketException) {
      return WebSocketException('WebSocket连接失败: ${error.message}', code: 'WEBSOCKET_CONNECTION_ERROR');
    } else if (error.toString().contains('Connection refused')) {
      return const WebSocketException('WebSocket服务器拒绝连接，请确认服务器运行在 ws://localhost:8000/', code: 'WEBSOCKET_REFUSED');
    } else if (error.toString().contains('timeout')) {
      return const WebSocketException('WebSocket连接超时，请检查网络或服务器状态', code: 'WEBSOCKET_TIMEOUT');
    } else {
      return WebSocketException('WebSocket错误: $error', code: 'UNKNOWN_WEBSOCKET_ERROR');
    }
  }

  /// 判断错误是否可以重试
  static bool isRetryableError(AppException exception) {
    const retryableCodes = {
      'WEBSOCKET_TIMEOUT',
      'WEBSOCKET_CONNECTION_ERROR',
      'INTERNAL_SERVER_ERROR',
      'BAD_GATEWAY',
      'SERVICE_UNAVAILABLE',
      'GATEWAY_TIMEOUT',
      'SOCKET_ERROR',
    };
    
    return retryableCodes.contains(exception.code);
  }

  /// 获取重试延迟时间（毫秒）
  static int getRetryDelay(AppException exception, int attemptNumber) {
    // 指数退避策略
    const baseDelay = 1000; // 1秒
    final maxDelay = baseDelay * (1 << attemptNumber.clamp(0, 5)); // 最大32秒
    
    switch (exception.code) {
      case 'WEBSOCKET_TIMEOUT':
      case 'GATEWAY_TIMEOUT':
        return maxDelay;
      case 'INTERNAL_SERVER_ERROR':
      case 'SERVICE_UNAVAILABLE':
        return (maxDelay * 0.8).round(); // 稍微快一点重试
      default:
        return maxDelay;
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
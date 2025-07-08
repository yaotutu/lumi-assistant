/// 应用异常基类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException(String message, {String? code}) 
      : super(message, code: code);
}

/// WebSocket异常
class WebSocketException extends AppException {
  const WebSocketException(String message, {String? code}) 
      : super(message, code: code);
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException(String message, {String? code}) 
      : super(message, code: code);
}

/// 本地存储异常
class CacheException extends AppException {
  const CacheException(String message, {String? code}) 
      : super(message, code: code);
}
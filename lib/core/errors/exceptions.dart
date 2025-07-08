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
  const NetworkException(super.message, {super.code});
}

/// WebSocket异常
class WebSocketException extends AppException {
  const WebSocketException(super.message, {super.code});
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// 本地存储异常
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}
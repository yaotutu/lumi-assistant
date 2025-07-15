/// API相关常量
class ApiConstants {
  /// WebSocket服务器基础地址
  /// 使用Python服务器：ws://192.168.110.199:8000/xiaozhi/v1
  /// 生产环境需要根据实际服务器IP调整
  static const String webSocketBaseUrl = 'ws://192.168.110.199:8000/xiaozhi/v1';

  /// HTTP API基础地址
  /// 使用Python服务器：http://192.168.110.199:8000/api
  /// 生产环境需要根据实际服务器IP调整
  static const String httpBaseUrl = 'http://192.168.110.199:8000/api';

  /// 默认认证Token
  static const String defaultToken = 'your-token1';

  /// 协议版本
  static const int protocolVersion = 1;

  /// 连接超时时间（毫秒）
  static const int connectTimeout = 5000;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 3000;


  /// 最大重连次数
  static const int maxReconnectAttempts = 5;

  /// 连接超时时间（毫秒）
  static const int connectionTimeout = 10000;

  /// 重连延迟时间（毫秒）
  static const int reconnectDelay = 2000;
}

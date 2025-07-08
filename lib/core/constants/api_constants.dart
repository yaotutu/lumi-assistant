/// API相关常量
class ApiConstants {
  /// WebSocket服务器地址
  static const String webSocketUrl = 'ws://localhost:8080/ws';
  
  /// HTTP API基础地址
  static const String httpBaseUrl = 'http://localhost:8080/api';
  
  /// 连接超时时间（毫秒）
  static const int connectTimeout = 5000;
  
  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 3000;
  
  /// 心跳间隔时间（毫秒）
  static const int heartbeatInterval = 30000;
  
  /// 最大重连次数
  static const int maxReconnectAttempts = 5;
}
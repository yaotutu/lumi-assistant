import 'package:freezed_annotation/freezed_annotation.dart';

part 'exceptions.freezed.dart';

/// 应用异常基类 - 使用Freezed优化
/// 
/// 提供统一的异常处理机制，包括：
/// - 错误消息
/// - 错误代码
/// - 错误类型分类
/// - 错误元数据
/// 
/// 使用Freezed的优势：
/// - 自动生成copyWith方法
/// - 自动生成equals和hashCode
/// - 自动生成toString
/// - 类型安全的sealed类支持
/// - 不可变性保证
@freezed
sealed class AppException with _$AppException implements Exception {
  /// 网络异常
  /// 
  /// 网络连接、请求、响应相关的异常
  const factory AppException.network({
    /// 错误消息
    required String message,
    
    /// 错误代码
    String? code,
    
    /// HTTP状态码
    int? statusCode,
    
    /// 请求URL
    String? url,
    
    /// 错误详情
    Map<String, dynamic>? details,
  }) = NetworkException;

  /// WebSocket异常
  /// 
  /// WebSocket连接、通信相关的异常
  const factory AppException.webSocket({
    /// 错误消息
    required String message,
    
    /// 错误代码
    String? code,
    
    /// 连接状态
    String? connectionState,
    
    /// 重连次数
    @Default(0) int reconnectAttempts,
    
    /// 错误详情
    Map<String, dynamic>? details,
  }) = WebSocketException;

  /// 服务器异常
  /// 
  /// 服务器端错误相关的异常
  const factory AppException.server({
    /// 错误消息
    required String message,
    
    /// 错误代码
    String? code,
    
    /// HTTP状态码
    int? statusCode,
    
    /// 服务器错误类型
    String? serverErrorType,
    
    /// 错误详情
    Map<String, dynamic>? details,
  }) = ServerException;

  /// 本地存储异常
  /// 
  /// 本地存储、缓存相关的异常
  const factory AppException.cache({
    /// 错误消息
    required String message,
    
    /// 错误代码
    String? code,
    
    /// 存储类型
    String? storageType,
    
    /// 操作类型
    String? operationType,
    
    /// 错误详情
    Map<String, dynamic>? details,
  }) = CacheException;

  /// 认证异常
  /// 
  /// 用户认证、授权相关的异常
  const factory AppException.auth({
    /// 错误消息
    required String message,
    
    /// 错误代码
    String? code,
    
    /// 认证类型
    String? authType,
    
    /// 是否需要重新登录
    @Default(false) bool requiresReauth,
    
    /// 错误详情
    Map<String, dynamic>? details,
  }) = AuthException;

  /// 数据验证异常
  /// 
  /// 数据验证、格式化相关的异常
  const factory AppException.validation({
    /// 错误消息
    required String message,
    
    /// 错误代码
    String? code,
    
    /// 验证字段
    String? field,
    
    /// 验证规则
    String? rule,
    
    /// 错误详情
    Map<String, dynamic>? details,
  }) = ValidationException;

  /// 业务逻辑异常
  /// 
  /// 业务规则、逻辑处理相关的异常
  const factory AppException.business({
    /// 错误消息
    required String message,
    
    /// 错误代码
    String? code,
    
    /// 业务类型
    String? businessType,
    
    /// 错误详情
    Map<String, dynamic>? details,
  }) = BusinessException;

  /// 系统异常
  /// 
  /// 系统级别的异常
  const factory AppException.system({
    /// 错误消息
    required String message,
    
    /// 错误代码
    String? code,
    
    /// 系统组件
    String? component,
    
    /// 错误详情
    Map<String, dynamic>? details,
  }) = SystemException;

  /// 未知异常
  /// 
  /// 未分类的异常
  const factory AppException.unknown({
    /// 错误消息
    required String message,
    
    /// 错误代码
    String? code,
    
    /// 原始异常
    Object? originalException,
    
    /// 错误详情
    Map<String, dynamic>? details,
  }) = UnknownException;
}

/// 应用异常扩展方法
/// 
/// 提供便捷的异常处理和查询方法
extension AppExceptionExtension on AppException {
  /// 是否是网络异常
  bool get isNetworkException => this is NetworkException;
  
  /// 是否是WebSocket异常
  bool get isWebSocketException => this is WebSocketException;
  
  /// 是否是服务器异常
  bool get isServerException => this is ServerException;
  
  /// 是否是缓存异常
  bool get isCacheException => this is CacheException;
  
  /// 是否是认证异常
  bool get isAuthException => this is AuthException;
  
  /// 是否是验证异常
  bool get isValidationException => this is ValidationException;
  
  /// 是否是业务异常
  bool get isBusinessException => this is BusinessException;
  
  /// 是否是系统异常
  bool get isSystemException => this is SystemException;
  
  /// 是否是未知异常
  bool get isUnknownException => this is UnknownException;
  
  /// 获取错误消息
  String get errorMessage => when(
    network: (message, code, statusCode, url, details) => message,
    webSocket: (message, code, connectionState, reconnectAttempts, details) => message,
    server: (message, code, statusCode, serverErrorType, details) => message,
    cache: (message, code, storageType, operationType, details) => message,
    auth: (message, code, authType, requiresReauth, details) => message,
    validation: (message, code, field, rule, details) => message,
    business: (message, code, businessType, details) => message,
    system: (message, code, component, details) => message,
    unknown: (message, code, originalException, details) => message,
  );
  
  /// 获取错误代码
  String? get errorCode => when(
    network: (message, code, statusCode, url, details) => code,
    webSocket: (message, code, connectionState, reconnectAttempts, details) => code,
    server: (message, code, statusCode, serverErrorType, details) => code,
    cache: (message, code, storageType, operationType, details) => code,
    auth: (message, code, authType, requiresReauth, details) => code,
    validation: (message, code, field, rule, details) => code,
    business: (message, code, businessType, details) => code,
    system: (message, code, component, details) => code,
    unknown: (message, code, originalException, details) => code,
  );
  
  /// 获取错误详情
  Map<String, dynamic>? get errorDetails => when(
    network: (message, code, statusCode, url, details) => details,
    webSocket: (message, code, connectionState, reconnectAttempts, details) => details,
    server: (message, code, statusCode, serverErrorType, details) => details,
    cache: (message, code, storageType, operationType, details) => details,
    auth: (message, code, authType, requiresReauth, details) => details,
    validation: (message, code, field, rule, details) => details,
    business: (message, code, businessType, details) => details,
    system: (message, code, component, details) => details,
    unknown: (message, code, originalException, details) => details,
  );
  
  /// 获取用户友好的错误消息
  String get userFriendlyMessage => when(
    network: (message, code, statusCode, url, details) {
      if (statusCode != null) {
        switch (statusCode) {
          case 400:
            return '请求参数错误';
          case 401:
            return '认证失败，请重新登录';
          case 403:
            return '没有访问权限';
          case 404:
            return '请求的资源不存在';
          case 500:
            return '服务器内部错误';
          case 503:
            return '服务暂时不可用';
          default:
            return '网络请求失败';
        }
      }
      return '网络连接失败，请检查网络设置';
    },
    webSocket: (message, code, connectionState, reconnectAttempts, details) {
      if (reconnectAttempts > 0) {
        return '连接不稳定，正在重连...';
      }
      return '连接失败，请检查网络设置';
    },
    server: (message, code, statusCode, serverErrorType, details) => '服务器错误，请稍后重试',
    cache: (message, code, storageType, operationType, details) => '本地存储错误',
    auth: (message, code, authType, requiresReauth, details) => '认证失败，请重新登录',
    validation: (message, code, field, rule, details) => '数据验证失败',
    business: (message, code, businessType, details) => message,
    system: (message, code, component, details) => '系统错误',
    unknown: (message, code, originalException, details) => '未知错误',
  );
  
  /// 获取错误严重程度
  ErrorSeverity get severity => when(
    network: (message, code, statusCode, url, details) => ErrorSeverity.medium,
    webSocket: (message, code, connectionState, reconnectAttempts, details) => ErrorSeverity.medium,
    server: (message, code, statusCode, serverErrorType, details) => ErrorSeverity.high,
    cache: (message, code, storageType, operationType, details) => ErrorSeverity.low,
    auth: (message, code, authType, requiresReauth, details) => ErrorSeverity.high,
    validation: (message, code, field, rule, details) => ErrorSeverity.medium,
    business: (message, code, businessType, details) => ErrorSeverity.medium,
    system: (message, code, component, details) => ErrorSeverity.high,
    unknown: (message, code, originalException, details) => ErrorSeverity.medium,
  );
  
  /// 是否可以重试
  bool get canRetry => when(
    network: (message, code, statusCode, url, details) => statusCode != 400 && statusCode != 401 && statusCode != 403,
    webSocket: (message, code, connectionState, reconnectAttempts, details) => reconnectAttempts < 5,
    server: (message, code, statusCode, serverErrorType, details) => statusCode != 400 && statusCode != 401 && statusCode != 403,
    cache: (message, code, storageType, operationType, details) => true,
    auth: (message, code, authType, requiresReauth, details) => !requiresReauth,
    validation: (message, code, field, rule, details) => false,
    business: (message, code, businessType, details) => false,
    system: (message, code, component, details) => true,
    unknown: (message, code, originalException, details) => true,
  );
  
  /// 获取建议的重试延迟(毫秒)
  int get retryDelay => when(
    network: (message, code, statusCode, url, details) => 2000,
    webSocket: (message, code, connectionState, reconnectAttempts, details) {
      final baseDelay = 1000;
      final maxDelay = 30000;
      final delay = baseDelay * (1 << reconnectAttempts.clamp(0, 5));
      return delay.clamp(baseDelay, maxDelay);
    },
    server: (message, code, statusCode, serverErrorType, details) => 5000,
    cache: (message, code, storageType, operationType, details) => 1000,
    auth: (message, code, authType, requiresReauth, details) => 0,
    validation: (message, code, field, rule, details) => 0,
    business: (message, code, businessType, details) => 0,
    system: (message, code, component, details) => 3000,
    unknown: (message, code, originalException, details) => 3000,
  );
  
  /// 获取完整的错误信息
  Map<String, dynamic> get fullErrorInfo => {
    'type': runtimeType.toString(),
    'message': errorMessage,
    'code': errorCode,
    'details': errorDetails,
    'userFriendlyMessage': userFriendlyMessage,
    'severity': severity.name,
    'canRetry': canRetry,
    'retryDelay': retryDelay,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

/// 错误严重程度枚举
enum ErrorSeverity {
  /// 低严重程度
  low,
  
  /// 中等严重程度
  medium,
  
  /// 高严重程度
  high,
  
  /// 严重
  critical,
}

/// 异常工厂方法
/// 
/// 提供快速创建各种异常的便捷方法
class AppExceptionFactory {
  /// 创建网络异常
  static AppException createNetworkException(
    String message, {
    String? code,
    int? statusCode,
    String? url,
    Map<String, dynamic>? details,
  }) {
    return AppException.network(
      message: message,
      code: code,
      statusCode: statusCode,
      url: url,
      details: details,
    );
  }
  
  /// 创建WebSocket异常
  static AppException createWebSocketException(
    String message, {
    String? code,
    String? connectionState,
    int reconnectAttempts = 0,
    Map<String, dynamic>? details,
  }) {
    return AppException.webSocket(
      message: message,
      code: code,
      connectionState: connectionState,
      reconnectAttempts: reconnectAttempts,
      details: details,
    );
  }
  
  /// 创建服务器异常
  static AppException createServerException(
    String message, {
    String? code,
    int? statusCode,
    String? serverErrorType,
    Map<String, dynamic>? details,
  }) {
    return AppException.server(
      message: message,
      code: code,
      statusCode: statusCode,
      serverErrorType: serverErrorType,
      details: details,
    );
  }
  
  /// 创建缓存异常
  static AppException createCacheException(
    String message, {
    String? code,
    String? storageType,
    String? operationType,
    Map<String, dynamic>? details,
  }) {
    return AppException.cache(
      message: message,
      code: code,
      storageType: storageType,
      operationType: operationType,
      details: details,
    );
  }
  
  /// 创建认证异常
  static AppException createAuthException(
    String message, {
    String? code,
    String? authType,
    bool requiresReauth = false,
    Map<String, dynamic>? details,
  }) {
    return AppException.auth(
      message: message,
      code: code,
      authType: authType,
      requiresReauth: requiresReauth,
      details: details,
    );
  }
  
  /// 创建验证异常
  static AppException createValidationException(
    String message, {
    String? code,
    String? field,
    String? rule,
    Map<String, dynamic>? details,
  }) {
    return AppException.validation(
      message: message,
      code: code,
      field: field,
      rule: rule,
      details: details,
    );
  }
  
  /// 创建业务异常
  static AppException createBusinessException(
    String message, {
    String? code,
    String? businessType,
    Map<String, dynamic>? details,
  }) {
    return AppException.business(
      message: message,
      code: code,
      businessType: businessType,
      details: details,
    );
  }
  
  /// 创建系统异常
  static AppException createSystemException(
    String message, {
    String? code,
    String? component,
    Map<String, dynamic>? details,
  }) {
    return AppException.system(
      message: message,
      code: code,
      component: component,
      details: details,
    );
  }
  
  /// 创建未知异常
  static AppException createUnknownException(
    String message, {
    String? code,
    Object? originalException,
    Map<String, dynamic>? details,
  }) {
    return AppException.unknown(
      message: message,
      code: code,
      originalException: originalException,
      details: details,
    );
  }
  
  /// 从通用异常转换为AppException
  static AppException fromException(Exception exception) {
    if (exception is AppException) {
      return exception;
    }
    
    return AppException.unknown(
      message: exception.toString(),
      originalException: exception,
    );
  }
}
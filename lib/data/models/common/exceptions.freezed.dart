// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exceptions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppException {
  /// 错误消息
  String get message => throw _privateConstructorUsedError;

  /// 错误代码
  String? get code => throw _privateConstructorUsedError;

  /// 错误详情
  Map<String, dynamic>? get details => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppExceptionCopyWith<AppException> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppExceptionCopyWith<$Res> {
  factory $AppExceptionCopyWith(
          AppException value, $Res Function(AppException) then) =
      _$AppExceptionCopyWithImpl<$Res, AppException>;
  @useResult
  $Res call({String message, String? code, Map<String, dynamic>? details});
}

/// @nodoc
class _$AppExceptionCopyWithImpl<$Res, $Val extends AppException>
    implements $AppExceptionCopyWith<$Res> {
  _$AppExceptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$NetworkExceptionImplCopyWith(_$NetworkExceptionImpl value,
          $Res Function(_$NetworkExceptionImpl) then) =
      __$$NetworkExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      int? statusCode,
      String? url,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$NetworkExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$NetworkExceptionImpl>
    implements _$$NetworkExceptionImplCopyWith<$Res> {
  __$$NetworkExceptionImplCopyWithImpl(_$NetworkExceptionImpl _value,
      $Res Function(_$NetworkExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? statusCode = freezed,
    Object? url = freezed,
    Object? details = freezed,
  }) {
    return _then(_$NetworkExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$NetworkExceptionImpl implements NetworkException {
  const _$NetworkExceptionImpl(
      {required this.message,
      this.code,
      this.statusCode,
      this.url,
      final Map<String, dynamic>? details})
      : _details = details;

  /// 错误消息
  @override
  final String message;

  /// 错误代码
  @override
  final String? code;

  /// HTTP状态码
  @override
  final int? statusCode;

  /// 请求URL
  @override
  final String? url;

  /// 错误详情
  final Map<String, dynamic>? _details;

  /// 错误详情
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.network(message: $message, code: $code, statusCode: $statusCode, url: $url, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, statusCode, url,
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      __$$NetworkExceptionImplCopyWithImpl<_$NetworkExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) {
    return network(message, code, statusCode, url, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) {
    return network?.call(message, code, statusCode, url, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, code, statusCode, url, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkException implements AppException {
  const factory NetworkException(
      {required final String message,
      final String? code,
      final int? statusCode,
      final String? url,
      final Map<String, dynamic>? details}) = _$NetworkExceptionImpl;

  /// 错误消息
  @override
  String get message;

  /// 错误代码
  @override
  String? get code;

  /// HTTP状态码
  int? get statusCode;

  /// 请求URL
  String? get url;

  /// 错误详情
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WebSocketExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$WebSocketExceptionImplCopyWith(_$WebSocketExceptionImpl value,
          $Res Function(_$WebSocketExceptionImpl) then) =
      __$$WebSocketExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      String? connectionState,
      int reconnectAttempts,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$WebSocketExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$WebSocketExceptionImpl>
    implements _$$WebSocketExceptionImplCopyWith<$Res> {
  __$$WebSocketExceptionImplCopyWithImpl(_$WebSocketExceptionImpl _value,
      $Res Function(_$WebSocketExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? connectionState = freezed,
    Object? reconnectAttempts = null,
    Object? details = freezed,
  }) {
    return _then(_$WebSocketExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      connectionState: freezed == connectionState
          ? _value.connectionState
          : connectionState // ignore: cast_nullable_to_non_nullable
              as String?,
      reconnectAttempts: null == reconnectAttempts
          ? _value.reconnectAttempts
          : reconnectAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$WebSocketExceptionImpl implements WebSocketException {
  const _$WebSocketExceptionImpl(
      {required this.message,
      this.code,
      this.connectionState,
      this.reconnectAttempts = 0,
      final Map<String, dynamic>? details})
      : _details = details;

  /// 错误消息
  @override
  final String message;

  /// 错误代码
  @override
  final String? code;

  /// 连接状态
  @override
  final String? connectionState;

  /// 重连次数
  @override
  @JsonKey()
  final int reconnectAttempts;

  /// 错误详情
  final Map<String, dynamic>? _details;

  /// 错误详情
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.webSocket(message: $message, code: $code, connectionState: $connectionState, reconnectAttempts: $reconnectAttempts, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebSocketExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.connectionState, connectionState) ||
                other.connectionState == connectionState) &&
            (identical(other.reconnectAttempts, reconnectAttempts) ||
                other.reconnectAttempts == reconnectAttempts) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, connectionState,
      reconnectAttempts, const DeepCollectionEquality().hash(_details));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebSocketExceptionImplCopyWith<_$WebSocketExceptionImpl> get copyWith =>
      __$$WebSocketExceptionImplCopyWithImpl<_$WebSocketExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) {
    return webSocket(
        message, code, connectionState, reconnectAttempts, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) {
    return webSocket?.call(
        message, code, connectionState, reconnectAttempts, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) {
    if (webSocket != null) {
      return webSocket(
          message, code, connectionState, reconnectAttempts, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) {
    return webSocket(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return webSocket?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (webSocket != null) {
      return webSocket(this);
    }
    return orElse();
  }
}

abstract class WebSocketException implements AppException {
  const factory WebSocketException(
      {required final String message,
      final String? code,
      final String? connectionState,
      final int reconnectAttempts,
      final Map<String, dynamic>? details}) = _$WebSocketExceptionImpl;

  /// 错误消息
  @override
  String get message;

  /// 错误代码
  @override
  String? get code;

  /// 连接状态
  String? get connectionState;

  /// 重连次数
  int get reconnectAttempts;

  /// 错误详情
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebSocketExceptionImplCopyWith<_$WebSocketExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$ServerExceptionImplCopyWith(_$ServerExceptionImpl value,
          $Res Function(_$ServerExceptionImpl) then) =
      __$$ServerExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      int? statusCode,
      String? serverErrorType,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$ServerExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$ServerExceptionImpl>
    implements _$$ServerExceptionImplCopyWith<$Res> {
  __$$ServerExceptionImplCopyWithImpl(
      _$ServerExceptionImpl _value, $Res Function(_$ServerExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? statusCode = freezed,
    Object? serverErrorType = freezed,
    Object? details = freezed,
  }) {
    return _then(_$ServerExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      serverErrorType: freezed == serverErrorType
          ? _value.serverErrorType
          : serverErrorType // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$ServerExceptionImpl implements ServerException {
  const _$ServerExceptionImpl(
      {required this.message,
      this.code,
      this.statusCode,
      this.serverErrorType,
      final Map<String, dynamic>? details})
      : _details = details;

  /// 错误消息
  @override
  final String message;

  /// 错误代码
  @override
  final String? code;

  /// HTTP状态码
  @override
  final int? statusCode;

  /// 服务器错误类型
  @override
  final String? serverErrorType;

  /// 错误详情
  final Map<String, dynamic>? _details;

  /// 错误详情
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.server(message: $message, code: $code, statusCode: $statusCode, serverErrorType: $serverErrorType, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.serverErrorType, serverErrorType) ||
                other.serverErrorType == serverErrorType) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, statusCode,
      serverErrorType, const DeepCollectionEquality().hash(_details));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerExceptionImplCopyWith<_$ServerExceptionImpl> get copyWith =>
      __$$ServerExceptionImplCopyWithImpl<_$ServerExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) {
    return server(message, code, statusCode, serverErrorType, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) {
    return server?.call(message, code, statusCode, serverErrorType, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(message, code, statusCode, serverErrorType, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerException implements AppException {
  const factory ServerException(
      {required final String message,
      final String? code,
      final int? statusCode,
      final String? serverErrorType,
      final Map<String, dynamic>? details}) = _$ServerExceptionImpl;

  /// 错误消息
  @override
  String get message;

  /// 错误代码
  @override
  String? get code;

  /// HTTP状态码
  int? get statusCode;

  /// 服务器错误类型
  String? get serverErrorType;

  /// 错误详情
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerExceptionImplCopyWith<_$ServerExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$CacheExceptionImplCopyWith(_$CacheExceptionImpl value,
          $Res Function(_$CacheExceptionImpl) then) =
      __$$CacheExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      String? storageType,
      String? operationType,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$CacheExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$CacheExceptionImpl>
    implements _$$CacheExceptionImplCopyWith<$Res> {
  __$$CacheExceptionImplCopyWithImpl(
      _$CacheExceptionImpl _value, $Res Function(_$CacheExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? storageType = freezed,
    Object? operationType = freezed,
    Object? details = freezed,
  }) {
    return _then(_$CacheExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      storageType: freezed == storageType
          ? _value.storageType
          : storageType // ignore: cast_nullable_to_non_nullable
              as String?,
      operationType: freezed == operationType
          ? _value.operationType
          : operationType // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$CacheExceptionImpl implements CacheException {
  const _$CacheExceptionImpl(
      {required this.message,
      this.code,
      this.storageType,
      this.operationType,
      final Map<String, dynamic>? details})
      : _details = details;

  /// 错误消息
  @override
  final String message;

  /// 错误代码
  @override
  final String? code;

  /// 存储类型
  @override
  final String? storageType;

  /// 操作类型
  @override
  final String? operationType;

  /// 错误详情
  final Map<String, dynamic>? _details;

  /// 错误详情
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.cache(message: $message, code: $code, storageType: $storageType, operationType: $operationType, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.storageType, storageType) ||
                other.storageType == storageType) &&
            (identical(other.operationType, operationType) ||
                other.operationType == operationType) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, storageType,
      operationType, const DeepCollectionEquality().hash(_details));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheExceptionImplCopyWith<_$CacheExceptionImpl> get copyWith =>
      __$$CacheExceptionImplCopyWithImpl<_$CacheExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) {
    return cache(message, code, storageType, operationType, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) {
    return cache?.call(message, code, storageType, operationType, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(message, code, storageType, operationType, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) {
    return cache(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return cache?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(this);
    }
    return orElse();
  }
}

abstract class CacheException implements AppException {
  const factory CacheException(
      {required final String message,
      final String? code,
      final String? storageType,
      final String? operationType,
      final Map<String, dynamic>? details}) = _$CacheExceptionImpl;

  /// 错误消息
  @override
  String get message;

  /// 错误代码
  @override
  String? get code;

  /// 存储类型
  String? get storageType;

  /// 操作类型
  String? get operationType;

  /// 错误详情
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CacheExceptionImplCopyWith<_$CacheExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$AuthExceptionImplCopyWith(
          _$AuthExceptionImpl value, $Res Function(_$AuthExceptionImpl) then) =
      __$$AuthExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      String? authType,
      bool requiresReauth,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$AuthExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$AuthExceptionImpl>
    implements _$$AuthExceptionImplCopyWith<$Res> {
  __$$AuthExceptionImplCopyWithImpl(
      _$AuthExceptionImpl _value, $Res Function(_$AuthExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? authType = freezed,
    Object? requiresReauth = null,
    Object? details = freezed,
  }) {
    return _then(_$AuthExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      authType: freezed == authType
          ? _value.authType
          : authType // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresReauth: null == requiresReauth
          ? _value.requiresReauth
          : requiresReauth // ignore: cast_nullable_to_non_nullable
              as bool,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$AuthExceptionImpl implements AuthException {
  const _$AuthExceptionImpl(
      {required this.message,
      this.code,
      this.authType,
      this.requiresReauth = false,
      final Map<String, dynamic>? details})
      : _details = details;

  /// 错误消息
  @override
  final String message;

  /// 错误代码
  @override
  final String? code;

  /// 认证类型
  @override
  final String? authType;

  /// 是否需要重新登录
  @override
  @JsonKey()
  final bool requiresReauth;

  /// 错误详情
  final Map<String, dynamic>? _details;

  /// 错误详情
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.auth(message: $message, code: $code, authType: $authType, requiresReauth: $requiresReauth, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.authType, authType) ||
                other.authType == authType) &&
            (identical(other.requiresReauth, requiresReauth) ||
                other.requiresReauth == requiresReauth) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, authType,
      requiresReauth, const DeepCollectionEquality().hash(_details));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthExceptionImplCopyWith<_$AuthExceptionImpl> get copyWith =>
      __$$AuthExceptionImplCopyWithImpl<_$AuthExceptionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) {
    return auth(message, code, authType, requiresReauth, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) {
    return auth?.call(message, code, authType, requiresReauth, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(message, code, authType, requiresReauth, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) {
    return auth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return auth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(this);
    }
    return orElse();
  }
}

abstract class AuthException implements AppException {
  const factory AuthException(
      {required final String message,
      final String? code,
      final String? authType,
      final bool requiresReauth,
      final Map<String, dynamic>? details}) = _$AuthExceptionImpl;

  /// 错误消息
  @override
  String get message;

  /// 错误代码
  @override
  String? get code;

  /// 认证类型
  String? get authType;

  /// 是否需要重新登录
  bool get requiresReauth;

  /// 错误详情
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthExceptionImplCopyWith<_$AuthExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$ValidationExceptionImplCopyWith(_$ValidationExceptionImpl value,
          $Res Function(_$ValidationExceptionImpl) then) =
      __$$ValidationExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      String? field,
      String? rule,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$ValidationExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$ValidationExceptionImpl>
    implements _$$ValidationExceptionImplCopyWith<$Res> {
  __$$ValidationExceptionImplCopyWithImpl(_$ValidationExceptionImpl _value,
      $Res Function(_$ValidationExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? field = freezed,
    Object? rule = freezed,
    Object? details = freezed,
  }) {
    return _then(_$ValidationExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      field: freezed == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String?,
      rule: freezed == rule
          ? _value.rule
          : rule // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$ValidationExceptionImpl implements ValidationException {
  const _$ValidationExceptionImpl(
      {required this.message,
      this.code,
      this.field,
      this.rule,
      final Map<String, dynamic>? details})
      : _details = details;

  /// 错误消息
  @override
  final String message;

  /// 错误代码
  @override
  final String? code;

  /// 验证字段
  @override
  final String? field;

  /// 验证规则
  @override
  final String? rule;

  /// 错误详情
  final Map<String, dynamic>? _details;

  /// 错误详情
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.validation(message: $message, code: $code, field: $field, rule: $rule, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.rule, rule) || other.rule == rule) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, field, rule,
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationExceptionImplCopyWith<_$ValidationExceptionImpl> get copyWith =>
      __$$ValidationExceptionImplCopyWithImpl<_$ValidationExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) {
    return validation(message, code, field, rule, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) {
    return validation?.call(message, code, field, rule, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, code, field, rule, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationException implements AppException {
  const factory ValidationException(
      {required final String message,
      final String? code,
      final String? field,
      final String? rule,
      final Map<String, dynamic>? details}) = _$ValidationExceptionImpl;

  /// 错误消息
  @override
  String get message;

  /// 错误代码
  @override
  String? get code;

  /// 验证字段
  String? get field;

  /// 验证规则
  String? get rule;

  /// 错误详情
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationExceptionImplCopyWith<_$ValidationExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BusinessExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$BusinessExceptionImplCopyWith(_$BusinessExceptionImpl value,
          $Res Function(_$BusinessExceptionImpl) then) =
      __$$BusinessExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      String? businessType,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$BusinessExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$BusinessExceptionImpl>
    implements _$$BusinessExceptionImplCopyWith<$Res> {
  __$$BusinessExceptionImplCopyWithImpl(_$BusinessExceptionImpl _value,
      $Res Function(_$BusinessExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? businessType = freezed,
    Object? details = freezed,
  }) {
    return _then(_$BusinessExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      businessType: freezed == businessType
          ? _value.businessType
          : businessType // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$BusinessExceptionImpl implements BusinessException {
  const _$BusinessExceptionImpl(
      {required this.message,
      this.code,
      this.businessType,
      final Map<String, dynamic>? details})
      : _details = details;

  /// 错误消息
  @override
  final String message;

  /// 错误代码
  @override
  final String? code;

  /// 业务类型
  @override
  final String? businessType;

  /// 错误详情
  final Map<String, dynamic>? _details;

  /// 错误详情
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.business(message: $message, code: $code, businessType: $businessType, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.businessType, businessType) ||
                other.businessType == businessType) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, businessType,
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessExceptionImplCopyWith<_$BusinessExceptionImpl> get copyWith =>
      __$$BusinessExceptionImplCopyWithImpl<_$BusinessExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) {
    return business(message, code, businessType, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) {
    return business?.call(message, code, businessType, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) {
    if (business != null) {
      return business(message, code, businessType, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) {
    return business(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return business?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (business != null) {
      return business(this);
    }
    return orElse();
  }
}

abstract class BusinessException implements AppException {
  const factory BusinessException(
      {required final String message,
      final String? code,
      final String? businessType,
      final Map<String, dynamic>? details}) = _$BusinessExceptionImpl;

  /// 错误消息
  @override
  String get message;

  /// 错误代码
  @override
  String? get code;

  /// 业务类型
  String? get businessType;

  /// 错误详情
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessExceptionImplCopyWith<_$BusinessExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SystemExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$SystemExceptionImplCopyWith(_$SystemExceptionImpl value,
          $Res Function(_$SystemExceptionImpl) then) =
      __$$SystemExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      String? component,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$SystemExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$SystemExceptionImpl>
    implements _$$SystemExceptionImplCopyWith<$Res> {
  __$$SystemExceptionImplCopyWithImpl(
      _$SystemExceptionImpl _value, $Res Function(_$SystemExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? component = freezed,
    Object? details = freezed,
  }) {
    return _then(_$SystemExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      component: freezed == component
          ? _value.component
          : component // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$SystemExceptionImpl implements SystemException {
  const _$SystemExceptionImpl(
      {required this.message,
      this.code,
      this.component,
      final Map<String, dynamic>? details})
      : _details = details;

  /// 错误消息
  @override
  final String message;

  /// 错误代码
  @override
  final String? code;

  /// 系统组件
  @override
  final String? component;

  /// 错误详情
  final Map<String, dynamic>? _details;

  /// 错误详情
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.system(message: $message, code: $code, component: $component, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.component, component) ||
                other.component == component) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, component,
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemExceptionImplCopyWith<_$SystemExceptionImpl> get copyWith =>
      __$$SystemExceptionImplCopyWithImpl<_$SystemExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) {
    return system(message, code, component, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) {
    return system?.call(message, code, component, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) {
    if (system != null) {
      return system(message, code, component, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) {
    return system(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return system?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (system != null) {
      return system(this);
    }
    return orElse();
  }
}

abstract class SystemException implements AppException {
  const factory SystemException(
      {required final String message,
      final String? code,
      final String? component,
      final Map<String, dynamic>? details}) = _$SystemExceptionImpl;

  /// 错误消息
  @override
  String get message;

  /// 错误代码
  @override
  String? get code;

  /// 系统组件
  String? get component;

  /// 错误详情
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemExceptionImplCopyWith<_$SystemExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$UnknownExceptionImplCopyWith(_$UnknownExceptionImpl value,
          $Res Function(_$UnknownExceptionImpl) then) =
      __$$UnknownExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      Object? originalException,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$UnknownExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$UnknownExceptionImpl>
    implements _$$UnknownExceptionImplCopyWith<$Res> {
  __$$UnknownExceptionImplCopyWithImpl(_$UnknownExceptionImpl _value,
      $Res Function(_$UnknownExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? originalException = freezed,
    Object? details = freezed,
  }) {
    return _then(_$UnknownExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      originalException: freezed == originalException
          ? _value.originalException
          : originalException,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$UnknownExceptionImpl implements UnknownException {
  const _$UnknownExceptionImpl(
      {required this.message,
      this.code,
      this.originalException,
      final Map<String, dynamic>? details})
      : _details = details;

  /// 错误消息
  @override
  final String message;

  /// 错误代码
  @override
  final String? code;

  /// 原始异常
  @override
  final Object? originalException;

  /// 错误详情
  final Map<String, dynamic>? _details;

  /// 错误详情
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.unknown(message: $message, code: $code, originalException: $originalException, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality()
                .equals(other.originalException, originalException) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      message,
      code,
      const DeepCollectionEquality().hash(originalException),
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith =>
      __$$UnknownExceptionImplCopyWithImpl<_$UnknownExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)
        network,
    required TResult Function(
            String message,
            String? code,
            String? connectionState,
            int reconnectAttempts,
            Map<String, dynamic>? details)
        webSocket,
    required TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)
        server,
    required TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)
        cache,
    required TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)
        auth,
    required TResult Function(String message, String? code, String? field,
            String? rule, Map<String, dynamic>? details)
        validation,
    required TResult Function(String message, String? code,
            String? businessType, Map<String, dynamic>? details)
        business,
    required TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)
        system,
    required TResult Function(String message, String? code,
            Object? originalException, Map<String, dynamic>? details)
        unknown,
  }) {
    return unknown(message, code, originalException, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code, int? statusCode,
            String? url, Map<String, dynamic>? details)?
        network,
    TResult? Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult? Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult? Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult? Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult? Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult? Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult? Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult? Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
  }) {
    return unknown?.call(message, code, originalException, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code, int? statusCode, String? url,
            Map<String, dynamic>? details)?
        network,
    TResult Function(String message, String? code, String? connectionState,
            int reconnectAttempts, Map<String, dynamic>? details)?
        webSocket,
    TResult Function(String message, String? code, int? statusCode,
            String? serverErrorType, Map<String, dynamic>? details)?
        server,
    TResult Function(String message, String? code, String? storageType,
            String? operationType, Map<String, dynamic>? details)?
        cache,
    TResult Function(String message, String? code, String? authType,
            bool requiresReauth, Map<String, dynamic>? details)?
        auth,
    TResult Function(String message, String? code, String? field, String? rule,
            Map<String, dynamic>? details)?
        validation,
    TResult Function(String message, String? code, String? businessType,
            Map<String, dynamic>? details)?
        business,
    TResult Function(String message, String? code, String? component,
            Map<String, dynamic>? details)?
        system,
    TResult Function(String message, String? code, Object? originalException,
            Map<String, dynamic>? details)?
        unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, code, originalException, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(WebSocketException value) webSocket,
    required TResult Function(ServerException value) server,
    required TResult Function(CacheException value) cache,
    required TResult Function(AuthException value) auth,
    required TResult Function(ValidationException value) validation,
    required TResult Function(BusinessException value) business,
    required TResult Function(SystemException value) system,
    required TResult Function(UnknownException value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(WebSocketException value)? webSocket,
    TResult? Function(ServerException value)? server,
    TResult? Function(CacheException value)? cache,
    TResult? Function(AuthException value)? auth,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(BusinessException value)? business,
    TResult? Function(SystemException value)? system,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(WebSocketException value)? webSocket,
    TResult Function(ServerException value)? server,
    TResult Function(CacheException value)? cache,
    TResult Function(AuthException value)? auth,
    TResult Function(ValidationException value)? validation,
    TResult Function(BusinessException value)? business,
    TResult Function(SystemException value)? system,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownException implements AppException {
  const factory UnknownException(
      {required final String message,
      final String? code,
      final Object? originalException,
      final Map<String, dynamic>? details}) = _$UnknownExceptionImpl;

  /// 错误消息
  @override
  String get message;

  /// 错误代码
  @override
  String? get code;

  /// 原始异常
  Object? get originalException;

  /// 错误详情
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

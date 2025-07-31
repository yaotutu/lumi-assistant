// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConnectionManagerState {
  /// WebSocket连接状态
  /// 包含连接状态、错误信息、重连次数等
  WebSocketState get webSocketState => throw _privateConstructorUsedError;

  /// 网络连接状态
  /// 检查基础网络连接是否可用
  NetworkState get networkState => throw _privateConstructorUsedError;

  /// 握手结果状态
  /// 包含握手状态、会话ID、设备ID等
  HandshakeResult get handshakeResult => throw _privateConstructorUsedError;

  /// 是否已初始化
  /// 标识连接管理器是否已完成初始化
  bool get isInitialized => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionManagerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionManagerStateCopyWith<ConnectionManagerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionManagerStateCopyWith<$Res> {
  factory $ConnectionManagerStateCopyWith(
    ConnectionManagerState value,
    $Res Function(ConnectionManagerState) then,
  ) = _$ConnectionManagerStateCopyWithImpl<$Res, ConnectionManagerState>;
  @useResult
  $Res call({
    WebSocketState webSocketState,
    NetworkState networkState,
    HandshakeResult handshakeResult,
    bool isInitialized,
  });

  $WebSocketStateCopyWith<$Res> get webSocketState;
}

/// @nodoc
class _$ConnectionManagerStateCopyWithImpl<
  $Res,
  $Val extends ConnectionManagerState
>
    implements $ConnectionManagerStateCopyWith<$Res> {
  _$ConnectionManagerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionManagerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? webSocketState = null,
    Object? networkState = null,
    Object? handshakeResult = null,
    Object? isInitialized = null,
  }) {
    return _then(
      _value.copyWith(
            webSocketState:
                null == webSocketState
                    ? _value.webSocketState
                    : webSocketState // ignore: cast_nullable_to_non_nullable
                        as WebSocketState,
            networkState:
                null == networkState
                    ? _value.networkState
                    : networkState // ignore: cast_nullable_to_non_nullable
                        as NetworkState,
            handshakeResult:
                null == handshakeResult
                    ? _value.handshakeResult
                    : handshakeResult // ignore: cast_nullable_to_non_nullable
                        as HandshakeResult,
            isInitialized:
                null == isInitialized
                    ? _value.isInitialized
                    : isInitialized // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of ConnectionManagerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WebSocketStateCopyWith<$Res> get webSocketState {
    return $WebSocketStateCopyWith<$Res>(_value.webSocketState, (value) {
      return _then(_value.copyWith(webSocketState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConnectionManagerStateImplCopyWith<$Res>
    implements $ConnectionManagerStateCopyWith<$Res> {
  factory _$$ConnectionManagerStateImplCopyWith(
    _$ConnectionManagerStateImpl value,
    $Res Function(_$ConnectionManagerStateImpl) then,
  ) = __$$ConnectionManagerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    WebSocketState webSocketState,
    NetworkState networkState,
    HandshakeResult handshakeResult,
    bool isInitialized,
  });

  @override
  $WebSocketStateCopyWith<$Res> get webSocketState;
}

/// @nodoc
class __$$ConnectionManagerStateImplCopyWithImpl<$Res>
    extends
        _$ConnectionManagerStateCopyWithImpl<$Res, _$ConnectionManagerStateImpl>
    implements _$$ConnectionManagerStateImplCopyWith<$Res> {
  __$$ConnectionManagerStateImplCopyWithImpl(
    _$ConnectionManagerStateImpl _value,
    $Res Function(_$ConnectionManagerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionManagerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? webSocketState = null,
    Object? networkState = null,
    Object? handshakeResult = null,
    Object? isInitialized = null,
  }) {
    return _then(
      _$ConnectionManagerStateImpl(
        webSocketState:
            null == webSocketState
                ? _value.webSocketState
                : webSocketState // ignore: cast_nullable_to_non_nullable
                    as WebSocketState,
        networkState:
            null == networkState
                ? _value.networkState
                : networkState // ignore: cast_nullable_to_non_nullable
                    as NetworkState,
        handshakeResult:
            null == handshakeResult
                ? _value.handshakeResult
                : handshakeResult // ignore: cast_nullable_to_non_nullable
                    as HandshakeResult,
        isInitialized:
            null == isInitialized
                ? _value.isInitialized
                : isInitialized // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$ConnectionManagerStateImpl implements _ConnectionManagerState {
  const _$ConnectionManagerStateImpl({
    required this.webSocketState,
    required this.networkState,
    required this.handshakeResult,
    this.isInitialized = false,
  });

  /// WebSocket连接状态
  /// 包含连接状态、错误信息、重连次数等
  @override
  final WebSocketState webSocketState;

  /// 网络连接状态
  /// 检查基础网络连接是否可用
  @override
  final NetworkState networkState;

  /// 握手结果状态
  /// 包含握手状态、会话ID、设备ID等
  @override
  final HandshakeResult handshakeResult;

  /// 是否已初始化
  /// 标识连接管理器是否已完成初始化
  @override
  @JsonKey()
  final bool isInitialized;

  @override
  String toString() {
    return 'ConnectionManagerState(webSocketState: $webSocketState, networkState: $networkState, handshakeResult: $handshakeResult, isInitialized: $isInitialized)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionManagerStateImpl &&
            (identical(other.webSocketState, webSocketState) ||
                other.webSocketState == webSocketState) &&
            (identical(other.networkState, networkState) ||
                other.networkState == networkState) &&
            (identical(other.handshakeResult, handshakeResult) ||
                other.handshakeResult == handshakeResult) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    webSocketState,
    networkState,
    handshakeResult,
    isInitialized,
  );

  /// Create a copy of ConnectionManagerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionManagerStateImplCopyWith<_$ConnectionManagerStateImpl>
  get copyWith =>
      __$$ConnectionManagerStateImplCopyWithImpl<_$ConnectionManagerStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ConnectionManagerState implements ConnectionManagerState {
  const factory _ConnectionManagerState({
    required final WebSocketState webSocketState,
    required final NetworkState networkState,
    required final HandshakeResult handshakeResult,
    final bool isInitialized,
  }) = _$ConnectionManagerStateImpl;

  /// WebSocket连接状态
  /// 包含连接状态、错误信息、重连次数等
  @override
  WebSocketState get webSocketState;

  /// 网络连接状态
  /// 检查基础网络连接是否可用
  @override
  NetworkState get networkState;

  /// 握手结果状态
  /// 包含握手状态、会话ID、设备ID等
  @override
  HandshakeResult get handshakeResult;

  /// 是否已初始化
  /// 标识连接管理器是否已完成初始化
  @override
  bool get isInitialized;

  /// Create a copy of ConnectionManagerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionManagerStateImplCopyWith<_$ConnectionManagerStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

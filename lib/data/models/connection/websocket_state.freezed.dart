// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'websocket_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WebSocketState {
  /// 连接状态
  WebSocketConnectionState get connectionState =>
      throw _privateConstructorUsedError;

  /// 错误信息
  /// 连接失败时的详细错误描述
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 错误代码
  /// 便于错误分类和处理
  String? get errorCode => throw _privateConstructorUsedError;

  /// 最后连接成功时间
  /// 用于连接时长计算和连接质量评估
  DateTime? get lastConnectedAt => throw _privateConstructorUsedError;

  /// 连接断开时间
  /// 用于计算断开时长和重连策略
  DateTime? get disconnectedAt => throw _privateConstructorUsedError;

  /// 重连尝试次数
  /// 用于重连策略和限制
  int get reconnectAttempts => throw _privateConstructorUsedError;

  /// 最大重连次数
  /// 超过此次数将停止重连
  int get maxReconnectAttempts => throw _privateConstructorUsedError;

  /// 连接尝试开始时间
  /// 用于计算连接耗时
  DateTime? get connectingStartedAt => throw _privateConstructorUsedError;

  /// 连接建立总时长(毫秒)
  /// 记录连接建立的耗时
  int? get connectionDuration => throw _privateConstructorUsedError;

  /// 发送消息总数
  /// 统计通过此连接发送的消息数量
  int get messagesSent => throw _privateConstructorUsedError;

  /// 接收消息总数
  /// 统计通过此连接接收的消息数量
  int get messagesReceived => throw _privateConstructorUsedError;

  /// 最后心跳时间
  /// 用于连接健康检查
  DateTime? get lastHeartbeatAt => throw _privateConstructorUsedError;

  /// 心跳间隔(毫秒)
  /// 心跳检查的时间间隔
  int get heartbeatInterval => throw _privateConstructorUsedError;

  /// 连接质量评分 (0-100)
  /// 根据连接稳定性、延迟等因素计算
  int get qualityScore => throw _privateConstructorUsedError;

  /// 平均延迟(毫秒)
  /// 基于心跳响应时间计算
  int get averageLatency => throw _privateConstructorUsedError;

  /// 连接标签
  /// 用于标识连接的用途或类型
  String? get connectionTag => throw _privateConstructorUsedError;

  /// 连接元数据
  /// 存储连接相关的附加信息
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of WebSocketState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebSocketStateCopyWith<WebSocketState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebSocketStateCopyWith<$Res> {
  factory $WebSocketStateCopyWith(
          WebSocketState value, $Res Function(WebSocketState) then) =
      _$WebSocketStateCopyWithImpl<$Res, WebSocketState>;
  @useResult
  $Res call(
      {WebSocketConnectionState connectionState,
      String? errorMessage,
      String? errorCode,
      DateTime? lastConnectedAt,
      DateTime? disconnectedAt,
      int reconnectAttempts,
      int maxReconnectAttempts,
      DateTime? connectingStartedAt,
      int? connectionDuration,
      int messagesSent,
      int messagesReceived,
      DateTime? lastHeartbeatAt,
      int heartbeatInterval,
      int qualityScore,
      int averageLatency,
      String? connectionTag,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$WebSocketStateCopyWithImpl<$Res, $Val extends WebSocketState>
    implements $WebSocketStateCopyWith<$Res> {
  _$WebSocketStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebSocketState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectionState = null,
    Object? errorMessage = freezed,
    Object? errorCode = freezed,
    Object? lastConnectedAt = freezed,
    Object? disconnectedAt = freezed,
    Object? reconnectAttempts = null,
    Object? maxReconnectAttempts = null,
    Object? connectingStartedAt = freezed,
    Object? connectionDuration = freezed,
    Object? messagesSent = null,
    Object? messagesReceived = null,
    Object? lastHeartbeatAt = freezed,
    Object? heartbeatInterval = null,
    Object? qualityScore = null,
    Object? averageLatency = null,
    Object? connectionTag = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      connectionState: null == connectionState
          ? _value.connectionState
          : connectionState // ignore: cast_nullable_to_non_nullable
              as WebSocketConnectionState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
      lastConnectedAt: freezed == lastConnectedAt
          ? _value.lastConnectedAt
          : lastConnectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      disconnectedAt: freezed == disconnectedAt
          ? _value.disconnectedAt
          : disconnectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reconnectAttempts: null == reconnectAttempts
          ? _value.reconnectAttempts
          : reconnectAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      maxReconnectAttempts: null == maxReconnectAttempts
          ? _value.maxReconnectAttempts
          : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      connectingStartedAt: freezed == connectingStartedAt
          ? _value.connectingStartedAt
          : connectingStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      connectionDuration: freezed == connectionDuration
          ? _value.connectionDuration
          : connectionDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      messagesSent: null == messagesSent
          ? _value.messagesSent
          : messagesSent // ignore: cast_nullable_to_non_nullable
              as int,
      messagesReceived: null == messagesReceived
          ? _value.messagesReceived
          : messagesReceived // ignore: cast_nullable_to_non_nullable
              as int,
      lastHeartbeatAt: freezed == lastHeartbeatAt
          ? _value.lastHeartbeatAt
          : lastHeartbeatAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      heartbeatInterval: null == heartbeatInterval
          ? _value.heartbeatInterval
          : heartbeatInterval // ignore: cast_nullable_to_non_nullable
              as int,
      qualityScore: null == qualityScore
          ? _value.qualityScore
          : qualityScore // ignore: cast_nullable_to_non_nullable
              as int,
      averageLatency: null == averageLatency
          ? _value.averageLatency
          : averageLatency // ignore: cast_nullable_to_non_nullable
              as int,
      connectionTag: freezed == connectionTag
          ? _value.connectionTag
          : connectionTag // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebSocketStateImplCopyWith<$Res>
    implements $WebSocketStateCopyWith<$Res> {
  factory _$$WebSocketStateImplCopyWith(_$WebSocketStateImpl value,
          $Res Function(_$WebSocketStateImpl) then) =
      __$$WebSocketStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {WebSocketConnectionState connectionState,
      String? errorMessage,
      String? errorCode,
      DateTime? lastConnectedAt,
      DateTime? disconnectedAt,
      int reconnectAttempts,
      int maxReconnectAttempts,
      DateTime? connectingStartedAt,
      int? connectionDuration,
      int messagesSent,
      int messagesReceived,
      DateTime? lastHeartbeatAt,
      int heartbeatInterval,
      int qualityScore,
      int averageLatency,
      String? connectionTag,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$WebSocketStateImplCopyWithImpl<$Res>
    extends _$WebSocketStateCopyWithImpl<$Res, _$WebSocketStateImpl>
    implements _$$WebSocketStateImplCopyWith<$Res> {
  __$$WebSocketStateImplCopyWithImpl(
      _$WebSocketStateImpl _value, $Res Function(_$WebSocketStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebSocketState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectionState = null,
    Object? errorMessage = freezed,
    Object? errorCode = freezed,
    Object? lastConnectedAt = freezed,
    Object? disconnectedAt = freezed,
    Object? reconnectAttempts = null,
    Object? maxReconnectAttempts = null,
    Object? connectingStartedAt = freezed,
    Object? connectionDuration = freezed,
    Object? messagesSent = null,
    Object? messagesReceived = null,
    Object? lastHeartbeatAt = freezed,
    Object? heartbeatInterval = null,
    Object? qualityScore = null,
    Object? averageLatency = null,
    Object? connectionTag = freezed,
    Object? metadata = null,
  }) {
    return _then(_$WebSocketStateImpl(
      connectionState: null == connectionState
          ? _value.connectionState
          : connectionState // ignore: cast_nullable_to_non_nullable
              as WebSocketConnectionState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
      lastConnectedAt: freezed == lastConnectedAt
          ? _value.lastConnectedAt
          : lastConnectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      disconnectedAt: freezed == disconnectedAt
          ? _value.disconnectedAt
          : disconnectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reconnectAttempts: null == reconnectAttempts
          ? _value.reconnectAttempts
          : reconnectAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      maxReconnectAttempts: null == maxReconnectAttempts
          ? _value.maxReconnectAttempts
          : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      connectingStartedAt: freezed == connectingStartedAt
          ? _value.connectingStartedAt
          : connectingStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      connectionDuration: freezed == connectionDuration
          ? _value.connectionDuration
          : connectionDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      messagesSent: null == messagesSent
          ? _value.messagesSent
          : messagesSent // ignore: cast_nullable_to_non_nullable
              as int,
      messagesReceived: null == messagesReceived
          ? _value.messagesReceived
          : messagesReceived // ignore: cast_nullable_to_non_nullable
              as int,
      lastHeartbeatAt: freezed == lastHeartbeatAt
          ? _value.lastHeartbeatAt
          : lastHeartbeatAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      heartbeatInterval: null == heartbeatInterval
          ? _value.heartbeatInterval
          : heartbeatInterval // ignore: cast_nullable_to_non_nullable
              as int,
      qualityScore: null == qualityScore
          ? _value.qualityScore
          : qualityScore // ignore: cast_nullable_to_non_nullable
              as int,
      averageLatency: null == averageLatency
          ? _value.averageLatency
          : averageLatency // ignore: cast_nullable_to_non_nullable
              as int,
      connectionTag: freezed == connectionTag
          ? _value.connectionTag
          : connectionTag // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$WebSocketStateImpl implements _WebSocketState {
  const _$WebSocketStateImpl(
      {required this.connectionState,
      this.errorMessage,
      this.errorCode,
      this.lastConnectedAt,
      this.disconnectedAt,
      this.reconnectAttempts = 0,
      this.maxReconnectAttempts = 5,
      this.connectingStartedAt,
      this.connectionDuration,
      this.messagesSent = 0,
      this.messagesReceived = 0,
      this.lastHeartbeatAt,
      this.heartbeatInterval = 30000,
      this.qualityScore = 0,
      this.averageLatency = 0,
      this.connectionTag,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  /// 连接状态
  @override
  final WebSocketConnectionState connectionState;

  /// 错误信息
  /// 连接失败时的详细错误描述
  @override
  final String? errorMessage;

  /// 错误代码
  /// 便于错误分类和处理
  @override
  final String? errorCode;

  /// 最后连接成功时间
  /// 用于连接时长计算和连接质量评估
  @override
  final DateTime? lastConnectedAt;

  /// 连接断开时间
  /// 用于计算断开时长和重连策略
  @override
  final DateTime? disconnectedAt;

  /// 重连尝试次数
  /// 用于重连策略和限制
  @override
  @JsonKey()
  final int reconnectAttempts;

  /// 最大重连次数
  /// 超过此次数将停止重连
  @override
  @JsonKey()
  final int maxReconnectAttempts;

  /// 连接尝试开始时间
  /// 用于计算连接耗时
  @override
  final DateTime? connectingStartedAt;

  /// 连接建立总时长(毫秒)
  /// 记录连接建立的耗时
  @override
  final int? connectionDuration;

  /// 发送消息总数
  /// 统计通过此连接发送的消息数量
  @override
  @JsonKey()
  final int messagesSent;

  /// 接收消息总数
  /// 统计通过此连接接收的消息数量
  @override
  @JsonKey()
  final int messagesReceived;

  /// 最后心跳时间
  /// 用于连接健康检查
  @override
  final DateTime? lastHeartbeatAt;

  /// 心跳间隔(毫秒)
  /// 心跳检查的时间间隔
  @override
  @JsonKey()
  final int heartbeatInterval;

  /// 连接质量评分 (0-100)
  /// 根据连接稳定性、延迟等因素计算
  @override
  @JsonKey()
  final int qualityScore;

  /// 平均延迟(毫秒)
  /// 基于心跳响应时间计算
  @override
  @JsonKey()
  final int averageLatency;

  /// 连接标签
  /// 用于标识连接的用途或类型
  @override
  final String? connectionTag;

  /// 连接元数据
  /// 存储连接相关的附加信息
  final Map<String, dynamic> _metadata;

  /// 连接元数据
  /// 存储连接相关的附加信息
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'WebSocketState(connectionState: $connectionState, errorMessage: $errorMessage, errorCode: $errorCode, lastConnectedAt: $lastConnectedAt, disconnectedAt: $disconnectedAt, reconnectAttempts: $reconnectAttempts, maxReconnectAttempts: $maxReconnectAttempts, connectingStartedAt: $connectingStartedAt, connectionDuration: $connectionDuration, messagesSent: $messagesSent, messagesReceived: $messagesReceived, lastHeartbeatAt: $lastHeartbeatAt, heartbeatInterval: $heartbeatInterval, qualityScore: $qualityScore, averageLatency: $averageLatency, connectionTag: $connectionTag, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebSocketStateImpl &&
            (identical(other.connectionState, connectionState) ||
                other.connectionState == connectionState) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.lastConnectedAt, lastConnectedAt) ||
                other.lastConnectedAt == lastConnectedAt) &&
            (identical(other.disconnectedAt, disconnectedAt) ||
                other.disconnectedAt == disconnectedAt) &&
            (identical(other.reconnectAttempts, reconnectAttempts) ||
                other.reconnectAttempts == reconnectAttempts) &&
            (identical(other.maxReconnectAttempts, maxReconnectAttempts) ||
                other.maxReconnectAttempts == maxReconnectAttempts) &&
            (identical(other.connectingStartedAt, connectingStartedAt) ||
                other.connectingStartedAt == connectingStartedAt) &&
            (identical(other.connectionDuration, connectionDuration) ||
                other.connectionDuration == connectionDuration) &&
            (identical(other.messagesSent, messagesSent) ||
                other.messagesSent == messagesSent) &&
            (identical(other.messagesReceived, messagesReceived) ||
                other.messagesReceived == messagesReceived) &&
            (identical(other.lastHeartbeatAt, lastHeartbeatAt) ||
                other.lastHeartbeatAt == lastHeartbeatAt) &&
            (identical(other.heartbeatInterval, heartbeatInterval) ||
                other.heartbeatInterval == heartbeatInterval) &&
            (identical(other.qualityScore, qualityScore) ||
                other.qualityScore == qualityScore) &&
            (identical(other.averageLatency, averageLatency) ||
                other.averageLatency == averageLatency) &&
            (identical(other.connectionTag, connectionTag) ||
                other.connectionTag == connectionTag) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      connectionState,
      errorMessage,
      errorCode,
      lastConnectedAt,
      disconnectedAt,
      reconnectAttempts,
      maxReconnectAttempts,
      connectingStartedAt,
      connectionDuration,
      messagesSent,
      messagesReceived,
      lastHeartbeatAt,
      heartbeatInterval,
      qualityScore,
      averageLatency,
      connectionTag,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of WebSocketState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebSocketStateImplCopyWith<_$WebSocketStateImpl> get copyWith =>
      __$$WebSocketStateImplCopyWithImpl<_$WebSocketStateImpl>(
          this, _$identity);
}

abstract class _WebSocketState implements WebSocketState {
  const factory _WebSocketState(
      {required final WebSocketConnectionState connectionState,
      final String? errorMessage,
      final String? errorCode,
      final DateTime? lastConnectedAt,
      final DateTime? disconnectedAt,
      final int reconnectAttempts,
      final int maxReconnectAttempts,
      final DateTime? connectingStartedAt,
      final int? connectionDuration,
      final int messagesSent,
      final int messagesReceived,
      final DateTime? lastHeartbeatAt,
      final int heartbeatInterval,
      final int qualityScore,
      final int averageLatency,
      final String? connectionTag,
      final Map<String, dynamic> metadata}) = _$WebSocketStateImpl;

  /// 连接状态
  @override
  WebSocketConnectionState get connectionState;

  /// 错误信息
  /// 连接失败时的详细错误描述
  @override
  String? get errorMessage;

  /// 错误代码
  /// 便于错误分类和处理
  @override
  String? get errorCode;

  /// 最后连接成功时间
  /// 用于连接时长计算和连接质量评估
  @override
  DateTime? get lastConnectedAt;

  /// 连接断开时间
  /// 用于计算断开时长和重连策略
  @override
  DateTime? get disconnectedAt;

  /// 重连尝试次数
  /// 用于重连策略和限制
  @override
  int get reconnectAttempts;

  /// 最大重连次数
  /// 超过此次数将停止重连
  @override
  int get maxReconnectAttempts;

  /// 连接尝试开始时间
  /// 用于计算连接耗时
  @override
  DateTime? get connectingStartedAt;

  /// 连接建立总时长(毫秒)
  /// 记录连接建立的耗时
  @override
  int? get connectionDuration;

  /// 发送消息总数
  /// 统计通过此连接发送的消息数量
  @override
  int get messagesSent;

  /// 接收消息总数
  /// 统计通过此连接接收的消息数量
  @override
  int get messagesReceived;

  /// 最后心跳时间
  /// 用于连接健康检查
  @override
  DateTime? get lastHeartbeatAt;

  /// 心跳间隔(毫秒)
  /// 心跳检查的时间间隔
  @override
  int get heartbeatInterval;

  /// 连接质量评分 (0-100)
  /// 根据连接稳定性、延迟等因素计算
  @override
  int get qualityScore;

  /// 平均延迟(毫秒)
  /// 基于心跳响应时间计算
  @override
  int get averageLatency;

  /// 连接标签
  /// 用于标识连接的用途或类型
  @override
  String? get connectionTag;

  /// 连接元数据
  /// 存储连接相关的附加信息
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of WebSocketState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebSocketStateImplCopyWith<_$WebSocketStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

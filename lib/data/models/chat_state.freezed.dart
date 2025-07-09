// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChatState {
  /// 聊天消息列表
  /// 按时间顺序排列，最新消息在最后
  List<ChatUIMessage> get messages => throw _privateConstructorUsedError;

  /// 是否正在发送消息
  /// 用于UI显示发送状态和禁用发送按钮
  bool get isSending => throw _privateConstructorUsedError;

  /// 是否正在接收响应
  /// 用于UI显示接收状态和typing指示器
  bool get isReceiving => throw _privateConstructorUsedError;

  /// 当前错误信息
  /// 为null表示没有错误
  String? get error => throw _privateConstructorUsedError;

  /// 会话ID
  /// 标识当前聊天会话，用于消息关联
  String? get sessionId => throw _privateConstructorUsedError;

  /// 最后一次活动时间
  /// 用于会话超时检查
  DateTime? get lastActivityTime => throw _privateConstructorUsedError;

  /// 是否允许发送消息
  /// 根据连接状态和其他条件动态设置
  bool get canSendMessage => throw _privateConstructorUsedError;

  /// 未读消息数量
  /// 用于通知和徽章显示
  int get unreadCount => throw _privateConstructorUsedError;

  /// 会话元数据
  /// 存储会话相关的附加信息
  Map<String, dynamic> get sessionMetadata =>
      throw _privateConstructorUsedError;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatStateCopyWith<ChatState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
  @useResult
  $Res call({
    List<ChatUIMessage> messages,
    bool isSending,
    bool isReceiving,
    String? error,
    String? sessionId,
    DateTime? lastActivityTime,
    bool canSendMessage,
    int unreadCount,
    Map<String, dynamic> sessionMetadata,
  });
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? isSending = null,
    Object? isReceiving = null,
    Object? error = freezed,
    Object? sessionId = freezed,
    Object? lastActivityTime = freezed,
    Object? canSendMessage = null,
    Object? unreadCount = null,
    Object? sessionMetadata = null,
  }) {
    return _then(
      _value.copyWith(
            messages:
                null == messages
                    ? _value.messages
                    : messages // ignore: cast_nullable_to_non_nullable
                        as List<ChatUIMessage>,
            isSending:
                null == isSending
                    ? _value.isSending
                    : isSending // ignore: cast_nullable_to_non_nullable
                        as bool,
            isReceiving:
                null == isReceiving
                    ? _value.isReceiving
                    : isReceiving // ignore: cast_nullable_to_non_nullable
                        as bool,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
            sessionId:
                freezed == sessionId
                    ? _value.sessionId
                    : sessionId // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastActivityTime:
                freezed == lastActivityTime
                    ? _value.lastActivityTime
                    : lastActivityTime // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            canSendMessage:
                null == canSendMessage
                    ? _value.canSendMessage
                    : canSendMessage // ignore: cast_nullable_to_non_nullable
                        as bool,
            unreadCount:
                null == unreadCount
                    ? _value.unreadCount
                    : unreadCount // ignore: cast_nullable_to_non_nullable
                        as int,
            sessionMetadata:
                null == sessionMetadata
                    ? _value.sessionMetadata
                    : sessionMetadata // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatStateImplCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$$ChatStateImplCopyWith(
    _$ChatStateImpl value,
    $Res Function(_$ChatStateImpl) then,
  ) = __$$ChatStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ChatUIMessage> messages,
    bool isSending,
    bool isReceiving,
    String? error,
    String? sessionId,
    DateTime? lastActivityTime,
    bool canSendMessage,
    int unreadCount,
    Map<String, dynamic> sessionMetadata,
  });
}

/// @nodoc
class __$$ChatStateImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateImpl>
    implements _$$ChatStateImplCopyWith<$Res> {
  __$$ChatStateImplCopyWithImpl(
    _$ChatStateImpl _value,
    $Res Function(_$ChatStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? isSending = null,
    Object? isReceiving = null,
    Object? error = freezed,
    Object? sessionId = freezed,
    Object? lastActivityTime = freezed,
    Object? canSendMessage = null,
    Object? unreadCount = null,
    Object? sessionMetadata = null,
  }) {
    return _then(
      _$ChatStateImpl(
        messages:
            null == messages
                ? _value._messages
                : messages // ignore: cast_nullable_to_non_nullable
                    as List<ChatUIMessage>,
        isSending:
            null == isSending
                ? _value.isSending
                : isSending // ignore: cast_nullable_to_non_nullable
                    as bool,
        isReceiving:
            null == isReceiving
                ? _value.isReceiving
                : isReceiving // ignore: cast_nullable_to_non_nullable
                    as bool,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
        sessionId:
            freezed == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastActivityTime:
            freezed == lastActivityTime
                ? _value.lastActivityTime
                : lastActivityTime // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        canSendMessage:
            null == canSendMessage
                ? _value.canSendMessage
                : canSendMessage // ignore: cast_nullable_to_non_nullable
                    as bool,
        unreadCount:
            null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                    as int,
        sessionMetadata:
            null == sessionMetadata
                ? _value._sessionMetadata
                : sessionMetadata // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc

class _$ChatStateImpl implements _ChatState {
  const _$ChatStateImpl({
    final List<ChatUIMessage> messages = const [],
    this.isSending = false,
    this.isReceiving = false,
    this.error,
    this.sessionId,
    this.lastActivityTime,
    this.canSendMessage = true,
    this.unreadCount = 0,
    final Map<String, dynamic> sessionMetadata = const {},
  }) : _messages = messages,
       _sessionMetadata = sessionMetadata;

  /// 聊天消息列表
  /// 按时间顺序排列，最新消息在最后
  final List<ChatUIMessage> _messages;

  /// 聊天消息列表
  /// 按时间顺序排列，最新消息在最后
  @override
  @JsonKey()
  List<ChatUIMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  /// 是否正在发送消息
  /// 用于UI显示发送状态和禁用发送按钮
  @override
  @JsonKey()
  final bool isSending;

  /// 是否正在接收响应
  /// 用于UI显示接收状态和typing指示器
  @override
  @JsonKey()
  final bool isReceiving;

  /// 当前错误信息
  /// 为null表示没有错误
  @override
  final String? error;

  /// 会话ID
  /// 标识当前聊天会话，用于消息关联
  @override
  final String? sessionId;

  /// 最后一次活动时间
  /// 用于会话超时检查
  @override
  final DateTime? lastActivityTime;

  /// 是否允许发送消息
  /// 根据连接状态和其他条件动态设置
  @override
  @JsonKey()
  final bool canSendMessage;

  /// 未读消息数量
  /// 用于通知和徽章显示
  @override
  @JsonKey()
  final int unreadCount;

  /// 会话元数据
  /// 存储会话相关的附加信息
  final Map<String, dynamic> _sessionMetadata;

  /// 会话元数据
  /// 存储会话相关的附加信息
  @override
  @JsonKey()
  Map<String, dynamic> get sessionMetadata {
    if (_sessionMetadata is EqualUnmodifiableMapView) return _sessionMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sessionMetadata);
  }

  @override
  String toString() {
    return 'ChatState(messages: $messages, isSending: $isSending, isReceiving: $isReceiving, error: $error, sessionId: $sessionId, lastActivityTime: $lastActivityTime, canSendMessage: $canSendMessage, unreadCount: $unreadCount, sessionMetadata: $sessionMetadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.isSending, isSending) ||
                other.isSending == isSending) &&
            (identical(other.isReceiving, isReceiving) ||
                other.isReceiving == isReceiving) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.lastActivityTime, lastActivityTime) ||
                other.lastActivityTime == lastActivityTime) &&
            (identical(other.canSendMessage, canSendMessage) ||
                other.canSendMessage == canSendMessage) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            const DeepCollectionEquality().equals(
              other._sessionMetadata,
              _sessionMetadata,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_messages),
    isSending,
    isReceiving,
    error,
    sessionId,
    lastActivityTime,
    canSendMessage,
    unreadCount,
    const DeepCollectionEquality().hash(_sessionMetadata),
  );

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      __$$ChatStateImplCopyWithImpl<_$ChatStateImpl>(this, _$identity);
}

abstract class _ChatState implements ChatState {
  const factory _ChatState({
    final List<ChatUIMessage> messages,
    final bool isSending,
    final bool isReceiving,
    final String? error,
    final String? sessionId,
    final DateTime? lastActivityTime,
    final bool canSendMessage,
    final int unreadCount,
    final Map<String, dynamic> sessionMetadata,
  }) = _$ChatStateImpl;

  /// 聊天消息列表
  /// 按时间顺序排列，最新消息在最后
  @override
  List<ChatUIMessage> get messages;

  /// 是否正在发送消息
  /// 用于UI显示发送状态和禁用发送按钮
  @override
  bool get isSending;

  /// 是否正在接收响应
  /// 用于UI显示接收状态和typing指示器
  @override
  bool get isReceiving;

  /// 当前错误信息
  /// 为null表示没有错误
  @override
  String? get error;

  /// 会话ID
  /// 标识当前聊天会话，用于消息关联
  @override
  String? get sessionId;

  /// 最后一次活动时间
  /// 用于会话超时检查
  @override
  DateTime? get lastActivityTime;

  /// 是否允许发送消息
  /// 根据连接状态和其他条件动态设置
  @override
  bool get canSendMessage;

  /// 未读消息数量
  /// 用于通知和徽章显示
  @override
  int get unreadCount;

  /// 会话元数据
  /// 存储会话相关的附加信息
  @override
  Map<String, dynamic> get sessionMetadata;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

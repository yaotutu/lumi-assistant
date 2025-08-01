// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_ui_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatUIMessage _$ChatUIMessageFromJson(Map<String, dynamic> json) {
  return _ChatUIMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatUIMessage {
  /// 消息ID
  String get id => throw _privateConstructorUsedError;

  /// 消息内容
  String get content => throw _privateConstructorUsedError;

  /// 发送者类型
  ChatSender get sender => throw _privateConstructorUsedError;

  /// 消息状态
  ChatMessageStatus get status => throw _privateConstructorUsedError;

  /// 消息时间
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// 是否为临时消息（如正在输入提示）
  bool get isTemporary => throw _privateConstructorUsedError;

  /// 是否为错误消息
  bool get isError => throw _privateConstructorUsedError;

  /// 错误信息
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 关联的原始消息ID（用于响应匹配）
  String? get originalMessageId => throw _privateConstructorUsedError;

  /// 附加数据
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ChatUIMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatUIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatUIMessageCopyWith<ChatUIMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatUIMessageCopyWith<$Res> {
  factory $ChatUIMessageCopyWith(
          ChatUIMessage value, $Res Function(ChatUIMessage) then) =
      _$ChatUIMessageCopyWithImpl<$Res, ChatUIMessage>;
  @useResult
  $Res call(
      {String id,
      String content,
      ChatSender sender,
      ChatMessageStatus status,
      DateTime timestamp,
      bool isTemporary,
      bool isError,
      String? errorMessage,
      String? originalMessageId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ChatUIMessageCopyWithImpl<$Res, $Val extends ChatUIMessage>
    implements $ChatUIMessageCopyWith<$Res> {
  _$ChatUIMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatUIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? sender = null,
    Object? status = null,
    Object? timestamp = null,
    Object? isTemporary = null,
    Object? isError = null,
    Object? errorMessage = freezed,
    Object? originalMessageId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as ChatSender,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChatMessageStatus,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isTemporary: null == isTemporary
          ? _value.isTemporary
          : isTemporary // ignore: cast_nullable_to_non_nullable
              as bool,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      originalMessageId: freezed == originalMessageId
          ? _value.originalMessageId
          : originalMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatUIMessageImplCopyWith<$Res>
    implements $ChatUIMessageCopyWith<$Res> {
  factory _$$ChatUIMessageImplCopyWith(
          _$ChatUIMessageImpl value, $Res Function(_$ChatUIMessageImpl) then) =
      __$$ChatUIMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      ChatSender sender,
      ChatMessageStatus status,
      DateTime timestamp,
      bool isTemporary,
      bool isError,
      String? errorMessage,
      String? originalMessageId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$ChatUIMessageImplCopyWithImpl<$Res>
    extends _$ChatUIMessageCopyWithImpl<$Res, _$ChatUIMessageImpl>
    implements _$$ChatUIMessageImplCopyWith<$Res> {
  __$$ChatUIMessageImplCopyWithImpl(
      _$ChatUIMessageImpl _value, $Res Function(_$ChatUIMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatUIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? sender = null,
    Object? status = null,
    Object? timestamp = null,
    Object? isTemporary = null,
    Object? isError = null,
    Object? errorMessage = freezed,
    Object? originalMessageId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$ChatUIMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as ChatSender,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChatMessageStatus,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isTemporary: null == isTemporary
          ? _value.isTemporary
          : isTemporary // ignore: cast_nullable_to_non_nullable
              as bool,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      originalMessageId: freezed == originalMessageId
          ? _value.originalMessageId
          : originalMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatUIMessageImpl implements _ChatUIMessage {
  const _$ChatUIMessageImpl(
      {required this.id,
      required this.content,
      required this.sender,
      this.status = ChatMessageStatus.sent,
      required this.timestamp,
      this.isTemporary = false,
      this.isError = false,
      this.errorMessage,
      this.originalMessageId,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$ChatUIMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatUIMessageImplFromJson(json);

  /// 消息ID
  @override
  final String id;

  /// 消息内容
  @override
  final String content;

  /// 发送者类型
  @override
  final ChatSender sender;

  /// 消息状态
  @override
  @JsonKey()
  final ChatMessageStatus status;

  /// 消息时间
  @override
  final DateTime timestamp;

  /// 是否为临时消息（如正在输入提示）
  @override
  @JsonKey()
  final bool isTemporary;

  /// 是否为错误消息
  @override
  @JsonKey()
  final bool isError;

  /// 错误信息
  @override
  final String? errorMessage;

  /// 关联的原始消息ID（用于响应匹配）
  @override
  final String? originalMessageId;

  /// 附加数据
  final Map<String, dynamic>? _metadata;

  /// 附加数据
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ChatUIMessage(id: $id, content: $content, sender: $sender, status: $status, timestamp: $timestamp, isTemporary: $isTemporary, isError: $isError, errorMessage: $errorMessage, originalMessageId: $originalMessageId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatUIMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isTemporary, isTemporary) ||
                other.isTemporary == isTemporary) &&
            (identical(other.isError, isError) || other.isError == isError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.originalMessageId, originalMessageId) ||
                other.originalMessageId == originalMessageId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      content,
      sender,
      status,
      timestamp,
      isTemporary,
      isError,
      errorMessage,
      originalMessageId,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ChatUIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatUIMessageImplCopyWith<_$ChatUIMessageImpl> get copyWith =>
      __$$ChatUIMessageImplCopyWithImpl<_$ChatUIMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatUIMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatUIMessage implements ChatUIMessage {
  const factory _ChatUIMessage(
      {required final String id,
      required final String content,
      required final ChatSender sender,
      final ChatMessageStatus status,
      required final DateTime timestamp,
      final bool isTemporary,
      final bool isError,
      final String? errorMessage,
      final String? originalMessageId,
      final Map<String, dynamic>? metadata}) = _$ChatUIMessageImpl;

  factory _ChatUIMessage.fromJson(Map<String, dynamic> json) =
      _$ChatUIMessageImpl.fromJson;

  /// 消息ID
  @override
  String get id;

  /// 消息内容
  @override
  String get content;

  /// 发送者类型
  @override
  ChatSender get sender;

  /// 消息状态
  @override
  ChatMessageStatus get status;

  /// 消息时间
  @override
  DateTime get timestamp;

  /// 是否为临时消息（如正在输入提示）
  @override
  bool get isTemporary;

  /// 是否为错误消息
  @override
  bool get isError;

  /// 错误信息
  @override
  String? get errorMessage;

  /// 关联的原始消息ID（用于响应匹配）
  @override
  String? get originalMessageId;

  /// 附加数据
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ChatUIMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatUIMessageImplCopyWith<_$ChatUIMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

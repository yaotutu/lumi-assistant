// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  /// 消息ID
  String get id => throw _privateConstructorUsedError;

  /// 消息类型
  MessageType get type => throw _privateConstructorUsedError;

  /// 消息内容
  String? get content => throw _privateConstructorUsedError;

  /// 消息状态
  MessageStatus get status => throw _privateConstructorUsedError;

  /// 发送时间戳
  int get timestamp => throw _privateConstructorUsedError;

  /// 设备ID
  @JsonKey(name: 'device_id')
  String? get deviceId => throw _privateConstructorUsedError;

  /// 会话ID
  @JsonKey(name: 'session_id')
  String? get sessionId => throw _privateConstructorUsedError;

  /// 附加数据
  @JsonKey(name: 'metadata')
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// 错误信息
  @JsonKey(name: 'error_message')
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 错误代码
  @JsonKey(name: 'error_code')
  String? get errorCode => throw _privateConstructorUsedError;

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageModelCopyWith<MessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
          MessageModel value, $Res Function(MessageModel) then) =
      _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String? content,
      MessageStatus status,
      int timestamp,
      @JsonKey(name: 'device_id') String? deviceId,
      @JsonKey(name: 'session_id') String? sessionId,
      @JsonKey(name: 'metadata') Map<String, dynamic>? metadata,
      @JsonKey(name: 'error_message') String? errorMessage,
      @JsonKey(name: 'error_code') String? errorCode});
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res, $Val extends MessageModel>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? content = freezed,
    Object? status = null,
    Object? timestamp = null,
    Object? deviceId = freezed,
    Object? sessionId = freezed,
    Object? metadata = freezed,
    Object? errorMessage = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
          _$MessageModelImpl value, $Res Function(_$MessageModelImpl) then) =
      __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String? content,
      MessageStatus status,
      int timestamp,
      @JsonKey(name: 'device_id') String? deviceId,
      @JsonKey(name: 'session_id') String? sessionId,
      @JsonKey(name: 'metadata') Map<String, dynamic>? metadata,
      @JsonKey(name: 'error_message') String? errorMessage,
      @JsonKey(name: 'error_code') String? errorCode});
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
      _$MessageModelImpl _value, $Res Function(_$MessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? content = freezed,
    Object? status = null,
    Object? timestamp = null,
    Object? deviceId = freezed,
    Object? sessionId = freezed,
    Object? metadata = freezed,
    Object? errorMessage = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_$MessageModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageModelImpl implements _MessageModel {
  const _$MessageModelImpl(
      {required this.id,
      required this.type,
      this.content,
      this.status = MessageStatus.pending,
      required this.timestamp,
      @JsonKey(name: 'device_id') this.deviceId,
      @JsonKey(name: 'session_id') this.sessionId,
      @JsonKey(name: 'metadata') final Map<String, dynamic>? metadata,
      @JsonKey(name: 'error_message') this.errorMessage,
      @JsonKey(name: 'error_code') this.errorCode})
      : _metadata = metadata;

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  /// 消息ID
  @override
  final String id;

  /// 消息类型
  @override
  final MessageType type;

  /// 消息内容
  @override
  final String? content;

  /// 消息状态
  @override
  @JsonKey()
  final MessageStatus status;

  /// 发送时间戳
  @override
  final int timestamp;

  /// 设备ID
  @override
  @JsonKey(name: 'device_id')
  final String? deviceId;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  final String? sessionId;

  /// 附加数据
  final Map<String, dynamic>? _metadata;

  /// 附加数据
  @override
  @JsonKey(name: 'metadata')
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// 错误信息
  @override
  @JsonKey(name: 'error_message')
  final String? errorMessage;

  /// 错误代码
  @override
  @JsonKey(name: 'error_code')
  final String? errorCode;

  @override
  String toString() {
    return 'MessageModel(id: $id, type: $type, content: $content, status: $status, timestamp: $timestamp, deviceId: $deviceId, sessionId: $sessionId, metadata: $metadata, errorMessage: $errorMessage, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      content,
      status,
      timestamp,
      deviceId,
      sessionId,
      const DeepCollectionEquality().hash(_metadata),
      errorMessage,
      errorCode);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(
      this,
    );
  }
}

abstract class _MessageModel implements MessageModel {
  const factory _MessageModel(
          {required final String id,
          required final MessageType type,
          final String? content,
          final MessageStatus status,
          required final int timestamp,
          @JsonKey(name: 'device_id') final String? deviceId,
          @JsonKey(name: 'session_id') final String? sessionId,
          @JsonKey(name: 'metadata') final Map<String, dynamic>? metadata,
          @JsonKey(name: 'error_message') final String? errorMessage,
          @JsonKey(name: 'error_code') final String? errorCode}) =
      _$MessageModelImpl;

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  /// 消息ID
  @override
  String get id;

  /// 消息类型
  @override
  MessageType get type;

  /// 消息内容
  @override
  String? get content;

  /// 消息状态
  @override
  MessageStatus get status;

  /// 发送时间戳
  @override
  int get timestamp;

  /// 设备ID
  @override
  @JsonKey(name: 'device_id')
  String? get deviceId;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  String? get sessionId;

  /// 附加数据
  @override
  @JsonKey(name: 'metadata')
  Map<String, dynamic>? get metadata;

  /// 错误信息
  @override
  @JsonKey(name: 'error_message')
  String? get errorMessage;

  /// 错误代码
  @override
  @JsonKey(name: 'error_code')
  String? get errorCode;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HelloMessage _$HelloMessageFromJson(Map<String, dynamic> json) {
  return _HelloMessage.fromJson(json);
}

/// @nodoc
mixin _$HelloMessage {
  /// 消息ID
  String get id => throw _privateConstructorUsedError;

  /// 消息类型（固定为hello）
  MessageType get type => throw _privateConstructorUsedError;

  /// 客户端版本
  String get version => throw _privateConstructorUsedError;

  /// 设备ID
  @JsonKey(name: 'device_id')
  String get deviceId => throw _privateConstructorUsedError;

  /// 设备信息
  @JsonKey(name: 'device_info')
  DeviceInfo get deviceInfo => throw _privateConstructorUsedError;

  /// 客户端能力
  List<String> get capabilities => throw _privateConstructorUsedError;

  /// 发送时间戳
  int get timestamp => throw _privateConstructorUsedError;

  /// Serializes this HelloMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HelloMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HelloMessageCopyWith<HelloMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HelloMessageCopyWith<$Res> {
  factory $HelloMessageCopyWith(
          HelloMessage value, $Res Function(HelloMessage) then) =
      _$HelloMessageCopyWithImpl<$Res, HelloMessage>;
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String version,
      @JsonKey(name: 'device_id') String deviceId,
      @JsonKey(name: 'device_info') DeviceInfo deviceInfo,
      List<String> capabilities,
      int timestamp});

  $DeviceInfoCopyWith<$Res> get deviceInfo;
}

/// @nodoc
class _$HelloMessageCopyWithImpl<$Res, $Val extends HelloMessage>
    implements $HelloMessageCopyWith<$Res> {
  _$HelloMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HelloMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? version = null,
    Object? deviceId = null,
    Object? deviceInfo = null,
    Object? capabilities = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceInfo: null == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as DeviceInfo,
      capabilities: null == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of HelloMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceInfoCopyWith<$Res> get deviceInfo {
    return $DeviceInfoCopyWith<$Res>(_value.deviceInfo, (value) {
      return _then(_value.copyWith(deviceInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HelloMessageImplCopyWith<$Res>
    implements $HelloMessageCopyWith<$Res> {
  factory _$$HelloMessageImplCopyWith(
          _$HelloMessageImpl value, $Res Function(_$HelloMessageImpl) then) =
      __$$HelloMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String version,
      @JsonKey(name: 'device_id') String deviceId,
      @JsonKey(name: 'device_info') DeviceInfo deviceInfo,
      List<String> capabilities,
      int timestamp});

  @override
  $DeviceInfoCopyWith<$Res> get deviceInfo;
}

/// @nodoc
class __$$HelloMessageImplCopyWithImpl<$Res>
    extends _$HelloMessageCopyWithImpl<$Res, _$HelloMessageImpl>
    implements _$$HelloMessageImplCopyWith<$Res> {
  __$$HelloMessageImplCopyWithImpl(
      _$HelloMessageImpl _value, $Res Function(_$HelloMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of HelloMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? version = null,
    Object? deviceId = null,
    Object? deviceInfo = null,
    Object? capabilities = null,
    Object? timestamp = null,
  }) {
    return _then(_$HelloMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceInfo: null == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as DeviceInfo,
      capabilities: null == capabilities
          ? _value._capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HelloMessageImpl implements _HelloMessage {
  const _$HelloMessageImpl(
      {required this.id,
      this.type = MessageType.hello,
      required this.version,
      @JsonKey(name: 'device_id') required this.deviceId,
      @JsonKey(name: 'device_info') required this.deviceInfo,
      required final List<String> capabilities,
      required this.timestamp})
      : _capabilities = capabilities;

  factory _$HelloMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$HelloMessageImplFromJson(json);

  /// 消息ID
  @override
  final String id;

  /// 消息类型（固定为hello）
  @override
  @JsonKey()
  final MessageType type;

  /// 客户端版本
  @override
  final String version;

  /// 设备ID
  @override
  @JsonKey(name: 'device_id')
  final String deviceId;

  /// 设备信息
  @override
  @JsonKey(name: 'device_info')
  final DeviceInfo deviceInfo;

  /// 客户端能力
  final List<String> _capabilities;

  /// 客户端能力
  @override
  List<String> get capabilities {
    if (_capabilities is EqualUnmodifiableListView) return _capabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_capabilities);
  }

  /// 发送时间戳
  @override
  final int timestamp;

  @override
  String toString() {
    return 'HelloMessage(id: $id, type: $type, version: $version, deviceId: $deviceId, deviceInfo: $deviceInfo, capabilities: $capabilities, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HelloMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            const DeepCollectionEquality()
                .equals(other._capabilities, _capabilities) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      version,
      deviceId,
      deviceInfo,
      const DeepCollectionEquality().hash(_capabilities),
      timestamp);

  /// Create a copy of HelloMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HelloMessageImplCopyWith<_$HelloMessageImpl> get copyWith =>
      __$$HelloMessageImplCopyWithImpl<_$HelloMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HelloMessageImplToJson(
      this,
    );
  }
}

abstract class _HelloMessage implements HelloMessage {
  const factory _HelloMessage(
      {required final String id,
      final MessageType type,
      required final String version,
      @JsonKey(name: 'device_id') required final String deviceId,
      @JsonKey(name: 'device_info') required final DeviceInfo deviceInfo,
      required final List<String> capabilities,
      required final int timestamp}) = _$HelloMessageImpl;

  factory _HelloMessage.fromJson(Map<String, dynamic> json) =
      _$HelloMessageImpl.fromJson;

  /// 消息ID
  @override
  String get id;

  /// 消息类型（固定为hello）
  @override
  MessageType get type;

  /// 客户端版本
  @override
  String get version;

  /// 设备ID
  @override
  @JsonKey(name: 'device_id')
  String get deviceId;

  /// 设备信息
  @override
  @JsonKey(name: 'device_info')
  DeviceInfo get deviceInfo;

  /// 客户端能力
  @override
  List<String> get capabilities;

  /// 发送时间戳
  @override
  int get timestamp;

  /// Create a copy of HelloMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HelloMessageImplCopyWith<_$HelloMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) {
  return _DeviceInfo.fromJson(json);
}

/// @nodoc
mixin _$DeviceInfo {
  /// 设备平台
  String get platform => throw _privateConstructorUsedError;

  /// 设备型号
  String get model => throw _privateConstructorUsedError;

  /// 操作系统版本
  @JsonKey(name: 'os_version')
  String get osVersion => throw _privateConstructorUsedError;

  /// 应用版本
  @JsonKey(name: 'app_version')
  String get appVersion => throw _privateConstructorUsedError;

  /// 屏幕尺寸
  @JsonKey(name: 'screen_size')
  String? get screenSize => throw _privateConstructorUsedError;

  /// 设备名称
  @JsonKey(name: 'device_name')
  String? get deviceName => throw _privateConstructorUsedError;

  /// 时区
  String? get timezone => throw _privateConstructorUsedError;

  /// 语言设置
  String? get locale => throw _privateConstructorUsedError;

  /// Serializes this DeviceInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceInfoCopyWith<DeviceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceInfoCopyWith<$Res> {
  factory $DeviceInfoCopyWith(
          DeviceInfo value, $Res Function(DeviceInfo) then) =
      _$DeviceInfoCopyWithImpl<$Res, DeviceInfo>;
  @useResult
  $Res call(
      {String platform,
      String model,
      @JsonKey(name: 'os_version') String osVersion,
      @JsonKey(name: 'app_version') String appVersion,
      @JsonKey(name: 'screen_size') String? screenSize,
      @JsonKey(name: 'device_name') String? deviceName,
      String? timezone,
      String? locale});
}

/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res, $Val extends DeviceInfo>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? platform = null,
    Object? model = null,
    Object? osVersion = null,
    Object? appVersion = null,
    Object? screenSize = freezed,
    Object? deviceName = freezed,
    Object? timezone = freezed,
    Object? locale = freezed,
  }) {
    return _then(_value.copyWith(
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      osVersion: null == osVersion
          ? _value.osVersion
          : osVersion // ignore: cast_nullable_to_non_nullable
              as String,
      appVersion: null == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String,
      screenSize: freezed == screenSize
          ? _value.screenSize
          : screenSize // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceInfoImplCopyWith<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  factory _$$DeviceInfoImplCopyWith(
          _$DeviceInfoImpl value, $Res Function(_$DeviceInfoImpl) then) =
      __$$DeviceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String platform,
      String model,
      @JsonKey(name: 'os_version') String osVersion,
      @JsonKey(name: 'app_version') String appVersion,
      @JsonKey(name: 'screen_size') String? screenSize,
      @JsonKey(name: 'device_name') String? deviceName,
      String? timezone,
      String? locale});
}

/// @nodoc
class __$$DeviceInfoImplCopyWithImpl<$Res>
    extends _$DeviceInfoCopyWithImpl<$Res, _$DeviceInfoImpl>
    implements _$$DeviceInfoImplCopyWith<$Res> {
  __$$DeviceInfoImplCopyWithImpl(
      _$DeviceInfoImpl _value, $Res Function(_$DeviceInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? platform = null,
    Object? model = null,
    Object? osVersion = null,
    Object? appVersion = null,
    Object? screenSize = freezed,
    Object? deviceName = freezed,
    Object? timezone = freezed,
    Object? locale = freezed,
  }) {
    return _then(_$DeviceInfoImpl(
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      osVersion: null == osVersion
          ? _value.osVersion
          : osVersion // ignore: cast_nullable_to_non_nullable
              as String,
      appVersion: null == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String,
      screenSize: freezed == screenSize
          ? _value.screenSize
          : screenSize // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceInfoImpl implements _DeviceInfo {
  const _$DeviceInfoImpl(
      {required this.platform,
      required this.model,
      @JsonKey(name: 'os_version') required this.osVersion,
      @JsonKey(name: 'app_version') required this.appVersion,
      @JsonKey(name: 'screen_size') this.screenSize,
      @JsonKey(name: 'device_name') this.deviceName,
      this.timezone,
      this.locale});

  factory _$DeviceInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceInfoImplFromJson(json);

  /// 设备平台
  @override
  final String platform;

  /// 设备型号
  @override
  final String model;

  /// 操作系统版本
  @override
  @JsonKey(name: 'os_version')
  final String osVersion;

  /// 应用版本
  @override
  @JsonKey(name: 'app_version')
  final String appVersion;

  /// 屏幕尺寸
  @override
  @JsonKey(name: 'screen_size')
  final String? screenSize;

  /// 设备名称
  @override
  @JsonKey(name: 'device_name')
  final String? deviceName;

  /// 时区
  @override
  final String? timezone;

  /// 语言设置
  @override
  final String? locale;

  @override
  String toString() {
    return 'DeviceInfo(platform: $platform, model: $model, osVersion: $osVersion, appVersion: $appVersion, screenSize: $screenSize, deviceName: $deviceName, timezone: $timezone, locale: $locale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceInfoImpl &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.osVersion, osVersion) ||
                other.osVersion == osVersion) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.screenSize, screenSize) ||
                other.screenSize == screenSize) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, platform, model, osVersion,
      appVersion, screenSize, deviceName, timezone, locale);

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      __$$DeviceInfoImplCopyWithImpl<_$DeviceInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceInfoImplToJson(
      this,
    );
  }
}

abstract class _DeviceInfo implements DeviceInfo {
  const factory _DeviceInfo(
      {required final String platform,
      required final String model,
      @JsonKey(name: 'os_version') required final String osVersion,
      @JsonKey(name: 'app_version') required final String appVersion,
      @JsonKey(name: 'screen_size') final String? screenSize,
      @JsonKey(name: 'device_name') final String? deviceName,
      final String? timezone,
      final String? locale}) = _$DeviceInfoImpl;

  factory _DeviceInfo.fromJson(Map<String, dynamic> json) =
      _$DeviceInfoImpl.fromJson;

  /// 设备平台
  @override
  String get platform;

  /// 设备型号
  @override
  String get model;

  /// 操作系统版本
  @override
  @JsonKey(name: 'os_version')
  String get osVersion;

  /// 应用版本
  @override
  @JsonKey(name: 'app_version')
  String get appVersion;

  /// 屏幕尺寸
  @override
  @JsonKey(name: 'screen_size')
  String? get screenSize;

  /// 设备名称
  @override
  @JsonKey(name: 'device_name')
  String? get deviceName;

  /// 时区
  @override
  String? get timezone;

  /// 语言设置
  @override
  String? get locale;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  /// 消息ID
  String get id => throw _privateConstructorUsedError;

  /// 消息类型（固定为chat）
  MessageType get type => throw _privateConstructorUsedError;

  /// 消息内容
  String get content => throw _privateConstructorUsedError;

  /// 会话ID
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;

  /// 设备ID
  @JsonKey(name: 'device_id')
  String get deviceId => throw _privateConstructorUsedError;

  /// 发送时间戳
  int get timestamp => throw _privateConstructorUsedError;

  /// 是否需要回复
  @JsonKey(name: 'expect_reply')
  bool get expectReply => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String content,
      @JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'device_id') String deviceId,
      int timestamp,
      @JsonKey(name: 'expect_reply') bool expectReply});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? content = null,
    Object? sessionId = null,
    Object? deviceId = null,
    Object? timestamp = null,
    Object? expectReply = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      expectReply: null == expectReply
          ? _value.expectReply
          : expectReply // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String content,
      @JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'device_id') String deviceId,
      int timestamp,
      @JsonKey(name: 'expect_reply') bool expectReply});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? content = null,
    Object? sessionId = null,
    Object? deviceId = null,
    Object? timestamp = null,
    Object? expectReply = null,
  }) {
    return _then(_$ChatMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      expectReply: null == expectReply
          ? _value.expectReply
          : expectReply // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {required this.id,
      this.type = MessageType.chat,
      required this.content,
      @JsonKey(name: 'session_id') required this.sessionId,
      @JsonKey(name: 'device_id') required this.deviceId,
      required this.timestamp,
      @JsonKey(name: 'expect_reply') this.expectReply = true});

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  /// 消息ID
  @override
  final String id;

  /// 消息类型（固定为chat）
  @override
  @JsonKey()
  final MessageType type;

  /// 消息内容
  @override
  final String content;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  final String sessionId;

  /// 设备ID
  @override
  @JsonKey(name: 'device_id')
  final String deviceId;

  /// 发送时间戳
  @override
  final int timestamp;

  /// 是否需要回复
  @override
  @JsonKey(name: 'expect_reply')
  final bool expectReply;

  @override
  String toString() {
    return 'ChatMessage(id: $id, type: $type, content: $content, sessionId: $sessionId, deviceId: $deviceId, timestamp: $timestamp, expectReply: $expectReply)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.expectReply, expectReply) ||
                other.expectReply == expectReply));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, content, sessionId,
      deviceId, timestamp, expectReply);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
          {required final String id,
          final MessageType type,
          required final String content,
          @JsonKey(name: 'session_id') required final String sessionId,
          @JsonKey(name: 'device_id') required final String deviceId,
          required final int timestamp,
          @JsonKey(name: 'expect_reply') final bool expectReply}) =
      _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  /// 消息ID
  @override
  String get id;

  /// 消息类型（固定为chat）
  @override
  MessageType get type;

  /// 消息内容
  @override
  String get content;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  String get sessionId;

  /// 设备ID
  @override
  @JsonKey(name: 'device_id')
  String get deviceId;

  /// 发送时间戳
  @override
  int get timestamp;

  /// 是否需要回复
  @override
  @JsonKey(name: 'expect_reply')
  bool get expectReply;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResponseMessage _$ResponseMessageFromJson(Map<String, dynamic> json) {
  return _ResponseMessage.fromJson(json);
}

/// @nodoc
mixin _$ResponseMessage {
  /// 消息ID
  String get id => throw _privateConstructorUsedError;

  /// 消息类型（固定为response）
  MessageType get type => throw _privateConstructorUsedError;

  /// 响应内容
  String get content => throw _privateConstructorUsedError;

  /// 原始请求ID
  @JsonKey(name: 'request_id')
  String get requestId => throw _privateConstructorUsedError;

  /// 会话ID
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;

  /// 响应时间戳
  int get timestamp => throw _privateConstructorUsedError;

  /// 是否完成
  bool get completed => throw _privateConstructorUsedError;

  /// 附加数据
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ResponseMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResponseMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResponseMessageCopyWith<ResponseMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResponseMessageCopyWith<$Res> {
  factory $ResponseMessageCopyWith(
          ResponseMessage value, $Res Function(ResponseMessage) then) =
      _$ResponseMessageCopyWithImpl<$Res, ResponseMessage>;
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String content,
      @JsonKey(name: 'request_id') String requestId,
      @JsonKey(name: 'session_id') String sessionId,
      int timestamp,
      bool completed,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ResponseMessageCopyWithImpl<$Res, $Val extends ResponseMessage>
    implements $ResponseMessageCopyWith<$Res> {
  _$ResponseMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResponseMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? content = null,
    Object? requestId = null,
    Object? sessionId = null,
    Object? timestamp = null,
    Object? completed = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResponseMessageImplCopyWith<$Res>
    implements $ResponseMessageCopyWith<$Res> {
  factory _$$ResponseMessageImplCopyWith(_$ResponseMessageImpl value,
          $Res Function(_$ResponseMessageImpl) then) =
      __$$ResponseMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String content,
      @JsonKey(name: 'request_id') String requestId,
      @JsonKey(name: 'session_id') String sessionId,
      int timestamp,
      bool completed,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$ResponseMessageImplCopyWithImpl<$Res>
    extends _$ResponseMessageCopyWithImpl<$Res, _$ResponseMessageImpl>
    implements _$$ResponseMessageImplCopyWith<$Res> {
  __$$ResponseMessageImplCopyWithImpl(
      _$ResponseMessageImpl _value, $Res Function(_$ResponseMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResponseMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? content = null,
    Object? requestId = null,
    Object? sessionId = null,
    Object? timestamp = null,
    Object? completed = null,
    Object? metadata = freezed,
  }) {
    return _then(_$ResponseMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResponseMessageImpl implements _ResponseMessage {
  const _$ResponseMessageImpl(
      {required this.id,
      this.type = MessageType.response,
      required this.content,
      @JsonKey(name: 'request_id') required this.requestId,
      @JsonKey(name: 'session_id') required this.sessionId,
      required this.timestamp,
      this.completed = true,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$ResponseMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResponseMessageImplFromJson(json);

  /// 消息ID
  @override
  final String id;

  /// 消息类型（固定为response）
  @override
  @JsonKey()
  final MessageType type;

  /// 响应内容
  @override
  final String content;

  /// 原始请求ID
  @override
  @JsonKey(name: 'request_id')
  final String requestId;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  final String sessionId;

  /// 响应时间戳
  @override
  final int timestamp;

  /// 是否完成
  @override
  @JsonKey()
  final bool completed;

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
    return 'ResponseMessage(id: $id, type: $type, content: $content, requestId: $requestId, sessionId: $sessionId, timestamp: $timestamp, completed: $completed, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResponseMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      content,
      requestId,
      sessionId,
      timestamp,
      completed,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ResponseMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResponseMessageImplCopyWith<_$ResponseMessageImpl> get copyWith =>
      __$$ResponseMessageImplCopyWithImpl<_$ResponseMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResponseMessageImplToJson(
      this,
    );
  }
}

abstract class _ResponseMessage implements ResponseMessage {
  const factory _ResponseMessage(
      {required final String id,
      final MessageType type,
      required final String content,
      @JsonKey(name: 'request_id') required final String requestId,
      @JsonKey(name: 'session_id') required final String sessionId,
      required final int timestamp,
      final bool completed,
      final Map<String, dynamic>? metadata}) = _$ResponseMessageImpl;

  factory _ResponseMessage.fromJson(Map<String, dynamic> json) =
      _$ResponseMessageImpl.fromJson;

  /// 消息ID
  @override
  String get id;

  /// 消息类型（固定为response）
  @override
  MessageType get type;

  /// 响应内容
  @override
  String get content;

  /// 原始请求ID
  @override
  @JsonKey(name: 'request_id')
  String get requestId;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  String get sessionId;

  /// 响应时间戳
  @override
  int get timestamp;

  /// 是否完成
  @override
  bool get completed;

  /// 附加数据
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ResponseMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResponseMessageImplCopyWith<_$ResponseMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ErrorMessage _$ErrorMessageFromJson(Map<String, dynamic> json) {
  return _ErrorMessage.fromJson(json);
}

/// @nodoc
mixin _$ErrorMessage {
  /// 消息ID
  String get id => throw _privateConstructorUsedError;

  /// 消息类型（固定为error）
  MessageType get type => throw _privateConstructorUsedError;

  /// 错误消息
  @JsonKey(name: 'error_message')
  String get errorMessage => throw _privateConstructorUsedError;

  /// 错误代码
  @JsonKey(name: 'error_code')
  String get errorCode => throw _privateConstructorUsedError;

  /// 原始请求ID
  @JsonKey(name: 'request_id')
  String? get requestId => throw _privateConstructorUsedError;

  /// 错误时间戳
  int get timestamp => throw _privateConstructorUsedError;

  /// 错误详情
  @JsonKey(name: 'error_details')
  Map<String, dynamic>? get errorDetails => throw _privateConstructorUsedError;

  /// Serializes this ErrorMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ErrorMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ErrorMessageCopyWith<ErrorMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ErrorMessageCopyWith<$Res> {
  factory $ErrorMessageCopyWith(
          ErrorMessage value, $Res Function(ErrorMessage) then) =
      _$ErrorMessageCopyWithImpl<$Res, ErrorMessage>;
  @useResult
  $Res call(
      {String id,
      MessageType type,
      @JsonKey(name: 'error_message') String errorMessage,
      @JsonKey(name: 'error_code') String errorCode,
      @JsonKey(name: 'request_id') String? requestId,
      int timestamp,
      @JsonKey(name: 'error_details') Map<String, dynamic>? errorDetails});
}

/// @nodoc
class _$ErrorMessageCopyWithImpl<$Res, $Val extends ErrorMessage>
    implements $ErrorMessageCopyWith<$Res> {
  _$ErrorMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ErrorMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? errorMessage = null,
    Object? errorCode = null,
    Object? requestId = freezed,
    Object? timestamp = null,
    Object? errorDetails = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: null == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String,
      requestId: freezed == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      errorDetails: freezed == errorDetails
          ? _value.errorDetails
          : errorDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ErrorMessageImplCopyWith<$Res>
    implements $ErrorMessageCopyWith<$Res> {
  factory _$$ErrorMessageImplCopyWith(
          _$ErrorMessageImpl value, $Res Function(_$ErrorMessageImpl) then) =
      __$$ErrorMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MessageType type,
      @JsonKey(name: 'error_message') String errorMessage,
      @JsonKey(name: 'error_code') String errorCode,
      @JsonKey(name: 'request_id') String? requestId,
      int timestamp,
      @JsonKey(name: 'error_details') Map<String, dynamic>? errorDetails});
}

/// @nodoc
class __$$ErrorMessageImplCopyWithImpl<$Res>
    extends _$ErrorMessageCopyWithImpl<$Res, _$ErrorMessageImpl>
    implements _$$ErrorMessageImplCopyWith<$Res> {
  __$$ErrorMessageImplCopyWithImpl(
      _$ErrorMessageImpl _value, $Res Function(_$ErrorMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ErrorMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? errorMessage = null,
    Object? errorCode = null,
    Object? requestId = freezed,
    Object? timestamp = null,
    Object? errorDetails = freezed,
  }) {
    return _then(_$ErrorMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: null == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String,
      requestId: freezed == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      errorDetails: freezed == errorDetails
          ? _value._errorDetails
          : errorDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ErrorMessageImpl implements _ErrorMessage {
  const _$ErrorMessageImpl(
      {required this.id,
      this.type = MessageType.error,
      @JsonKey(name: 'error_message') required this.errorMessage,
      @JsonKey(name: 'error_code') required this.errorCode,
      @JsonKey(name: 'request_id') this.requestId,
      required this.timestamp,
      @JsonKey(name: 'error_details') final Map<String, dynamic>? errorDetails})
      : _errorDetails = errorDetails;

  factory _$ErrorMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ErrorMessageImplFromJson(json);

  /// 消息ID
  @override
  final String id;

  /// 消息类型（固定为error）
  @override
  @JsonKey()
  final MessageType type;

  /// 错误消息
  @override
  @JsonKey(name: 'error_message')
  final String errorMessage;

  /// 错误代码
  @override
  @JsonKey(name: 'error_code')
  final String errorCode;

  /// 原始请求ID
  @override
  @JsonKey(name: 'request_id')
  final String? requestId;

  /// 错误时间戳
  @override
  final int timestamp;

  /// 错误详情
  final Map<String, dynamic>? _errorDetails;

  /// 错误详情
  @override
  @JsonKey(name: 'error_details')
  Map<String, dynamic>? get errorDetails {
    final value = _errorDetails;
    if (value == null) return null;
    if (_errorDetails is EqualUnmodifiableMapView) return _errorDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ErrorMessage(id: $id, type: $type, errorMessage: $errorMessage, errorCode: $errorCode, requestId: $requestId, timestamp: $timestamp, errorDetails: $errorDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality()
                .equals(other._errorDetails, _errorDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      errorMessage,
      errorCode,
      requestId,
      timestamp,
      const DeepCollectionEquality().hash(_errorDetails));

  /// Create a copy of ErrorMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorMessageImplCopyWith<_$ErrorMessageImpl> get copyWith =>
      __$$ErrorMessageImplCopyWithImpl<_$ErrorMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ErrorMessageImplToJson(
      this,
    );
  }
}

abstract class _ErrorMessage implements ErrorMessage {
  const factory _ErrorMessage(
      {required final String id,
      final MessageType type,
      @JsonKey(name: 'error_message') required final String errorMessage,
      @JsonKey(name: 'error_code') required final String errorCode,
      @JsonKey(name: 'request_id') final String? requestId,
      required final int timestamp,
      @JsonKey(name: 'error_details')
      final Map<String, dynamic>? errorDetails}) = _$ErrorMessageImpl;

  factory _ErrorMessage.fromJson(Map<String, dynamic> json) =
      _$ErrorMessageImpl.fromJson;

  /// 消息ID
  @override
  String get id;

  /// 消息类型（固定为error）
  @override
  MessageType get type;

  /// 错误消息
  @override
  @JsonKey(name: 'error_message')
  String get errorMessage;

  /// 错误代码
  @override
  @JsonKey(name: 'error_code')
  String get errorCode;

  /// 原始请求ID
  @override
  @JsonKey(name: 'request_id')
  String? get requestId;

  /// 错误时间戳
  @override
  int get timestamp;

  /// 错误详情
  @override
  @JsonKey(name: 'error_details')
  Map<String, dynamic>? get errorDetails;

  /// Create a copy of ErrorMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorMessageImplCopyWith<_$ErrorMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListenMessage _$ListenMessageFromJson(Map<String, dynamic> json) {
  return _ListenMessage.fromJson(json);
}

/// @nodoc
mixin _$ListenMessage {
  /// 消息类型（固定为listen）
  MessageType get type => throw _privateConstructorUsedError;

  /// 模式（manual手动输入）
  String get mode => throw _privateConstructorUsedError;

  /// 状态（detect检测）
  String get state => throw _privateConstructorUsedError;

  /// 文字内容
  String get text => throw _privateConstructorUsedError;

  /// Serializes this ListenMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListenMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListenMessageCopyWith<ListenMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListenMessageCopyWith<$Res> {
  factory $ListenMessageCopyWith(
          ListenMessage value, $Res Function(ListenMessage) then) =
      _$ListenMessageCopyWithImpl<$Res, ListenMessage>;
  @useResult
  $Res call({MessageType type, String mode, String state, String text});
}

/// @nodoc
class _$ListenMessageCopyWithImpl<$Res, $Val extends ListenMessage>
    implements $ListenMessageCopyWith<$Res> {
  _$ListenMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListenMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? mode = null,
    Object? state = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListenMessageImplCopyWith<$Res>
    implements $ListenMessageCopyWith<$Res> {
  factory _$$ListenMessageImplCopyWith(
          _$ListenMessageImpl value, $Res Function(_$ListenMessageImpl) then) =
      __$$ListenMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MessageType type, String mode, String state, String text});
}

/// @nodoc
class __$$ListenMessageImplCopyWithImpl<$Res>
    extends _$ListenMessageCopyWithImpl<$Res, _$ListenMessageImpl>
    implements _$$ListenMessageImplCopyWith<$Res> {
  __$$ListenMessageImplCopyWithImpl(
      _$ListenMessageImpl _value, $Res Function(_$ListenMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListenMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? mode = null,
    Object? state = null,
    Object? text = null,
  }) {
    return _then(_$ListenMessageImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListenMessageImpl implements _ListenMessage {
  const _$ListenMessageImpl(
      {this.type = MessageType.listen,
      this.mode = 'manual',
      this.state = 'detect',
      required this.text});

  factory _$ListenMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListenMessageImplFromJson(json);

  /// 消息类型（固定为listen）
  @override
  @JsonKey()
  final MessageType type;

  /// 模式（manual手动输入）
  @override
  @JsonKey()
  final String mode;

  /// 状态（detect检测）
  @override
  @JsonKey()
  final String state;

  /// 文字内容
  @override
  final String text;

  @override
  String toString() {
    return 'ListenMessage(type: $type, mode: $mode, state: $state, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListenMessageImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, mode, state, text);

  /// Create a copy of ListenMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListenMessageImplCopyWith<_$ListenMessageImpl> get copyWith =>
      __$$ListenMessageImplCopyWithImpl<_$ListenMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListenMessageImplToJson(
      this,
    );
  }
}

abstract class _ListenMessage implements ListenMessage {
  const factory _ListenMessage(
      {final MessageType type,
      final String mode,
      final String state,
      required final String text}) = _$ListenMessageImpl;

  factory _ListenMessage.fromJson(Map<String, dynamic> json) =
      _$ListenMessageImpl.fromJson;

  /// 消息类型（固定为listen）
  @override
  MessageType get type;

  /// 模式（manual手动输入）
  @override
  String get mode;

  /// 状态（detect检测）
  @override
  String get state;

  /// 文字内容
  @override
  String get text;

  /// Create a copy of ListenMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListenMessageImplCopyWith<_$ListenMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SttMessage _$SttMessageFromJson(Map<String, dynamic> json) {
  return _SttMessage.fromJson(json);
}

/// @nodoc
mixin _$SttMessage {
  /// 消息类型（固定为stt）
  MessageType get type => throw _privateConstructorUsedError;

  /// 会话ID
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;

  /// 识别到的文字
  String get text => throw _privateConstructorUsedError;

  /// Serializes this SttMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SttMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SttMessageCopyWith<SttMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SttMessageCopyWith<$Res> {
  factory $SttMessageCopyWith(
          SttMessage value, $Res Function(SttMessage) then) =
      _$SttMessageCopyWithImpl<$Res, SttMessage>;
  @useResult
  $Res call(
      {MessageType type,
      @JsonKey(name: 'session_id') String sessionId,
      String text});
}

/// @nodoc
class _$SttMessageCopyWithImpl<$Res, $Val extends SttMessage>
    implements $SttMessageCopyWith<$Res> {
  _$SttMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SttMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sessionId = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SttMessageImplCopyWith<$Res>
    implements $SttMessageCopyWith<$Res> {
  factory _$$SttMessageImplCopyWith(
          _$SttMessageImpl value, $Res Function(_$SttMessageImpl) then) =
      __$$SttMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MessageType type,
      @JsonKey(name: 'session_id') String sessionId,
      String text});
}

/// @nodoc
class __$$SttMessageImplCopyWithImpl<$Res>
    extends _$SttMessageCopyWithImpl<$Res, _$SttMessageImpl>
    implements _$$SttMessageImplCopyWith<$Res> {
  __$$SttMessageImplCopyWithImpl(
      _$SttMessageImpl _value, $Res Function(_$SttMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of SttMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sessionId = null,
    Object? text = null,
  }) {
    return _then(_$SttMessageImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SttMessageImpl implements _SttMessage {
  const _$SttMessageImpl(
      {this.type = MessageType.stt,
      @JsonKey(name: 'session_id') required this.sessionId,
      required this.text});

  factory _$SttMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SttMessageImplFromJson(json);

  /// 消息类型（固定为stt）
  @override
  @JsonKey()
  final MessageType type;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  final String sessionId;

  /// 识别到的文字
  @override
  final String text;

  @override
  String toString() {
    return 'SttMessage(type: $type, sessionId: $sessionId, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SttMessageImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, sessionId, text);

  /// Create a copy of SttMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SttMessageImplCopyWith<_$SttMessageImpl> get copyWith =>
      __$$SttMessageImplCopyWithImpl<_$SttMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SttMessageImplToJson(
      this,
    );
  }
}

abstract class _SttMessage implements SttMessage {
  const factory _SttMessage(
      {final MessageType type,
      @JsonKey(name: 'session_id') required final String sessionId,
      required final String text}) = _$SttMessageImpl;

  factory _SttMessage.fromJson(Map<String, dynamic> json) =
      _$SttMessageImpl.fromJson;

  /// 消息类型（固定为stt）
  @override
  MessageType get type;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  String get sessionId;

  /// 识别到的文字
  @override
  String get text;

  /// Create a copy of SttMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SttMessageImplCopyWith<_$SttMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TtsMessage _$TtsMessageFromJson(Map<String, dynamic> json) {
  return _TtsMessage.fromJson(json);
}

/// @nodoc
mixin _$TtsMessage {
  /// 消息类型（固定为tts）
  MessageType get type => throw _privateConstructorUsedError;

  /// 会话ID
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;

  /// 音频编码格式
  @JsonKey(name: 'audio_codec')
  String? get audioCodec => throw _privateConstructorUsedError;

  /// 音频片段索引
  int? get index => throw _privateConstructorUsedError;

  /// 状态（start开始，sentence_start句子开始等）
  String? get state => throw _privateConstructorUsedError;

  /// 文字内容（可选，某些状态下可能没有文字内容）
  String? get text => throw _privateConstructorUsedError;

  /// Serializes this TtsMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TtsMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TtsMessageCopyWith<TtsMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TtsMessageCopyWith<$Res> {
  factory $TtsMessageCopyWith(
          TtsMessage value, $Res Function(TtsMessage) then) =
      _$TtsMessageCopyWithImpl<$Res, TtsMessage>;
  @useResult
  $Res call(
      {MessageType type,
      @JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'audio_codec') String? audioCodec,
      int? index,
      String? state,
      String? text});
}

/// @nodoc
class _$TtsMessageCopyWithImpl<$Res, $Val extends TtsMessage>
    implements $TtsMessageCopyWith<$Res> {
  _$TtsMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TtsMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sessionId = null,
    Object? audioCodec = freezed,
    Object? index = freezed,
    Object? state = freezed,
    Object? text = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      audioCodec: freezed == audioCodec
          ? _value.audioCodec
          : audioCodec // ignore: cast_nullable_to_non_nullable
              as String?,
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TtsMessageImplCopyWith<$Res>
    implements $TtsMessageCopyWith<$Res> {
  factory _$$TtsMessageImplCopyWith(
          _$TtsMessageImpl value, $Res Function(_$TtsMessageImpl) then) =
      __$$TtsMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MessageType type,
      @JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'audio_codec') String? audioCodec,
      int? index,
      String? state,
      String? text});
}

/// @nodoc
class __$$TtsMessageImplCopyWithImpl<$Res>
    extends _$TtsMessageCopyWithImpl<$Res, _$TtsMessageImpl>
    implements _$$TtsMessageImplCopyWith<$Res> {
  __$$TtsMessageImplCopyWithImpl(
      _$TtsMessageImpl _value, $Res Function(_$TtsMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of TtsMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sessionId = null,
    Object? audioCodec = freezed,
    Object? index = freezed,
    Object? state = freezed,
    Object? text = freezed,
  }) {
    return _then(_$TtsMessageImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      audioCodec: freezed == audioCodec
          ? _value.audioCodec
          : audioCodec // ignore: cast_nullable_to_non_nullable
              as String?,
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TtsMessageImpl implements _TtsMessage {
  const _$TtsMessageImpl(
      {this.type = MessageType.tts,
      @JsonKey(name: 'session_id') required this.sessionId,
      @JsonKey(name: 'audio_codec') this.audioCodec,
      this.index,
      this.state,
      this.text});

  factory _$TtsMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$TtsMessageImplFromJson(json);

  /// 消息类型（固定为tts）
  @override
  @JsonKey()
  final MessageType type;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  final String sessionId;

  /// 音频编码格式
  @override
  @JsonKey(name: 'audio_codec')
  final String? audioCodec;

  /// 音频片段索引
  @override
  final int? index;

  /// 状态（start开始，sentence_start句子开始等）
  @override
  final String? state;

  /// 文字内容（可选，某些状态下可能没有文字内容）
  @override
  final String? text;

  @override
  String toString() {
    return 'TtsMessage(type: $type, sessionId: $sessionId, audioCodec: $audioCodec, index: $index, state: $state, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TtsMessageImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.audioCodec, audioCodec) ||
                other.audioCodec == audioCodec) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, sessionId, audioCodec, index, state, text);

  /// Create a copy of TtsMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TtsMessageImplCopyWith<_$TtsMessageImpl> get copyWith =>
      __$$TtsMessageImplCopyWithImpl<_$TtsMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TtsMessageImplToJson(
      this,
    );
  }
}

abstract class _TtsMessage implements TtsMessage {
  const factory _TtsMessage(
      {final MessageType type,
      @JsonKey(name: 'session_id') required final String sessionId,
      @JsonKey(name: 'audio_codec') final String? audioCodec,
      final int? index,
      final String? state,
      final String? text}) = _$TtsMessageImpl;

  factory _TtsMessage.fromJson(Map<String, dynamic> json) =
      _$TtsMessageImpl.fromJson;

  /// 消息类型（固定为tts）
  @override
  MessageType get type;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  String get sessionId;

  /// 音频编码格式
  @override
  @JsonKey(name: 'audio_codec')
  String? get audioCodec;

  /// 音频片段索引
  @override
  int? get index;

  /// 状态（start开始，sentence_start句子开始等）
  @override
  String? get state;

  /// 文字内容（可选，某些状态下可能没有文字内容）
  @override
  String? get text;

  /// Create a copy of TtsMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TtsMessageImplCopyWith<_$TtsMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LlmMessage _$LlmMessageFromJson(Map<String, dynamic> json) {
  return _LlmMessage.fromJson(json);
}

/// @nodoc
mixin _$LlmMessage {
  /// 消息类型（固定为llm）
  MessageType get type => throw _privateConstructorUsedError;

  /// 会话ID
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;

  /// 情感状态
  String? get emotion => throw _privateConstructorUsedError;

  /// 文字内容
  String get text => throw _privateConstructorUsedError;

  /// Serializes this LlmMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LlmMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LlmMessageCopyWith<LlmMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LlmMessageCopyWith<$Res> {
  factory $LlmMessageCopyWith(
          LlmMessage value, $Res Function(LlmMessage) then) =
      _$LlmMessageCopyWithImpl<$Res, LlmMessage>;
  @useResult
  $Res call(
      {MessageType type,
      @JsonKey(name: 'session_id') String sessionId,
      String? emotion,
      String text});
}

/// @nodoc
class _$LlmMessageCopyWithImpl<$Res, $Val extends LlmMessage>
    implements $LlmMessageCopyWith<$Res> {
  _$LlmMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LlmMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sessionId = null,
    Object? emotion = freezed,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      emotion: freezed == emotion
          ? _value.emotion
          : emotion // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LlmMessageImplCopyWith<$Res>
    implements $LlmMessageCopyWith<$Res> {
  factory _$$LlmMessageImplCopyWith(
          _$LlmMessageImpl value, $Res Function(_$LlmMessageImpl) then) =
      __$$LlmMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MessageType type,
      @JsonKey(name: 'session_id') String sessionId,
      String? emotion,
      String text});
}

/// @nodoc
class __$$LlmMessageImplCopyWithImpl<$Res>
    extends _$LlmMessageCopyWithImpl<$Res, _$LlmMessageImpl>
    implements _$$LlmMessageImplCopyWith<$Res> {
  __$$LlmMessageImplCopyWithImpl(
      _$LlmMessageImpl _value, $Res Function(_$LlmMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of LlmMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sessionId = null,
    Object? emotion = freezed,
    Object? text = null,
  }) {
    return _then(_$LlmMessageImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      emotion: freezed == emotion
          ? _value.emotion
          : emotion // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LlmMessageImpl implements _LlmMessage {
  const _$LlmMessageImpl(
      {this.type = MessageType.llm,
      @JsonKey(name: 'session_id') required this.sessionId,
      this.emotion,
      required this.text});

  factory _$LlmMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$LlmMessageImplFromJson(json);

  /// 消息类型（固定为llm）
  @override
  @JsonKey()
  final MessageType type;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  final String sessionId;

  /// 情感状态
  @override
  final String? emotion;

  /// 文字内容
  @override
  final String text;

  @override
  String toString() {
    return 'LlmMessage(type: $type, sessionId: $sessionId, emotion: $emotion, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LlmMessageImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.emotion, emotion) || other.emotion == emotion) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, sessionId, emotion, text);

  /// Create a copy of LlmMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LlmMessageImplCopyWith<_$LlmMessageImpl> get copyWith =>
      __$$LlmMessageImplCopyWithImpl<_$LlmMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LlmMessageImplToJson(
      this,
    );
  }
}

abstract class _LlmMessage implements LlmMessage {
  const factory _LlmMessage(
      {final MessageType type,
      @JsonKey(name: 'session_id') required final String sessionId,
      final String? emotion,
      required final String text}) = _$LlmMessageImpl;

  factory _LlmMessage.fromJson(Map<String, dynamic> json) =
      _$LlmMessageImpl.fromJson;

  /// 消息类型（固定为llm）
  @override
  MessageType get type;

  /// 会话ID
  @override
  @JsonKey(name: 'session_id')
  String get sessionId;

  /// 情感状态
  @override
  String? get emotion;

  /// 文字内容
  @override
  String get text;

  /// Create a copy of LlmMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LlmMessageImplCopyWith<_$LlmMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

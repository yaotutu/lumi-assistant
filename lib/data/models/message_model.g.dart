// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      id: json['id'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      content: json['content'] as String?,
      status:
          $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
          MessageStatus.pending,
      timestamp: (json['timestamp'] as num).toInt(),
      deviceId: json['device_id'] as String?,
      sessionId: json['session_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      errorMessage: json['error_message'] as String?,
      errorCode: json['error_code'] as String?,
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp,
      'device_id': instance.deviceId,
      'session_id': instance.sessionId,
      'metadata': instance.metadata,
      'error_message': instance.errorMessage,
      'error_code': instance.errorCode,
    };

const _$MessageTypeEnumMap = {
  MessageType.hello: 'hello',
  MessageType.chat: 'chat',
  MessageType.listen: 'listen',
  MessageType.image: 'image',
  MessageType.ping: 'ping',
  MessageType.pong: 'pong',
  MessageType.error: 'error',
  MessageType.response: 'response',
  MessageType.stt: 'stt',
  MessageType.tts: 'tts',
  MessageType.llm: 'llm',
};

const _$MessageStatusEnumMap = {
  MessageStatus.pending: 'pending',
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.failed: 'failed',
};

_$HelloMessageImpl _$$HelloMessageImplFromJson(
  Map<String, dynamic> json,
) => _$HelloMessageImpl(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.hello,
  version: json['version'] as String,
  deviceId: json['device_id'] as String,
  deviceInfo: DeviceInfo.fromJson(json['device_info'] as Map<String, dynamic>),
  capabilities:
      (json['capabilities'] as List<dynamic>).map((e) => e as String).toList(),
  timestamp: (json['timestamp'] as num).toInt(),
);

Map<String, dynamic> _$$HelloMessageImplToJson(_$HelloMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'version': instance.version,
      'device_id': instance.deviceId,
      'device_info': instance.deviceInfo,
      'capabilities': instance.capabilities,
      'timestamp': instance.timestamp,
    };

_$DeviceInfoImpl _$$DeviceInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeviceInfoImpl(
      platform: json['platform'] as String,
      model: json['model'] as String,
      osVersion: json['os_version'] as String,
      appVersion: json['app_version'] as String,
      screenSize: json['screen_size'] as String?,
      deviceName: json['device_name'] as String?,
      timezone: json['timezone'] as String?,
      locale: json['locale'] as String?,
    );

Map<String, dynamic> _$$DeviceInfoImplToJson(_$DeviceInfoImpl instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'model': instance.model,
      'os_version': instance.osVersion,
      'app_version': instance.appVersion,
      'screen_size': instance.screenSize,
      'device_name': instance.deviceName,
      'timezone': instance.timezone,
      'locale': instance.locale,
    };

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.chat,
      content: json['content'] as String,
      sessionId: json['session_id'] as String,
      deviceId: json['device_id'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      expectReply: json['expect_reply'] as bool? ?? true,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'session_id': instance.sessionId,
      'device_id': instance.deviceId,
      'timestamp': instance.timestamp,
      'expect_reply': instance.expectReply,
    };

_$ResponseMessageImpl _$$ResponseMessageImplFromJson(
  Map<String, dynamic> json,
) => _$ResponseMessageImpl(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.response,
  content: json['content'] as String,
  requestId: json['request_id'] as String,
  sessionId: json['session_id'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  completed: json['completed'] as bool? ?? true,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ResponseMessageImplToJson(
  _$ResponseMessageImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'content': instance.content,
  'request_id': instance.requestId,
  'session_id': instance.sessionId,
  'timestamp': instance.timestamp,
  'completed': instance.completed,
  'metadata': instance.metadata,
};

_$ErrorMessageImpl _$$ErrorMessageImplFromJson(Map<String, dynamic> json) =>
    _$ErrorMessageImpl(
      id: json['id'] as String,
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.error,
      errorMessage: json['error_message'] as String,
      errorCode: json['error_code'] as String,
      requestId: json['request_id'] as String?,
      timestamp: (json['timestamp'] as num).toInt(),
      errorDetails: json['error_details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ErrorMessageImplToJson(_$ErrorMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'error_message': instance.errorMessage,
      'error_code': instance.errorCode,
      'request_id': instance.requestId,
      'timestamp': instance.timestamp,
      'error_details': instance.errorDetails,
    };

_$PingMessageImpl _$$PingMessageImplFromJson(Map<String, dynamic> json) =>
    _$PingMessageImpl(
      id: json['id'] as String,
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.ping,
      timestamp: (json['timestamp'] as num).toInt(),
    );

Map<String, dynamic> _$$PingMessageImplToJson(_$PingMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp,
    };

_$PongMessageImpl _$$PongMessageImplFromJson(Map<String, dynamic> json) =>
    _$PongMessageImpl(
      id: json['id'] as String,
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.pong,
      pingId: json['ping_id'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
    );

Map<String, dynamic> _$$PongMessageImplToJson(_$PongMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'ping_id': instance.pingId,
      'timestamp': instance.timestamp,
    };

_$ListenMessageImpl _$$ListenMessageImplFromJson(Map<String, dynamic> json) =>
    _$ListenMessageImpl(
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.listen,
      mode: json['mode'] as String? ?? 'manual',
      state: json['state'] as String? ?? 'detect',
      text: json['text'] as String,
    );

Map<String, dynamic> _$$ListenMessageImplToJson(_$ListenMessageImpl instance) =>
    <String, dynamic>{
      'type': _$MessageTypeEnumMap[instance.type]!,
      'mode': instance.mode,
      'state': instance.state,
      'text': instance.text,
    };

_$SttMessageImpl _$$SttMessageImplFromJson(Map<String, dynamic> json) =>
    _$SttMessageImpl(
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.stt,
      sessionId: json['session_id'] as String,
      text: json['text'] as String,
    );

Map<String, dynamic> _$$SttMessageImplToJson(_$SttMessageImpl instance) =>
    <String, dynamic>{
      'type': _$MessageTypeEnumMap[instance.type]!,
      'session_id': instance.sessionId,
      'text': instance.text,
    };

_$TtsMessageImpl _$$TtsMessageImplFromJson(Map<String, dynamic> json) =>
    _$TtsMessageImpl(
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.tts,
      sessionId: json['session_id'] as String,
      audioCodec: json['audio_codec'] as String?,
      index: (json['index'] as num?)?.toInt(),
      state: json['state'] as String?,
      text: json['text'] as String?,
    );

Map<String, dynamic> _$$TtsMessageImplToJson(_$TtsMessageImpl instance) =>
    <String, dynamic>{
      'type': _$MessageTypeEnumMap[instance.type]!,
      'session_id': instance.sessionId,
      'audio_codec': instance.audioCodec,
      'index': instance.index,
      'state': instance.state,
      'text': instance.text,
    };

_$LlmMessageImpl _$$LlmMessageImplFromJson(Map<String, dynamic> json) =>
    _$LlmMessageImpl(
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.llm,
      sessionId: json['session_id'] as String,
      emotion: json['emotion'] as String?,
      text: json['text'] as String,
    );

Map<String, dynamic> _$$LlmMessageImplToJson(_$LlmMessageImpl instance) =>
    <String, dynamic>{
      'type': _$MessageTypeEnumMap[instance.type]!,
      'session_id': instance.sessionId,
      'emotion': instance.emotion,
      'text': instance.text,
    };

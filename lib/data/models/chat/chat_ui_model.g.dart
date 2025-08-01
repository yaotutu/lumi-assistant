// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_ui_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatUIMessageImpl _$$ChatUIMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatUIMessageImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      sender: $enumDecode(_$ChatSenderEnumMap, json['sender']),
      status: $enumDecodeNullable(_$ChatMessageStatusEnumMap, json['status']) ??
          ChatMessageStatus.sent,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isTemporary: json['isTemporary'] as bool? ?? false,
      isError: json['isError'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      originalMessageId: json['originalMessageId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ChatUIMessageImplToJson(_$ChatUIMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'sender': _$ChatSenderEnumMap[instance.sender]!,
      'status': _$ChatMessageStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isTemporary': instance.isTemporary,
      'isError': instance.isError,
      'errorMessage': instance.errorMessage,
      'originalMessageId': instance.originalMessageId,
      'metadata': instance.metadata,
    };

const _$ChatSenderEnumMap = {
  ChatSender.user: 'user',
  ChatSender.assistant: 'assistant',
  ChatSender.system: 'system',
};

const _$ChatMessageStatusEnumMap = {
  ChatMessageStatus.sending: 'sending',
  ChatMessageStatus.sent: 'sent',
  ChatMessageStatus.delivered: 'delivered',
  ChatMessageStatus.failed: 'failed',
  ChatMessageStatus.receiving: 'receiving',
  ChatMessageStatus.received: 'received',
};

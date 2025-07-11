import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// 消息类型枚举
enum MessageType {
  @JsonValue('hello')
  hello,
  @JsonValue('chat')
  chat,
  @JsonValue('listen')
  listen,
  @JsonValue('image')
  image,
  @JsonValue('ping')
  ping,
  @JsonValue('pong')
  pong,
  @JsonValue('error')
  error,
  @JsonValue('response')
  response,
  @JsonValue('stt')
  stt,
  @JsonValue('tts')
  tts,
  @JsonValue('llm')
  llm,
}

/// 消息状态枚举
enum MessageStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('failed')
  failed,
}

/// 基础消息模型
@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    /// 消息ID
    required String id,
    
    /// 消息类型
    required MessageType type,
    
    /// 消息内容
    String? content,
    
    /// 消息状态
    @Default(MessageStatus.pending) MessageStatus status,
    
    /// 发送时间戳
    required int timestamp,
    
    /// 设备ID
    @JsonKey(name: 'device_id') String? deviceId,
    
    /// 会话ID
    @JsonKey(name: 'session_id') String? sessionId,
    
    /// 附加数据
    @JsonKey(name: 'metadata') Map<String, dynamic>? metadata,
    
    /// 错误信息
    @JsonKey(name: 'error_message') String? errorMessage,
    
    /// 错误代码
    @JsonKey(name: 'error_code') String? errorCode,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}

/// Hello握手消息模型
@freezed
class HelloMessage with _$HelloMessage {
  const factory HelloMessage({
    /// 消息ID
    required String id,
    
    /// 消息类型（固定为hello）
    @Default(MessageType.hello) MessageType type,
    
    /// 客户端版本
    required String version,
    
    /// 设备ID
    @JsonKey(name: 'device_id') required String deviceId,
    
    /// 设备信息
    @JsonKey(name: 'device_info') required DeviceInfo deviceInfo,
    
    /// 客户端能力
    required List<String> capabilities,
    
    /// 发送时间戳
    required int timestamp,
  }) = _HelloMessage;

  factory HelloMessage.fromJson(Map<String, dynamic> json) =>
      _$HelloMessageFromJson(json);
}

/// 设备信息模型
@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    /// 设备平台
    required String platform,
    
    /// 设备型号
    required String model,
    
    /// 操作系统版本
    @JsonKey(name: 'os_version') required String osVersion,
    
    /// 应用版本
    @JsonKey(name: 'app_version') required String appVersion,
    
    /// 屏幕尺寸
    @JsonKey(name: 'screen_size') String? screenSize,
    
    /// 设备名称
    @JsonKey(name: 'device_name') String? deviceName,
    
    /// 时区
    String? timezone,
    
    /// 语言设置
    String? locale,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}

/// 聊天消息模型
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    /// 消息ID
    required String id,
    
    /// 消息类型（固定为chat）
    @Default(MessageType.chat) MessageType type,
    
    /// 消息内容
    required String content,
    
    /// 会话ID
    @JsonKey(name: 'session_id') required String sessionId,
    
    /// 设备ID
    @JsonKey(name: 'device_id') required String deviceId,
    
    /// 发送时间戳
    required int timestamp,
    
    /// 是否需要回复
    @JsonKey(name: 'expect_reply') @Default(true) bool expectReply,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

/// 服务器响应消息模型
@freezed
class ResponseMessage with _$ResponseMessage {
  const factory ResponseMessage({
    /// 消息ID
    required String id,
    
    /// 消息类型（固定为response）
    @Default(MessageType.response) MessageType type,
    
    /// 响应内容
    required String content,
    
    /// 原始请求ID
    @JsonKey(name: 'request_id') required String requestId,
    
    /// 会话ID
    @JsonKey(name: 'session_id') required String sessionId,
    
    /// 响应时间戳
    required int timestamp,
    
    /// 是否完成
    @Default(true) bool completed,
    
    /// 附加数据
    Map<String, dynamic>? metadata,
  }) = _ResponseMessage;

  factory ResponseMessage.fromJson(Map<String, dynamic> json) =>
      _$ResponseMessageFromJson(json);
}

/// 错误消息模型
@freezed
class ErrorMessage with _$ErrorMessage {
  const factory ErrorMessage({
    /// 消息ID
    required String id,
    
    /// 消息类型（固定为error）
    @Default(MessageType.error) MessageType type,
    
    /// 错误消息
    @JsonKey(name: 'error_message') required String errorMessage,
    
    /// 错误代码
    @JsonKey(name: 'error_code') required String errorCode,
    
    /// 原始请求ID
    @JsonKey(name: 'request_id') String? requestId,
    
    /// 错误时间戳
    required int timestamp,
    
    /// 错误详情
    @JsonKey(name: 'error_details') Map<String, dynamic>? errorDetails,
  }) = _ErrorMessage;

  factory ErrorMessage.fromJson(Map<String, dynamic> json) =>
      _$ErrorMessageFromJson(json);
}

/// 心跳消息模型
@freezed
class PingMessage with _$PingMessage {
  const factory PingMessage({
    /// 消息ID
    required String id,
    
    /// 消息类型（固定为ping）
    @Default(MessageType.ping) MessageType type,
    
    /// 发送时间戳
    required int timestamp,
  }) = _PingMessage;

  factory PingMessage.fromJson(Map<String, dynamic> json) =>
      _$PingMessageFromJson(json);
}

/// 心跳响应消息模型
@freezed
class PongMessage with _$PongMessage {
  const factory PongMessage({
    /// 消息ID
    required String id,
    
    /// 消息类型（固定为pong）
    @Default(MessageType.pong) MessageType type,
    
    /// 原始ping消息ID
    @JsonKey(name: 'ping_id') required String pingId,
    
    /// 响应时间戳
    required int timestamp,
  }) = _PongMessage;

  factory PongMessage.fromJson(Map<String, dynamic> json) =>
      _$PongMessageFromJson(json);
}

/// Listen消息模型（文字输入）
@freezed
class ListenMessage with _$ListenMessage {
  const factory ListenMessage({
    /// 消息类型（固定为listen）
    @Default(MessageType.listen) MessageType type,
    
    /// 模式（manual手动输入）
    @Default('manual') String mode,
    
    /// 状态（detect检测）
    @Default('detect') String state,
    
    /// 文字内容
    required String text,
  }) = _ListenMessage;

  factory ListenMessage.fromJson(Map<String, dynamic> json) =>
      _$ListenMessageFromJson(json);
}

/// STT消息模型（语音转文字结果）
@freezed
class SttMessage with _$SttMessage {
  const factory SttMessage({
    /// 消息类型（固定为stt）
    @Default(MessageType.stt) MessageType type,
    
    /// 会话ID
    @JsonKey(name: 'session_id') required String sessionId,
    
    /// 识别到的文字
    required String text,
  }) = _SttMessage;

  factory SttMessage.fromJson(Map<String, dynamic> json) =>
      _$SttMessageFromJson(json);
}

/// TTS消息模型（文字转语音）
@freezed
class TtsMessage with _$TtsMessage {
  const factory TtsMessage({
    /// 消息类型（固定为tts）
    @Default(MessageType.tts) MessageType type,
    
    /// 会话ID
    @JsonKey(name: 'session_id') required String sessionId,
    
    /// 音频编码格式
    @JsonKey(name: 'audio_codec') String? audioCodec,
    
    /// 音频片段索引
    int? index,
    
    /// 状态（start开始，sentence_start句子开始等）
    String? state,
    
    /// 文字内容（可选，某些状态下可能没有文字内容）
    String? text,
  }) = _TtsMessage;

  factory TtsMessage.fromJson(Map<String, dynamic> json) =>
      _$TtsMessageFromJson(json);
}

/// LLM消息模型（AI思考和回复）
@freezed
class LlmMessage with _$LlmMessage {
  const factory LlmMessage({
    /// 消息类型（固定为llm）
    @Default(MessageType.llm) MessageType type,
    
    /// 会话ID
    @JsonKey(name: 'session_id') required String sessionId,
    
    /// 情感状态
    String? emotion,
    
    /// 文字内容
    required String text,
  }) = _LlmMessage;

  factory LlmMessage.fromJson(Map<String, dynamic> json) =>
      _$LlmMessageFromJson(json);
}
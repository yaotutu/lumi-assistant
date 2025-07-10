import 'package:freezed_annotation/freezed_annotation.dart';
import 'message_model.dart';

part 'chat_ui_model.freezed.dart';
part 'chat_ui_model.g.dart';

/// 聊天消息发送者类型
enum ChatSender {
  /// 用户消息
  user,
  /// 助手消息
  assistant,
  /// 系统消息
  system,
}

/// 聊天消息状态（UI展示用）
enum ChatMessageStatus {
  /// 发送中
  sending,
  /// 已发送
  sent,
  /// 已送达
  delivered,
  /// 发送失败
  failed,
  /// 接收中（流式响应）
  receiving,
  /// 已接收
  received,
}

/// 聊天界面消息模型
@freezed
class ChatUIMessage with _$ChatUIMessage {
  const factory ChatUIMessage({
    /// 消息ID
    required String id,
    
    /// 消息内容
    required String content,
    
    /// 发送者类型
    required ChatSender sender,
    
    /// 消息状态
    @Default(ChatMessageStatus.sent) ChatMessageStatus status,
    
    /// 消息时间
    required DateTime timestamp,
    
    /// 是否为临时消息（如正在输入提示）
    @Default(false) bool isTemporary,
    
    /// 是否为错误消息
    @Default(false) bool isError,
    
    /// 错误信息
    String? errorMessage,
    
    /// 关联的原始消息ID（用于响应匹配）
    String? originalMessageId,
    
    /// 附加数据
    Map<String, dynamic>? metadata,
  }) = _ChatUIMessage;

  factory ChatUIMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatUIMessageFromJson(json);
}

/// 聊天界面消息扩展方法
extension ChatUIMessageExtension on ChatUIMessage {
  /// 是否为用户消息
  bool get isUser => sender == ChatSender.user;
  
  /// 是否为助手消息
  bool get isAssistant => sender == ChatSender.assistant;
  
  /// 是否为系统消息
  bool get isSystem => sender == ChatSender.system;
  
  /// 是否可以重新发送
  bool get canResend => status == ChatMessageStatus.failed && isUser;
  
  /// 是否正在处理中
  bool get isProcessing => status == ChatMessageStatus.sending || 
                           status == ChatMessageStatus.receiving;
  
  /// 获取状态显示文本
  String get statusText {
    switch (status) {
      case ChatMessageStatus.sending:
        return '发送中...';
      case ChatMessageStatus.sent:
        return '已发送';
      case ChatMessageStatus.delivered:
        return '已送达';
      case ChatMessageStatus.failed:
        return '发送失败';
      case ChatMessageStatus.receiving:
        return '接收中...';
      case ChatMessageStatus.received:
        return '已接收';
    }
  }
}

/// 聊天界面消息转换工具
class ChatUIMessageConverter {
  /// 从ChatMessage转换为ChatUIMessage
  static ChatUIMessage fromChatMessage(ChatMessage message) {
    return ChatUIMessage(
      id: message.id,
      content: message.content,
      sender: ChatSender.user,
      timestamp: DateTime.fromMillisecondsSinceEpoch(message.timestamp),
      status: ChatMessageStatus.sent,
    );
  }
  
  /// 从ResponseMessage转换为ChatUIMessage
  static ChatUIMessage fromResponseMessage(ResponseMessage message) {
    return ChatUIMessage(
      id: message.id,
      content: message.content,
      sender: ChatSender.assistant,
      timestamp: DateTime.fromMillisecondsSinceEpoch(message.timestamp),
      status: message.completed ? ChatMessageStatus.received : ChatMessageStatus.receiving,
      originalMessageId: message.requestId,
      metadata: message.metadata,
    );
  }
  
  /// 从ErrorMessage转换为ChatUIMessage
  static ChatUIMessage fromErrorMessage(ErrorMessage message) {
    return ChatUIMessage(
      id: message.id,
      content: message.errorMessage,
      sender: ChatSender.system,
      timestamp: DateTime.fromMillisecondsSinceEpoch(message.timestamp),
      status: ChatMessageStatus.failed,
      isError: true,
      errorMessage: message.errorMessage,
      originalMessageId: message.requestId,
      metadata: message.errorDetails,
    );
  }
  
  /// 创建用户消息
  static ChatUIMessage createUserMessage(String content) {
    return ChatUIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sending,
    );
  }
  
  /// 创建系统消息
  static ChatUIMessage createSystemMessage(String content) {
    return ChatUIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: ChatSender.system,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.received,
    );
  }
  
  /// 创建助手消息
  static ChatUIMessage createAssistantMessage(String content) {
    return ChatUIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: ChatSender.assistant,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.received,
    );
  }
  
  /// 创建临时消息（如正在输入提示）
  static ChatUIMessage createTemporaryMessage(String content) {
    return ChatUIMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      sender: ChatSender.assistant,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.receiving,
      isTemporary: true,
    );
  }
}
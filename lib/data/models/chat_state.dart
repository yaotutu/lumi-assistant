import 'package:freezed_annotation/freezed_annotation.dart';

import 'chat_ui_model.dart';

part 'chat_state.freezed.dart';

/// 聊天状态 - 使用Freezed优化的不可变数据类
/// 
/// 管理聊天界面的所有状态，包括：
/// - 消息列表
/// - 发送和接收状态
/// - 错误状态
/// - 会话信息
/// 
/// 使用Freezed的优势：
/// - 自动生成copyWith方法，支持链式调用
/// - 自动生成equals和hashCode，优化性能
/// - 自动生成toString，方便调试
/// - 类型安全的序列化支持
/// - 不可变性保证，避免意外修改
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    /// 聊天消息列表
    /// 按时间顺序排列，最新消息在最后
    @Default([]) List<ChatUIMessage> messages,
    
    /// 是否正在发送消息
    /// 用于UI显示发送状态和禁用发送按钮
    @Default(false) bool isSending,
    
    /// 是否正在接收响应
    /// 用于UI显示接收状态和typing指示器
    @Default(false) bool isReceiving,
    
    /// 当前错误信息
    /// 为null表示没有错误
    String? error,
    
    /// 会话ID
    /// 标识当前聊天会话，用于消息关联
    String? sessionId,
    
    /// 最后一次活动时间
    /// 用于会话超时检查
    DateTime? lastActivityTime,
    
    /// 是否允许发送消息
    /// 根据连接状态和其他条件动态设置
    @Default(true) bool canSendMessage,
    
    /// 未读消息数量
    /// 用于通知和徽章显示
    @Default(0) int unreadCount,
    
    /// 会话元数据
    /// 存储会话相关的附加信息
    @Default({}) Map<String, dynamic> sessionMetadata,
  }) = _ChatState;

}

/// 聊天状态扩展方法
/// 
/// 提供便捷的状态查询和操作方法
extension ChatStateExtension on ChatState {
  /// 是否有消息
  bool get hasMessages => messages.isNotEmpty;
  
  /// 是否忙碌中
  /// 正在发送或接收消息时返回true
  bool get isBusy => isSending || isReceiving;
  
  /// 最后一条消息
  ChatUIMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;
  
  /// 最后一条用户消息
  ChatUIMessage? get lastUserMessage => 
      messages.reversed.firstWhere(
        (m) => m.isUser, 
        orElse: () => throw StateError('No user message found'),
      );
  
  /// 最后一条助手消息
  ChatUIMessage? get lastAssistantMessage => 
      messages.reversed.firstWhere(
        (m) => m.isAssistant, 
        orElse: () => throw StateError('No assistant message found'),
      );
  
  /// 用户消息数量
  int get userMessageCount => messages.where((m) => m.isUser).length;
  
  /// 助手消息数量
  int get assistantMessageCount => messages.where((m) => m.isAssistant).length;
  
  /// 系统消息数量
  int get systemMessageCount => messages.where((m) => m.isSystem).length;
  
  /// 失败消息数量
  int get failedMessageCount => 
      messages.where((m) => m.status == ChatMessageStatus.failed).length;
  
  /// 是否有错误
  bool get hasError => error != null;
  
  /// 是否有会话
  bool get hasSession => sessionId != null;
  
  /// 会话是否活跃
  /// 检查最后活动时间是否在指定时间内
  bool get isSessionActive {
    if (lastActivityTime == null) return false;
    final now = DateTime.now();
    final inactiveThreshold = Duration(minutes: 30); // 30分钟无活动视为不活跃
    return now.difference(lastActivityTime!) < inactiveThreshold;
  }
  
  /// 获取指定发送者的消息
  List<ChatUIMessage> messagesFrom(ChatSender sender) {
    return messages.where((m) => m.sender == sender).toList();
  }
  
  /// 获取指定状态的消息
  List<ChatUIMessage> messagesWithStatus(ChatMessageStatus status) {
    return messages.where((m) => m.status == status).toList();
  }
  
  /// 获取错误消息列表
  List<ChatUIMessage> get errorMessages => 
      messages.where((m) => m.isError).toList();
  
  /// 获取临时消息列表
  List<ChatUIMessage> get temporaryMessages => 
      messages.where((m) => m.isTemporary).toList();
  
  /// 获取可重发的消息列表
  List<ChatUIMessage> get resendableMessages => 
      messages.where((m) => m.canResend).toList();
  
  /// 获取正在处理的消息列表
  List<ChatUIMessage> get processingMessages => 
      messages.where((m) => m.isProcessing).toList();
  
  /// 计算消息统计信息
  Map<String, int> get messageStats {
    return {
      'total': messages.length,
      'user': userMessageCount,
      'assistant': assistantMessageCount,
      'system': systemMessageCount,
      'failed': failedMessageCount,
      'unread': unreadCount,
    };
  }
  
  /// 获取会话持续时间
  Duration? get sessionDuration {
    if (messages.isEmpty) return null;
    
    final firstMessage = messages.first;
    final lastMessage = messages.last;
    
    return lastMessage.timestamp.difference(firstMessage.timestamp);
  }
  
  /// 检查消息是否存在
  bool hasMessage(String messageId) {
    return messages.any((m) => m.id == messageId);
  }
  
  /// 根据ID获取消息
  ChatUIMessage? getMessage(String messageId) {
    try {
      return messages.firstWhere((m) => m.id == messageId);
    } catch (e) {
      return null;
    }
  }
  
  /// 获取消息索引
  int? getMessageIndex(String messageId) {
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].id == messageId) {
        return i;
      }
    }
    return null;
  }
}

/// 聊天状态工厂方法
/// 
/// 提供创建各种初始状态的便捷方法
extension ChatStateFactory on ChatState {
  /// 创建初始状态
  static ChatState initial() {
    return const ChatState();
  }
  
  /// 创建带欢迎消息的初始状态
  static ChatState withWelcomeMessage() {
    final welcomeMessage = ChatUIMessageConverter.createSystemMessage(
      '欢迎使用 Lumi Assistant！\n\n这是里程碑5的聊天界面基础演示。',
    );
    
    return ChatState(
      messages: [welcomeMessage],
      lastActivityTime: DateTime.now(),
    );
  }
  
  /// 创建带会话ID的状态
  static ChatState withSession(String sessionId) {
    return ChatState(
      sessionId: sessionId,
      lastActivityTime: DateTime.now(),
    );
  }
  
  /// 创建错误状态
  static ChatState withError(String errorMessage) {
    return ChatState(
      error: errorMessage,
      canSendMessage: false,
    );
  }
  
  /// 创建离线状态
  static ChatState offline() {
    return const ChatState(
      canSendMessage: false,
      error: '网络连接已断开',
    );
  }
}

/// 聊天状态操作方法
/// 
/// 提供常用的状态更新操作
extension ChatStateOperations on ChatState {
  /// 添加消息
  ChatState addMessage(ChatUIMessage message) {
    return copyWith(
      messages: [...messages, message],
      lastActivityTime: DateTime.now(),
      unreadCount: message.isAssistant ? unreadCount + 1 : unreadCount,
    );
  }
  
  /// 批量添加消息
  ChatState addMessages(List<ChatUIMessage> newMessages) {
    if (newMessages.isEmpty) return this;
    
    final assistantMessageCount = newMessages.where((m) => m.isAssistant).length;
    
    return copyWith(
      messages: [...messages, ...newMessages],
      lastActivityTime: DateTime.now(),
      unreadCount: unreadCount + assistantMessageCount,
    );
  }
  
  /// 更新消息
  ChatState updateMessage(String messageId, ChatUIMessage updatedMessage) {
    final messageIndex = getMessageIndex(messageId);
    if (messageIndex == null) return this;
    
    final updatedMessages = [...messages];
    updatedMessages[messageIndex] = updatedMessage;
    
    return copyWith(
      messages: updatedMessages,
      lastActivityTime: DateTime.now(),
    );
  }
  
  /// 删除消息
  ChatState removeMessage(String messageId) {
    final updatedMessages = messages.where((m) => m.id != messageId).toList();
    
    return copyWith(
      messages: updatedMessages,
      lastActivityTime: DateTime.now(),
    );
  }
  
  /// 清除所有消息
  ChatState clearMessages() {
    return copyWith(
      messages: [],
      unreadCount: 0,
      lastActivityTime: DateTime.now(),
    );
  }
  
  /// 清除临时消息
  ChatState clearTemporaryMessages() {
    final filteredMessages = messages.where((m) => !m.isTemporary).toList();
    
    return copyWith(
      messages: filteredMessages,
      lastActivityTime: DateTime.now(),
    );
  }
  
  /// 标记所有消息为已读
  ChatState markAllAsRead() {
    return copyWith(unreadCount: 0);
  }
  
  /// 开始发送消息
  ChatState startSending() {
    return copyWith(
      isSending: true,
      error: null,
    );
  }
  
  /// 完成发送消息
  ChatState finishSending() {
    return copyWith(
      isSending: false,
      lastActivityTime: DateTime.now(),
    );
  }
  
  /// 开始接收响应
  ChatState startReceiving() {
    return copyWith(
      isReceiving: true,
      error: null,
    );
  }
  
  /// 完成接收响应
  ChatState finishReceiving() {
    return copyWith(
      isReceiving: false,
      lastActivityTime: DateTime.now(),
    );
  }
  
  /// 设置错误状态
  ChatState setError(String errorMessage) {
    return copyWith(
      error: errorMessage,
      isSending: false,
      isReceiving: false,
    );
  }
  
  /// 清除错误状态
  ChatState clearError() {
    return copyWith(error: null);
  }
  
  /// 设置会话信息
  ChatState setSession(String sessionId) {
    return copyWith(
      sessionId: sessionId,
      lastActivityTime: DateTime.now(),
      canSendMessage: true,
    );
  }
  
  /// 清除会话信息
  ChatState clearSession() {
    return copyWith(
      sessionId: null,
      canSendMessage: false,
    );
  }
  
  /// 更新会话元数据
  ChatState updateSessionMetadata(Map<String, dynamic> metadata) {
    return copyWith(
      sessionMetadata: {...sessionMetadata, ...metadata},
    );
  }
}
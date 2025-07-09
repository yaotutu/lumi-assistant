import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/chat_ui_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/chat_state.dart';
import '../../data/models/connection_state.dart';
import 'connection_provider.dart';


/// 聊天状态管理
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  static const _uuid = Uuid();

  ChatNotifier(this._ref) : super(ChatStateFactory.initial()) {
    _initializeChat();
  }

  /// 初始化聊天
  void _initializeChat() {
    print('[ChatNotifier] 初始化聊天');
    
    // 监听连接状态变化
    _ref.listen(connectionManagerProvider, (previous, next) {
      print('[ChatNotifier] 连接状态变化: ${next.statusDescription}');
      if (next.handshakeResult.sessionId != null) {
        print('[ChatNotifier] 设置会话ID: ${next.handshakeResult.sessionId}');
        state = state.copyWith(sessionId: next.handshakeResult.sessionId);
      }
    });

    // 添加欢迎消息
    _addWelcomeMessage();
  }

  /// 添加欢迎消息
  void _addWelcomeMessage() {
    final welcomeMessage = ChatUIMessageConverter.createSystemMessage(
      '欢迎使用 Lumi Assistant！\n\n这是里程碑5的聊天界面基础演示。消息发送功能将在里程碑6中实现。',
    );
    
    state = state.copyWith(
      messages: [welcomeMessage],
    );
  }

  /// 发送消息
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    print('[ChatNotifier] 发送消息: $content');
    
    // 创建用户消息
    final userMessage = ChatUIMessageConverter.createUserMessage(content);
    
    // 添加到消息列表
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      error: null,
    );

    try {
      // 检查连接状态
      final connectionState = _ref.read(connectionManagerProvider);
      if (!connectionState.isFullyConnected) {
        throw Exception('未连接到服务器');
      }

      final sessionId = state.sessionId;
      if (sessionId == null) {
        throw Exception('会话未建立');
      }

      // 创建聊天消息
      final chatMessage = ChatMessage(
        id: userMessage.id,
        content: content,
        sessionId: sessionId,
        deviceId: 'device_id_placeholder', // 在里程碑6中从连接状态获取
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // 发送消息 (在里程碑6中实现)
      await _ref.read(connectionManagerProvider.notifier).sendMessage(chatMessage.toJson());
      
      // 更新用户消息状态为已发送
      _updateMessageStatus(userMessage.id, ChatMessageStatus.sent);
      
      // 开始接收响应
      state = state.copyWith(
        isSending: false,
        isReceiving: true,
      );

    } catch (e) {
      print('[ChatNotifier] 发送消息失败: $e');
      
      // 更新用户消息状态为失败
      _updateMessageStatus(userMessage.id, ChatMessageStatus.failed);
      
      state = state.copyWith(
        isSending: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// 重新发送消息
  Future<void> resendMessage(String messageId) async {
    final message = state.messages.firstWhere((m) => m.id == messageId);
    if (message.isUser) {
      // 更新消息状态为发送中
      _updateMessageStatus(messageId, ChatMessageStatus.sending);
      
      // 重新发送
      await sendMessage(message.content);
    }
  }

  /// 处理WebSocket消息 (在里程碑6中实现)
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    print('[ChatNotifier] 收到WebSocket消息: $message');
    
    try {
      switch (message['type']) {
        case 'response':
          _handleResponseMessage(message);
          break;
        case 'error':
          _handleErrorMessage(message);
          break;
        default:
          print('[ChatNotifier] 未知消息类型: ${message['type']}');
      }
    } catch (e) {
      print('[ChatNotifier] 处理消息失败: $e');
      _handleWebSocketError(e);
    }
  }

  /// 处理响应消息
  void _handleResponseMessage(Map<String, dynamic> messageData) {
    final responseMessage = ResponseMessage.fromJson(messageData);
    final chatMessage = ChatUIMessageConverter.fromResponseMessage(responseMessage);
    
    // 添加助手消息
    state = state.copyWith(
      messages: [...state.messages, chatMessage],
      isReceiving: false,
    );
  }

  /// 处理错误消息
  void _handleErrorMessage(Map<String, dynamic> messageData) {
    final errorMessage = ErrorMessage.fromJson(messageData);
    final chatMessage = ChatUIMessageConverter.fromErrorMessage(errorMessage);
    
    // 添加错误消息
    state = state.copyWith(
      messages: [...state.messages, chatMessage],
      isReceiving: false,
      error: errorMessage.errorMessage,
    );
  }

  /// 处理WebSocket错误
  void _handleWebSocketError(dynamic error) {
    print('[ChatNotifier] WebSocket错误: $error');
    
    state = state.copyWith(
      isSending: false,
      isReceiving: false,
      error: _getErrorMessage(error),
    );
  }

  /// 更新消息状态
  void _updateMessageStatus(String messageId, ChatMessageStatus status) {
    final messages = state.messages.map((message) {
      if (message.id == messageId) {
        return message.copyWith(status: status);
      }
      return message;
    }).toList();
    
    state = state.copyWith(messages: messages);
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 清除所有消息
  void clearMessages() {
    state = state.copyWith(messages: []);
    _addWelcomeMessage();
  }

  /// 获取错误消息
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  @override
  void dispose() {
    print('[ChatNotifier] 释放资源');
    super.dispose();
  }
}

/// 聊天状态Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

/// 发送消息Action Provider
final sendMessageProvider = Provider.autoDispose.family<Future<void>, String>((ref, message) async {
  final chatNotifier = ref.watch(chatProvider.notifier);
  await chatNotifier.sendMessage(message);
});

/// 重新发送消息Action Provider
final resendMessageProvider = Provider.autoDispose.family<Future<void>, String>((ref, messageId) async {
  final chatNotifier = ref.watch(chatProvider.notifier);
  await chatNotifier.resendMessage(messageId);
});


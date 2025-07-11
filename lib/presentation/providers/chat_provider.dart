import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/chat_ui_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/chat_state.dart';
import '../../data/models/connection_state.dart';
import '../../core/services/handshake_service.dart';
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
    
    // 首先检查当前握手状态
    _checkCurrentHandshakeState();
    
    // 监听连接状态变化
    _ref.listen(connectionManagerProvider, (previous, next) {
      print('[ChatNotifier] 连接状态变化: ${next.statusDescription}');
      if (next.handshakeResult.sessionId != null) {
        print('[ChatNotifier] 设置会话ID: ${next.handshakeResult.sessionId}');
        state = state.copyWith(sessionId: next.handshakeResult.sessionId);
      }
    });

    // 直接监听握手状态变化
    _ref.listen(handshakeServiceProvider, (previous, next) {
      print('[ChatNotifier] 握手状态变化: ${next.state}, sessionId: ${next.sessionId}');
      if (next.sessionId != null) {
        print('[ChatNotifier] 从握手服务设置会话ID: ${next.sessionId}');
        state = state.copyWith(sessionId: next.sessionId);
      }
    });

    // 监听WebSocket消息
    _startWebSocketMessageListener();

    // 添加欢迎消息
    _addWelcomeMessage();
  }

  /// 检查当前握手状态
  void _checkCurrentHandshakeState() {
    // 延迟检查，确保Provider初始化完成
    Future.microtask(() {
      try {
        final handshakeState = _ref.read(handshakeServiceProvider);
        print('[ChatNotifier] 检查当前握手状态: ${handshakeState.state}, sessionId: ${handshakeState.sessionId}');
        
        if (handshakeState.sessionId != null) {
          print('[ChatNotifier] 发现现有会话ID: ${handshakeState.sessionId}');
          state = state.copyWith(sessionId: handshakeState.sessionId);
        }
        
        final connectionState = _ref.read(connectionManagerProvider);
        print('[ChatNotifier] 检查连接状态: ${connectionState.statusDescription}');
        
        if (connectionState.handshakeResult.sessionId != null) {
          print('[ChatNotifier] 发现连接管理器中的会话ID: ${connectionState.handshakeResult.sessionId}');
          state = state.copyWith(sessionId: connectionState.handshakeResult.sessionId);
        }
      } catch (e) {
        print('[ChatNotifier] 检查当前状态失败: $e');
      }
    });
  }

  /// 开始监听WebSocket消息
  void _startWebSocketMessageListener() {
    print('[ChatNotifier] 开始监听WebSocket消息');
    
    // 获取连接管理器的消息流
    final connectionManager = _ref.read(connectionManagerProvider.notifier);
    
    // 监听消息流
    connectionManager.messageStream.listen(
      (message) {
        print('[ChatNotifier] 收到WebSocket消息: $message');
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        print('[ChatNotifier] WebSocket消息流错误: $error');
        _handleWebSocketError(error);
      },
    );
  }

  /// 添加欢迎消息
  void _addWelcomeMessage() {
    final welcomeMessage = ChatUIMessageConverter.createSystemMessage(
      '欢迎使用 Lumi Assistant！\n\n这是里程碑6的文字消息发送功能演示。\n\n如果显示"未连接到服务器"，请检查WebSocket服务器是否运行在 ws://192.168.110.199:8000/',
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

      // 首先尝试获取当前会话ID
      var sessionId = state.sessionId;
      print('[ChatNotifier] 当前会话ID: $sessionId');
      
      // 如果会话ID为空，尝试重新获取
      if (sessionId == null) {
        try {
          final handshakeState = _ref.read(handshakeServiceProvider);
          final connectionState = _ref.read(connectionManagerProvider);
          
          sessionId = handshakeState.sessionId ?? connectionState.handshakeResult.sessionId;
          
          if (sessionId != null) {
            print('[ChatNotifier] 重新获取到会话ID: $sessionId');
            state = state.copyWith(sessionId: sessionId);
          }
        } catch (e) {
          print('[ChatNotifier] 重新获取会话ID失败: $e');
        }
      }
      
      if (sessionId == null) {
        throw Exception('会话未建立');
      }

      // 创建listen消息（参考xiaozhi项目格式）
      final listenMessage = {
        "type": "listen",
        "state": "detect", 
        "text": content,
        "source": "text",
      };

      // 发送listen消息
      print('[ChatNotifier] 准备发送listen消息: $listenMessage');
      await _ref.read(connectionManagerProvider.notifier).sendMessage(listenMessage);
      
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

  /// 处理WebSocket消息
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    print('[ChatNotifier] 收到WebSocket消息: $message');
    
    try {
      final messageType = message['type'] as String?;
      
      switch (messageType) {
        case 'response':
          _handleResponseMessage(message);
          break;
        case 'error':
          _handleErrorMessage(message);
          break;
        case 'hello':
          // Hello消息由HandshakeService处理，这里忽略
          print('[ChatNotifier] 忽略Hello消息，由HandshakeService处理');
          break;
        case 'stt':
          _handleSttMessage(message);
          break;
        case 'tts':
          _handleTtsMessage(message);
          break;
        case 'llm':
          _handleLlmMessage(message);
          break;
        default:
          print('[ChatNotifier] 收到未知消息类型: $messageType');
          print('[ChatNotifier] 消息内容: $message');
      }
    } catch (e) {
      print('[ChatNotifier] 处理消息失败: $e');
      _handleWebSocketError(e);
    }
  }

  /// 处理响应消息
  void _handleResponseMessage(Map<String, dynamic> messageData) {
    print('[ChatNotifier] 处理响应消息: $messageData');
    
    try {
      final responseMessage = ResponseMessage.fromJson(messageData);
      final chatMessage = ChatUIMessageConverter.fromResponseMessage(responseMessage);
      
      // 添加助手消息
      state = state.copyWith(
        messages: [...state.messages, chatMessage],
        isReceiving: false,
        error: null,
      );
      
      print('[ChatNotifier] 响应消息添加成功: ${chatMessage.content}');
    } catch (e) {
      print('[ChatNotifier] 解析响应消息失败: $e');
      
      // 创建一个错误消息显示
      final errorMessage = ChatUIMessageConverter.createSystemMessage(
        '解析AI响应失败: $e',
      );
      
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isReceiving: false,
        error: '解析响应失败',
      );
    }
  }

  /// 处理错误消息
  void _handleErrorMessage(Map<String, dynamic> messageData) {
    print('[ChatNotifier] 处理错误消息: $messageData');
    
    try {
      final errorMessage = ErrorMessage.fromJson(messageData);
      final chatMessage = ChatUIMessageConverter.fromErrorMessage(errorMessage);
      
      // 添加错误消息
      state = state.copyWith(
        messages: [...state.messages, chatMessage],
        isReceiving: false,
        error: errorMessage.errorMessage,
      );
      
      print('[ChatNotifier] 错误消息添加成功: ${errorMessage.errorMessage}');
    } catch (e) {
      print('[ChatNotifier] 解析错误消息失败: $e');
      
      // 创建一个通用错误消息
      final fallbackErrorMessage = ChatUIMessageConverter.createSystemMessage(
        '收到服务器错误响应，但解析失败。',
      );
      
      state = state.copyWith(
        messages: [...state.messages, fallbackErrorMessage],
        isReceiving: false,
        error: '服务器错误',
      );
    }
  }

  /// 处理STT消息（语音转文字结果）
  void _handleSttMessage(Map<String, dynamic> messageData) {
    print('[ChatNotifier] 处理STT消息: $messageData');
    
    try {
      final sttMessage = SttMessage.fromJson(messageData);
      
      // STT消息只是显示用户的语音被识别的结果，通常不需要在聊天界面显示
      // 因为用户输入的消息已经显示了
      print('[ChatNotifier] STT识别结果: ${sttMessage.text}');
      
    } catch (e) {
      print('[ChatNotifier] 解析STT消息失败: $e');
    }
  }

  /// 处理TTS消息（文字转语音）
  void _handleTtsMessage(Map<String, dynamic> messageData) {
    print('[ChatNotifier] 处理TTS消息: $messageData');
    
    try {
      final ttsMessage = TtsMessage.fromJson(messageData);
      
      // 只处理包含文字内容的TTS消息
      if (ttsMessage.text != null && ttsMessage.text!.isNotEmpty) {
        // 根据TTS状态决定如何处理
        switch (ttsMessage.state) {
          case 'start':
            print('[ChatNotifier] AI开始回复');
            state = state.copyWith(
              isReceiving: true,
              isSending: false,
            );
            break;
          case 'sentence_start':
            // 这是AI的实际回复内容
            final aiMessage = ChatUIMessageConverter.createAssistantMessage(
              ttsMessage.text!,
            );
            
            // 添加AI回复消息
            state = state.copyWith(
              messages: [...state.messages, aiMessage],
              isReceiving: false,
              error: null,
            );
            
            print('[ChatNotifier] AI回复: ${ttsMessage.text}');
            break;
          default:
            print('[ChatNotifier] TTS状态: ${ttsMessage.state}');
        }
      }
      
    } catch (e) {
      print('[ChatNotifier] 解析TTS消息失败: $e');
    }
  }

  /// 处理LLM消息（AI思考和回复）
  void _handleLlmMessage(Map<String, dynamic> messageData) {
    print('[ChatNotifier] 处理LLM消息: $messageData');
    
    try {
      final llmMessage = LlmMessage.fromJson(messageData);
      
      // 处理AI的思考状态
      if (llmMessage.emotion != null) {
        print('[ChatNotifier] AI情感状态: ${llmMessage.emotion}');
        
        // 如果是thinking状态，可以显示AI正在思考
        if (llmMessage.emotion == 'thinking') {
          // 创建一个思考状态的消息
          final thinkingMessage = ChatUIMessageConverter.createSystemMessage(
            '🤔 AI正在思考...',
          );
          
          // 临时添加思考消息（之后会被实际回复替换）
          state = state.copyWith(
            messages: [...state.messages, thinkingMessage],
            isReceiving: true,
          );
        }
      }
      
      // 处理包含文字内容的LLM消息
      if (llmMessage.text.isNotEmpty && llmMessage.text != '🤔') {
        final aiMessage = ChatUIMessageConverter.createAssistantMessage(
          llmMessage.text,
        );
        
        // 移除可能的思考消息，添加实际回复
        final messagesWithoutThinking = state.messages
            .where((msg) => msg.content != '🤔 AI正在思考...')
            .toList();
        
        state = state.copyWith(
          messages: [...messagesWithoutThinking, aiMessage],
          isReceiving: false,
          error: null,
        );
        
        print('[ChatNotifier] LLM回复: ${llmMessage.text}');
      }
      
    } catch (e) {
      print('[ChatNotifier] 解析LLM消息失败: $e');
    }
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

  /// 手动重连
  Future<void> reconnect() async {
    print('[ChatNotifier] 手动重连');
    
    // 清除错误状态
    state = state.copyWith(error: null);
    
    // 触发重连
    await _ref.read(connectionManagerProvider.notifier).reconnect();
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

/// 重连Action Provider
final reconnectProvider = Provider.autoDispose<Future<void>>((ref) async {
  final chatNotifier = ref.watch(chatProvider.notifier);
  await chatNotifier.reconnect();
});


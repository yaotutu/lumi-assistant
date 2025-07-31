import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:uuid/uuid.dart'; // 暂未使用

import '../../data/models/chat/chat_ui_model.dart';
import '../../data/models/chat/message_model.dart';
import '../../data/models/chat/chat_state.dart';
import '../../data/models/connection/connection_state.dart';
import '../../core/services/network/handshake_service.dart';
import '../../core/errors/error_handler.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/loggers.dart';
import 'connection_provider.dart';


/// 聊天状态管理
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  // static const _uuid = Uuid(); // 暂未使用
  
  // 性能优化：限制内存中保留的消息数量
  static const int _maxMessagesInMemory = 50;
  
  // 跟踪当前正在构建的AI回复消息
  String? _currentAiMessageId;

  ChatNotifier(this._ref) : super(ChatStateFactory.initial()) {
    _initializeChat();
  }

  /// 初始化聊天
  void _initializeChat() {
    Loggers.chat.info('初始化聊天');
    
    // 首先检查当前握手状态
    _checkCurrentHandshakeState();
    
    // 监听连接状态变化
    _ref.listen(connectionManagerProvider, (previous, next) {
      Loggers.chat.info('连接状态变化: ${next.statusDescription}');
      if (next.handshakeResult.sessionId != null) {
        Loggers.chat.info('设置会话ID: ${next.handshakeResult.sessionId}');
        state = state.copyWith(sessionId: next.handshakeResult.sessionId);
      }
    });

    // 直接监听握手状态变化
    _ref.listen(handshakeServiceProvider, (previous, next) {
      Loggers.chat.info('握手状态变化: ${next.state}, sessionId: ${next.sessionId}');
      if (next.sessionId != null) {
        Loggers.chat.info('从握手服务设置会话ID: ${next.sessionId}');
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
        Loggers.chat.fine('检查当前握手状态: ${handshakeState.state}, sessionId: ${handshakeState.sessionId}');
        
        if (handshakeState.sessionId != null) {
          Loggers.chat.info('发现现有会话ID: ${handshakeState.sessionId}');
          state = state.copyWith(sessionId: handshakeState.sessionId);
        }
        
        final connectionState = _ref.read(connectionManagerProvider);
        Loggers.chat.fine('检查连接状态: ${connectionState.statusDescription}');
        
        if (connectionState.handshakeResult.sessionId != null) {
          Loggers.chat.info('发现连接管理器中的会话ID: ${connectionState.handshakeResult.sessionId}');
          state = state.copyWith(sessionId: connectionState.handshakeResult.sessionId);
        }
      } catch (e) {
        Loggers.chat.severe('检查当前状态失败', e);
      }
    });
  }

  /// 开始监听WebSocket消息
  void _startWebSocketMessageListener() {
    Loggers.chat.info('开始监听WebSocket消息');
    
    // 获取连接管理器的消息流
    final connectionManager = _ref.read(connectionManagerProvider.notifier);
    
    // 监听消息流
    connectionManager.messageStream.listen(
      (message) {
        Loggers.chat.fine('收到WebSocket消息: $message');
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        Loggers.chat.severe('WebSocket消息流错误', error);
        _handleWebSocketError(error);
      },
    );
  }

  /// 添加欢迎消息
  void _addWelcomeMessage() {
    final welcomeMessage = ChatUIMessageConverter.createSystemMessage(
      '欢迎使用 Lumi Assistant！\n\n您可以通过文字或语音与我对话。',
    );
    
    state = state.copyWith(
      messages: [welcomeMessage],
    );
  }

  /// 性能优化：添加消息并自动修剪（暂未使用，但保留作为工具方法）
  // void _addMessageWithTrimming(ChatUIMessage message) {
  //   state = state.copyWith(
  //     messages: [...state.messages, message],
  //   );
  //   _trimMessagesIfNeeded();
  // }

  /// 性能优化：修剪消息列表以避免内存溢出
  void _trimMessagesIfNeeded() {
    if (state.messages.length > _maxMessagesInMemory) {
      Loggers.chat.fine('消息数量超过限制 ($_maxMessagesInMemory)，开始修剪旧消息');
      
      // 保留最近的消息，但确保保留欢迎消息
      final messages = state.messages;
      final welcomeMessage = messages.firstWhere(
        (msg) => msg.sender == ChatSender.system,
        orElse: () => messages.first,
      );
      
      // 保留欢迎消息 + 最新的消息
      final recentMessages = messages.skip(messages.length - _maxMessagesInMemory + 1).toList();
      final trimmedMessages = [welcomeMessage, ...recentMessages];
      
      state = state.copyWith(messages: trimmedMessages);
      Loggers.chat.fine('消息修剪完成，当前消息数: ${trimmedMessages.length}');
    }
  }

  /// 发送消息
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    Loggers.chat.userAction('发送消息: $content');
    
    // 创建用户消息
    final userMessage = ChatUIMessageConverter.createUserMessage(content);
    
    // 添加到消息列表
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      error: null,
    );
    
    // 性能优化：检查是否需要修剪消息
    _trimMessagesIfNeeded();

    try {
      // 使用错误处理器的重试机制发送消息
      await ErrorHandler.withRetry(
        () => _performSendMessage(content, userMessage.id),
        maxAttempts: 3,
        retryIf: (error) {
          // 判断是否应该重试
          if (error is Exception) {
            final appException = ErrorHandler.handleMessageSendError(error, messageId: userMessage.id);
            return appException.canRetry;
          }
          return false;
        },
      );
      
      // 更新用户消息状态为已发送
      _updateMessageStatus(userMessage.id, ChatMessageStatus.sent);
      
      // 开始接收响应
      state = state.copyWith(
        isSending: false,
        isReceiving: true,
      );

    } catch (e) {
      Loggers.chat.severe('发送消息失败', e);
      
      // 使用错误处理器处理错误
      final appException = ErrorHandler.handleMessageSendError(e, messageId: userMessage.id);
      
      // 更新用户消息状态为失败
      _updateMessageStatus(userMessage.id, ChatMessageStatus.failed);
      
      state = state.copyWith(
        isSending: false,
        error: appException.userFriendlyMessage,
      );
    }
  }

  /// 执行实际的消息发送
  Future<void> _performSendMessage(String content, String messageId) async {
    // 检查连接状态
    final connectionState = _ref.read(connectionManagerProvider);
    if (!connectionState.isFullyConnected) {
      throw Exception('未连接到服务器');
    }

    // 首先尝试获取当前会话ID
    var sessionId = state.sessionId;
    Loggers.chat.fine('当前会话ID: $sessionId');
    
    // 如果会话ID为空，尝试重新获取
    if (sessionId == null) {
      try {
        final handshakeState = _ref.read(handshakeServiceProvider);
        final connectionState = _ref.read(connectionManagerProvider);
        
        sessionId = handshakeState.sessionId ?? connectionState.handshakeResult.sessionId;
        
        if (sessionId != null) {
          Loggers.chat.info('重新获取到会话ID: $sessionId');
          state = state.copyWith(sessionId: sessionId);
        }
      } catch (e) {
        Loggers.chat.warning('重新获取会话ID失败', e);
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
    Loggers.chat.fine('准备发送listen消息: $listenMessage');
    
    // 使用超时机制发送消息
    await ErrorHandler.withTimeout(
      () => _ref.read(connectionManagerProvider.notifier).sendMessage(listenMessage),
      timeout: const Duration(seconds: 10),
      timeoutMessage: '消息发送超时',
    );
  }

  /// 重新发送消息
  Future<void> resendMessage(String messageId) async {
    try {
      final message = state.messages.firstWhere((m) => m.id == messageId);
      if (message.isUser) {
        // 更新消息状态为发送中
        _updateMessageStatus(messageId, ChatMessageStatus.sending);
        
        // 使用错误处理器的重试机制重新发送
        await ErrorHandler.withRetry(
          () => _performSendMessage(message.content, messageId),
          maxAttempts: 3,
          retryIf: (error) {
            if (error is Exception) {
              final appException = ErrorHandler.handleMessageSendError(error, messageId: messageId);
              return appException.canRetry;
            }
            return false;
          },
        );
        
        // 更新消息状态为已发送
        _updateMessageStatus(messageId, ChatMessageStatus.sent);
        
        // 开始接收响应
        state = state.copyWith(
          isSending: false,
          isReceiving: true,
          error: null,
        );
      }
    } catch (e) {
      Loggers.chat.severe('重新发送消息失败', e);
      
      // 使用错误处理器处理错误
      final appException = ErrorHandler.handleMessageSendError(e, messageId: messageId);
      
      // 更新消息状态为失败
      _updateMessageStatus(messageId, ChatMessageStatus.failed);
      
      state = state.copyWith(
        isSending: false,
        error: appException.userFriendlyMessage,
      );
    }
  }

  /// 处理WebSocket消息
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    Loggers.chat.fine('收到WebSocket消息: $message');
    
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
          Loggers.chat.fine('忽略Hello消息，由HandshakeService处理');
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
          Loggers.chat.warning('收到未知消息类型: $messageType');
          Loggers.chat.fine('消息内容: $message');
      }
    } catch (e) {
      Loggers.chat.severe('处理消息失败', e);
      
      // 使用错误处理器处理消息解析错误
      final appException = ErrorHandler.handleMessageParseError(e, rawMessage: message);
      ErrorHandler.logError(appException, StackTrace.current, context: {
        'messageType': message['type'],
        'messageContent': message,
      });
      
      _handleWebSocketError(appException);
    }
  }

  /// 处理响应消息
  void _handleResponseMessage(Map<String, dynamic> messageData) {
    Loggers.chat.fine('处理响应消息: $messageData');
    
    try {
      final responseMessage = ResponseMessage.fromJson(messageData);
      final chatMessage = ChatUIMessageConverter.fromResponseMessage(responseMessage);
      
      // 添加助手消息
      state = state.copyWith(
        messages: [...state.messages, chatMessage],
        isReceiving: false,
        error: null,
      );
      
      Loggers.chat.info('响应消息添加成功: ${chatMessage.content}');
    } catch (e) {
      Loggers.chat.severe('解析响应消息失败', e);
      
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
    Loggers.chat.fine('处理错误消息: $messageData');
    
    try {
      final errorMessage = ErrorMessage.fromJson(messageData);
      final chatMessage = ChatUIMessageConverter.fromErrorMessage(errorMessage);
      
      // 添加错误消息
      state = state.copyWith(
        messages: [...state.messages, chatMessage],
        isReceiving: false,
        error: errorMessage.errorMessage,
      );
      
      Loggers.chat.info('错误消息添加成功: ${errorMessage.errorMessage}');
    } catch (e) {
      Loggers.chat.severe('解析错误消息失败', e);
      
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
    Loggers.chat.fine('处理STT消息: $messageData');
    
    try {
      final sttMessage = SttMessage.fromJson(messageData);
      
      // 按照Android客户端的实现：将语音识别结果作为用户消息显示
      if (sttMessage.text.isNotEmpty) {
        Loggers.chat.info('STT识别结果: ${sttMessage.text}');
        
        // 创建用户消息（语音识别结果）
        final userMessage = ChatUIMessageConverter.createUserMessage(sttMessage.text).copyWith(
          metadata: {'isVoiceInput': true}, // 标记这是语音输入
        );
        
        // 添加到消息列表
        state = state.copyWith(
          messages: [...state.messages, userMessage],
          isSending: false,
          isReceiving: true, // 等待AI回复
          error: null,
        );
        
        Loggers.chat.info('语音识别消息添加成功: ${sttMessage.text}');
      }
      
    } catch (e) {
      Loggers.chat.severe('解析STT消息失败', e);
    }
  }

  /// 处理TTS消息（文字转语音）
  void _handleTtsMessage(Map<String, dynamic> messageData) {
    Loggers.chat.fine('处理TTS消息: $messageData');
    
    try {
      final ttsMessage = TtsMessage.fromJson(messageData);
      
      // 根据TTS状态决定如何处理
      switch (ttsMessage.state) {
        case 'start':
          Loggers.chat.info('AI开始回复');
          state = state.copyWith(
            isReceiving: true,
            isSending: false,
          );
          // 重置当前AI消息ID
          _currentAiMessageId = null;
          break;
        case 'sentence_start':
          // 检查是否有文字内容
          if (ttsMessage.text != null && ttsMessage.text!.isNotEmpty) {
            _handleAiResponse(ttsMessage.text!);
          } else {
            Loggers.chat.fine('sentence_start状态但无文字内容');
          }
          break;
        case 'sentence_end':
          Loggers.chat.info('AI完成一句话');
          break;
        case 'stop':
          Loggers.chat.info('AI回复完成');
          state = state.copyWith(
            isReceiving: false,
            isSending: false,
          );
          // 清除当前AI消息ID
          _currentAiMessageId = null;
          break;
        default:
          Loggers.chat.fine('TTS状态: ${ttsMessage.state}');
      }
      
    } catch (e) {
      Loggers.chat.severe('解析TTS消息失败', e);
    }
  }

  /// 处理LLM消息（AI思考和回复）
  void _handleLlmMessage(Map<String, dynamic> messageData) {
    Loggers.chat.fine('处理LLM消息: $messageData');
    
    try {
      final llmMessage = LlmMessage.fromJson(messageData);
      
      // 处理AI的思考状态
      if (llmMessage.emotion != null) {
        Loggers.chat.fine('AI情感状态: ${llmMessage.emotion}');
        
        // 如果是thinking状态，显示AI正在思考
        if (llmMessage.emotion == 'thinking') {
          state = state.copyWith(
            isReceiving: true,
            isSending: false,
          );
          Loggers.chat.info('AI正在思考中...');
        } else if (llmMessage.emotion == 'error') {
          // 如果是error状态，停止思考并显示错误
          Loggers.chat.warning('AI遇到错误，停止思考状态');
          
          // 清除当前AI消息构建状态
          _currentAiMessageId = null;
          
          state = state.copyWith(
            isReceiving: false,
            isSending: false,
            error: llmMessage.text.isNotEmpty ? llmMessage.text : '操作过程中遇到错误',
          );
          
          // 添加简化的错误消息到聊天记录
          final simplifiedError = _simplifyErrorText(llmMessage.text);
          final errorMessage = ChatUIMessageConverter.createSystemMessage(
            '❌ $simplifiedError',
          );
          
          state = state.copyWith(
            messages: [...state.messages, errorMessage],
          );
        }
      }
      
      // 处理包含文字内容的LLM消息
      if (llmMessage.text.isNotEmpty && llmMessage.text != '🤔') {
        _handleAiResponse(llmMessage.text);
      }
      
    } catch (e) {
      Loggers.chat.severe('解析LLM消息失败', e);
    }
  }
  
  /// 处理AI回复内容（统一处理来自TTS和LLM的回复）
  void _handleAiResponse(String responseText) {
    Loggers.chat.info('处理AI回复: $responseText');
    
    // 如果当前没有正在构建的AI消息，创建一个新的
    if (_currentAiMessageId == null) {
      final aiMessage = ChatUIMessageConverter.createAssistantMessage(
        responseText,
      );
      
      // 添加AI回复消息
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isReceiving: false,
        error: null,
      );
      
      _currentAiMessageId = aiMessage.id;
      Loggers.chat.fine('创建新的AI消息: ${aiMessage.id}');
    } else {
      // 如果有正在构建的AI消息，更新其内容（支持流式回复）
      final updatedMessages = state.messages.map((message) {
        if (message.id == _currentAiMessageId) {
          return message.copyWith(
            content: '${message.content}\n\n$responseText',
            timestamp: DateTime.now(),
          );
        }
        return message;
      }).toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        isReceiving: false,
        error: null,
      );
      
      Loggers.chat.fine('更新AI消息: $_currentAiMessageId');
    }
  }

  /// 处理WebSocket错误
  void _handleWebSocketError(dynamic error) {
    Loggers.chat.severe('WebSocket错误', error);
    
    // 清除当前AI消息构建状态
    _currentAiMessageId = null;
    
    // 使用错误处理器处理错误
    final errorMessage = ErrorHandler.getErrorMessage(error);
    
    // 记录错误日志
    ErrorHandler.logError(error, StackTrace.current, context: {
      'currentAiMessageId': _currentAiMessageId,
      'sessionId': state.sessionId,
      'messageCount': state.messages.length,
    });
    
    state = state.copyWith(
      isSending: false,
      isReceiving: false,
      error: errorMessage,
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
    Loggers.chat.userAction('手动重连');
    
    // 清除错误状态
    state = state.copyWith(error: null);
    
    // 触发重连
    await _ref.read(connectionManagerProvider.notifier).reconnect();
  }


  /// 简化错误文本，只显示关键信息
  String _simplifyErrorText(String errorText) {
    if (errorText.isEmpty) return '操作失败，请稍后重试';
    
    // 移除"MCP工具调用失败:"前缀
    String simplified = errorText.replaceFirst('MCP工具调用失败: ', '');
    
    // 提取关键错误信息
    if (simplified.contains('设备响应超时')) {
      return '设备响应较慢，请稍后重试';
    } else if (simplified.contains('外部服务响应超时')) {
      return '网络服务响应超时，请检查网络连接';
    } else if (simplified.contains('操作超时')) {
      return '操作超时，请稍后重试';
    } else if (simplified.contains('网络连接')) {
      return '网络连接异常，请检查网络状态';
    } else if (simplified.contains('权限不足')) {
      return '权限不足，无法执行此操作';
    } else if (simplified.contains('设备不可用')) {
      return '设备暂时不可用';
    }
    
    // 移除多余的换行和格式，只保留第一行关键信息
    simplified = simplified.split('\n').first.trim();
    
    // 如果还是太长，截取关键部分
    if (simplified.length > 30) {
      return '${simplified.substring(0, 27)}...';
    }
    
    return simplified.isNotEmpty ? simplified : '操作失败，请稍后重试';
  }

  @override
  void dispose() {
    Loggers.chat.info('释放资源');
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


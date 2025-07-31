import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/chat_provider.dart';
import '../../providers/virtual_character_provider.dart';
import '../../../data/models/chat/chat_state.dart';
import '../../../core/constants/device_constants.dart';
import '../../../core/services/audio/voice_interrupt_service.dart';
import '../virtual_character/models/character_enums.dart';
import '../status/connection_status_widget.dart';
import '../status/handshake_status_widget.dart';
import 'chat_message_item.dart';
import 'chat_input_section.dart';

/// 聊天界面模式
enum ChatInterfaceMode {
  /// 完整模式 - 用于主聊天页面
  full,
  /// 紧凑模式 - 用于悬浮聊天窗口
  compact,
}

/// 统一的聊天界面组件
/// 
/// 支持两种显示模式：
/// - full: 完整聊天界面，包含标题栏、状态指示器、输入栏等
/// - compact: 紧凑聊天界面，专为悬浮窗口优化
/// 
/// 数据状态完全共享，使用相同的chatProvider
class ChatInterface extends HookConsumerWidget {
  /// 显示模式
  final ChatInterfaceMode mode;
  
  /// 设备类型（用于响应式设计）
  final DeviceType? deviceType;
  
  /// 是否为横屏模式
  final bool isLandscape;
  
  /// 关闭回调（紧凑模式使用）
  final VoidCallback? onClose;
  
  /// 语音开始回调
  final VoidCallback? onVoiceStart;
  
  /// 语音结束回调
  final VoidCallback? onVoiceEnd;
  
  /// 是否启用语音输入（默认启用）
  final bool enableVoiceInput;
  
  /// 是否启用文本输入（默认启用）
  final bool enableTextInput;
  
  /// 自定义背景色
  final Color? backgroundColor;
  
  /// 构造函数
  const ChatInterface({
    super.key,
    required this.mode,
    this.deviceType,
    this.isLandscape = false,
    this.onClose,
    this.onVoiceStart,
    this.onVoiceEnd,
    this.enableVoiceInput = true,
    this.enableTextInput = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取聊天状态
    final chatState = ref.watch(chatProvider);
    final characterNotifier = ref.read(virtualCharacterProvider.notifier);
    
    // 控制器
    final scrollController = useScrollController();
    final inputController = useTextEditingController();
    final focusNode = useFocusNode();
    
    // 监听聊天状态变化，同步虚拟人物状态
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.isBusy != next.isBusy) {
        if (next.isBusy) {
          characterNotifier.updateStatus(CharacterStatus.thinking);
        } else {
          characterNotifier.updateStatus(CharacterStatus.idle);
        }
      }
    });
    
    // 自动滚动到底部
    useEffect(() {
      if (chatState.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
      return null;
    }, [chatState.messages.length]);
    
    return Container(
      color: backgroundColor,
      child: mode == ChatInterfaceMode.full
          ? _buildFullInterface(context, ref, chatState, scrollController, inputController, focusNode)
          : _buildCompactInterface(context, ref, chatState, scrollController, inputController, focusNode),
    );
  }
  
  /// 构建完整聊天界面
  Widget _buildFullInterface(
    BuildContext context,
    WidgetRef ref,
    ChatState chatState,
    ScrollController scrollController,
    TextEditingController inputController,
    FocusNode focusNode,
  ) {
    final effectiveDeviceType = deviceType ?? _getDeviceType(context);
    final isCompact = effectiveDeviceType != DeviceType.standard;
    
    return Column(
      children: [
        // 顶部应用栏
        _buildAppBar(context, ref, effectiveDeviceType),
        
        // 消息列表区域
        Expanded(
          child: _buildMessageList(context, ref, chatState, scrollController, isCompact),
        ),
        
        // 底部输入区域
        ChatInputSection(
          controller: inputController,
          focusNode: focusNode,
          scrollController: scrollController,
          deviceType: effectiveDeviceType,
          isCompact: isCompact,
          enableVoiceInput: enableVoiceInput,
          enableTextInput: enableTextInput,
          onSendMessage: (message) => _sendMessage(ref, message),
          onVoiceStart: onVoiceStart,
          onVoiceEnd: onVoiceEnd,
        ),
      ],
    );
  }
  
  /// 构建紧凑聊天界面
  Widget _buildCompactInterface(
    BuildContext context,
    WidgetRef ref,
    ChatState chatState,
    ScrollController scrollController,
    TextEditingController inputController,
    FocusNode focusNode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 紧凑标题栏
          _buildCompactHeader(context, ref),
          
          const SizedBox(height: 12),
          
          // 消息列表
          Expanded(
            child: _buildMessageList(context, ref, chatState, scrollController, true),
          ),
          
          // 紧凑输入区域（根据配置决定是否显示）
          if (enableTextInput) ...[
            const SizedBox(height: 12),
            ChatInputSection(
              controller: inputController,
              focusNode: focusNode,
              scrollController: scrollController,
              deviceType: DeviceType.small,
              isCompact: true,
              enableVoiceInput: enableVoiceInput,
              enableTextInput: enableTextInput,
              onSendMessage: (message) => _sendMessage(ref, message),
              onVoiceStart: onVoiceStart,
              onVoiceEnd: onVoiceEnd,
            ),
          ],
        ],
      ),
    );
  }
  
  /// 构建应用栏
  Widget _buildAppBar(BuildContext context, WidgetRef ref, DeviceType deviceType) {
    final appBarHeight = _calculateAppBarHeight(deviceType);
    
    return Container(
      height: appBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: deviceType == DeviceType.micro ? 4.0 : 
                   deviceType == DeviceType.tiny ? 8.0 : 16.0,
        vertical: deviceType == DeviceType.micro ? 4.0 : 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          _buildBackButton(context, deviceType),
          
          if (deviceType != DeviceType.micro) const SizedBox(width: 8),
          
          // 应用信息
          Expanded(
            child: _buildAppTitle(context, deviceType),
          ),
          
          // 连接状态指示器
          if (deviceType != DeviceType.micro) ...[
            _buildConnectionStatus(context, deviceType),
          ],
        ],
      ),
    );
  }
  
  /// 构建紧凑标题栏
  Widget _buildCompactHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // 标题
        Expanded(
          child: Text(
            'Lumi Assistant',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        
        // 关闭按钮
        if (onClose != null)
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
            tooltip: '关闭',
          ),
      ],
    );
  }
  
  /// 构建消息列表
  Widget _buildMessageList(
    BuildContext context,
    WidgetRef ref,
    ChatState chatState,
    ScrollController scrollController,
    bool isCompact,
  ) {
    if (chatState.messages.isEmpty && !chatState.isBusy) {
      return _buildEmptyState(context, isCompact);
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chatState.messages.length + (chatState.isBusy ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == chatState.messages.length) {
            // 加载指示器
            return _buildLoadingIndicator(context, isCompact);
          }
          
          final message = chatState.messages[index];
          return ChatMessageItem(
            message: message,
            isCompact: isCompact,
          );
        },
      ),
    );
  }
  
  /// 构建空状态
  Widget _buildEmptyState(BuildContext context, bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: isCompact ? 32 : 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: isCompact ? 8 : 16),
            Text(
              '开始对话吧！',
              style: TextStyle(
                // 使用默认字体大小，通过全局fontScale缩放
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isCompact ? 4 : 8),
            Text(
              enableTextInput ? '输入消息或使用语音与AI助手聊天' : '使用语音与AI助手聊天',
              style: TextStyle(
                fontSize: 12, // 小字体提示文本
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建加载指示器
  Widget _buildLoadingIndicator(BuildContext context, bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16, 
        vertical: isCompact ? 8 : 12,
      ),
      child: Row(
        children: [
          Container(
            width: isCompact ? 24 : 32,
            height: isCompact ? 24 : 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
            ),
            child: Center(
              child: Icon(
                Icons.smart_toy,
                size: isCompact ? 12 : 16,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(width: isCompact ? 8 : 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12, 
                vertical: isCompact ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: isCompact ? 12 : 16,
                    height: isCompact ? 12 : 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                    ),
                  ),
                  SizedBox(width: isCompact ? 6 : 8),
                  Text(
                    '正在思考...',
                    style: TextStyle(
                      fontSize: 12, // 小字体加载提示
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建返回按钮
  Widget _buildBackButton(BuildContext context, DeviceType deviceType) {
    final iconSize = deviceType == DeviceType.micro ? 14.0 :
                    deviceType == DeviceType.tiny ? 16.0 : 20.0;
    final buttonSize = deviceType == DeviceType.micro ? 28.0 :
                      deviceType == DeviceType.tiny ? 32.0 : 48.0;
    
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: Icon(
        Icons.arrow_back_ios,
        color: Colors.white.withValues(alpha: 0.9),
        size: iconSize,
      ),
      tooltip: '返回',
      constraints: BoxConstraints(
        minWidth: buttonSize,
        minHeight: buttonSize,
      ),
    );
  }
  
  /// 构建应用标题
  Widget _buildAppTitle(BuildContext context, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return Text(
          'L',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            fontSize: 12, // 小字体信息
          ),
        );
      case DeviceType.tiny:
        return Text(
          'Lumi',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
          ),
        );
      case DeviceType.small:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lumi Assistant',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      case DeviceType.standard:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assistant,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Lumi Assistant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '智能语音助手',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12, // 小字体信息
              ),
            ),
          ],
        );
    }
  }
  
  /// 构建连接状态
  Widget _buildConnectionStatus(BuildContext context, DeviceType deviceType) {
    if (deviceType == DeviceType.tiny) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConnectionStatusWidget(
            showDetails: false,
            onTap: () {},
          ),
        ],
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConnectionStatusWidget(
          showDetails: false,
          onTap: () {},
        ),
        const SizedBox(width: 6),
        HandshakeStatusWidget(
          showDetails: false,
          onTap: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  
  /// 发送消息
  /// 
  /// 参考Android客户端实现：发送消息前自动停止音频播放
  Future<void> _sendMessage(WidgetRef ref, String message) async {
    if (message.trim().isEmpty) return;
    
    try {
      // 🎯 核心功能：发送消息前自动打断正在播放的AI语音
      // 这是语音打断功能的核心实现，参考Android客户端的成功模式
      print('[ChatInterface] 发送消息前执行自动语音打断');
      
      final voiceInterruptService = ref.read(voiceInterruptServiceProvider);
      await voiceInterruptService.autoInterruptBeforeSend();
      
      // 发送消息
      ref.read(chatProvider.notifier).sendMessage(message);
      
    } catch (e) {
      print('[ChatInterface] 发送消息时的语音打断失败: $e');
      // 即使打断失败，也要继续发送消息
      ref.read(chatProvider.notifier).sendMessage(message);
    }
  }
  
  /// 获取设备类型
  DeviceType _getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final minDimension = size.width < size.height ? size.width : size.height;
    
    if (minDimension < 300) return DeviceType.micro;
    if (minDimension < 400) return DeviceType.tiny;
    if (minDimension < 600) return DeviceType.small;
    return DeviceType.standard;
  }
  
  /// 计算应用栏高度
  double _calculateAppBarHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return 35;
      case DeviceType.tiny:
        return 45;
      case DeviceType.small:
        return 55;
      case DeviceType.standard:
        return 70;
    }
  }
}
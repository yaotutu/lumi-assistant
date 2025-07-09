import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/connection_status_widget.dart';
import '../../widgets/handshake_status_widget.dart';
import '../../providers/chat_provider.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_background.dart';

/// 响应式聊天页面 - 支持多设备尺寸
class ChatPageResponsive extends HookConsumerWidget {
  const ChatPageResponsive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputController = useTextEditingController();
    final scrollController = useScrollController();
    final focusNode = useFocusNode();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 获取屏幕信息
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          final mediaQuery = MediaQuery.of(context);
          final padding = mediaQuery.padding;
          final keyboardHeight = mediaQuery.viewInsets.bottom;
          
          // 动态计算各部分高度
          final appBarHeight = _calculateAppBarHeight(screenHeight);
          final inputBarHeight = _calculateInputBarHeight(screenHeight);
          final availableHeight = screenHeight - appBarHeight - inputBarHeight - padding.top - padding.bottom - keyboardHeight;
          
          print('[ChatPage] 屏幕信息: ${screenWidth}x${screenHeight}, 可用高度: $availableHeight');
          
          return Stack(
            children: [
              // 背景层
              const ChatBackground(),
              
              // 主要内容层 - 使用SafeArea确保不被系统UI遮挡
              SafeArea(
                child: Column(
                  children: [
                    // 顶部应用栏 - 动态高度
                    SizedBox(
                      height: appBarHeight,
                      child: _buildResponsiveAppBar(context, screenWidth),
                    ),
                    
                    // 消息列表区域 - 使用Flexible而不是Expanded
                    Flexible(
                      child: Container(
                        height: availableHeight > 0 ? availableHeight : 100, // 最小高度保护
                        child: ChatMessageList(
                          scrollController: scrollController,
                        ),
                      ),
                    ),
                    
                    // 底部输入区域 - 动态高度
                    Container(
                      constraints: BoxConstraints(
                        minHeight: inputBarHeight,
                        maxHeight: screenHeight * 0.3, // 最大不超过屏幕30%
                      ),
                      child: ChatInputBar(
                        controller: inputController,
                        focusNode: focusNode,
                        scrollController: scrollController,
                        onSendMessage: (message) => _sendMessage(context, ref, message),
                        isCompact: _isCompactMode(screenHeight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 计算应用栏高度
  double _calculateAppBarHeight(double screenHeight) {
    if (screenHeight < 400) return 45; // 超小屏幕
    if (screenHeight < 600) return 55; // 小屏幕
    return 70; // 标准屏幕
  }

  /// 计算输入栏高度
  double _calculateInputBarHeight(double screenHeight) {
    if (screenHeight < 400) return 50; // 超小屏幕
    if (screenHeight < 600) return 60; // 小屏幕
    return 80; // 标准屏幕
  }

  /// 判断是否为紧凑模式
  bool _isCompactMode(double screenHeight) {
    return screenHeight < 600;
  }

  /// 构建响应式应用栏
  Widget _buildResponsiveAppBar(BuildContext context, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 400 ? 8.0 : 16.0,
        vertical: 8.0,
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white.withValues(alpha: 0.9),
              size: screenWidth < 400 ? 16 : 20,
            ),
            tooltip: '返回',
            constraints: BoxConstraints(
              minWidth: screenWidth < 400 ? 32 : 48,
              minHeight: screenWidth < 400 ? 32 : 48,
            ),
          ),
          
          // 应用信息 - 紧凑模式下简化显示
          Expanded(
            child: screenWidth < 400 
                ? _buildCompactTitle(context)
                : _buildFullTitle(context),
          ),
          
          // 连接状态指示器 - 小屏幕下简化
          if (screenWidth >= 300) ...[
            ConnectionStatusWidget(
              showDetails: false,
              onTap: () => _showConnectionDetails(context),
            ),
            const SizedBox(width: 4),
            HandshakeStatusWidget(
              showDetails: false,
              onTap: () => _showHandshakeDetails(context),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建紧凑标题
  Widget _buildCompactTitle(BuildContext context) {
    return Text(
      'Lumi',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 构建完整标题
  Widget _buildFullTitle(BuildContext context) {
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
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// 发送消息
  void _sendMessage(BuildContext context, WidgetRef ref, String message) {
    if (message.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(message);
  }

  /// 显示连接详情对话框
  void _showConnectionDetails(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: screenWidth < 500 ? screenWidth * 0.9 : 400,
          child: const ConnectionStatusCard(),
        ),
      ),
    );
  }

  /// 显示握手详情对话框
  void _showHandshakeDetails(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: screenWidth < 500 ? screenWidth * 0.9 : 400,
          child: const HandshakeStatusCard(),
        ),
      ),
    );
  }
}
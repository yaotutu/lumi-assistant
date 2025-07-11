import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/connection_status_widget.dart';
import '../../widgets/handshake_status_widget.dart';
import '../../widgets/error_banner.dart';
import '../../providers/chat_provider.dart';
import '../../../core/constants/device_constants.dart';
import '../../../data/models/chat_state.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_background.dart';

/// 响应式聊天页面 - 支持多设备尺寸（3-4寸小屏、平板、手表）
class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputController = useTextEditingController();
    final scrollController = useScrollController();
    final focusNode = useFocusNode();

    // 监听聊天状态错误
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        // 显示错误横幅
        ErrorBannerExtension.showErrorBanner(
          context,
          errorMessage: next.error!,
          onRetry: () => ref.read(chatProvider.notifier).clearError(),
        );
      }
    });

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
          
          // 设备类型判断
          final deviceType = _getDeviceType(screenWidth, screenHeight);
          final isCompact = deviceType != DeviceType.standard;
          
          // 动态计算各部分高度
          final appBarHeight = _calculateAppBarHeight(deviceType);
          final inputBarMinHeight = _calculateInputBarHeight(deviceType);
          final availableHeight = screenHeight - appBarHeight - inputBarMinHeight - padding.top - padding.bottom - keyboardHeight;
          
          print('[ChatPage] 设备: ${deviceType.name}, 屏幕: ${screenWidth}x${screenHeight}, 可用高度: $availableHeight');
          
          return Stack(
            children: [
              // 背景层
              const ChatBackground(),
              
              // 主要内容层 - 完全响应式设计
              SafeArea(
                child: Column(
                  children: [
                    // 顶部应用栏 - 响应式设计
                    _buildResponsiveAppBar(context, deviceType),
                    
                    // 消息列表区域 - 智能空间分配
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: availableHeight > 100 ? availableHeight : 100,
                        ),
                        child: ChatMessageList(
                          scrollController: scrollController,
                          isCompact: isCompact,
                        ),
                      ),
                    ),
                    
                    // 底部输入区域 - 响应式高度
                    ChatInputBar(
                      controller: inputController,
                      focusNode: focusNode,
                      scrollController: scrollController,
                      onSendMessage: (message) => _sendMessage(context, ref, message),
                      isCompact: isCompact,
                      deviceType: deviceType,
                      onVoiceStart: () {
                        print('[ChatPage] 语音录制开始');
                        // 可以在这里添加语音开始的UI反馈
                      },
                      onVoiceEnd: () {
                        print('[ChatPage] 语音录制结束');
                        // 可以在这里添加语音结束的UI反馈
                      },
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

  /// 设备类型枚举
  /// 
  /// 设备类型定义：
  /// - micro: 手表类设备 (< 300px)
  /// - tiny: 超小屏设备 (300-400px)  
  /// - small: 小屏设备 (400-600px)
  /// - standard: 标准屏设备 (> 600px)
  DeviceType _getDeviceType(double width, double height) {
    final minDimension = width < height ? width : height;
    
    if (minDimension < 300) return DeviceType.micro;    // 手表
    if (minDimension < 400) return DeviceType.tiny;     // 超小屏
    if (minDimension < 600) return DeviceType.small;    // 小屏
    return DeviceType.standard;                          // 标准屏
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

  /// 计算输入栏最小高度
  double _calculateInputBarHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return 40;
      case DeviceType.tiny:
        return 50;
      case DeviceType.small:
        return 60;
      case DeviceType.standard:
        return 80;
    }
  }

  /// 计算输入栏最大高度
  double _calculateInputBarMaxHeight(double screenHeight, DeviceType deviceType) {
    final ratio = deviceType == DeviceType.micro ? 0.4 : 0.3;
    return screenHeight * ratio;
  }

  /// 构建响应式应用栏
  Widget _buildResponsiveAppBar(BuildContext context, DeviceType deviceType) {
    
    return Container(
      height: _calculateAppBarHeight(deviceType),
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
          
          // 连接状态指示器 - 微型设备隐藏
          if (deviceType != DeviceType.micro) ...[
            _buildConnectionStatus(context, deviceType),
          ],
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
            fontSize: 12,
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
                fontSize: 12,
              ),
            ),
          ],
        );
    }
  }

  /// 构建连接状态
  Widget _buildConnectionStatus(BuildContext context, DeviceType deviceType) {
    if (deviceType == DeviceType.tiny) {
      // 小屏幕只显示一个状态指示器
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConnectionStatusWidget(
            showDetails: false,
            onTap: () => _showConnectionDetails(context),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConnectionStatusWidget(
          showDetails: false,
          onTap: () => _showConnectionDetails(context),
        ),
        const SizedBox(width: 6),
        HandshakeStatusWidget(
          showDetails: false,
          onTap: () => _showHandshakeDetails(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 发送消息
  void _sendMessage(BuildContext context, WidgetRef ref, String message) {
    if (message.trim().isEmpty) return;
    
    // 直接调用发送消息，错误会通过ref.listen处理
    ref.read(chatProvider.notifier).sendMessage(message);
  }

  /// 显示连接详情对话框
  void _showConnectionDetails(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenSize.width < 500 ? screenSize.width * 0.9 : 400,
            maxHeight: screenSize.height * 0.8,
          ),
          child: const ConnectionStatusCard(),
        ),
      ),
    );
  }

  /// 显示握手详情对话框
  void _showHandshakeDetails(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenSize.width < 500 ? screenSize.width * 0.9 : 400,
            maxHeight: screenSize.height * 0.8,
          ),
          child: const HandshakeStatusCard(),
        ),
      ),
    );
  }
}
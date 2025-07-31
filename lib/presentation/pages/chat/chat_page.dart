import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/common/error_banner.dart';
import '../../providers/chat_provider.dart';
import '../../../core/constants/device_constants.dart';
import '../../../data/models/chat/chat_state.dart';
import '../../widgets/chat/chat_interface.dart';
import 'widgets/chat_background.dart';

/// 响应式聊天页面 - 支持多设备尺寸（3-4寸小屏、平板、手表）
class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          
          // 设备类型判断
          final deviceType = _getDeviceType(screenWidth, screenHeight);
          final isLandscape = screenWidth > screenHeight;
          
          print('[ChatPage] 设备: ${deviceType.name}, 屏幕: ${screenWidth}x$screenHeight');
          
          return Stack(
            children: [
              // 背景层
              const ChatBackground(),
              
              // 主要内容层 - 使用统一的ChatInterface
              ChatInterface(
                mode: ChatInterfaceMode.full,
                deviceType: deviceType,
                isLandscape: isLandscape,
                enableVoiceInput: true,
                enableTextInput: true,
                onVoiceStart: () {
                  print('[ChatPage] 语音录制开始');
                },
                onVoiceEnd: () {
                  print('[ChatPage] 语音录制结束');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// 获取设备类型
  DeviceType _getDeviceType(double width, double height) {
    final minDimension = width < height ? width : height;
    
    if (minDimension < 300) return DeviceType.micro;    // 手表
    if (minDimension < 400) return DeviceType.tiny;     // 超小屏
    if (minDimension < 600) return DeviceType.small;    // 小屏
    return DeviceType.standard;                          // 标准屏
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/device_constants.dart';
import '../../../widgets/voice_input_widget.dart';
import '../../../providers/audio_stream_provider.dart';

/// 聊天输入栏组件 - 全新设计，白色背景黑色文字，支持键盘自动抬起，集成语音功能
class ChatInputBar extends HookConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final Function(String) onSendMessage;
  final bool isCompact;
  final DeviceType deviceType;
  final VoidCallback? onVoiceStart;
  final VoidCallback? onVoiceEnd;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.onSendMessage,
    this.isCompact = false,
    this.deviceType = DeviceType.standard,
    this.onVoiceStart,
    this.onVoiceEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听输入变化
    final hasText = useState(false);
    
    // 语音状态
    final audioStreamState = ref.watch(audioStreamProvider);
    
    useEffect(() {
      void listener() {
        hasText.value = controller.text.trim().isNotEmpty;
        print('[ChatInputBar] 文本变化: "${controller.text}" (hasText: ${hasText.value})');
      }
      
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    // 根据设备类型动态调整参数
    final padding = _getPaddingForDevice(deviceType);
    final inputHeight = _getInputHeightForDevice(deviceType);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98), // 高透明度白色背景
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 输入框
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: inputHeight,
                  maxHeight: inputHeight * 2.5, // 最大高度限制
                ),
                decoration: BoxDecoration(
                  color: Colors.white, // 纯白色背景
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: focusNode.hasFocus 
                        ? Colors.blue.withValues(alpha: 0.6) 
                        : Colors.grey.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 文本输入框
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: '输入消息...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500], // 灰色提示文字
                            fontSize: _getFontSizeForDevice(deviceType),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: _getVerticalPaddingForDevice(deviceType),
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.black87, // 深黑色文字，在白色背景下清晰可读
                          fontSize: _getFontSizeForDevice(deviceType),
                          fontWeight: FontWeight.w400,
                          height: 1.4, // 行高
                        ),
                        maxLines: _getMaxLinesForDevice(deviceType),
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            onSendMessage(value.trim());
                            controller.clear();
                          }
                        },
                      ),
                    ),
                    
                    // 附件按钮（预留）
                    if (deviceType != DeviceType.micro)
                      IconButton(
                        onPressed: () => _showAttachmentOptions(context),
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Colors.grey[600],
                          size: _getIconSizeForDevice(deviceType),
                        ),
                        tooltip: '添加附件',
                        constraints: BoxConstraints(
                          minWidth: _getButtonSizeForDevice(deviceType) * 0.8,
                          minHeight: _getButtonSizeForDevice(deviceType) * 0.8,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 发送按钮或语音按钮
            hasText.value 
                ? _buildSendButton(context)
                : _buildVoiceButton(context),
          ],
        ),
      ),
    );
  }

  /// 构建发送按钮
  Widget _buildSendButton(BuildContext context) {
    return GestureDetector(
      onTap: _sendMessage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _getButtonSizeForDevice(deviceType),
        height: _getButtonSizeForDevice(deviceType),
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: _getIconSizeForDevice(deviceType),
        ),
      ),
    );
  }

  /// 构建语音按钮
  Widget _buildVoiceButton(BuildContext context) {
    return VoiceInputWidget(
      size: _getButtonSizeForDevice(deviceType),
      onVoiceStart: onVoiceStart,
      onVoiceEnd: onVoiceEnd,
      onVoiceCancel: () {
        print('[ChatInputBar] 语音录制取消');
      },
    );
  }

  /// 根据设备类型获取Padding
  EdgeInsets _getPaddingForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return const EdgeInsets.all(8);
      case DeviceType.tiny:
        return const EdgeInsets.all(12);
      case DeviceType.small:
        return const EdgeInsets.all(16);
      case DeviceType.standard:
        return const EdgeInsets.all(20);
    }
  }

  /// 根据设备类型获取输入框高度
  double _getInputHeightForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return 36;
      case DeviceType.tiny:
        return 40;
      case DeviceType.small:
        return 44;
      case DeviceType.standard:
        return 48;
    }
  }

  /// 根据设备类型获取垂直内边距
  double _getVerticalPaddingForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return 8;
      case DeviceType.tiny:
        return 10;
      case DeviceType.small:
        return 12;
      case DeviceType.standard:
        return 14;
    }
  }

  /// 根据设备类型获取字体大小
  double _getFontSizeForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return 14;
      case DeviceType.tiny:
        return 15;
      case DeviceType.small:
        return 16;
      case DeviceType.standard:
        return 17;
    }
  }

  /// 根据设备类型获取最大行数
  int _getMaxLinesForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return 2;
      case DeviceType.tiny:
        return 3;
      case DeviceType.small:
        return 4;
      case DeviceType.standard:
        return 5;
    }
  }

  /// 根据设备类型获取按钮大小
  double _getButtonSizeForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return 36;
      case DeviceType.tiny:
        return 40;
      case DeviceType.small:
        return 44;
      case DeviceType.standard:
        return 48;
    }
  }

  /// 根据设备类型获取图标大小
  double _getIconSizeForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro:
        return 16;
      case DeviceType.tiny:
        return 18;
      case DeviceType.small:
        return 20;
      case DeviceType.standard:
        return 22;
    }
  }

  /// 发送消息
  void _sendMessage() {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      onSendMessage(text);
      controller.clear();
      
      // 滚动到底部
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// 显示附件选项
  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.image, color: Colors.grey[700]),
              title: Text('选择图片', style: TextStyle(color: Colors.grey[800])),
              onTap: () {
                Navigator.pop(context);
                _showFeatureNotAvailable(context, '图片发送');
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.grey[700]),
              title: Text('拍照', style: TextStyle(color: Colors.grey[800])),
              onTap: () {
                Navigator.pop(context);
                _showFeatureNotAvailable(context, '拍照');
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_file, color: Colors.grey[700]),
              title: Text('选择文件', style: TextStyle(color: Colors.grey[800])),
              onTap: () {
                Navigator.pop(context);
                _showFeatureNotAvailable(context, '文件发送');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示功能未实现提示
  void _showFeatureNotAvailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature功能将在后续里程碑中实现'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/constants/device_constants.dart';

/// 调试版本的聊天输入栏 - 用于诊断输入问题
class ChatInputBarDebug extends HookWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final Function(String) onSendMessage;
  final bool isCompact;
  final DeviceType deviceType;

  const ChatInputBarDebug({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.onSendMessage,
    this.isCompact = false,
    this.deviceType = DeviceType.standard,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = useState(false);
    final debugText = useState('');
    
    useEffect(() {
      void listener() {
        hasText.value = controller.text.trim().isNotEmpty;
        debugText.value = controller.text;
        print('[ChatInputBarDebug] 文本变化: "${controller.text}" (长度: ${controller.text.length})');
      }
      
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 调试信息面板
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.yellow, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🐛 调试信息',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '设备类型: ${deviceType.name}',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              Text(
                '输入内容: "${debugText.value}"',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              Text(
                '字符长度: ${debugText.value.length}',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              Text(
                '有文本: ${hasText.value}',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              Text(
                '字体大小: ${_getFontSizeForDevice(deviceType)}px',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              Text(
                '最大行数: ${_getMaxLinesForDevice(deviceType)}',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
        
        // 输入框主体
        Container(
          padding: _getPaddingForDevice(deviceType),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 输入框
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2), // 提高对比度用于调试
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.5), // 蓝色边框便于识别
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 文本输入框
                        Expanded(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: '输入消息...',
                              hintStyle: TextStyle(
                                color: Colors.grey[300],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.white, // 纯白色文字
                              fontSize: _getFontSizeForDevice(deviceType),
                              fontWeight: FontWeight.w500, // 加粗便于看清
                            ),
                            maxLines: _getMaxLinesForDevice(deviceType),
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onChanged: (value) {
                              print('[ChatInputBarDebug] onChanged: "$value"');
                            },
                            onSubmitted: (value) {
                              print('[ChatInputBarDebug] onSubmitted: "$value"');
                              if (value.trim().isNotEmpty) {
                                onSendMessage(value.trim());
                                controller.clear();
                              }
                            },
                          ),
                        ),
                        
                        // 附件按钮
                        IconButton(
                          onPressed: () => _showAttachmentOptions(context),
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          tooltip: '添加附件',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 发送按钮
                GestureDetector(
                  onTap: hasText.value ? _sendMessage : null,
                  child: Container(
                    width: _getButtonSizeForDevice(deviceType),
                    height: _getButtonSizeForDevice(deviceType),
                    decoration: BoxDecoration(
                      color: hasText.value
                          ? Colors.blue.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasText.value
                            ? Colors.blue.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      hasText.value ? Icons.send : Icons.mic,
                      color: Colors.white,
                      size: _getIconSizeForDevice(deviceType),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 复制原有的辅助方法
  EdgeInsets _getPaddingForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro: return const EdgeInsets.all(4);
      case DeviceType.tiny: return const EdgeInsets.all(8);
      case DeviceType.small: return const EdgeInsets.all(12);
      case DeviceType.standard: return const EdgeInsets.all(16);
    }
  }

  double _getFontSizeForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro: return 12;
      case DeviceType.tiny: return 14;
      case DeviceType.small: return 15;
      case DeviceType.standard: return 16;
    }
  }

  int _getMaxLinesForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro: return 2;
      case DeviceType.tiny: return 3;
      case DeviceType.small: return 4;
      case DeviceType.standard: return 5;
    }
  }

  double _getButtonSizeForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro: return 32;
      case DeviceType.tiny: return 36;
      case DeviceType.small: return 42;
      case DeviceType.standard: return 48;
    }
  }

  double _getIconSizeForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.micro: return 14;
      case DeviceType.tiny: return 16;
      case DeviceType.small: return 18;
      case DeviceType.standard: return 20;
    }
  }

  void _sendMessage() {
    final text = controller.text.trim();
    print('[ChatInputBarDebug] _sendMessage: "$text"');
    if (text.isNotEmpty) {
      onSendMessage(text);
      controller.clear();
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    print('[ChatInputBarDebug] 显示附件选项');
    // 简化的实现
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('附件功能调试中')),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/device_constants.dart';
import '../voice_input_widget.dart';

/// 聊天输入组件
/// 
/// 支持文本输入和语音输入
/// 可根据设备类型和模式进行响应式调整
class ChatInputSection extends HookConsumerWidget {
  /// 文本控制器
  final TextEditingController controller;
  
  /// 焦点节点
  final FocusNode focusNode;
  
  /// 滚动控制器
  final ScrollController scrollController;
  
  /// 设备类型
  final DeviceType deviceType;
  
  /// 是否为紧凑模式
  final bool isCompact;
  
  /// 是否启用语音输入
  final bool enableVoiceInput;
  
  /// 是否启用文本输入
  final bool enableTextInput;
  
  /// 发送消息回调
  final Function(String) onSendMessage;
  
  /// 语音开始回调
  final VoidCallback? onVoiceStart;
  
  /// 语音结束回调
  final VoidCallback? onVoiceEnd;

  const ChatInputSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.deviceType,
    required this.isCompact,
    required this.onSendMessage,
    this.enableVoiceInput = true,
    this.enableTextInput = true,
    this.onVoiceStart,
    this.onVoiceEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听输入变化
    final hasText = useState(false);
    
    // 语音状态 (目前未使用，为未来功能预留)
    // final audioStreamState = ref.watch(audioStreamProvider);
    
    useEffect(() {
      void listener() {
        hasText.value = controller.text.trim().isNotEmpty;
      }
      
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    // 根据设备类型动态调整参数
    final padding = _getPaddingForDevice(deviceType, isCompact);
    final inputHeight = _getInputHeightForDevice(deviceType, isCompact);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        boxShadow: isCompact ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _buildInputRow(context, hasText, inputHeight),
      ),
    );
  }
  
  /// 构建输入行
  Widget _buildInputRow(BuildContext context, ValueNotifier<bool> hasText, double inputHeight) {
    if (!enableTextInput && enableVoiceInput) {
      // 只显示语音按钮
      return Center(
        child: _buildVoiceButton(context),
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 输入框
        if (enableTextInput) ...[
          Expanded(
            child: _buildTextInput(context, inputHeight),
          ),
          const SizedBox(width: 12),
        ],
        
        // 发送按钮或语音按钮
        if (enableTextInput)
          hasText.value 
              ? _buildSendButton(context)
              : enableVoiceInput 
                  ? _buildVoiceButton(context)
                  : const SizedBox.shrink(),
      ],
    );
  }
  
  /// 构建文本输入框
  Widget _buildTextInput(BuildContext context, double inputHeight) {
    return Container(
      constraints: BoxConstraints(
        minHeight: inputHeight,
        maxHeight: inputHeight * (isCompact ? 2.0 : 2.5),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
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
                  color: Colors.grey[500],
                  fontSize: _getFontSizeForDevice(deviceType, isCompact),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10 : 12,
                  vertical: _getVerticalPaddingForDevice(deviceType, isCompact),
                ),
              ),
              style: TextStyle(
                color: Colors.black87,
                fontSize: _getFontSizeForDevice(deviceType, isCompact),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              maxLines: _getMaxLinesForDevice(deviceType, isCompact),
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
          
          // 附件按钮（仅在非紧凑模式且非微型设备显示）
          if (!isCompact && deviceType != DeviceType.micro)
            IconButton(
              onPressed: () => _showAttachmentOptions(context),
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.grey[600],
                size: _getIconSizeForDevice(deviceType, isCompact),
              ),
              tooltip: '添加附件',
              constraints: BoxConstraints(
                minWidth: _getButtonSizeForDevice(deviceType, isCompact) * 0.8,
                minHeight: _getButtonSizeForDevice(deviceType, isCompact) * 0.8,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建发送按钮
  Widget _buildSendButton(BuildContext context) {
    return GestureDetector(
      onTap: _sendMessage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _getButtonSizeForDevice(deviceType, isCompact),
        height: _getButtonSizeForDevice(deviceType, isCompact),
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
          size: _getIconSizeForDevice(deviceType, isCompact),
        ),
      ),
    );
  }

  /// 构建语音按钮
  Widget _buildVoiceButton(BuildContext context) {
    return VoiceInputWidget(
      size: _getVoiceButtonSizeForDevice(deviceType, isCompact),
      onVoiceStart: onVoiceStart,
      onVoiceEnd: onVoiceEnd,
      onVoiceCancel: () {
        print('[ChatInputSection] 语音录制取消');
      },
    );
  }

  /// 根据设备类型获取Padding
  EdgeInsets _getPaddingForDevice(DeviceType deviceType, bool isCompact) {
    final basePadding = switch (deviceType) {
      DeviceType.micro => 8.0,
      DeviceType.tiny => 12.0,
      DeviceType.small => 16.0,
      DeviceType.standard => 20.0,
    };
    
    return EdgeInsets.all(isCompact ? basePadding * 0.7 : basePadding);
  }

  /// 根据设备类型获取输入框高度
  double _getInputHeightForDevice(DeviceType deviceType, bool isCompact) {
    final baseHeight = switch (deviceType) {
      DeviceType.micro => 32.0,
      DeviceType.tiny => 36.0,
      DeviceType.small => 40.0,
      DeviceType.standard => 42.0,
    };
    
    return isCompact ? baseHeight * 0.9 : baseHeight;
  }

  /// 根据设备类型获取垂直内边距
  double _getVerticalPaddingForDevice(DeviceType deviceType, bool isCompact) {
    final basePadding = switch (deviceType) {
      DeviceType.micro => 6.0,
      DeviceType.tiny => 8.0,
      DeviceType.small => 10.0,
      DeviceType.standard => 12.0,
    };
    
    return isCompact ? basePadding * 0.8 : basePadding;
  }

  /// 根据设备类型获取字体大小
  double _getFontSizeForDevice(DeviceType deviceType, bool isCompact) {
    final baseFontSize = switch (deviceType) {
      DeviceType.micro => 14.0,
      DeviceType.tiny => 15.0,
      DeviceType.small => 16.0,
      DeviceType.standard => 17.0,
    };
    
    return isCompact ? baseFontSize * 0.9 : baseFontSize;
  }

  /// 根据设备类型获取最大行数
  int _getMaxLinesForDevice(DeviceType deviceType, bool isCompact) {
    final baseMaxLines = switch (deviceType) {
      DeviceType.micro => 2,
      DeviceType.tiny => 3,
      DeviceType.small => 4,
      DeviceType.standard => 5,
    };
    
    return isCompact ? (baseMaxLines * 0.6).ceil() : baseMaxLines;
  }

  /// 根据设备类型获取按钮大小
  double _getButtonSizeForDevice(DeviceType deviceType, bool isCompact) {
    final baseSize = switch (deviceType) {
      DeviceType.micro => 36.0,
      DeviceType.tiny => 40.0,
      DeviceType.small => 44.0,
      DeviceType.standard => 48.0,
    };
    
    return isCompact ? baseSize * 0.8 : baseSize;
  }

  /// 根据设备类型获取图标大小
  double _getIconSizeForDevice(DeviceType deviceType, bool isCompact) {
    final baseSize = switch (deviceType) {
      DeviceType.micro => 16.0,
      DeviceType.tiny => 18.0,
      DeviceType.small => 20.0,
      DeviceType.standard => 22.0,
    };
    
    return isCompact ? baseSize * 0.9 : baseSize;
  }

  /// 根据设备类型获取语音按钮大小
  double _getVoiceButtonSizeForDevice(DeviceType deviceType, bool isCompact) {
    final baseSize = switch (deviceType) {
      DeviceType.micro => 108.0,  // 36 * 3
      DeviceType.tiny => 120.0,   // 40 * 3
      DeviceType.small => 132.0,  // 44 * 3
      DeviceType.standard => 144.0, // 48 * 3
    };
    
    return isCompact ? baseSize * 0.6 : baseSize;
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
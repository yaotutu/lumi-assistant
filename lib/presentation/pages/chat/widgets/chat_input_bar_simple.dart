import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 简化版聊天输入栏 - 专注于解决输入可见性问题
class ChatInputBarSimple extends HookWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSendMessage;

  const ChatInputBarSimple({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = useState(false);
    
    useEffect(() {
      void listener() {
        hasText.value = controller.text.trim().isNotEmpty;
        print('[ChatInputBarSimple] 文本: "${controller.text}" (长度: ${controller.text.length})');
      }
      
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800], // 深灰色背景，提供对比
        border: Border(
          top: BorderSide(color: Colors.grey[600]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 输入框
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white, // 白色背景
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(
                    color: Colors.black, // 黑色文字
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      onSendMessage(value.trim());
                      controller.clear();
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 发送按钮
            GestureDetector(
              onTap: hasText.value ? _sendMessage : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasText.value ? Colors.blue : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasText.value ? Icons.send : Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = controller.text.trim();
    print('[ChatInputBarSimple] 发送: "$text"');
    if (text.isNotEmpty) {
      onSendMessage(text);
      controller.clear();
    }
  }
}
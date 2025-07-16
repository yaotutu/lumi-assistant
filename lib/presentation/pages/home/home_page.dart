import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../chat/chat_page.dart';
import 'widgets/background_layer.dart';
import 'widgets/floating_chat_button.dart';
import '../../widgets/floating_chat/floating_chat_widget.dart';

/// 应用主页 - 极简背景设计
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 统一背景
          const BackgroundLayer(),
          
          // 顶部状态 - 极简
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // 应用名
                Text(
                  'Lumi Assistant',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // 连接状态
                Icon(
                  Icons.wifi,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ),
          
          // 时间 - 直接显示在背景上
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: StreamBuilder<DateTime>(
              stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
              initialData: DateTime.now(),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();
                return Column(
                  children: [
                    Text(
                      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 56,
                        fontWeight: FontWeight.w100,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(now),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // 浮动聊天按钮
          Positioned(
            bottom: 140,
            right: 140, // 调整位置，避免与悬浮聊天图标重叠
            child: FloatingChatButton(
              onTap: () => _startChat(context),
              size: 80.0,
              icon: Icons.chat_bubble_outline,
            ),
          ),
          
          // 测试按钮 - 暂时禁用以排除干扰
          // Positioned(
          //   bottom: 80,
          //   left: 24,
          //   child: FloatingActionButton.small(
          //     heroTag: "test_character",
          //     onPressed: () => _testVirtualCharacter(context),
          //     backgroundColor: Colors.orange.withValues(alpha: 0.8),
          //     foregroundColor: Colors.white,
          //     child: const Icon(Icons.bug_report, size: 16),
          //   ),
          // ),
          
          // // 统一测试按钮
          // Positioned(
          //   bottom: 80,
          //   left: 80,
          //   child: FloatingActionButton.small(
          //     heroTag: "test_unified",
          //     onPressed: () => _testUnifiedCharacter(context),
          //     backgroundColor: Colors.green.withValues(alpha: 0.8),
          //     foregroundColor: Colors.white,
          //     child: const Icon(Icons.widgets, size: 16),
          //   ),
          // ),
          
          // // 简化测试按钮
          // Positioned(
          //   bottom: 80,
          //   left: 136,
          //   child: FloatingActionButton.small(
          //     heroTag: "test_simple",
          //     onPressed: () => _testSimpleCharacter(context),
          //     backgroundColor: Colors.purple.withValues(alpha: 0.8),
          //     foregroundColor: Colors.white,
          //     child: const Icon(Icons.phone_android, size: 16),
          //   ),
          // ),
          
          // // 直接渲染器测试按钮
          // Positioned(
          //   bottom: 80,
          //   left: 192,
          //   child: FloatingActionButton.small(
          //     heroTag: "test_direct",
          //     onPressed: () => _testDirectRenderer(context),
          //     backgroundColor: Colors.red.withValues(alpha: 0.8),
          //     foregroundColor: Colors.white,
          //     child: const Icon(Icons.build, size: 16),
          //   ),
          // ),
          
          // 悬浮聊天组件 - 使用响应式参数
          const FloatingChatWidget(
            initialState: FloatingChatState.collapsed,
            enableBackgroundBlur: true,
            // 其他参数将通过ScreenUtils自动计算
          ),
        ],
      ),
    );
  }
  
  /// 格式化日期
  String _formatDate(DateTime time) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    return '${time.year}年${months[time.month - 1]}${time.day}日 ${weekdays[time.weekday % 7]}';
  }


  /// 开始聊天
  void _startChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatPage(),
      ),
    );
  }

  // 测试方法已移除，清理主页面界面
}
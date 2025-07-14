import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../chat/chat_page.dart';
import 'widgets/background_layer.dart';
import 'widgets/floating_actions.dart';

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
          
          // 浮动按钮
          FloatingActions(
            onSettingsTap: () => _showSettings(context),
            onMainActionTap: () => _startChat(context),
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

  /// 显示设置
  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('设置功能将在后续里程碑中实现'),
        action: SnackBarAction(
          label: '确定',
          onPressed: () {},
        ),
      ),
    );
  }

  /// 开始聊天
  void _startChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatPage(),
      ),
    );
  }
}
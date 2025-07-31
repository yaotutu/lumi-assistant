import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/gotify_provider.dart';
import '../../widgets/notification_bubble.dart';
import '../../../domain/models/notification_types.dart';

/// Gotify 测试页面
/// 
/// 职责：测试 Gotify 服务集成和通知显示功能
/// 功能：
/// 1. 显示 Gotify 连接状态
/// 2. 手动启动/停止 Gotify 服务
/// 3. 查看通知气泡效果
class GotifyTestPage extends ConsumerWidget {
  const GotifyTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听 Gotify 启用状态
    final isEnabled = ref.watch(gotifyEnabledProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Gotify 集成测试'),
        backgroundColor: Colors.grey[850],
      ),
      body: Stack(
        children: [
          // 主内容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gotify 服务开关
                Card(
                  color: Colors.grey[850],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Gotify 服务',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '启用 Gotify：',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Switch(
                              value: isEnabled,
                              onChanged: (value) async {
                                // 更新启用状态
                                ref.read(gotifyEnabledProvider.notifier).state = value;
                                
                                // 启动或停止服务
                                final service = ref.read(gotifyServiceProvider);
                                if (value) {
                                  await service.start();
                                } else {
                                  await service.stop();
                                }
                              },
                              activeColor: Colors.teal,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 测试通知按钮
                ElevatedButton.icon(
                  onPressed: () {
                    // 添加测试通知
                    NotificationBubbleManager.instance.addGotifyNotification(
                      '这是一条来自 Gotify 的测试通知',
                      title: '测试通知',
                      level: NotificationLevel.normal,
                    );
                  },
                  icon: const Icon(Icons.notifications),
                  label: const Text('发送测试通知'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 说明文字
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    '请确保已在 gotify_service.dart 中配置正确的服务器地址和令牌',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // 通知气泡
          ListenableBuilder(
            listenable: NotificationBubbleManager.instance,
            builder: (context, child) {
              return const NotificationBubble(
                alignment: Alignment.centerLeft,
                size: 60,
                margin: EdgeInsets.only(left: 16),
              );
            },
          ),
        ],
      ),
    );
  }
}
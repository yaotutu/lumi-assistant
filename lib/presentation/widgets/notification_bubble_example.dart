import 'package:flutter/material.dart';
import 'notification_bubble.dart';
import '../../data/models/notification/notification_types.dart';

/// 通知气泡使用示例
/// 
/// 展示如何在应用中集成通知气泡组件
/// 
/// 使用方法：
/// 1. 在需要显示通知的页面中添加 NotificationBubble 组件
/// 2. 使用 NotificationBubbleManager.instance 添加通知
/// 
/// 示例：
/// ```dart
/// // 在页面的 Stack 中添加通知气泡
/// Stack(
///   children: [
///     // 页面主内容
///     YourMainContent(),
///     
///     // 通知气泡 - 位于左侧
///     ListenableBuilder(
///       listenable: NotificationBubbleManager.instance,
///       builder: (context, child) {
///         return const NotificationBubble(
///           alignment: Alignment.centerLeft,
///           size: 60,
///           margin: EdgeInsets.only(left: 16),
///         );
///       },
///     ),
///   ],
/// )
/// ```
/// 
/// 添加通知示例：
/// ```dart
/// // 添加 Gotify 通知
/// NotificationBubbleManager.instance.addGotifyNotification(
///   '服务器备份完成',
///   title: 'Backup',
///   level: NotificationLevel.normal,
///   source: NotificationSource(
///     id: 'gotify_server_1',
///     name: 'Main Server',
///     type: NotificationType.gotify,
///   ),
///   onTap: () => print('查看备份详情'),
/// );
/// 
/// // 添加紧急天气警告
/// NotificationBubbleManager.instance.addWeatherNotification(
///   '暴雨红色预警！请立即采取防护措施',
///   title: '天气预警',
///   level: NotificationLevel.urgent,
/// );
/// 
/// // 添加系统更新通知
/// NotificationBubbleManager.instance.addSystemNotification(
///   '系统更新可用，包含重要安全修复',
///   title: '更新',
///   level: NotificationLevel.high,
/// );
/// 
/// // 添加 IoT 设备通知
/// NotificationBubbleManager.instance.addIoTNotification(
///   '客厅温度过高，空调已自动开启',
///   title: '智能家居',
/// );
/// 
/// // 添加安全警告
/// NotificationBubbleManager.instance.addSecurityNotification(
///   '检测到异常登录尝试',
///   title: '安全警告',
///   level: NotificationLevel.urgent,
/// );
/// 
/// // 添加自定义通知
/// NotificationBubbleManager.instance.addNotification(
///   message: '自定义消息内容',
///   title: '自定义标题',
///   type: NotificationType.custom,
///   level: NotificationLevel.low,
///   icon: Icons.star,
///   color: Colors.purple,
///   onTap: () => print('自定义操作'),
/// );
/// ```
class NotificationBubbleExample extends StatelessWidget {
  const NotificationBubbleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          // 主内容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '通知气泡集成示例',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                // 测试按钮组
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        NotificationBubbleManager.instance.addSystemNotification(
                          '这是一条普通测试通知',
                          title: '测试',
                          level: NotificationLevel.normal,
                        );
                      },
                      icon: const Icon(Icons.info),
                      label: const Text('普通通知'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        NotificationBubbleManager.instance.addSecurityNotification(
                          '检测到可疑活动！',
                          title: '安全警告',
                          level: NotificationLevel.urgent,
                        );
                      },
                      icon: const Icon(Icons.warning),
                      label: const Text('紧急通知'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        NotificationBubbleManager.instance.addWeatherNotification(
                          '今天多云，适宜出行',
                          title: '天气',
                          level: NotificationLevel.low,
                        );
                      },
                      icon: const Icon(Icons.wb_sunny),
                      label: const Text('低级别通知'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 通知气泡 - 集成示例
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
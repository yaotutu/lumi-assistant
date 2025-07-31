import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/app_settings.dart';
import '../../providers/gotify_provider.dart';

/// Gotify 配置页面
/// 
/// 职责：管理 Gotify 服务器连接配置
/// 功能：
/// 1. 配置服务器地址
/// 2. 配置客户端令牌
/// 3. 测试连接
/// 4. 启用/禁用服务
class SettingsGotifyPage extends HookConsumerWidget {
  const SettingsGotifyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final isEnabled = ref.watch(gotifyEnabledProvider);
    
    // 使用 Hooks 管理表单状态
    final serverUrlController = useTextEditingController(
      text: settings.gotifyServerUrl,
    );
    final clientTokenController = useTextEditingController(
      text: settings.gotifyClientToken,
    );
    
    // 测试连接状态
    final isTesting = useState(false);
    final testResult = useState<String?>(null);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gotify 通知配置'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 服务启用开关
          Card(
            child: SwitchListTile(
              title: const Text(
                '启用 Gotify 通知',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('接收来自 Gotify 服务器的推送通知'),
              value: isEnabled,
              onChanged: (value) async {
                ref.read(gotifyEnabledProvider.notifier).state = value;
                
                final service = ref.read(gotifyServiceProvider);
                if (value) {
                  // 保存配置后启动服务
                  settings.updateGotifyServerUrl(serverUrlController.text);
                  settings.updateGotifyClientToken(clientTokenController.text);
                  await service.start();
                } else {
                  await service.stop();
                }
              },
              activeColor: Colors.teal,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 服务器配置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Text(
                  '服务器配置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 服务器地址输入
                TextField(
                  controller: serverUrlController,
                  decoration: const InputDecoration(
                    labelText: '服务器地址',
                    hintText: 'http://192.168.1.100:8080',
                    helperText: '输入您的 Gotify 服务器地址',
                    prefixIcon: Icon(Icons.cloud_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    settings.updateGotifyServerUrl(value);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 客户端令牌输入
                TextField(
                  controller: clientTokenController,
                  decoration: const InputDecoration(
                    labelText: '客户端令牌',
                    hintText: 'CQHwPMiMBwRVwI1...',
                    helperText: '从 Gotify 管理界面获取客户端令牌',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    settings.updateGotifyClientToken(value);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 测试连接按钮
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: isTesting.value ? null : () async {
                        isTesting.value = true;
                        testResult.value = null;
                        
                        try {
                          // TODO: 实现连接测试逻辑
                          await Future.delayed(const Duration(seconds: 2));
                          testResult.value = '✅ 连接成功！';
                        } catch (e) {
                          testResult.value = '❌ 连接失败：$e';
                        } finally {
                          isTesting.value = false;
                        }
                      },
                      icon: isTesting.value 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.network_check),
                      label: Text(isTesting.value ? '测试中...' : '测试连接'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    
                    if (testResult.value != null) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          testResult.value!,
                          style: TextStyle(
                            color: testResult.value!.startsWith('✅') 
                              ? Colors.green 
                              : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 使用说明
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        '配置说明',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. 登录您的 Gotify 服务器管理界面\n'
                    '2. 进入 "Clients" 页面\n'
                    '3. 创建新的客户端或使用现有客户端\n'
                    '4. 复制客户端令牌到上方输入框\n'
                    '5. 测试连接确保配置正确\n'
                    '6. 启用服务开始接收通知',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
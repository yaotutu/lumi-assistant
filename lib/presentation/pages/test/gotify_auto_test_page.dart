import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/services/gotify_auth_service.dart';
import '../../../core/config/app_settings.dart';
import '../../providers/gotify_provider.dart';
import '../../widgets/notification_bubble.dart';

/// Gotify 自动测试页面
/// 
/// 自动创建客户端并配置令牌
class GotifyAutoTestPage extends ConsumerStatefulWidget {
  const GotifyAutoTestPage({super.key});

  @override
  ConsumerState<GotifyAutoTestPage> createState() => _GotifyAutoTestPageState();
}

class _GotifyAutoTestPageState extends ConsumerState<GotifyAutoTestPage> {
  bool _isLoading = false;
  String? _clientToken;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // 页面加载时自动执行
    _autoSetup();
  }
  
  Future<void> _autoSetup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 从设置中获取配置
      final settings = AppSettings.instance;
      final serverUrl = settings.gotifyServerUrl;
      
      if (serverUrl.isEmpty) {
        setState(() {
          _errorMessage = '请先在设置中配置 Gotify 服务器地址';
        });
        return;
      }
      
      // 使用默认凭据尝试创建客户端
      final token = await GotifyAuthService.createClientAndGetToken(
        serverUrl: serverUrl,
        username: 'admin',  // 默认用户名
        password: 'admin',  // 默认密码
        clientName: 'Lumi Assistant Test',
      );
      
      if (token != null) {
        setState(() {
          _clientToken = token;
        });
        
        // 保存令牌到设置
        await settings.updateGotifyClientToken(token);
        
        // 启动 Gotify 服务
        ref.read(gotifyEnabledProvider.notifier).state = true;
        await ref.read(gotifyServiceProvider).start();
        
      } else {
        setState(() {
          _errorMessage = '无法获取客户端令牌，请检查网络连接和凭据';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '设置失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Gotify 自动配置'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text('正在自动配置 Gotify...'),
                      ] else if (_errorMessage != null) ...[
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '配置失败',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[400]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _autoSetup,
                          icon: const Icon(Icons.refresh),
                          label: const Text('重试'),
                        ),
                      ] else if (_clientToken != null) ...[
                        Icon(
                          Icons.check_circle,
                          size: 48,
                          color: Colors.green[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '配置成功！',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '客户端令牌：',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      _clientToken!,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: _clientToken!),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('令牌已复制到剪贴板'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Gotify 服务已启动，现在可以接收通知了！',
                          style: TextStyle(color: Colors.green),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '测试方法：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '1. 登录 Gotify 管理界面\n'
                            '2. 在 Applications 页面使用任意应用令牌发送消息\n'
                            '3. 通知会显示在左侧的通知气泡中',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../providers/connection_provider.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/handshake_status_widget.dart';

/// 应用主页
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用Hook管理本地状态
    final currentTime = useState(DateTime.now());
    
    // 定时更新时间
    useEffect(() {
      final timer = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now())
          .listen((time) => currentTime.value = time);
      
      return timer.cancel;
    }, []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部应用标题和连接状态
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assistant,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // 连接状态指示器
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConnectionStatusWidget(
                              showDetails: true,
                              onTap: () => _showConnectionDetails(context),
                            ),
                            const SizedBox(width: 8),
                            HandshakeStatusWidget(
                              showDetails: true,
                              onTap: () => _showHandshakeDetails(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 中央内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 添加一些顶部间距
                      const SizedBox(height: 20),
                      
                      // 主要信息卡片
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 成功图标
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              
                              // 标题
                              Text(
                                '项目初始化成功！',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              
                              // 时间显示
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, 
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatTime(currentTime.value),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // 里程碑状态
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '里程碑3已完成',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Hello握手流程验证成功\nWebSocket连接正常工作',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.green[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 准备下一步提示
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '准备开始里程碑4：基础UI框架',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // 添加一些底部间距
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              // 底部状态信息
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'v${AppConstants.appVersion}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '里程碑 4/10',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 显示连接详情对话框
  void _showConnectionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: const ConnectionStatusCard(),
        ),
      ),
    );
  }

  /// 显示握手详情对话框
  void _showHandshakeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: const HandshakeStatusCard(),
        ),
      ),
    );
  }

  /// 格式化时间显示
  String _formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
           '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
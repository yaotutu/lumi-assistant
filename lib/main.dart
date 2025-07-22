import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/services/app_initializer.dart';
import 'core/services/app_configuration.dart';
import 'core/config/app_settings.dart';
import 'presentation/pages/home/home_page.dart';

/// Lumi Assistant 应用入口点
/// 
/// 职责：应用启动和根组件创建
/// 架构：使用服务化架构，分离关注点
void main() async {
  // Flutter框架初始化，必须在所有异步操作前调用
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 执行应用初始化流程（日志、性能优化、Opus库等）
    await AppInitializer.instance.initialize();
    
    // 启动应用
    runApp(
      // Riverpod状态管理作用域
      const ProviderScope(
        child: LumiAssistantApp(),
      ),
    );
    
  } catch (error) {
    // 应用初始化失败，显示错误信息
    print('❌ 应用启动失败: $error');
    
    // 启动一个最小化的错误显示应用
    runApp(_buildErrorApp(error));
  }
}

/// 构建错误显示应用
/// 
/// 用途：当应用初始化失败时，显示用户友好的错误界面
/// 参数：[error] 错误信息
Widget _buildErrorApp(Object error) {
  return MaterialApp(
    title: 'Lumi Assistant - 启动失败',
    home: Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 错误图标
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade600,
              ),
              const SizedBox(height: 16),
              
              // 错误标题
              Text(
                '应用启动失败',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 12),
              
              // 错误详情
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 24),
              
              // 重启按钮
              ElevatedButton(
                onPressed: () {
                  // 重置初始化状态并重启应用
                  AppInitializer.instance.reset();
                  main();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('重新启动'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Lumi Assistant 应用根组件
/// 
/// 职责：
/// - 提供MaterialApp配置
/// - 管理全局应用状态
/// - 执行应用预初始化
class LumiAssistantApp extends ConsumerWidget {
  const LumiAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取应用设置
    final settings = ref.watch(appSettingsProvider);
    
    // 执行应用预初始化（异步，不阻塞UI）
    Future.microtask(() {
      AppPreInitializer.instance.preInitialize(ref);
    });
    
    // 使用配置服务构建MaterialApp
    return AppConfiguration.instance.getMaterialApp(
      settings: settings,
      child: const HomePage(),
    );
  }
}
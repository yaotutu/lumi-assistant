import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:opus_dart/opus_dart.dart';

import 'presentation/themes/app_theme.dart';
import 'presentation/pages/home/home_page.dart';
import 'core/constants/app_constants.dart';
import 'core/config/app_settings.dart';

/// 应用入口点
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 性能优化：系统级设置
  await _applyPerformanceOptimizations();
  
  // 性能优化：异步初始化Opus库，不阻塞应用启动
  _initializeOpusAsync();
  
  runApp(
    const ProviderScope(
      child: LumiAssistantApp(),
    ),
  );
}

/// 应用性能优化设置
Future<void> _applyPerformanceOptimizations() async {
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  // 简化：直接禁用调试日志（主要配置在动态配置中处理）
  print('[性能] 调试日志已禁用');
}

/// 性能优化：异步初始化Opus库
Future<void> _initializeOpusAsync() async {
  try {
    initOpus(await opus_flutter.load());
    print('[主程序] Opus初始化成功: ${getOpusVersion()}');
  } catch (e) {
    print('[主程序] Opus初始化失败: $e');
    // 启动后续的重试机制或降级处理
  }
}

/// Lumi Assistant应用根组件
class LumiAssistantApp extends ConsumerWidget {
  const LumiAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // 简化：禁用性能监控（主要配置在动态配置中处理）
      showPerformanceOverlay: false,
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
      showSemanticsDebugger: false,
      
      // 全局字体缩放：使用配置系统的fontScale
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // 使用配置系统的字体缩放比例
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child!,
        );
      },
      
      // 主题配置（已优化性能）
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: ThemeMode.system,
      
      // 首页
      home: const HomePage(),
    );
  }
}
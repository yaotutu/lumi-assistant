import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:opus_dart/opus_dart.dart';

import 'presentation/themes/app_theme.dart';
import 'presentation/pages/home/home_page.dart';
import 'core/constants/app_constants.dart';

/// 应用入口点
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Opus库 - 参考xiaozhi-android-client
  try {
    initOpus(await opus_flutter.load());
    print('[主程序] Opus初始化成功: ${getOpusVersion()}');
  } catch (e) {
    print('[主程序] Opus初始化失败: $e');
  }
  
  runApp(
    const ProviderScope(
      child: LumiAssistantApp(),
    ),
  );
}

/// Lumi Assistant应用根组件
class LumiAssistantApp extends StatelessWidget {
  const LumiAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // 主题配置
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: ThemeMode.system,
      
      // 首页
      home: const HomePage(),
    );
  }
}
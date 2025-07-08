import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'presentation/themes/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'core/constants/app_constants.dart';

/// 应用入口点
void main() {
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
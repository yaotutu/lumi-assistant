import 'package:flutter/material.dart';

/// 无动画页面切换构建器 - 性能优化
class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 直接返回child，不添加任何动画
    return child;
  }
}

/// 应用主题配置
class AppTheme {
  /// 主色调
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  
  /// 辅助色
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  
  /// 背景色
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  /// 文字色
  static const Color textColorPrimary = Color(0xFF212121);
  static const Color textColorSecondary = Color(0xFF757575);
  
  /// 错误色
  static const Color errorColor = Color(0xFFB00020);
  
  /// 成功色
  static const Color successColor = Color(0xFF4CAF50);
  
  /// 警告色
  static const Color warningColor = Color(0xFFFF9800);
  
  /// 获取亮色主题 - 性能优化版本（关闭动画和Material效果）
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: false, // 主题配置通过动态配置管理
      brightness: Brightness.light,
      
      // 色彩方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      
      // 性能优化：关闭所有动画
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const _NoAnimationPageTransitionsBuilder(),
          TargetPlatform.iOS: const _NoAnimationPageTransitionsBuilder(),
        },
      ),
      
      // 关闭Material波纹效果
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      // AppBar主题 - 去除阴影
      appBarTheme: const AppBarTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textColorPrimary,
      ),
      
      // 卡片主题 - 去除阴影
      cardTheme: CardTheme(
        elevation: 0, // 关闭阴影
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      
      // 输入框主题 - 简化
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: surfaceColor,
      ),
      
      // 按钮主题 - 去除阴影
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0, // 关闭阴影
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // 浮动按钮主题 - 去除阴影
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0, // 关闭阴影
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        shape: CircleBorder(),
      ),
      
      // 关闭对话框动画
      dialogTheme: const DialogTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      
      // 关闭底部表单动画
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }
  
  /// 获取暗色主题 - 性能优化版本（关闭动画和Material效果）
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: false, // 主题配置通过动态配置管理
      brightness: Brightness.dark,
      
      // 色彩方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      
      // 性能优化：关闭所有动画
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const _NoAnimationPageTransitionsBuilder(),
          TargetPlatform.iOS: const _NoAnimationPageTransitionsBuilder(),
        },
      ),
      
      // 关闭Material波纹效果
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      // AppBar主题 - 去除阴影
      appBarTheme: const AppBarTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      
      // 卡片主题 - 去除阴影
      cardTheme: CardTheme(
        elevation: 0, // 关闭阴影
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade700, width: 1),
        ),
      ),
      
      // 输入框主题 - 简化
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
      
      // 按钮主题 - 去除阴影
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0, // 关闭阴影
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // 浮动按钮主题 - 去除阴影
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0, // 关闭阴影
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        shape: CircleBorder(),
      ),
      
      // 关闭对话框动画
      dialogTheme: const DialogTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      
      // 关闭底部表单动画
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }
}
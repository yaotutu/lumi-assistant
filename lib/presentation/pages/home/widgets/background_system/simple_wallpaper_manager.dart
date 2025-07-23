import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/config/app_settings.dart';
import '../../../../../core/config/wallpaper_config.dart';
import 'builtin_wallpapers.dart';

/// 简化的壁纸管理器
/// 
/// 职责：
/// - 管理两种背景模式：内置壁纸、自定义图片
/// - 提供统一的背景渲染接口
/// - 支持多种内置壁纸选择
/// 
/// 设计理念：
/// - 丰富选择：多种内置壁纸和自定义图片
/// - 专业分类：内置壁纸和用户图片分开管理
/// - 易于扩展：新增壁纸只需要在BuiltinWallpapers中添加
/// - 用户控制：支持用户上传自定义壁纸
class SimpleWallpaperManager extends ConsumerWidget {
  /// 构造函数
  const SimpleWallpaperManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取当前壁纸设置
    final settings = ref.watch(appSettingsProvider);
    final wallpaperMode = settings.wallpaperMode;
    
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: _buildWallpaperByMode(wallpaperMode, settings),
    );
  }
  
  /// 根据模式构建对应的壁纸
  /// 
  /// 参数：
  /// - [mode] 当前壁纸模式
  /// - [settings] 应用设置实例
  /// 
  /// 返回：对应模式的壁纸Widget
  Widget _buildWallpaperByMode(WallpaperMode mode, AppSettings settings) {
    switch (mode) {
      case WallpaperMode.builtinWallpaper:
        return BuiltinWallpapers.createWallpaper(settings.builtinWallpaperType);
        
      case WallpaperMode.customImage:
        return _buildCustomImage(
          settings.customWallpaperPath, 
          settings.enableWallpaperOverlay,
        );
    }
  }
  
  
  /// 构建自定义图片背景
  /// 
  /// 参数：
  /// - [imagePath] 用户选择的图片路径
  /// - [enableOverlay] 是否启用遮罩层
  /// 
  /// 智能显示算法：
  /// - 使用BoxFit.cover保持图片比例
  /// - 确保图片完全填充屏幕，无黑边
  /// - 可能会裁剪图片边缘，但会智能选择最佳显示区域
  Widget _buildCustomImage(String? imagePath, bool enableOverlay) {
    // 如果没有设置自定义图片，回退到默认内置壁纸
    if (imagePath == null || imagePath.isEmpty) {
      return BuiltinWallpapers.createWallpaper(BuiltinWallpaperType.blueGradient);
    }
    
    final imageFile = File(imagePath);
    
    // 如果文件不存在，回退到默认内置壁纸
    if (!imageFile.existsSync()) {
      return BuiltinWallpapers.createWallpaper(BuiltinWallpaperType.blueGradient);
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取屏幕尺寸，用于优化图片显示
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        
        return Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(imageFile),
              // 智能显示算法：使用cover保持图片比例并填充整个屏幕
              // cover会智能选择图片的中心区域进行显示，避免显示"一个角"的问题
              fit: BoxFit.cover,
              
              // 使用高质量的图片过滤器，提升图片清晰度
              filterQuality: FilterQuality.high,
              
              // 根据用户设置决定是否添加遮罩层
              colorFilter: enableOverlay 
                ? ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.2), // 轻微遮罩，提升文字可读性
                    BlendMode.darken,
                  )
                : null,
            ),
          ),
        );
      },
    );
  }
  
}
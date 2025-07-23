import 'package:flutter/material.dart';
import '../../../../../core/config/wallpaper_config.dart';
import 'animated_starfield_background.dart';

/// 内置壁纸管理器
/// 
/// 职责：
/// - 根据内置壁纸类型创建对应的背景组件
/// - 提供各种预设的美观壁纸
/// 
/// 支持的壁纸类型：
/// - 经典蓝色渐变
/// - 动态星空
/// - 深紫渐变
/// - 暖色渐变
class BuiltinWallpapers {
  /// 根据内置壁纸类型创建对应的Widget
  /// 
  /// 参数：
  /// - [type] 内置壁纸类型
  /// 
  /// 返回：对应的壁纸Widget
  static Widget createWallpaper(BuiltinWallpaperType type) {
    switch (type) {
      case BuiltinWallpaperType.blueGradient:
        return const _BlueGradientWallpaper();
        
      case BuiltinWallpaperType.animatedStarfield:
        return const AnimatedStarfieldBackground();
        
      case BuiltinWallpaperType.purpleGradient:
        return const _PurpleGradientWallpaper();
        
      case BuiltinWallpaperType.warmGradient:
        return const _WarmGradientWallpaper();
    }
  }
}

/// 经典蓝色渐变壁纸
/// 
/// 深蓝到浅蓝的经典渐变，适合长时间使用
class _BlueGradientWallpaper extends StatelessWidget {
  /// 构造函数
  const _BlueGradientWallpaper();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E), // 深蓝色
            Color(0xFF3949AB), // 中蓝色  
            Color(0xFF5C6BC0), // 浅蓝色
            Color(0xFF7E57C2), // 淡紫色
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

/// 深紫渐变壁纸
/// 
/// 优雅的紫色系渐变，营造神秘氛围
class _PurpleGradientWallpaper extends StatelessWidget {
  /// 构造函数
  const _PurpleGradientWallpaper();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4A148C), // 深紫色
            Color(0xFF7B1FA2), // 中紫色
            Color(0xFF9C27B0), // 浅紫色
            Color(0xFFBA68C8), // 淡紫色
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

/// 暖色渐变壁纸
/// 
/// 温暖的橙红色系渐变，营造舒适氛围
class _WarmGradientWallpaper extends StatelessWidget {
  /// 构造函数
  const _WarmGradientWallpaper();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            Color(0xFFFF6F00), // 深橙色
            Color(0xFFFF8F00), // 中橙色
            Color(0xFFFFA726), // 浅橙色
            Color(0xFFFFCC80), // 淡橙色
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}
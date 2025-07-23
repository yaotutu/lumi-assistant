import 'package:flutter/material.dart';

/// 壁纸主要模式枚举
/// 
/// 支持两大类壁纸模式：
/// 1. 内置壁纸（系统提供的多种壁纸）
/// 2. 自定义图片（用户上传的图片）
enum WallpaperMode {
  /// 内置壁纸模式
  builtinWallpaper('内置壁纸', Icons.wallpaper, '系统提供的精美壁纸'),
  
  /// 自定义图片背景
  customImage('自定义壁纸', Icons.image, '用户上传的本地图片');
  
  /// 构造函数
  const WallpaperMode(this.displayName, this.icon, this.description);
  
  /// 显示名称
  final String displayName;
  
  /// 图标
  final IconData icon;
  
  /// 功能描述
  final String description;
}

/// 内置壁纸类型枚举
/// 
/// 定义系统提供的各种内置壁纸选项
enum BuiltinWallpaperType {
  /// 经典蓝色渐变
  blueGradient('经典渐变', Icons.gradient, '深蓝到浅蓝的经典渐变背景'),
  
  /// 动态星空
  animatedStarfield('动态星空', Icons.star, '闪烁移动的星空背景'),
  
  /// 深紫渐变
  purpleGradient('紫色渐变', Icons.gradient, '深紫到浅紫的渐变背景'),
  
  /// 暖色渐变
  warmGradient('暖色渐变', Icons.gradient, '橙色到红色的温暖渐变');
  
  /// 构造函数
  const BuiltinWallpaperType(this.displayName, this.icon, this.description);
  
  /// 显示名称
  final String displayName;
  
  /// 图标
  final IconData icon;
  
  /// 功能描述
  final String description;
}
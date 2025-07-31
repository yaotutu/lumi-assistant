import 'package:flutter/material.dart';

/// 通知图标配置
/// 
/// 支持两种图标类型：
/// 1. IconData - Material Design 图标
/// 2. Widget - 自定义 Widget（如图片）
class NotificationIconConfig {
  /// Material Design 图标
  final IconData? iconData;
  
  /// 自定义 Widget 构建器
  final Widget Function(double size)? widgetBuilder;
  
  const NotificationIconConfig.icon(IconData icon) 
      : iconData = icon, 
        widgetBuilder = null;
        
  const NotificationIconConfig.widget(Widget Function(double size) builder)
      : widgetBuilder = builder,
        iconData = null;
        
  /// 构建图标 Widget
  Widget build(double size, {Color? color}) {
    if (widgetBuilder != null) {
      return widgetBuilder!(size);
    } else if (iconData != null) {
      return Icon(
        iconData,
        size: size,
        color: color,
      );
    } else {
      // 默认图标
      return Icon(
        Icons.notifications,
        size: size,
        color: color,
      );
    }
  }
  
  /// 创建 Gotify logo 配置
  static NotificationIconConfig gotifyLogo() {
    return NotificationIconConfig.widget((size) {
      // 让 logo 在 80x80 的气泡中更加显眼
      final logoSize = size * 1.2;  // logo 放大到 120%，让它更加突出
      return Center(
        child: Image.asset(
          'assets/images/logos/gotify.png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
        ),
      );
    });
  }
}
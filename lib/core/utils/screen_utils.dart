/// 屏幕工具类
/// 
/// 提供屏幕尺寸检测、模式判断等功能
library;

import 'package:flutter/material.dart';

/// 屏幕模式枚举
enum ScreenMode {
  /// 大屏幕模式 - 支持完整的悬浮聊天界面
  /// 特征：宽度 >= 600px 或者 横屏且宽度 >= 800px
  large,
  
  /// 小屏幕模式 - 简化的界面
  /// 特征：宽度 < 600px 且竖屏，或者宽度 < 800px 且横屏
  small,
  
  /// 特别小屏幕模式 - 最简化界面
  /// 特征：宽度 < 400px 或者高度 < 400px
  tiny,
}

/// 屏幕工具类
class ScreenUtils {
  /// 获取屏幕模式
  /// 
  /// 参数：
  /// - [context] BuildContext
  /// 
  /// 返回：
  /// - [ScreenMode] 屏幕模式
  static ScreenMode getScreenMode(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isLandscape = width > height;
    
    // 特别小屏幕判断
    if (width < 400 || height < 400) {
      return ScreenMode.tiny;
    }
    
    // 大屏幕判断
    if (isLandscape) {
      // 横屏模式：宽度 >= 800px 认为是大屏幕
      if (width >= 800) {
        return ScreenMode.large;
      }
    } else {
      // 竖屏模式：宽度 >= 600px 认为是大屏幕
      if (width >= 600) {
        return ScreenMode.large;
      }
    }
    
    return ScreenMode.small;
  }
  
  /// 是否为大屏幕
  /// 
  /// 参数：
  /// - [context] BuildContext
  /// 
  /// 返回：
  /// - [bool] 是否为大屏幕
  static bool isLargeScreen(BuildContext context) {
    return getScreenMode(context) == ScreenMode.large;
  }
  
  /// 是否为小屏幕
  /// 
  /// 参数：
  /// - [context] BuildContext
  /// 
  /// 返回：
  /// - [bool] 是否为小屏幕
  static bool isSmallScreen(BuildContext context) {
    return getScreenMode(context) == ScreenMode.small;
  }
  
  /// 是否为特别小屏幕
  /// 
  /// 参数：
  /// - [context] BuildContext
  /// 
  /// 返回：
  /// - [bool] 是否为特别小屏幕
  static bool isTinyScreen(BuildContext context) {
    return getScreenMode(context) == ScreenMode.tiny;
  }
  
  /// 是否应该显示悬浮聊天图标
  /// 
  /// 在特别小屏幕且非聊天页面时不显示
  /// 
  /// 参数：
  /// - [context] BuildContext
  /// - [isInChatPage] 是否在聊天页面
  /// 
  /// 返回：
  /// - [bool] 是否应该显示
  static bool shouldShowFloatingChatIcon(BuildContext context, {bool isInChatPage = false}) {
    final screenMode = getScreenMode(context);
    
    // 特别小屏幕且非聊天页面时不显示
    if (screenMode == ScreenMode.tiny && !isInChatPage) {
      return false;
    }
    
    return true;
  }
  
  /// 获取悬浮聊天的布局参数
  /// 
  /// 参数：
  /// - [context] BuildContext
  /// 
  /// 返回：
  /// - [FloatingChatLayoutParams] 布局参数
  static FloatingChatLayoutParams getFloatingChatLayoutParams(BuildContext context) {
    final screenMode = getScreenMode(context);
    
    switch (screenMode) {
      case ScreenMode.large:
        return FloatingChatLayoutParams(
          // 大屏幕：支持完整的左右分割布局
          collapsedSize: 100.0,
          expandedWidthRatio: 0.8,
          expandedHeightRatio: 0.6,
          showFullChatInterface: true,
          showCharacterOnRight: true,
          centerContent: true,
        );
        
      case ScreenMode.small:
        return FloatingChatLayoutParams(
          // 小屏幕：简化布局，表情在中间，文字在上方
          collapsedSize: 80.0,
          expandedWidthRatio: 0.9,
          expandedHeightRatio: 0.7,
          showFullChatInterface: false,
          showCharacterOnRight: false,
          centerContent: true,
        );
        
      case ScreenMode.tiny:
        return FloatingChatLayoutParams(
          // 特别小屏幕：最简化布局
          collapsedSize: 60.0,
          expandedWidthRatio: 0.95,
          expandedHeightRatio: 0.8,
          showFullChatInterface: false,
          showCharacterOnRight: false,
          centerContent: true,
        );
    }
  }
  
  /// 获取屏幕信息描述
  /// 
  /// 参数：
  /// - [context] BuildContext
  /// 
  /// 返回：
  /// - [String] 屏幕信息描述
  static String getScreenDescription(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenMode = getScreenMode(context);
    final isLandscape = size.width > size.height;
    
    return 'Screen: ${size.width.toInt()}x${size.height.toInt()}, '
           'Mode: ${screenMode.name}, '
           'Orientation: ${isLandscape ? "Landscape" : "Portrait"}';
  }
}

/// 悬浮聊天布局参数
class FloatingChatLayoutParams {
  /// 收缩状态大小
  final double collapsedSize;
  
  /// 展开状态宽度比例
  final double expandedWidthRatio;
  
  /// 展开状态高度比例
  final double expandedHeightRatio;
  
  /// 是否显示完整聊天界面
  final bool showFullChatInterface;
  
  /// 是否在右侧显示虚拟人物
  final bool showCharacterOnRight;
  
  /// 是否居中显示内容
  final bool centerContent;
  
  /// 构造函数
  const FloatingChatLayoutParams({
    required this.collapsedSize,
    required this.expandedWidthRatio,
    required this.expandedHeightRatio,
    required this.showFullChatInterface,
    required this.showCharacterOnRight,
    required this.centerContent,
  });
}
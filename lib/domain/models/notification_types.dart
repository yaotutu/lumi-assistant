import 'package:flutter/material.dart';

/// 通知类型枚举
/// 
/// 定义所有支持的通知来源类型
/// 每种类型都有对应的默认图标、颜色和标题
enum NotificationType {
  /// 系统通知 - 应用更新、系统状态等
  system,
  
  /// Gotify 推送服务通知
  gotify,
  
  /// 天气服务通知 - 天气预警、温度变化等
  weather,
  
  /// IoT 设备通知 - 智能家居设备状态、触发事件等
  iot,
  
  /// 安全警告 - 异常登录、安全事件等
  security,
  
  /// 下载管理 - 下载完成、进度更新等
  download,
  
  /// 消息通知 - 聊天消息、邮件等
  message,
  
  /// 日程提醒 - 日历事件、待办事项等
  calendar,
  
  /// 媒体控制 - 音乐播放、视频状态等
  media,
  
  /// 网络状态 - 连接断开、网络切换等
  network,
  
  /// 电池状态 - 低电量、充电状态等
  battery,
  
  /// 存储空间 - 空间不足、清理提醒等
  storage,
  
  /// 自定义通知 - 用户自定义的通知类型
  custom,
}

/// 通知级别枚举
/// 
/// 定义通知的重要程度
/// 影响通知的显示方式和用户打扰程度
enum NotificationLevel {
  /// 低级别 - 一般信息，不需要立即关注
  low,
  
  /// 普通级别 - 常规通知，默认级别
  normal,
  
  /// 高级别 - 重要通知，需要用户关注
  high,
  
  /// 紧急级别 - 紧急事件，需要立即处理
  urgent,
}

/// 通知类型配置
/// 
/// 为每种通知类型定义默认的视觉样式和文本
class NotificationTypeConfig {
  /// 获取通知类型的默认配置
  static NotificationConfig getConfig(NotificationType type) {
    switch (type) {
      case NotificationType.system:
        return NotificationConfig(
          icon: Icons.settings,
          color: Colors.blue,
          defaultTitle: '系统',
          category: '系统消息',
        );
        
      case NotificationType.gotify:
        return NotificationConfig(
          icon: Icons.cloud,
          color: Colors.teal,
          defaultTitle: 'Gotify',
          category: '推送服务',
        );
        
      case NotificationType.weather:
        return NotificationConfig(
          icon: Icons.wb_sunny,
          color: Colors.orange,
          defaultTitle: '天气',
          category: '天气信息',
        );
        
      case NotificationType.iot:
        return NotificationConfig(
          icon: Icons.devices,
          color: Colors.green,
          defaultTitle: 'IoT设备',
          category: '智能家居',
        );
        
      case NotificationType.security:
        return NotificationConfig(
          icon: Icons.security,
          color: Colors.red,
          defaultTitle: '安全警告',
          category: '安全',
        );
        
      case NotificationType.download:
        return NotificationConfig(
          icon: Icons.download_done,
          color: Colors.purple,
          defaultTitle: '下载',
          category: '下载管理',
        );
        
      case NotificationType.message:
        return NotificationConfig(
          icon: Icons.message,
          color: Colors.indigo,
          defaultTitle: '消息',
          category: '通讯',
        );
        
      case NotificationType.calendar:
        return NotificationConfig(
          icon: Icons.calendar_today,
          color: Colors.amber,
          defaultTitle: '日程',
          category: '日程提醒',
        );
        
      case NotificationType.media:
        return NotificationConfig(
          icon: Icons.play_circle,
          color: Colors.pink,
          defaultTitle: '媒体',
          category: '媒体控制',
        );
        
      case NotificationType.network:
        return NotificationConfig(
          icon: Icons.wifi,
          color: Colors.cyan,
          defaultTitle: '网络',
          category: '网络状态',
        );
        
      case NotificationType.battery:
        return NotificationConfig(
          icon: Icons.battery_alert,
          color: Colors.lime,
          defaultTitle: '电池',
          category: '电源管理',
        );
        
      case NotificationType.storage:
        return NotificationConfig(
          icon: Icons.storage,
          color: Colors.brown,
          defaultTitle: '存储',
          category: '存储空间',
        );
        
      case NotificationType.custom:
        return NotificationConfig(
          icon: Icons.notifications,
          color: Colors.grey,
          defaultTitle: '通知',
          category: '其他',
        );
    }
  }
  
  /// 根据级别获取颜色调整
  /// 
  /// 高级别通知可能使用更醒目的颜色
  static Color getLevelAdjustedColor(Color baseColor, NotificationLevel level) {
    switch (level) {
      case NotificationLevel.low:
        // 低级别：颜色变淡
        return baseColor.withValues(alpha: 0.7);
        
      case NotificationLevel.normal:
        // 普通级别：使用原色
        return baseColor;
        
      case NotificationLevel.high:
        // 高级别：颜色加深
        return baseColor.withValues(alpha: 0.9);
        
      case NotificationLevel.urgent:
        // 紧急级别：使用红色调
        return Color.lerp(baseColor, Colors.red, 0.3) ?? baseColor;
    }
  }
  
  /// 根据级别获取图标大小倍数
  static double getLevelIconScale(NotificationLevel level) {
    switch (level) {
      case NotificationLevel.low:
        return 0.9;
      case NotificationLevel.normal:
        return 1.0;
      case NotificationLevel.high:
        return 1.1;
      case NotificationLevel.urgent:
        return 1.2;
    }
  }
}

/// 通知配置模型
/// 
/// 包含通知类型的默认视觉配置
class NotificationConfig {
  /// 默认图标
  final IconData icon;
  
  /// 默认颜色
  final Color color;
  
  /// 默认标题
  final String defaultTitle;
  
  /// 分类名称
  final String category;
  
  const NotificationConfig({
    required this.icon,
    required this.color,
    required this.defaultTitle,
    required this.category,
  });
}

/// 通知源信息
/// 
/// 用于标识通知的来源，便于后续过滤和管理
class NotificationSource {
  /// 源标识符
  final String id;
  
  /// 源名称
  final String name;
  
  /// 源类型
  final NotificationType type;
  
  /// 是否启用
  final bool enabled;
  
  const NotificationSource({
    required this.id,
    required this.name,
    required this.type,
    this.enabled = true,
  });
}
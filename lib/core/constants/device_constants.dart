/// 设备类型枚举
/// 
/// 根据屏幕最小维度分类设备类型，确保应用在各种设备上的最佳体验
enum DeviceType {
  /// 微型设备（手表类）- 最小维度 < 300px
  /// 
  /// 特征：
  /// - 极小屏幕空间
  /// - 需要极简UI
  /// - 只显示核心功能
  /// - 最小字体和图标
  micro,

  /// 超小屏设备 - 最小维度 300-400px
  /// 
  /// 特征：
  /// - 3-4寸小屏设备
  /// - 简化UI布局
  /// - 减少辅助信息
  /// - 较小的组件尺寸
  tiny,

  /// 小屏设备 - 最小维度 400-600px
  /// 
  /// 特征：
  /// - 常规手机屏幕
  /// - 中等密度布局
  /// - 部分功能简化
  /// - 标准组件尺寸
  small,

  /// 标准屏设备 - 最小维度 > 600px
  /// 
  /// 特征：
  /// - 大屏手机、平板
  /// - 完整功能显示
  /// - 丰富的UI元素
  /// - 标准间距和尺寸
  standard,
}

/// 设备类型扩展方法
extension DeviceTypeExtension on DeviceType {
  /// 是否为紧凑模式
  bool get isCompact => this != DeviceType.standard;
  
  /// 是否为超小设备
  bool get isTiny => this == DeviceType.micro || this == DeviceType.tiny;
  
  /// 获取设备类型描述
  String get description {
    switch (this) {
      case DeviceType.micro:
        return '微型设备 (手表类)';
      case DeviceType.tiny:
        return '超小屏设备 (3-4寸)';
      case DeviceType.small:
        return '小屏设备 (手机)';
      case DeviceType.standard:
        return '标准屏设备 (大屏/平板)';
    }
  }
  
  /// 获取推荐的内容密度
  double get contentDensity {
    switch (this) {
      case DeviceType.micro:
        return 0.6;  // 极简内容
      case DeviceType.tiny:
        return 0.7;  // 精简内容
      case DeviceType.small:
        return 0.85; // 适中内容
      case DeviceType.standard:
        return 1.0;  // 完整内容
    }
  }
  
  /// 获取推荐的文字缩放比例
  double get fontScale {
    switch (this) {
      case DeviceType.micro:
        return 0.8;
      case DeviceType.tiny:
        return 0.9;
      case DeviceType.small:
        return 0.95;
      case DeviceType.standard:
        return 1.0;
    }
  }
}
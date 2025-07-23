/// 背景配置管理
/// 
/// 负责管理所有背景相关的用户配置：
/// - 背景模式选择 (默认/电子相册)
/// - 电子相册图片源配置
/// - 自定义图片管理
library;

/// 背景模式类型
enum BackgroundType {
  /// 默认系统背景
  systemDefault,
  /// 电子相册模式
  photoAlbum,
}

/// 电子相册图片源类型
enum PhotoAlbumSourceType {
  /// 系统内置图片
  systemBuiltIn,
  /// 用户自定义上传
  userCustom,
  /// 外部服务 (Immich等)
  externalService,
}

/// 系统内置背景类型
enum SystemBackgroundType {
  /// 蓝色渐变
  blueGradient,
  /// 绿色渐变
  greenGradient,
  /// 紫色渐变
  purpleGradient,
  /// 橙色渐变
  orangeGradient,
  /// 纯黑色
  pureBlack,
  /// 纯白色
  pureWhite,
  /// 深灰色
  darkGray,
}

/// 背景配置模型
class BackgroundConfig {
  /// 当前背景模式
  final BackgroundType backgroundType;
  
  /// 系统背景类型 (当backgroundType为systemDefault时使用)
  final SystemBackgroundType systemBackgroundType;
  
  /// 是否启用电子相册
  final bool isPhotoAlbumEnabled;
  
  /// 电子相册图片源类型
  final PhotoAlbumSourceType photoAlbumSourceType;
  
  /// 电子相册切换间隔 (秒)
  final int photoAlbumSwitchInterval;
  
  /// 是否启用高斯模糊背景
  final bool enableBlurredBackground;
  
  /// 高斯模糊强度
  final double blurIntensity;
  
  /// 用户自定义图片路径列表
  final List<String> customPhotoPaths;
  
  /// 外部服务配置 (预留)
  final Map<String, dynamic> externalServiceConfig;
  
  /// 构造函数
  const BackgroundConfig({
    this.backgroundType = BackgroundType.systemDefault,
    this.systemBackgroundType = SystemBackgroundType.blueGradient,
    this.isPhotoAlbumEnabled = false,
    this.photoAlbumSourceType = PhotoAlbumSourceType.systemBuiltIn,
    this.photoAlbumSwitchInterval = 10,
    this.enableBlurredBackground = true,
    this.blurIntensity = 10.0,
    this.customPhotoPaths = const [],
    this.externalServiceConfig = const {},
  });
  
  /// 复制配置
  BackgroundConfig copyWith({
    BackgroundType? backgroundType,
    SystemBackgroundType? systemBackgroundType,
    bool? isPhotoAlbumEnabled,
    PhotoAlbumSourceType? photoAlbumSourceType,
    int? photoAlbumSwitchInterval,
    bool? enableBlurredBackground,
    double? blurIntensity,
    List<String>? customPhotoPaths,
    Map<String, dynamic>? externalServiceConfig,
  }) {
    return BackgroundConfig(
      backgroundType: backgroundType ?? this.backgroundType,
      systemBackgroundType: systemBackgroundType ?? this.systemBackgroundType,
      isPhotoAlbumEnabled: isPhotoAlbumEnabled ?? this.isPhotoAlbumEnabled,
      photoAlbumSourceType: photoAlbumSourceType ?? this.photoAlbumSourceType,
      photoAlbumSwitchInterval: photoAlbumSwitchInterval ?? this.photoAlbumSwitchInterval,
      enableBlurredBackground: enableBlurredBackground ?? this.enableBlurredBackground,
      blurIntensity: blurIntensity ?? this.blurIntensity,
      customPhotoPaths: customPhotoPaths ?? this.customPhotoPaths,
      externalServiceConfig: externalServiceConfig ?? this.externalServiceConfig,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'backgroundType': backgroundType.index,
      'systemBackgroundType': systemBackgroundType.index,
      'isPhotoAlbumEnabled': isPhotoAlbumEnabled,
      'photoAlbumSourceType': photoAlbumSourceType.index,
      'photoAlbumSwitchInterval': photoAlbumSwitchInterval,
      'enableBlurredBackground': enableBlurredBackground,
      'blurIntensity': blurIntensity,
      'customPhotoPaths': customPhotoPaths,
      'externalServiceConfig': externalServiceConfig,
    };
  }
  
  /// 从JSON创建
  factory BackgroundConfig.fromJson(Map<String, dynamic> json) {
    return BackgroundConfig(
      backgroundType: BackgroundType.values[json['backgroundType'] ?? 0],
      systemBackgroundType: SystemBackgroundType.values[json['systemBackgroundType'] ?? 0],
      isPhotoAlbumEnabled: json['isPhotoAlbumEnabled'] ?? false,
      photoAlbumSourceType: PhotoAlbumSourceType.values[json['photoAlbumSourceType'] ?? 0],
      photoAlbumSwitchInterval: json['photoAlbumSwitchInterval'] ?? 10,
      enableBlurredBackground: json['enableBlurredBackground'] ?? true,
      blurIntensity: (json['blurIntensity'] ?? 10.0).toDouble(),
      customPhotoPaths: List<String>.from(json['customPhotoPaths'] ?? []),
      externalServiceConfig: Map<String, dynamic>.from(json['externalServiceConfig'] ?? {}),
    );
  }
}

/// 系统内置背景描述
class SystemBackgroundInfo {
  final SystemBackgroundType type;
  final String name;
  final String description;
  final List<int> colors; // 颜色值列表
  
  const SystemBackgroundInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.colors,
  });
}

/// 系统内置背景数据
class SystemBackgroundData {
  static const List<SystemBackgroundInfo> backgrounds = [
    SystemBackgroundInfo(
      type: SystemBackgroundType.blueGradient,
      name: '蓝色渐变',
      description: '经典的蓝色渐变背景，宁静优雅',
      colors: [0xFF4A90E2, 0xFF7B68EE],
    ),
    SystemBackgroundInfo(
      type: SystemBackgroundType.greenGradient,
      name: '绿色渐变',
      description: '清新的绿色渐变，自然舒适',
      colors: [0xFF32CD32, 0xFF98FB98],
    ),
    SystemBackgroundInfo(
      type: SystemBackgroundType.purpleGradient,
      name: '紫色渐变',
      description: '神秘的紫色渐变，优雅神秘',
      colors: [0xFF8A2BE2, 0xFFDDA0DD],
    ),
    SystemBackgroundInfo(
      type: SystemBackgroundType.orangeGradient,
      name: '橙色渐变',
      description: '温暖的橙色渐变，活力充沛',
      colors: [0xFFFF6B35, 0xFFFFA500],
    ),
    SystemBackgroundInfo(
      type: SystemBackgroundType.pureBlack,
      name: '纯黑色',
      description: '经典黑色背景，简约大方',
      colors: [0xFF000000],
    ),
    SystemBackgroundInfo(
      type: SystemBackgroundType.pureWhite,
      name: '纯白色',
      description: '简洁白色背景，清爽明亮',
      colors: [0xFFFFFFFF],
    ),
    SystemBackgroundInfo(
      type: SystemBackgroundType.darkGray,
      name: '深灰色',
      description: '深灰色背景，沉稳内敛',
      colors: [0xFF2F2F2F],
    ),
  ];
  
  /// 根据类型获取背景信息
  static SystemBackgroundInfo? getBackgroundInfo(SystemBackgroundType type) {
    try {
      return backgrounds.firstWhere((bg) => bg.type == type);
    } catch (e) {
      return null;
    }
  }
}
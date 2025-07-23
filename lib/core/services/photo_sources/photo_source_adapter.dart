/// 照片源适配器基础接口
/// 
/// 提供统一的照片获取接口，支持多种照片来源：
/// - 免费图片网站（Picsum、Unsplash等）
/// - 本地相册
/// - 网络相册（Google Photos、iCloud等）
/// - 社交媒体（Instagram、微博等）
library;

import 'dart:typed_data';

/// 照片信息模型
class PhotoInfo {
  /// 照片唯一标识
  final String id;
  
  /// 照片标题
  final String title;
  
  /// 照片描述
  final String? description;
  
  /// 作者信息
  final String? author;
  
  /// 照片URL（不同尺寸）
  final PhotoUrls urls;
  
  /// 照片尺寸信息
  final PhotoSize size;
  
  /// 照片来源
  final String source;
  
  /// 拍摄时间
  final DateTime? takenAt;
  
  /// 构造函数
  const PhotoInfo({
    required this.id,
    required this.title,
    this.description,
    this.author,
    required this.urls,
    required this.size,
    required this.source,
    this.takenAt,
  });
}

/// 照片URL集合（不同尺寸）
class PhotoUrls {
  /// 原图URL
  final String original;
  
  /// 大图URL
  final String large;
  
  /// 中图URL
  final String medium;
  
  /// 小图URL
  final String small;
  
  /// 缩略图URL
  final String thumbnail;
  
  /// 构造函数
  const PhotoUrls({
    required this.original,
    required this.large,
    required this.medium,
    required this.small,
    required this.thumbnail,
  });
}

/// 照片尺寸信息
class PhotoSize {
  /// 宽度
  final int width;
  
  /// 高度
  final int height;
  
  /// 构造函数
  const PhotoSize({
    required this.width,
    required this.height,
  });
  
  /// 获取宽高比
  double get aspectRatio => width / height;
  
  /// 是否为横向照片
  bool get isLandscape => width > height;
  
  /// 是否为纵向照片
  bool get isPortrait => height > width;
  
  /// 是否为正方形照片
  bool get isSquare => width == height;
}

/// 照片获取配置
class PhotoFetchConfig {
  /// 每次获取的照片数量
  final int count;
  
  /// 照片尺寸偏好
  final PhotoSizePreference sizePreference;
  
  /// 照片方向偏好
  final PhotoOrientationPreference orientationPreference;
  
  /// 照片类别偏好
  final List<String> categories;
  
  /// 是否允许缓存
  final bool enableCache;
  
  /// 缓存时长（分钟）
  final int cacheMinutes;
  
  /// 构造函数
  const PhotoFetchConfig({
    this.count = 20,
    this.sizePreference = PhotoSizePreference.large,
    this.orientationPreference = PhotoOrientationPreference.any,
    this.categories = const [],
    this.enableCache = true,
    this.cacheMinutes = 60,
  });
}

/// 照片尺寸偏好
enum PhotoSizePreference {
  /// 小图优先（快速加载）
  small,
  /// 中图优先（平衡加载速度和质量）
  medium,
  /// 大图优先（高质量显示）
  large,
  /// 原图优先（最高质量）
  original,
}

/// 照片方向偏好
enum PhotoOrientationPreference {
  /// 任意方向
  any,
  /// 横向优先
  landscape,
  /// 纵向优先
  portrait,
  /// 正方形优先
  square,
}

/// 照片源适配器异常
class PhotoSourceException implements Exception {
  /// 错误消息
  final String message;
  
  /// 错误代码
  final String? code;
  
  /// 原始异常
  final dynamic originalException;
  
  /// 构造函数
  const PhotoSourceException(
    this.message, {
    this.code,
    this.originalException,
  });
  
  @override
  String toString() => 'PhotoSourceException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 照片源适配器基础接口
abstract class PhotoSourceAdapter {
  /// 适配器名称
  String get name;
  
  /// 适配器描述
  String get description;
  
  /// 是否支持随机获取
  bool get supportsRandom;
  
  /// 是否支持分类获取
  bool get supportsCategories;
  
  /// 是否支持搜索
  bool get supportsSearch;
  
  /// 是否需要API密钥
  bool get requiresApiKey;
  
  /// 支持的照片类别列表
  List<String> get supportedCategories;
  
  /// 初始化适配器
  /// 
  /// 参数：
  /// - [apiKey] API密钥（如果需要）
  /// - [config] 其他配置参数
  Future<void> initialize({String? apiKey, Map<String, dynamic>? config});
  
  /// 随机获取照片
  /// 
  /// 参数：
  /// - [config] 获取配置
  /// 
  /// 返回：
  /// - [List<PhotoInfo>] 照片信息列表
  Future<List<PhotoInfo>> fetchRandomPhotos(PhotoFetchConfig config);
  
  /// 根据类别获取照片
  /// 
  /// 参数：
  /// - [category] 照片类别
  /// - [config] 获取配置
  /// 
  /// 返回：
  /// - [List<PhotoInfo>] 照片信息列表
  Future<List<PhotoInfo>> fetchPhotosByCategory(String category, PhotoFetchConfig config);
  
  /// 搜索照片
  /// 
  /// 参数：
  /// - [query] 搜索关键词
  /// - [config] 获取配置
  /// 
  /// 返回：
  /// - [List<PhotoInfo>] 照片信息列表
  Future<List<PhotoInfo>> searchPhotos(String query, PhotoFetchConfig config);
  
  /// 获取照片二进制数据
  /// 
  /// 参数：
  /// - [photoInfo] 照片信息
  /// - [sizePreference] 尺寸偏好
  /// 
  /// 返回：
  /// - [Uint8List] 照片二进制数据
  Future<Uint8List> fetchPhotoData(PhotoInfo photoInfo, PhotoSizePreference sizePreference);
  
  /// 检查适配器是否可用
  /// 
  /// 返回：
  /// - [bool] 是否可用
  Future<bool> isAvailable();
  
  /// 获取使用统计信息
  /// 
  /// 返回：
  /// - [Map<String, dynamic>] 统计信息
  Map<String, dynamic> getUsageStats();
}
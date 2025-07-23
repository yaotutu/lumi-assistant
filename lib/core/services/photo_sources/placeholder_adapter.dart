/// 占位图片适配器
/// 
/// 生成彩色渐变占位图片，无需网络连接
/// - 完全本地生成，无网络依赖
/// - 在中国大陆100%可用
/// - 支持多种颜色和尺寸
/// - 用于网络不可用时的备选方案
library;

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'photo_source_adapter.dart';
import '../../utils/loggers.dart';

/// 占位图片适配器实现
class PlaceholderAdapter implements PhotoSourceAdapter {
  /// 随机数生成器
  final Random _random = Random();
  
  /// 使用统计
  final Map<String, int> _usageStats = {
    'fetchCount': 0,
    'errorCount': 0,
    'cacheHits': 0,
  };
  
  /// 照片缓存
  final Map<String, List<PhotoInfo>> _cache = {};
  
  /// 预定义的渐变色彩组合
  static const List<List<Color>> _gradientColors = [
    [Color(0xFF667eea), Color(0xFF764ba2)], // 紫蓝渐变
    [Color(0xFFf093fb), Color(0xFFf5576c)], // 粉红渐变
    [Color(0xFF4facfe), Color(0xFF00f2fe)], // 蓝青渐变
    [Color(0xFF43e97b), Color(0xFF38f9d7)], // 绿青渐变
    [Color(0xFFfa709a), Color(0xFFfee140)], // 粉黄渐变
    [Color(0xFFa8edea), Color(0xFFfed6e3)], // 青粉渐变
    [Color(0xFFffecd2), Color(0xFFfcb69f)], // 橙黄渐变
    [Color(0xFF667db6), Color(0xFF0082c8), Color(0xFF0082c8), Color(0xFF667db6)], // 蓝色四色渐变
    [Color(0xFFfbc2eb), Color(0xFFa6c1ee)], // 粉蓝渐变
    [Color(0xFFfdbb2d), Color(0xFF22c1c3)], // 黄青渐变
  ];
  
  /// 构造函数
  PlaceholderAdapter();
  
  @override
  String get name => 'PlaceholderImages';
  
  @override
  String get description => '本地生成的彩色渐变占位图片，无需网络连接';
  
  @override
  bool get supportsRandom => true;
  
  @override
  bool get supportsCategories => true;
  
  @override
  bool get supportsSearch => false;
  
  @override
  bool get requiresApiKey => false;
  
  @override
  List<String> get supportedCategories => const [
    'gradient', 'warm', 'cool', 'nature', 'abstract'
  ];
  
  @override
  Future<void> initialize({String? apiKey, Map<String, dynamic>? config}) async {
    try {
      Loggers.system.info('占位图片适配器初始化成功（无需网络连接）');
    } catch (e) {
      Loggers.system.severe('占位图片适配器初始化失败', e);
      throw PhotoSourceException(
        '占位图片适配器初始化失败: $e',
        code: 'INIT_FAILED',
        originalException: e,
      );
    }
  }
  
  @override
  Future<List<PhotoInfo>> fetchRandomPhotos(PhotoFetchConfig config) async {
    try {
      // 检查缓存
      if (config.enableCache && _cache.containsKey('random_${config.count}')) {
        final cached = _cache['random_${config.count}']!;
        if (cached.isNotEmpty) {
          _usageStats['cacheHits'] = _usageStats['cacheHits']! + 1;
          Loggers.system.fine('从缓存获取${cached.length}张占位图片');
          return cached.take(config.count).toList()..shuffle(_random);
        }
      }
      
      // 生成随机占位图片列表
      final photos = <PhotoInfo>[];
      
      for (int i = 0; i < config.count; i++) {
        final photoId = 'placeholder_${DateTime.now().millisecondsSinceEpoch}_$i';
        final gradientIndex = _random.nextInt(_gradientColors.length);
        
        final urls = PhotoUrls(
          original: 'placeholder://gradient/$gradientIndex/1920x1080',
          large: 'placeholder://gradient/$gradientIndex/1200x800',
          medium: 'placeholder://gradient/$gradientIndex/800x600',
          small: 'placeholder://gradient/$gradientIndex/400x300',
          thumbnail: 'placeholder://gradient/$gradientIndex/200x200',
        );
        
        final photo = PhotoInfo(
          id: photoId,
          title: '渐变背景 #${i + 1}',
          description: '精美渐变色彩背景图片',
          author: 'Lumi Assistant',
          source: name,
          urls: urls,
          size: PhotoSize(
            width: 1920,
            height: 1080,
          ),
          takenAt: DateTime.now(),
        );
        
        photos.add(photo);
      }
      
      // 缓存结果
      if (config.enableCache) {
        _cache['random_${config.count}'] = photos;
        
        // 设置缓存过期
        Future.delayed(Duration(minutes: config.cacheMinutes), () {
          _cache.remove('random_${config.count}');
        });
      }
      
      _usageStats['fetchCount'] = _usageStats['fetchCount']! + 1;
      Loggers.system.info('成功生成${photos.length}张占位图片');
      
      return photos;
    } catch (e) {
      _usageStats['errorCount'] = _usageStats['errorCount']! + 1;
      Loggers.system.severe('生成占位图片失败', e);
      rethrow;
    }
  }
  
  @override
  Future<List<PhotoInfo>> fetchPhotosByCategory(String category, PhotoFetchConfig config) async {
    // 占位图片适配器目前不区分分类，直接返回随机图片
    // 未来可以根据分类选择不同的色彩主题
    return fetchRandomPhotos(config);
  }
  
  @override
  Future<List<PhotoInfo>> searchPhotos(String query, PhotoFetchConfig config) async {
    throw PhotoSourceException(
      '占位图片不支持搜索',
      code: 'UNSUPPORTED_OPERATION',
    );
  }
  
  @override
  Future<Uint8List> fetchPhotoData(PhotoInfo photoInfo, PhotoSizePreference sizePreference) async {
    try {
      // 解析URL中的渐变信息
      final url = _getUrlByPreference(photoInfo, sizePreference);
      final uri = Uri.parse(url);
      final gradientIndex = int.parse(uri.pathSegments[1]);
      final sizeParts = uri.pathSegments[2].split('x');
      final width = int.parse(sizeParts[0]);
      final height = int.parse(sizeParts[1]);
      
      // 生成渐变图片
      final imageData = await _generateGradientImage(gradientIndex, width, height);
      
      Loggers.system.fine('成功生成占位图片: ${photoInfo.id}，尺寸: ${width}x$height');
      return imageData;
    } catch (e) {
      Loggers.system.severe('生成占位图片失败: ${photoInfo.id}', e);
      throw PhotoSourceException(
        '生成占位图片失败: $e',
        code: 'GENERATION_ERROR',
        originalException: e,
      );
    }
  }
  
  @override
  Future<bool> isAvailable() async {
    // 占位图片适配器始终可用
    return true;
  }
  
  @override
  Map<String, dynamic> getUsageStats() {
    return Map<String, dynamic>.from(_usageStats);
  }
  
  /// 根据尺寸偏好获取URL
  String _getUrlByPreference(PhotoInfo photoInfo, PhotoSizePreference sizePreference) {
    switch (sizePreference) {
      case PhotoSizePreference.small:
        return photoInfo.urls.small;
      case PhotoSizePreference.medium:
        return photoInfo.urls.medium;
      case PhotoSizePreference.large:
        return photoInfo.urls.large;
      case PhotoSizePreference.original:
        return photoInfo.urls.original;
    }
  }
  
  /// 生成渐变图片
  Future<Uint8List> _generateGradientImage(int gradientIndex, int width, int height) async {
    final colors = _gradientColors[gradientIndex % _gradientColors.length];
    
    // 创建一个简单的渐变图片数据
    // 这里使用简单的算法生成PNG格式的图片数据
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // 创建渐变
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
}
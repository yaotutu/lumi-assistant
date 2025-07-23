/// Unsplash Source 适配器
/// 
/// 从 Unsplash Source (source.unsplash.com) 获取免费随机图片
/// - 完全免费，无需API密钥
/// - 支持随机图片和指定尺寸
/// - 在中国大陆可以正常访问
/// - 提供高质量摄影作品
library;

import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'photo_source_adapter.dart';
import '../../utils/loggers.dart';

/// Unsplash Source 适配器实现
class UnsplashSourceAdapter implements PhotoSourceAdapter {
  /// HTTP客户端
  final http.Client _httpClient;
  
  /// 基础API地址
  static const String _baseUrl = 'https://source.unsplash.com';
  
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
  
  /// 构造函数
  UnsplashSourceAdapter({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  
  @override
  String get name => 'Unsplash Source';
  
  @override
  String get description => '免费高质量随机图片服务，来自Unsplash Source，中国大陆可访问';
  
  @override
  bool get supportsRandom => true;
  
  @override
  bool get supportsCategories => true; // Unsplash支持分类
  
  @override
  bool get supportsSearch => false; // Source版本不支持搜索
  
  @override
  bool get requiresApiKey => false;
  
  @override
  List<String> get supportedCategories => const [
    'nature', 'landscape', 'city', 'technology', 'people', 
    'animals', 'food', 'travel', 'architecture', 'business'
  ];
  
  @override
  Future<void> initialize({String? apiKey, Map<String, dynamic>? config}) async {
    // 测试连接
    try {
      final response = await _httpClient.head(
        Uri.parse('$_baseUrl/800x600/?random=1'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw PhotoSourceException(
          'Unsplash Source服务不可用，状态码: ${response.statusCode}',
          code: 'SERVICE_UNAVAILABLE',
        );
      }
      
      Loggers.system.info('Unsplash Source适配器初始化成功');
    } catch (e) {
      Loggers.system.severe('Unsplash Source适配器初始化失败', e);
      throw PhotoSourceException(
        'Unsplash Source适配器初始化失败: $e',
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
          Loggers.system.fine('从缓存获取${cached.length}张随机图片');
          return cached.take(config.count).toList()..shuffle(_random);
        }
      }
      
      // 生成随机照片列表
      final photos = <PhotoInfo>[];
      
      for (int i = 0; i < config.count; i++) {
        final photoId = 'unsplash_${DateTime.now().millisecondsSinceEpoch}_$i';
        final randomSeed = _random.nextInt(10000);
        
        final urls = PhotoUrls(
          original: '$_baseUrl/1920x1080/?random=$randomSeed',
          large: '$_baseUrl/1200x800/?random=$randomSeed',
          medium: '$_baseUrl/800x600/?random=$randomSeed',
          small: '$_baseUrl/400x300/?random=$randomSeed',
          thumbnail: '$_baseUrl/200x200/?random=$randomSeed',
        );
        
        final photo = PhotoInfo(
          id: photoId,
          title: '精美随机图片 #${i + 1}',
          description: '来自Unsplash的高质量摄影作品',
          author: 'Unsplash摄影师',
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
      Loggers.system.info('成功获取${photos.length}张随机图片');
      
      return photos;
    } catch (e) {
      _usageStats['errorCount'] = _usageStats['errorCount']! + 1;
      Loggers.system.severe('获取随机图片失败', e);
      rethrow;
    }
  }
  
  @override
  Future<List<PhotoInfo>> fetchPhotosByCategory(String category, PhotoFetchConfig config) async {
    try {
      final photos = <PhotoInfo>[];
      
      for (int i = 0; i < config.count; i++) {
        final photoId = 'unsplash_${category}_${DateTime.now().millisecondsSinceEpoch}_$i';
        final randomSeed = _random.nextInt(10000);
        
        final urls = PhotoUrls(
          original: '$_baseUrl/1920x1080/?$category&random=$randomSeed',
          large: '$_baseUrl/1200x800/?$category&random=$randomSeed',
          medium: '$_baseUrl/800x600/?$category&random=$randomSeed',
          small: '$_baseUrl/400x300/?$category&random=$randomSeed',
          thumbnail: '$_baseUrl/200x200/?$category&random=$randomSeed',
        );
        
        final photo = PhotoInfo(
          id: photoId,
          title: '${_getCategoryName(category)} #${i + 1}',
          description: '来自Unsplash的${_getCategoryName(category)}主题摄影作品',
          author: 'Unsplash摄影师',
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
      
      _usageStats['fetchCount'] = _usageStats['fetchCount']! + 1;
      Loggers.system.info('成功获取${photos.length}张${_getCategoryName(category)}图片');
      
      return photos;
    } catch (e) {
      _usageStats['errorCount'] = _usageStats['errorCount']! + 1;
      Loggers.system.severe('获取分类图片失败', e);
      rethrow;
    }
  }
  
  @override
  Future<List<PhotoInfo>> searchPhotos(String query, PhotoFetchConfig config) async {
    throw PhotoSourceException(
      'Unsplash Source不支持搜索照片',
      code: 'UNSUPPORTED_OPERATION',
    );
  }
  
  @override
  Future<Uint8List> fetchPhotoData(PhotoInfo photoInfo, PhotoSizePreference sizePreference) async {
    try {
      String url;
      switch (sizePreference) {
        case PhotoSizePreference.small:
          url = photoInfo.urls.small;
          break;
        case PhotoSizePreference.medium:
          url = photoInfo.urls.medium;
          break;
        case PhotoSizePreference.large:
          url = photoInfo.urls.large;
          break;
        case PhotoSizePreference.original:
          url = photoInfo.urls.original;
          break;
      }
      
      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Lumi-Assistant/1.0'},
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw PhotoSourceException(
          '下载图片失败，状态码: ${response.statusCode}',
          code: 'DOWNLOAD_FAILED',
        );
      }
      
      Loggers.system.fine('成功下载图片: ${photoInfo.id}，大小: ${response.bodyBytes.length} bytes');
      return response.bodyBytes;
    } catch (e) {
      Loggers.system.severe('下载图片失败: ${photoInfo.id}', e);
      throw PhotoSourceException(
        '下载图片失败: $e',
        code: 'DOWNLOAD_ERROR',
        originalException: e,
      );
    }
  }
  
  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _httpClient.head(
        Uri.parse('$_baseUrl/400x300/?random=1'),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      Loggers.system.warning('Unsplash Source服务检查失败', e);
      return false;
    }
  }
  
  @override
  Map<String, dynamic> getUsageStats() {
    return Map<String, dynamic>.from(_usageStats);
  }
  
  /// 获取分类的中文名称
  String _getCategoryName(String category) {
    const categoryNames = {
      'nature': '自然风光',
      'landscape': '风景',
      'city': '城市',
      'technology': '科技',
      'people': '人物',
      'animals': '动物',
      'food': '美食',
      'travel': '旅行',
      'architecture': '建筑',
      'business': '商务',
    };
    
    return categoryNames[category] ?? category;
  }
}
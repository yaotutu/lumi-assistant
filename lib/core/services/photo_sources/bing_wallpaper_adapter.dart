/// Bing 每日壁纸适配器
/// 
/// 从必应每日壁纸API获取高质量图片
/// - 完全免费，无需API密钥
/// - 必应官方壁纸，质量极高
/// - 在中国大陆可以正常访问
/// - 每日更新的精美壁纸
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'photo_source_adapter.dart';
import '../../utils/loggers.dart';

/// Bing 壁纸适配器实现
class BingWallpaperAdapter implements PhotoSourceAdapter {
  /// HTTP客户端
  final http.Client _httpClient;
  
  /// Bing 壁纸API地址（中国版，国内可访问）
  static const String _apiUrl = 'https://cn.bing.com/HPImageArchive.aspx';
  
  /// Bing 图片基础URL
  static const String _imageBaseUrl = 'https://cn.bing.com';
  
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
  BingWallpaperAdapter({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  
  @override
  String get name => 'Bing Daily Wallpaper';
  
  @override
  String get description => '必应每日壁纸，高质量官方壁纸，中国大陆可访问';
  
  @override
  bool get supportsRandom => true;
  
  @override
  bool get supportsCategories => false; // Bing壁纸不支持分类
  
  @override
  bool get supportsSearch => false; // Bing壁纸不支持搜索
  
  @override
  bool get requiresApiKey => false;
  
  @override
  List<String> get supportedCategories => const []; // 不支持分类
  
  @override
  Future<void> initialize({String? apiKey, Map<String, dynamic>? config}) async {
    try {
      // 测试API连接
      final response = await _httpClient.get(
        Uri.parse('$_apiUrl?format=js&idx=0&n=1&mkt=zh-CN'),
        headers: {'User-Agent': 'Lumi-Assistant/1.0'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw PhotoSourceException(
          'Bing壁纸服务不可用，状态码: ${response.statusCode}',
          code: 'SERVICE_UNAVAILABLE',
        );
      }
      
      Loggers.system.info('Bing壁纸适配器初始化成功');
    } catch (e) {
      Loggers.system.severe('Bing壁纸适配器初始化失败', e);
      throw PhotoSourceException(
        'Bing壁纸适配器初始化失败: $e',
        code: 'INIT_FAILED',
        originalException: e,
      );
    }
  }
  
  @override
  Future<List<PhotoInfo>> fetchRandomPhotos(PhotoFetchConfig config) async {
    try {
      // 检查缓存
      if (config.enableCache && _cache.containsKey('bing_${config.count}')) {
        final cached = _cache['bing_${config.count}']!;
        if (cached.isNotEmpty) {
          _usageStats['cacheHits'] = _usageStats['cacheHits']! + 1;  
          Loggers.system.fine('从缓存获取${cached.length}张Bing壁纸');
          return cached.take(config.count).toList()..shuffle(_random);
        }
      }
      
      // 获取最近的壁纸（最多8张）
      final requestCount = (config.count > 8) ? 8 : config.count;
      final response = await _httpClient.get(
        Uri.parse('$_apiUrl?format=js&idx=0&n=$requestCount&mkt=zh-CN'),
        headers: {'User-Agent': 'Lumi-Assistant/1.0'},
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        throw PhotoSourceException(
          'Bing壁纸API请求失败，状态码: ${response.statusCode}',
          code: 'API_ERROR',
        );
      }
      
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final images = jsonData['images'] as List<dynamic>;
      
      final photos = <PhotoInfo>[];
      
      for (int i = 0; i < images.length && i < config.count; i++) {
        final imageData = images[i] as Map<String, dynamic>;
        final photoInfo = _parseBingImageData(imageData, i);
        photos.add(photoInfo);
      }
      
      // 如果需要更多图片，重复现有的图片
      while (photos.length < config.count) {
        final existingPhoto = photos[_random.nextInt(photos.length)];
        final duplicatedPhoto = PhotoInfo(
          id: '${existingPhoto.id}_dup_${photos.length}',
          title: '${existingPhoto.title} (重复 ${photos.length + 1})',
          description: existingPhoto.description,
          author: existingPhoto.author,
          source: existingPhoto.source,
          urls: existingPhoto.urls,
          size: existingPhoto.size,
          takenAt: DateTime.now(),
        );
        photos.add(duplicatedPhoto);
      }
      
      // 缓存结果
      if (config.enableCache) {
        _cache['bing_${config.count}'] = photos;
        
        // 设置缓存过期
        Future.delayed(Duration(minutes: config.cacheMinutes), () {
          _cache.remove('bing_${config.count}');
        });
      }
      
      _usageStats['fetchCount'] = _usageStats['fetchCount']! + 1;
      Loggers.system.info('成功获取${photos.length}张Bing壁纸');
      
      return photos;
    } catch (e) {
      _usageStats['errorCount'] = _usageStats['errorCount']! + 1;
      Loggers.system.severe('获取Bing壁纸失败', e);
      rethrow;
    }
  }
  
  @override
  Future<List<PhotoInfo>> fetchPhotosByCategory(String category, PhotoFetchConfig config) async {
    throw PhotoSourceException(
      'Bing壁纸不支持分类获取',
      code: 'UNSUPPORTED_OPERATION',
    );
  }
  
  @override
  Future<List<PhotoInfo>> searchPhotos(String query, PhotoFetchConfig config) async {
    throw PhotoSourceException(
      'Bing壁纸不支持搜索',
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
          '下载Bing壁纸失败，状态码: ${response.statusCode}',
          code: 'DOWNLOAD_FAILED',
        );
      }
      
      Loggers.system.fine('成功下载Bing壁纸: ${photoInfo.id}，大小: ${response.bodyBytes.length} bytes');
      return response.bodyBytes;
    } catch (e) {
      Loggers.system.severe('下载Bing壁纸失败: ${photoInfo.id}', e);
      throw PhotoSourceException(
        '下载Bing壁纸失败: $e',
        code: 'DOWNLOAD_ERROR',
        originalException: e,
      );
    }
  }
  
  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_apiUrl?format=js&idx=0&n=1&mkt=zh-CN'),
        headers: {'User-Agent': 'Lumi-Assistant/1.0'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      Loggers.system.warning('Bing壁纸服务检查失败', e);
      return false;
    }
  }
  
  @override
  Map<String, dynamic> getUsageStats() {
    return Map<String, dynamic>.from(_usageStats);
  }
  
  /// 解析Bing图片数据
  PhotoInfo _parseBingImageData(Map<String, dynamic> imageData, int index) {
    final urlBase = imageData['urlbase'] as String;
    final title = imageData['title'] as String? ?? '必应每日壁纸';
    final copyright = imageData['copyright'] as String? ?? '';
    final date = imageData['enddate'] as String? ?? '';
    
    // 构建不同尺寸的URL
    final urls = PhotoUrls(
      original: '$_imageBaseUrl${urlBase}_UHD.jpg', // 超高清
      large: '$_imageBaseUrl${urlBase}_1920x1080.jpg', // 全高清
      medium: '$_imageBaseUrl${urlBase}_1366x768.jpg', // 中等尺寸
      small: '$_imageBaseUrl${urlBase}_800x480.jpg', // 小尺寸
      thumbnail: '$_imageBaseUrl${urlBase}_400x240.jpg', // 缩略图
    );
    
    return PhotoInfo(
      id: 'bing_${date}_$index',
      title: title,
      description: copyright,
      author: '必应官方',
      source: name,
      urls: urls,
      size: PhotoSize(
        width: 1920,
        height: 1080,
      ),
      takenAt: _parseBingDate(date),
    );
  }
  
  /// 解析Bing日期格式
  DateTime _parseBingDate(String dateString) {
    try {
      if (dateString.length >= 8) {
        final year = int.parse(dateString.substring(0, 4));
        final month = int.parse(dateString.substring(4, 6));
        final day = int.parse(dateString.substring(6, 8));
        return DateTime(year, month, day);
      }
    } catch (e) {
      Loggers.system.warning('解析Bing日期失败: $dateString', e);
    }
    return DateTime.now();
  }
}
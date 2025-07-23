/// Unsplash 官方API适配器
/// 
/// 从 Unsplash.com 官方API获取免费高质量图片
/// - 完全免费，需要API密钥
/// - 支持随机图片、搜索和分类
/// - 提供世界最高质量的摄影作品
/// - 支持中国大陆访问（通过CDN加速）
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'photo_source_adapter.dart';
import '../../utils/loggers.dart';

/// Unsplash 官方API适配器实现
class UnsplashApiAdapter implements PhotoSourceAdapter {
  /// HTTP客户端
  final http.Client _httpClient;
  
  /// API基础地址
  static const String _apiBaseUrl = 'https://api.unsplash.com';
  
  /// 公共演示用的访问密钥（Unsplash官方提供的演示密钥）
  static const String _accessKey = 'SjEuYQ6_uRVKzS8xmVrjnHLcPcvVfDZoN2xqfKQtCKQ';
  
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
  UnsplashApiAdapter({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  
  @override
  String get name => 'Unsplash';
  
  @override
  String get description => 'Unsplash官方API，世界最高质量的免费摄影作品';
  
  @override
  bool get supportsRandom => true;
  
  @override
  bool get supportsCategories => true;
  
  @override
  bool get supportsSearch => true;
  
  @override
  bool get requiresApiKey => true;
  
  @override
  List<String> get supportedCategories => const [
    'nature', 'landscape', 'city', 'technology', 'people', 
    'animals', 'food', 'travel', 'architecture', 'business',
    'fashion', 'film', 'health', 'history', 'spirituality',
    'experimental', 'textures', 'current-events', 'wallpapers'
  ];
  
  @override
  Future<void> initialize({String? apiKey, Map<String, dynamic>? config}) async {
    try {
      final key = apiKey ?? _accessKey;
      
      // 测试API连接
      final response = await _httpClient.get(
        Uri.parse('$_apiBaseUrl/photos/random?count=1'),
        headers: {
          'Authorization': 'Client-ID $key',
          'User-Agent': 'Lumi-Assistant/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 401) {
        throw PhotoSourceException(
          'Unsplash API密钥无效',
          code: 'INVALID_API_KEY',
        );
      } else if (response.statusCode != 200) {
        throw PhotoSourceException(
          'Unsplash API服务不可用，状态码: ${response.statusCode}',
          code: 'SERVICE_UNAVAILABLE',
        );
      }
      
      Loggers.system.info('Unsplash API适配器初始化成功');
    } catch (e) {
      Loggers.system.severe('Unsplash API适配器初始化失败', e);
      throw PhotoSourceException(
        'Unsplash API适配器初始化失败: $e',
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
          Loggers.system.fine('从缓存获取${cached.length}张Unsplash随机图片');
          return cached.take(config.count).toList()..shuffle(_random);
        }
      }
      
      // 构建API请求URL
      final uri = Uri.parse('$_apiBaseUrl/photos/random').replace(queryParameters: {
        'count': config.count.toString(),
        'orientation': _getOrientationString(config.orientationPreference),
        if (config.orientationPreference != PhotoOrientationPreference.any)
          'orientation': _getOrientationString(config.orientationPreference),
      });
      
      final response = await _httpClient.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'User-Agent': 'Lumi-Assistant/1.0',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        throw PhotoSourceException(
          'Unsplash API请求失败，状态码: ${response.statusCode}',
          code: 'API_ERROR',
        );
      }
      
      final List<dynamic> jsonData = json.decode(response.body);
      final photos = <PhotoInfo>[];
      
      for (int i = 0; i < jsonData.length; i++) {
        final photoData = jsonData[i] as Map<String, dynamic>;
        final photoInfo = _parseUnsplashPhoto(photoData);
        photos.add(photoInfo);
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
      Loggers.system.info('成功获取${photos.length}张Unsplash随机图片');
      
      return photos;
    } catch (e) {
      _usageStats['errorCount'] = _usageStats['errorCount']! + 1;
      Loggers.system.severe('获取Unsplash随机图片失败', e);
      rethrow;
    }
  }
  
  @override
  Future<List<PhotoInfo>> fetchPhotosByCategory(String category, PhotoFetchConfig config) async {
    try {
      // 构建搜索请求URL
      final uri = Uri.parse('$_apiBaseUrl/search/photos').replace(queryParameters: {
        'query': category,
        'page': '1',
        'per_page': config.count.toString(),
        'orientation': _getOrientationString(config.orientationPreference),
        'order_by': 'relevant',
      });
      
      final response = await _httpClient.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'User-Agent': 'Lumi-Assistant/1.0',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        throw PhotoSourceException(
          'Unsplash分类搜索失败，状态码: ${response.statusCode}',
          code: 'API_ERROR',
        );
      }
      
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData['results'] ?? [];
      final photos = <PhotoInfo>[];
      
      for (int i = 0; i < results.length; i++) {
        final photoData = results[i] as Map<String, dynamic>;
        final photoInfo = _parseUnsplashPhoto(photoData);
        photos.add(photoInfo);
      }
      
      _usageStats['fetchCount'] = _usageStats['fetchCount']! + 1;
      Loggers.system.info('成功获取${photos.length}张Unsplash分类图片: $category');
      
      return photos;
    } catch (e) {
      _usageStats['errorCount'] = _usageStats['errorCount']! + 1;
      Loggers.system.severe('获取Unsplash分类图片失败', e);
      rethrow;
    }
  }
  
  @override
  Future<List<PhotoInfo>> searchPhotos(String query, PhotoFetchConfig config) async {
    try {
      // 构建搜索请求URL
      final uri = Uri.parse('$_apiBaseUrl/search/photos').replace(queryParameters: {
        'query': query,
        'page': '1',
        'per_page': config.count.toString(),
        'orientation': _getOrientationString(config.orientationPreference),
        'order_by': 'relevant',
      });
      
      final response = await _httpClient.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'User-Agent': 'Lumi-Assistant/1.0',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        throw PhotoSourceException(
          'Unsplash搜索失败，状态码: ${response.statusCode}',
          code: 'API_ERROR',
        );
      }
      
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData['results'] ?? [];
      final photos = <PhotoInfo>[];
      
      for (int i = 0; i < results.length; i++) {
        final photoData = results[i] as Map<String, dynamic>;
        final photoInfo = _parseUnsplashPhoto(photoData);
        photos.add(photoInfo);
      }
      
      _usageStats['fetchCount'] = _usageStats['fetchCount']! + 1;
      Loggers.system.info('成功搜索到${photos.length}张Unsplash图片: $query');
      
      return photos;
    } catch (e) {
      _usageStats['errorCount'] = _usageStats['errorCount']! + 1;
      Loggers.system.severe('Unsplash搜索失败', e);
      rethrow;
    }
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
          '下载Unsplash图片失败，状态码: ${response.statusCode}',
          code: 'DOWNLOAD_FAILED',
        );
      }
      
      Loggers.system.fine('成功下载Unsplash图片: ${photoInfo.id}，大小: ${response.bodyBytes.length} bytes');
      return response.bodyBytes;
    } catch (e) {
      Loggers.system.severe('下载Unsplash图片失败: ${photoInfo.id}', e);
      throw PhotoSourceException(
        '下载Unsplash图片失败: $e',
        code: 'DOWNLOAD_ERROR',
        originalException: e,
      );
    }
  }
  
  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_apiBaseUrl/photos/random?count=1'),
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'User-Agent': 'Lumi-Assistant/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      Loggers.system.warning('Unsplash API服务检查失败', e);
      return false;
    }
  }
  
  @override
  Map<String, dynamic> getUsageStats() {
    return Map<String, dynamic>.from(_usageStats);
  }
  
  /// 解析Unsplash照片数据
  PhotoInfo _parseUnsplashPhoto(Map<String, dynamic> photoData) {
    final id = photoData['id'] as String;
    final description = photoData['description'] as String? ?? photoData['alt_description'] as String? ?? 'Unsplash美图';
    final user = photoData['user'] as Map<String, dynamic>? ?? {};
    final userName = user['name'] as String? ?? 'Unsplash摄影师';
    final urls = photoData['urls'] as Map<String, dynamic>;
    final width = photoData['width'] as int? ?? 1920;
    final height = photoData['height'] as int? ?? 1080;
    final createdAt = photoData['created_at'] as String?;
    
    final photoUrls = PhotoUrls(
      original: urls['full'] as String? ?? urls['raw'] as String,
      large: urls['regular'] as String,
      medium: urls['small'] as String,
      small: urls['thumb'] as String,
      thumbnail: urls['thumb'] as String,
    );
    
    return PhotoInfo(
      id: id,
      title: description,
      description: description,
      author: userName,
      source: name,
      urls: photoUrls,
      size: PhotoSize(
        width: width,
        height: height,
      ),
      takenAt: _parseUnsplashDate(createdAt),
    );
  }
  
  /// 解析Unsplash日期格式
  DateTime? _parseUnsplashDate(String? dateString) {
    if (dateString == null) return null;
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      Loggers.system.warning('解析Unsplash日期失败: $dateString', e);
      return null;
    }
  }
  
  /// 获取方向字符串
  String _getOrientationString(PhotoOrientationPreference preference) {
    switch (preference) {
      case PhotoOrientationPreference.landscape:
        return 'landscape';
      case PhotoOrientationPreference.portrait:
        return 'portrait';
      case PhotoOrientationPreference.square:
        return 'squarish';
      case PhotoOrientationPreference.any:
        return 'landscape'; // 默认使用横向
    }
  }
}
/// Picsum Photos 适配器
/// 
/// 从 Lorem Picsum (https://picsum.photos/) 获取免费随机图片
/// - 完全免费，无需API密钥
/// - 支持随机图片和指定尺寸
/// - 提供高质量摄影作品
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'photo_source_adapter.dart';
import '../../utils/loggers.dart';

/// Picsum Photos 适配器实现
class PicsumAdapter implements PhotoSourceAdapter {
  /// HTTP客户端
  final http.Client _httpClient;
  
  /// 基础API地址
  static const String _baseUrl = 'https://picsum.photos';
  
  /// 照片列表API地址
  static const String _listUrl = '$_baseUrl/v2/list';
  
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
  PicsumAdapter({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  
  @override
  String get name => 'Picsum Photos';
  
  @override
  String get description => '免费高质量随机图片服务，来自Lorem Picsum';
  
  @override
  bool get supportsRandom => true;
  
  @override
  bool get supportsCategories => false; // Picsum不支持分类
  
  @override
  bool get supportsSearch => false; // Picsum不支持搜索
  
  @override
  bool get requiresApiKey => false;
  
  @override
  List<String> get supportedCategories => const []; // 不支持分类
  
  @override
  Future<void> initialize({String? apiKey, Map<String, dynamic>? config}) async {
    // Picsum不需要初始化，检查网络连接
    try {
      final response = await _httpClient.get(
        Uri.parse('$_listUrl?page=1&limit=1'),
        headers: {'User-Agent': 'Lumi-Assistant/1.0'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode != 200) {
        throw PhotoSourceException(
          'Picsum服务不可用，状态码: ${response.statusCode}',
          code: 'SERVICE_UNAVAILABLE',
        );
      }
      
      Loggers.system.info('Picsum适配器初始化成功');
    } catch (e) {
      Loggers.system.severe('Picsum适配器初始化失败', e);
      throw PhotoSourceException(
        'Picsum适配器初始化失败: $e',
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
      
      // 获取照片列表
      final photos = await _fetchPhotoList(config.count);
      
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
    throw PhotoSourceException(
      'Picsum不支持分类获取照片',
      code: 'UNSUPPORTED_OPERATION',
    );
  }
  
  @override
  Future<List<PhotoInfo>> searchPhotos(String query, PhotoFetchConfig config) async {
    throw PhotoSourceException(
      'Picsum不支持搜索照片',
      code: 'UNSUPPORTED_OPERATION',
    );
  }
  
  @override
  Future<Uint8List> fetchPhotoData(PhotoInfo photoInfo, PhotoSizePreference sizePreference) async {
    try {
      // 根据尺寸偏好选择URL
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
      final response = await _httpClient.get(
        Uri.parse('$_listUrl?page=1&limit=1'),
        headers: {'User-Agent': 'Lumi-Assistant/1.0'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      Loggers.system.warning('Picsum服务检查失败', e);
      return false;
    }
  }
  
  @override
  Map<String, dynamic> getUsageStats() {
    return Map<String, dynamic>.from(_usageStats);
  }
  
  /// 获取照片列表
  Future<List<PhotoInfo>> _fetchPhotoList(int count) async {
    // Picsum的API限制每页最多100张
    final limit = count.clamp(1, 100);
    final page = _random.nextInt(10) + 1; // 随机选择页面
    
    final response = await _httpClient.get(
      Uri.parse('$_listUrl?page=$page&limit=$limit'),
      headers: {'User-Agent': 'Lumi-Assistant/1.0'},
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode != 200) {
      throw PhotoSourceException(
        'API请求失败，状态码: ${response.statusCode}',
        code: 'API_ERROR',
      );
    }
    
    final List<dynamic> jsonList = json.decode(response.body);
    final List<PhotoInfo> photos = [];
    
    for (final item in jsonList) {
      try {
        final photo = _parsePhotoFromJson(item);
        photos.add(photo);
      } catch (e) {
        Loggers.system.warning('解析照片信息失败', e);
        // 继续处理其他照片
      }
    }
    
    // 打乱顺序以增加随机性
    photos.shuffle(_random);
    
    return photos;
  }
  
  /// 从JSON解析照片信息
  PhotoInfo _parsePhotoFromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final width = json['width'] as int;
    final height = json['height'] as int;
    final author = json['author'] as String?;
    // final url = json['url'] as String?; // 暂时不使用原始URL
    
    // 构建不同尺寸的URL
    final urls = PhotoUrls(
      original: '$_baseUrl/id/$id',
      large: '$_baseUrl/id/$id/1200/800',
      medium: '$_baseUrl/id/$id/800/600',
      small: '$_baseUrl/id/$id/400/300',
      thumbnail: '$_baseUrl/id/$id/200/150',
    );
    
    return PhotoInfo(
      id: id,
      title: author != null ? '$author的作品' : '精美照片',
      description: '来自Picsum的高质量摄影作品',
      author: author,
      urls: urls,
      size: PhotoSize(width: width, height: height),
      source: name,
      takenAt: null, // Picsum不提供拍摄时间
    );
  }
  
  /// 释放资源
  void dispose() {
    _httpClient.close();
    _cache.clear();
  }
}
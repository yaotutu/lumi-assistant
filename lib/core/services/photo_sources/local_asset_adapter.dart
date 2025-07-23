/// 本地资源适配器
/// 
/// 从应用内的assets资源获取背景图片
/// - 100%可用，无网络依赖
/// - 高质量预设背景图片
/// - 支持多种分类和主题
/// - 加载速度快，性能优秀
library;

import 'dart:math';
import 'package:flutter/services.dart';
import 'photo_source_adapter.dart';
import '../../utils/loggers.dart';

/// 本地资源适配器实现
class LocalAssetAdapter implements PhotoSourceAdapter {
  /// 随机数生成器
  final Random _random = Random();
  
  /// 使用统计
  final Map<String, int> _usageStats = {
    'fetchCount': 0,
    'errorCount': 0,
    'cacheHits': 0,
  };
  
  /// 预定义的本地背景图片资源
  static const List<Map<String, dynamic>> _localAssets = [
    // 原始1920x1080图片
    {
      'id': 'nature_mountain',
      'path': 'assets/images/backgrounds/nature_mountain.jpg',
      'title': '自然山景 (1920x1080)',
      'description': '雄伟的山脉景观，展现大自然的壮丽',
      'category': 'nature',
      'tags': ['mountain', 'landscape', 'nature'],
      'resolution': '1920x1080',
    },
    {
      'id': 'city_skyline',
      'path': 'assets/images/backgrounds/city_skyline.jpg',
      'title': '城市天际线 (1920x1080)',
      'description': '现代化城市的夜景天际线',
      'category': 'city',
      'tags': ['city', 'skyline', 'urban', 'night'],
      'resolution': '1920x1080',
    },
    {
      'id': 'landscape_lake',
      'path': 'assets/images/backgrounds/landscape_lake.jpg',
      'title': '湖泊风光 (1920x1080)',
      'description': '宁静的湖泊与远山相映成趣',
      'category': 'landscape',
      'tags': ['lake', 'landscape', 'water', 'peaceful'],
      'resolution': '1920x1080',
    },
    {
      'id': 'tech_space',
      'path': 'assets/images/backgrounds/tech_space.jpg',
      'title': '太空科技 (1920x1080)',
      'description': '充满科技感的太空场景',
      'category': 'technology',
      'tags': ['space', 'technology', 'futuristic'],
      'resolution': '1920x1080',
    },
    {
      'id': 'forest_path',
      'path': 'assets/images/backgrounds/forest_path.jpg',
      'title': '森林小径 (1920x1080)',
      'description': '阳光透过森林的神秘小径',
      'category': 'nature',
      'tags': ['forest', 'path', 'nature', 'trees'],
      'resolution': '1920x1080',
    },
    {
      'id': 'beach_sunset',
      'path': 'assets/images/backgrounds/beach_sunset.jpg',
      'title': '海滩日落 (1920x1080)',
      'description': '美丽的海滩日落景象',
      'category': 'landscape',
      'tags': ['beach', 'sunset', 'ocean', 'golden'],
      'resolution': '1920x1080',
    },

    // 测试用不同分辨率图片
    {
      'id': 'test_landscape_800x600',
      'path': 'assets/images/backgrounds/test_landscape_800x600.jpg',
      'title': '测试横屏 (800x600)',
      'description': '标准横屏比例测试图片',
      'category': 'test',
      'tags': ['test', 'landscape', '800x600'],
      'resolution': '800x600',
    },
    {
      'id': 'test_portrait_600x800',
      'path': 'assets/images/backgrounds/test_portrait_600x800.jpg',
      'title': '测试竖屏 (600x800)',
      'description': '标准竖屏比例测试图片',
      'category': 'test',
      'tags': ['test', 'portrait', '600x800'],
      'resolution': '600x800',
    },
    {
      'id': 'test_square_1000x1000',
      'path': 'assets/images/backgrounds/test_square_1000x1000.jpg',
      'title': '测试正方形 (1000x1000)',
      'description': '正方形比例测试图片',
      'category': 'test',
      'tags': ['test', 'square', '1000x1000'],
      'resolution': '1000x1000',
    },
    {
      'id': 'test_thin_portrait_400x800',
      'path': 'assets/images/backgrounds/test_thin_portrait_400x800.jpg',
      'title': '测试窄竖屏 (400x800)',
      'description': '极端竖屏比例测试图片',
      'category': 'test',
      'tags': ['test', 'thin', 'portrait', '400x800'],
      'resolution': '400x800',
    },
    {
      'id': 'test_wide_landscape_1200x400',
      'path': 'assets/images/backgrounds/test_wide_landscape_1200x400.jpg',
      'title': '测试宽横屏 (1200x400)',
      'description': '极端横屏比例测试图片',
      'category': 'test',
      'tags': ['test', 'wide', 'landscape', '1200x400'],
      'resolution': '1200x400',
    },
  ];
  
  /// 构造函数
  LocalAssetAdapter();
  
  @override
  String get name => 'Local Assets';
  
  @override
  String get description => '本地高质量背景图片资源，快速加载无网络依赖';
  
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
    'nature', 'landscape', 'city', 'technology', 'test'
  ];
  
  @override
  Future<void> initialize({String? apiKey, Map<String, dynamic>? config}) async {
    try {
      // 验证资源文件是否存在
      int validAssets = 0;
      for (final asset in _localAssets) {
        try {
          await rootBundle.load(asset['path'] as String);
          validAssets++;
        } catch (e) {
          Loggers.system.warning('本地资源文件不存在: ${asset['path']}', e);
        }
      }
      
      if (validAssets == 0) {
        throw PhotoSourceException(
          '没有找到有效的本地背景图片资源',
          code: 'NO_VALID_ASSETS',
        );
      }
      
      Loggers.system.info('本地资源适配器初始化成功，有效资源: $validAssets/${_localAssets.length}');
    } catch (e) {
      Loggers.system.severe('本地资源适配器初始化失败', e);
      throw PhotoSourceException(
        '本地资源适配器初始化失败: $e',
        code: 'INIT_FAILED',
        originalException: e,
      );
    }
  }
  
  @override
  Future<List<PhotoInfo>> fetchRandomPhotos(PhotoFetchConfig config) async {
    try {
      final photos = <PhotoInfo>[];
      final availableAssets = List<Map<String, dynamic>>.from(_localAssets);
      
      for (int i = 0; i < config.count; i++) {
        if (availableAssets.isEmpty) {
          // 如果资源用完了，重新填充列表
          availableAssets.addAll(_localAssets);
        }
        
        // 随机选择一个资源
        final randomIndex = _random.nextInt(availableAssets.length);
        final asset = availableAssets.removeAt(randomIndex);
        
        final photoInfo = _createPhotoInfoFromAsset(asset, i);
        photos.add(photoInfo);
      }
      
      _usageStats['fetchCount'] = _usageStats['fetchCount']! + 1;
      Loggers.system.info('成功获取${photos.length}张本地背景图片');
      
      return photos;
    } catch (e) {
      _usageStats['errorCount'] = _usageStats['errorCount']! + 1;
      Loggers.system.severe('获取本地背景图片失败', e);
      rethrow;
    }
  }
  
  @override
  Future<List<PhotoInfo>> fetchPhotosByCategory(String category, PhotoFetchConfig config) async {
    try {
      // 根据分类过滤资源
      final categoryAssets = _localAssets
          .where((asset) => asset['category'] == category)
          .toList();
      
      if (categoryAssets.isEmpty) {
        throw PhotoSourceException(
          '没有找到分类 $category 的本地背景图片',
          code: 'CATEGORY_NOT_FOUND',
        );
      }
      
      final photos = <PhotoInfo>[];
      final availableAssets = List<Map<String, dynamic>>.from(categoryAssets);
      
      for (int i = 0; i < config.count; i++) {
        if (availableAssets.isEmpty) {
          // 如果当前分类的资源用完了，重新填充
          availableAssets.addAll(categoryAssets);
        }
        
        final randomIndex = _random.nextInt(availableAssets.length);
        final asset = availableAssets.removeAt(randomIndex);
        
        final photoInfo = _createPhotoInfoFromAsset(asset, i);
        photos.add(photoInfo);
      }
      
      _usageStats['fetchCount'] = _usageStats['fetchCount']! + 1;
      Loggers.system.info('成功获取${photos.length}张$category类别的本地背景图片');
      
      return photos;
    } catch (e) {
      _usageStats['errorCount'] = _usageStats['errorCount']! + 1;
      Loggers.system.severe('获取分类背景图片失败', e);
      rethrow;
    }
  }
  
  @override
  Future<List<PhotoInfo>> searchPhotos(String query, PhotoFetchConfig config) async {
    throw PhotoSourceException(
      '本地资源不支持搜索功能',
      code: 'UNSUPPORTED_OPERATION',
    );
  }
  
  @override
  Future<Uint8List> fetchPhotoData(PhotoInfo photoInfo, PhotoSizePreference sizePreference) async {
    try {
      // 从PhotoInfo的URL中提取asset路径
      final assetPath = _extractAssetPath(photoInfo);
      
      // 加载资源文件
      final byteData = await rootBundle.load(assetPath);
      final imageData = byteData.buffer.asUint8List();
      
      Loggers.system.fine('成功加载本地图片: ${photoInfo.id}，大小: ${imageData.length} bytes');
      return imageData;
    } catch (e) {
      Loggers.system.severe('加载本地图片失败: ${photoInfo.id}', e);
      throw PhotoSourceException(
        '加载本地图片失败: $e',
        code: 'LOAD_FAILED',
        originalException: e,
      );
    }
  }
  
  @override
  Future<bool> isAvailable() async {
    // 本地资源适配器始终可用
    return true;
  }
  
  @override
  Map<String, dynamic> getUsageStats() {
    return Map<String, dynamic>.from(_usageStats);
  }
  
  /// 从资源数据创建PhotoInfo对象
  PhotoInfo _createPhotoInfoFromAsset(Map<String, dynamic> asset, int index) {
    final id = '${asset['id']}_${DateTime.now().millisecondsSinceEpoch}_$index';
    final assetPath = asset['path'] as String;
    
    // 使用asset:// 协议标识本地资源
    final urls = PhotoUrls(
      original: 'asset://$assetPath',
      large: 'asset://$assetPath',
      medium: 'asset://$assetPath',
      small: 'asset://$assetPath',
      thumbnail: 'asset://$assetPath',
    );
    
    return PhotoInfo(
      id: id,
      title: asset['title'] as String,
      description: asset['description'] as String,
      author: 'Lumi Assistant Collection',
      source: name,
      urls: urls,
      size: PhotoSize(
        width: 1920,
        height: 1080,
      ),
      takenAt: DateTime.now(),
    );
  }
  
  /// 从PhotoInfo的URL中提取asset路径
  String _extractAssetPath(PhotoInfo photoInfo) {
    final url = photoInfo.urls.original;
    if (url.startsWith('asset://')) {
      return url.substring(8); // 移除 'asset://' 前缀
    } else {
      throw PhotoSourceException(
        '无效的本地资源URL格式: $url',
        code: 'INVALID_URL_FORMAT',
      );
    }
  }
  
  /// 获取指定分类的资源数量
  int getAssetCountByCategory(String category) {
    return _localAssets
        .where((asset) => asset['category'] == category)
        .length;
  }
  
  /// 获取所有可用的资源信息
  List<Map<String, dynamic>> getAllAssetInfo() {
    return List<Map<String, dynamic>>.from(_localAssets);
  }
}
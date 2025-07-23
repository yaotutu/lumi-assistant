/// 照片源管理器
/// 
/// 统一管理多个照片源适配器，提供：
/// - 适配器注册和管理
/// - 智能照片获取策略
/// - 故障转移和负载均衡
/// - 缓存和性能优化
library;

import 'dart:async';
import 'dart:typed_data';
import 'photo_source_adapter.dart';
import 'picsum_adapter.dart';
import 'unsplash_source_adapter.dart';
import 'unsplash_api_adapter.dart';
import 'placeholder_adapter.dart';
import 'local_asset_adapter.dart';
import 'bing_wallpaper_adapter.dart';
import '../../utils/loggers.dart';

/// 照片源管理器
class PhotoSourceManager {
  /// 单例实例
  static final PhotoSourceManager _instance = PhotoSourceManager._internal();
  
  /// 获取单例实例
  static PhotoSourceManager get instance => _instance;
  
  /// 私有构造函数
  PhotoSourceManager._internal();
  
  /// 已注册的适配器
  final Map<String, PhotoSourceAdapter> _adapters = {};
  
  /// 当前活跃的适配器
  final List<String> _activeAdapters = [];
  
  /// 默认配置
  PhotoFetchConfig _defaultConfig = const PhotoFetchConfig();
  
  /// 是否已初始化
  bool _isInitialized = false;
  
  /// 获取策略
  PhotoFetchStrategy _fetchStrategy = PhotoFetchStrategy.roundRobin;
  
  /// 轮询索引
  int _roundRobinIndex = 0;
  
  /// 初始化管理器
  Future<void> initialize({
    PhotoFetchConfig? defaultConfig,
    PhotoFetchStrategy? fetchStrategy,
  }) async {
    if (_isInitialized) {
      Loggers.system.warning('PhotoSourceManager已经初始化');
      return;
    }
    
    try {
      _defaultConfig = defaultConfig ?? _defaultConfig;
      _fetchStrategy = fetchStrategy ?? _fetchStrategy;
      
      // 注册默认适配器
      await _registerDefaultAdapters();
      
      // 检查适配器可用性
      await _checkAdaptersAvailability();
      
      _isInitialized = true;
      Loggers.system.info('PhotoSourceManager初始化成功，活跃适配器: ${_activeAdapters.length}');
    } catch (e) {
      Loggers.system.severe('PhotoSourceManager初始化失败', e);
      rethrow;
    }
  }
  
  /// 注册照片源适配器
  Future<void> registerAdapter(String name, PhotoSourceAdapter adapter) async {
    try {
      await adapter.initialize();
      _adapters[name] = adapter;
      
      // 检查是否可用
      if (await adapter.isAvailable()) {
        if (!_activeAdapters.contains(name)) {
          _activeAdapters.add(name);
        }
        Loggers.system.info('照片源适配器注册成功: $name');
      } else {
        Loggers.system.warning('照片源适配器不可用: $name');
      }
    } catch (e) {
      Loggers.system.severe('注册照片源适配器失败: $name', e);
      throw PhotoSourceException(
        '注册适配器失败: $name',
        originalException: e,
      );
    }
  }
  
  /// 注销照片源适配器
  void unregisterAdapter(String name) {
    _adapters.remove(name);
    _activeAdapters.remove(name);
    Loggers.system.info('照片源适配器已注销: $name');
  }
  
  /// 获取随机照片
  Future<List<PhotoInfo>> fetchRandomPhotos({
    PhotoFetchConfig? config,
    String? preferredAdapter,
  }) async {
    _ensureInitialized();
    
    final fetchConfig = config ?? _defaultConfig;
    
    // 如果指定了适配器，优先使用
    if (preferredAdapter != null && _activeAdapters.contains(preferredAdapter)) {
      return await _fetchFromAdapter(preferredAdapter, (adapter) => 
        adapter.fetchRandomPhotos(fetchConfig));
    }
    
    // 使用获取策略选择适配器
    return await _fetchWithStrategy((adapter) => 
      adapter.fetchRandomPhotos(fetchConfig));
  }
  
  /// 根据类别获取照片
  Future<List<PhotoInfo>> fetchPhotosByCategory(
    String category, {
    PhotoFetchConfig? config,
    String? preferredAdapter,
  }) async {
    _ensureInitialized();
    
    final fetchConfig = config ?? _defaultConfig;
    
    // 过滤支持分类的适配器
    final categoryAdapters = _activeAdapters
        .where((name) => _adapters[name]!.supportsCategories)
        .toList();
    
    if (categoryAdapters.isEmpty) {
      throw PhotoSourceException('没有支持分类获取的照片源');
    }
    
    // 如果指定了适配器且支持分类，优先使用
    if (preferredAdapter != null && categoryAdapters.contains(preferredAdapter)) {
      return await _fetchFromAdapter(preferredAdapter, (adapter) => 
        adapter.fetchPhotosByCategory(category, fetchConfig));
    }
    
    // 从支持分类的适配器中选择
    final selectedAdapter = _selectAdapterByStrategy(categoryAdapters);
    return await _fetchFromAdapter(selectedAdapter, (adapter) => 
      adapter.fetchPhotosByCategory(category, fetchConfig));
  }
  
  /// 搜索照片
  Future<List<PhotoInfo>> searchPhotos(
    String query, {
    PhotoFetchConfig? config,
    String? preferredAdapter,
  }) async {
    _ensureInitialized();
    
    final fetchConfig = config ?? _defaultConfig;
    
    // 过滤支持搜索的适配器
    final searchAdapters = _activeAdapters
        .where((name) => _adapters[name]!.supportsSearch)
        .toList();
    
    if (searchAdapters.isEmpty) {
      throw PhotoSourceException('没有支持搜索的照片源');
    }
    
    // 如果指定了适配器且支持搜索，优先使用
    if (preferredAdapter != null && searchAdapters.contains(preferredAdapter)) {
      return await _fetchFromAdapter(preferredAdapter, (adapter) => 
        adapter.searchPhotos(query, fetchConfig));
    }
    
    // 从支持搜索的适配器中选择
    final selectedAdapter = _selectAdapterByStrategy(searchAdapters);
    return await _fetchFromAdapter(selectedAdapter, (adapter) => 
      adapter.searchPhotos(query, fetchConfig));
  }
  
  /// 获取照片数据
  Future<Uint8List> fetchPhotoData(
    PhotoInfo photoInfo,
    PhotoSizePreference sizePreference,
  ) async {
    _ensureInitialized();
    
    // 根据照片来源选择适配器
    final adapterName = _getAdapterNameBySource(photoInfo.source);
    if (adapterName == null || !_activeAdapters.contains(adapterName)) {
      throw PhotoSourceException('找不到照片源对应的适配器: ${photoInfo.source}');
    }
    
    return await _fetchFromAdapter(adapterName, (adapter) => 
      adapter.fetchPhotoData(photoInfo, sizePreference));
  }
  
  /// 获取所有可用的适配器信息
  List<PhotoSourceAdapterInfo> getAvailableAdapters() {
    return _activeAdapters.map((name) {
      final adapter = _adapters[name]!;
      return PhotoSourceAdapterInfo(
        name: adapter.name,
        description: adapter.description,
        supportsRandom: adapter.supportsRandom,
        supportsCategories: adapter.supportsCategories,
        supportsSearch: adapter.supportsSearch,
        supportedCategories: adapter.supportedCategories,
        usageStats: adapter.getUsageStats(),
      );
    }).toList();
  }
  
  /// 设置获取策略
  void setFetchStrategy(PhotoFetchStrategy strategy) {
    _fetchStrategy = strategy;
    Loggers.system.info('照片获取策略已更新: ${strategy.name}');
  }
  
  /// 设置默认配置
  void setDefaultConfig(PhotoFetchConfig config) {
    _defaultConfig = config;
    Loggers.system.info('默认照片获取配置已更新');
  }
  
  /// 检查适配器可用性
  Future<void> checkAdaptersHealth() async {
    final healthCheckResults = <String, bool>{};
    
    for (final name in _adapters.keys) {
      try {
        final isAvailable = await _adapters[name]!.isAvailable();
        healthCheckResults[name] = isAvailable;
        
        if (isAvailable && !_activeAdapters.contains(name)) {
          _activeAdapters.add(name);
        } else if (!isAvailable && _activeAdapters.contains(name)) {
          _activeAdapters.remove(name);
        }
      } catch (e) {
        healthCheckResults[name] = false;
        _activeAdapters.remove(name);
        Loggers.system.warning('适配器健康检查失败: $name', e);
      }
    }
    
    Loggers.system.info('适配器健康检查完成: $healthCheckResults');
  }
  
  /// 注册默认适配器
  Future<void> _registerDefaultAdapters() async {
    // 注册本地资源适配器（最高优先级，无需网络，100%可用）
    await registerAdapter('local_asset', LocalAssetAdapter());
    
    // 注册占位图片适配器（备选方案，无需网络，100%可用）
    await registerAdapter('placeholder', PlaceholderAdapter());
    
    // 注册Unsplash官方API适配器（最高质量的摄影作品）
    try {
      await registerAdapter('unsplash_api', UnsplashApiAdapter());
    } catch (e) {
      Loggers.system.warning('Unsplash API适配器注册失败（可能是网络问题）: $e');
    }
    
    // 注册Bing壁纸适配器（中国大陆可访问，高质量官方壁纸）
    try {
      await registerAdapter('bing_wallpaper', BingWallpaperAdapter());
    } catch (e) {
      Loggers.system.warning('Bing壁纸适配器注册失败（可能是网络问题）: $e');
    }
    
    // 注册Unsplash Source适配器（备用方案）
    try {
      await registerAdapter('unsplash_source', UnsplashSourceAdapter());
    } catch (e) {
      Loggers.system.warning('Unsplash Source适配器注册失败（可能是网络问题）: $e');
    }
    
    // 注册Picsum适配器（备用，可能在中国大陆无法访问）
    try {
      await registerAdapter('picsum', PicsumAdapter());
    } catch (e) {
      Loggers.system.warning('Picsum适配器注册失败（可能是网络问题）: $e');
    }
  }
  
  /// 检查适配器可用性
  Future<void> _checkAdaptersAvailability() async {
    await checkAdaptersHealth();
    
    if (_activeAdapters.isEmpty) {
      throw PhotoSourceException('没有可用的照片源适配器');
    }
  }
  
  /// 使用策略获取照片
  Future<List<PhotoInfo>> _fetchWithStrategy(
    Future<List<PhotoInfo>> Function(PhotoSourceAdapter) fetcher,
  ) async {
    if (_activeAdapters.isEmpty) {
      throw PhotoSourceException('没有可用的照片源适配器');
    }
    
    final selectedAdapter = _selectAdapterByStrategy(_activeAdapters);
    return await _fetchFromAdapter(selectedAdapter, fetcher);
  }
  
  /// 根据策略选择适配器
  String _selectAdapterByStrategy(List<String> availableAdapters) {
    switch (_fetchStrategy) {
      case PhotoFetchStrategy.roundRobin:
        final adapter = availableAdapters[_roundRobinIndex % availableAdapters.length];
        _roundRobinIndex = (_roundRobinIndex + 1) % availableAdapters.length;
        return adapter;
        
      case PhotoFetchStrategy.random:
        return availableAdapters[DateTime.now().millisecond % availableAdapters.length];
        
      case PhotoFetchStrategy.firstAvailable:
        return availableAdapters.first;
    }
  }
  
  /// 从指定适配器获取数据
  Future<T> _fetchFromAdapter<T>(
    String adapterName,
    Future<T> Function(PhotoSourceAdapter) fetcher,
  ) async {
    final adapter = _adapters[adapterName];
    if (adapter == null) {
      throw PhotoSourceException('适配器不存在: $adapterName');
    }
    
    try {
      return await fetcher(adapter);
    } catch (e) {
      // 如果失败，将适配器标记为不可用
      _activeAdapters.remove(adapterName);
      Loggers.system.warning('适配器执行失败，已移除: $adapterName', e);
      rethrow;
    }
  }
  
  /// 根据照片源获取适配器名称
  String? _getAdapterNameBySource(String source) {
    for (final entry in _adapters.entries) {
      if (entry.value.name == source) {
        return entry.key;
      }
    }
    return null;
  }
  
  /// 确保已初始化
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw PhotoSourceException('PhotoSourceManager未初始化，请先调用initialize()');
    }
  }
}

/// 照片获取策略
enum PhotoFetchStrategy {
  /// 轮询策略（默认）
  roundRobin,
  /// 随机策略
  random,
  /// 第一个可用
  firstAvailable,
}

/// 照片源适配器信息
class PhotoSourceAdapterInfo {
  /// 适配器名称
  final String name;
  
  /// 适配器描述
  final String description;
  
  /// 是否支持随机获取
  final bool supportsRandom;
  
  /// 是否支持分categories获取
  final bool supportsCategories;
  
  /// 是否支持搜索
  final bool supportsSearch;
  
  /// 支持的分类列表
  final List<String> supportedCategories;
  
  /// 使用统计
  final Map<String, dynamic> usageStats;
  
  /// 构造函数
  const PhotoSourceAdapterInfo({
    required this.name,
    required this.description,
    required this.supportsRandom,
    required this.supportsCategories,
    required this.supportsSearch,
    required this.supportedCategories,
    required this.usageStats,
  });
}
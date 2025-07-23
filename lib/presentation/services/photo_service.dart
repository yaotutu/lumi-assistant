/// 照片服务 - Presentation层
/// 
/// 为UI层提供照片相关功能，封装Core层的PhotoSourceManager
library;

import 'dart:typed_data';
import '../../core/services/photo_sources/photo_source_manager.dart';
import '../../core/services/photo_sources/photo_source_adapter.dart';

/// 照片服务类
class PhotoService {
  /// 单例实例
  static final PhotoService _instance = PhotoService._internal();
  
  /// 获取单例实例
  static PhotoService get instance => _instance;
  
  /// 私有构造函数
  PhotoService._internal();
  
  /// 照片源管理器
  PhotoSourceManager get _manager => PhotoSourceManager.instance;
  
  /// 初始化服务
  Future<void> initialize() async {
    await _manager.initialize();
  }
  
  /// 获取随机照片
  Future<List<PhotoInfo>> fetchRandomPhotos({
    PhotoFetchConfig? config,
    String? preferredAdapter,
  }) async {
    return await _manager.fetchRandomPhotos(
      config: config,
      preferredAdapter: preferredAdapter,
    );
  }
  
  /// 获取照片数据
  Future<Uint8List> fetchPhotoData(
    PhotoInfo photoInfo,
    PhotoSizePreference sizePreference,
  ) async {
    return await _manager.fetchPhotoData(photoInfo, sizePreference);
  }
  
  /// 检查适配器健康状态
  Future<void> checkAdaptersHealth() async {
    await _manager.checkAdaptersHealth();
  }
  
  /// 获取可用适配器信息
  List<PhotoSourceAdapterInfo> getAvailableAdapters() {
    return _manager.getAvailableAdapters();
  }
}
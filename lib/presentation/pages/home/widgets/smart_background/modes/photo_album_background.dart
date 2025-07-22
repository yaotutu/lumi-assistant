import 'package:flutter/material.dart';

/// 电子相册背景组件
/// 
/// 职责：
/// - 显示用户照片的轮播展示
/// - 支持照片的自动切换和手动控制
/// - 提供优雅的照片展示效果
/// 
/// 特点：
/// - 自动轮播用户选择的照片
/// - 支持各种照片格式和尺寸
/// - 平滑的切换动画效果
/// 
/// TODO: 未来功能扩展
/// - 连接相册应用获取照片
/// - 支持照片筛选和分类
/// - 添加照片信息显示
class PhotoAlbumBackground extends StatefulWidget {
  /// 构造函数
  const PhotoAlbumBackground({super.key});

  @override
  State<PhotoAlbumBackground> createState() => _PhotoAlbumBackgroundState();
}

class _PhotoAlbumBackgroundState extends State<PhotoAlbumBackground> {
  // 当前显示的照片索引
  int _currentPhotoIndex = 0;
  
  // 示例照片列表（实际应用中应从设备相册获取）
  final List<String> _demoPhotos = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4', // 山景
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e', // 森林
    'https://images.unsplash.com/photo-1501594907352-04cda38ebc29', // 湖泊
    'https://images.unsplash.com/photo-1426604966848-d7adac402bff', // 自然风光
    'https://images.unsplash.com/photo-1544947950-fa07a98d237f', // 城市
  ];

  @override
  void initState() {
    super.initState();
    
    // 启动自动轮播定时器
    _startAutoSlideShow();
  }
  
  /// 启动自动轮播
  void _startAutoSlideShow() {
    // 每10秒切换一张照片
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _currentPhotoIndex = (_currentPhotoIndex + 1) % _demoPhotos.length;
        });
        _startAutoSlideShow(); // 递归调用，继续轮播
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // 深色背景，确保照片加载失败时有合适的背景
        color: Color(0xFF1A237E),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 照片显示区域
          _buildPhotoDisplay(),
          
          // 渐变遮罩，确保上层内容清晰可见
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
          
          // 照片信息和控制区域
          _buildPhotoControls(),
        ],
      ),
    );
  }
  
  /// 构建照片显示区域
  Widget _buildPhotoDisplay() {
    if (_demoPhotos.isEmpty) {
      // 如果没有照片，显示占位内容
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无照片',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请在设置中添加相册照片',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Image.network(
        _demoPhotos[_currentPhotoIndex],
        key: ValueKey(_currentPhotoIndex),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 照片加载失败时显示占位图
          return Container(
            color: const Color(0xFF3949AB),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '照片加载失败',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          
          // 照片加载中显示进度指示器
          return Container(
            color: const Color(0xFF3949AB),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 构建照片控制区域
  Widget _buildPhotoControls() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 照片信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '电子相册',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_currentPhotoIndex + 1} / ${_demoPhotos.length}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          // 手动切换按钮
          Row(
            children: [
              // 上一张
              IconButton(
                onPressed: _demoPhotos.length > 1 ? _previousPhoto : null,
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                tooltip: '上一张照片',
              ),
              
              // 下一张
              IconButton(
                onPressed: _demoPhotos.length > 1 ? _nextPhoto : null,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                tooltip: '下一张照片',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 切换到上一张照片
  void _previousPhoto() {
    setState(() {
      _currentPhotoIndex = 
          (_currentPhotoIndex - 1 + _demoPhotos.length) % _demoPhotos.length;
    });
  }
  
  /// 切换到下一张照片
  void _nextPhoto() {
    setState(() {
      _currentPhotoIndex = (_currentPhotoIndex + 1) % _demoPhotos.length;
    });
  }
}
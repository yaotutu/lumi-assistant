import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 背景系统管理器
/// 
/// 核心职责：
/// - 统一管理所有背景模式的切换和渲染
/// - 提供背景系统的统一接口和生命周期管理
/// - 支持动态背景模式切换和配置管理
/// 
/// 设计理念：
/// - 纯背景展示，完全不可交互
/// - 支持复杂的背景逻辑（天气、时间、电子相册等）
/// - 模块化设计，每个背景模式独立实现
/// - 统一的配置管理和状态管理
class BackgroundSystemManager extends ConsumerStatefulWidget {
  /// 当前背景模式
  final BackgroundSystemMode mode;
  
  /// 背景配置参数
  final BackgroundSystemConfig config;
  
  /// 构造函数
  const BackgroundSystemManager({
    super.key,
    required this.mode,
    required this.config,
  });

  @override
  ConsumerState<BackgroundSystemManager> createState() => _BackgroundSystemManagerState();
}

class _BackgroundSystemManagerState extends ConsumerState<BackgroundSystemManager> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // 基础渐变背景，确保在任何情况下都有背景
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E), // 深蓝色
            Color(0xFF3949AB), // 中蓝色  
            Color(0xFF5C6BC0), // 浅蓝色
            Color(0xFF7E57C2), // 淡紫色
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 动态背景模式渲染器
          _buildBackgroundModeRenderer(),
          
          // 基础时间显示层（所有模式都有）
          _buildBaseTimeLayer(),
          
          // 渐变遮罩层（统一视觉效果）
          _buildOverlayLayer(),
        ],
      ),
    );
  }
  
  /// 构建背景模式渲染器
  Widget _buildBackgroundModeRenderer() {
    switch (widget.mode) {
      case BackgroundSystemMode.time:
        return _buildTimeMode();
      case BackgroundSystemMode.weather:
        return _buildWeatherMode();
      case BackgroundSystemMode.photoAlbum:
        return _buildPhotoAlbumMode();
      case BackgroundSystemMode.calendar:
        return _buildCalendarMode();
      case BackgroundSystemMode.systemInfo:
        return _buildSystemInfoMode();
      case BackgroundSystemMode.minimal:
        return _buildMinimalMode();
    }
  }
  
  /// 构建时间模式背景
  Widget _buildTimeMode() {
    // TODO: 实现复杂的时间背景
    // 功能包括：多时区显示、节假日提醒、倒计时等
    return const Center(
      child: Text(
        '🕐 时间模式背景\n（待实现）',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// 构建天气模式背景
  Widget _buildWeatherMode() {
    // TODO: 实现天气背景系统
    // 功能包括：实时天气、天气动画、天气预报、空气质量等
    return const Center(
      child: Text(
        '🌤️ 天气模式背景\n（待实现）',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// 构建电子相册模式背景
  Widget _buildPhotoAlbumMode() {
    // TODO: 实现电子相册背景
    // 功能包括：照片轮播、过渡动画、照片管理、相册选择等
    return const Center(
      child: Text(
        '📷 电子相册模式背景\n（待实现）',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// 构建日历模式背景
  Widget _buildCalendarMode() {
    // TODO: 实现日历背景系统
    // 功能包括：月历显示、事件提醒、节假日标记、农历显示等
    return const Center(
      child: Text(
        '📅 日历模式背景\n（待实现）',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// 构建系统信息模式背景
  Widget _buildSystemInfoMode() {
    // TODO: 实现系统信息背景
    // 功能包括：系统状态、网络信息、设备信息、性能监控等
    return const Center(
      child: Text(
        '💻 系统信息模式背景\n（待实现）',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// 构建极简模式背景
  Widget _buildMinimalMode() {
    // 极简模式：只有渐变背景，无任何额外内容
    return const SizedBox.shrink();
  }
  
  /// 构建基础时间显示层
  Widget _buildBaseTimeLayer() {
    // 当前使用简单的时间显示，未来可以根据模式调整
    if (widget.config.showBaseTime) {
      return Positioned(
        bottom: 160,
        left: 0,
        right: 0,
        child: StreamBuilder<DateTime>(
          stream: Stream.periodic(
            const Duration(seconds: 1),
            (_) => DateTime.now(),
          ),
          initialData: DateTime.now(),
          builder: (context, snapshot) {
            final now = snapshot.data ?? DateTime.now();
            
            return Column(
              children: [
                // 时间显示
                Text(
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: widget.config.timeOpacity),
                    fontSize: widget.config.timeFontSize,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 4.0,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
                
                if (widget.config.showDate) ...[
                  const SizedBox(height: 8),
                  // 日期显示
                  Text(
                    _formatDate(now),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: widget.config.dateOpacity),
                      fontSize: widget.config.dateFontSize,
                      fontWeight: FontWeight.w300,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  /// 构建遮罩层
  Widget _buildOverlayLayer() {
    if (widget.config.enableOverlay) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: widget.config.overlayTopOpacity),
              Colors.transparent,
              Colors.black.withValues(alpha: widget.config.overlayBottomOpacity),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  /// 格式化日期
  String _formatDate(DateTime time) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const months = [
      '1月', '2月', '3月', '4月', '5月', '6月',
      '7月', '8月', '9月', '10月', '11月', '12月'
    ];
    return '${time.year}年${months[time.month - 1]}${time.day}日 ${weekdays[time.weekday % 7]}';
  }
}

/// 背景系统模式枚举
enum BackgroundSystemMode {
  /// 时间模式 - 复杂的时间显示和时间相关功能
  time('时间模式', Icons.access_time, '显示时间、节假日、倒计时等'),
  
  /// 天气模式 - 天气信息和天气动画
  weather('天气模式', Icons.wb_sunny, '显示天气信息、动画效果、预报等'),
  
  /// 电子相册模式 - 照片轮播和管理
  photoAlbum('电子相册', Icons.photo_library, '照片轮播、相册管理、过渡动画'),
  
  /// 日历模式 - 日历显示和事件管理
  calendar('日历模式', Icons.calendar_today, '日历显示、事件提醒、节假日标记'),
  
  /// 系统信息模式 - 系统状态和设备信息
  systemInfo('系统信息', Icons.info, '系统状态、设备信息、性能监控'),
  
  /// 极简模式 - 纯渐变背景
  minimal('极简模式', Icons.minimize, '纯净的渐变背景，无额外内容');
  
  const BackgroundSystemMode(this.displayName, this.icon, this.description);
  
  /// 显示名称
  final String displayName;
  
  /// 图标
  final IconData icon;
  
  /// 功能描述
  final String description;
}

/// 背景系统配置类
class BackgroundSystemConfig {
  /// 是否显示基础时间
  final bool showBaseTime;
  
  /// 是否显示日期
  final bool showDate;
  
  /// 时间字体大小
  final double timeFontSize;
  
  /// 日期字体大小
  final double dateFontSize;
  
  /// 时间透明度
  final double timeOpacity;
  
  /// 日期透明度
  final double dateOpacity;
  
  /// 是否启用遮罩层
  final bool enableOverlay;
  
  /// 顶部遮罩透明度
  final double overlayTopOpacity;
  
  /// 底部遮罩透明度
  final double overlayBottomOpacity;
  
  /// 自动切换间隔（秒）
  final int autoSwitchInterval;
  
  /// 是否启用自动切换
  final bool enableAutoSwitch;
  
  /// 构造函数
  const BackgroundSystemConfig({
    this.showBaseTime = true,
    this.showDate = true,
    this.timeFontSize = 56.0,
    this.dateFontSize = 16.0,
    this.timeOpacity = 0.9,
    this.dateOpacity = 0.7,
    this.enableOverlay = true,
    this.overlayTopOpacity = 0.1,
    this.overlayBottomOpacity = 0.1,
    this.autoSwitchInterval = 30,
    this.enableAutoSwitch = false,
  });
  
  /// 默认配置
  static const BackgroundSystemConfig defaultConfig = BackgroundSystemConfig();
  
  /// 极简配置
  static const BackgroundSystemConfig minimalConfig = BackgroundSystemConfig(
    showBaseTime: true,
    showDate: false,
    enableOverlay: false,
  );
  
  /// 复杂配置
  static const BackgroundSystemConfig complexConfig = BackgroundSystemConfig(
    showBaseTime: true,
    showDate: true,
    timeFontSize: 64.0,
    dateFontSize: 18.0,
    enableAutoSwitch: true,
    autoSwitchInterval: 60,
  );
  
  /// 复制并修改配置
  BackgroundSystemConfig copyWith({
    bool? showBaseTime,
    bool? showDate,
    double? timeFontSize,
    double? dateFontSize,
    double? timeOpacity,
    double? dateOpacity,
    bool? enableOverlay,
    double? overlayTopOpacity,
    double? overlayBottomOpacity,
    int? autoSwitchInterval,
    bool? enableAutoSwitch,
  }) {
    return BackgroundSystemConfig(
      showBaseTime: showBaseTime ?? this.showBaseTime,
      showDate: showDate ?? this.showDate,
      timeFontSize: timeFontSize ?? this.timeFontSize,
      dateFontSize: dateFontSize ?? this.dateFontSize,
      timeOpacity: timeOpacity ?? this.timeOpacity,
      dateOpacity: dateOpacity ?? this.dateOpacity,
      enableOverlay: enableOverlay ?? this.enableOverlay,
      overlayTopOpacity: overlayTopOpacity ?? this.overlayTopOpacity,
      overlayBottomOpacity: overlayBottomOpacity ?? this.overlayBottomOpacity,
      autoSwitchInterval: autoSwitchInterval ?? this.autoSwitchInterval,
      enableAutoSwitch: enableAutoSwitch ?? this.enableAutoSwitch,
    );
  }
}
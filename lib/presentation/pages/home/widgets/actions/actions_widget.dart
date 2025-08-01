import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'weather_clock_widget.dart';

/// 操作区域组件
/// 
/// 职责：
/// - 提供各种功能操作按钮和控件
/// - 可以放置在页面的任意位置（中间、底部等）
/// - 支持动态显示和隐藏不同的操作组
/// 
/// 特点：
/// - 位置灵活，可配置放置位置
/// - 包含快捷操作、常用功能、扩展工具等
/// - 支持根据上下文动态调整显示内容
/// - 可以包含多个操作子区域
class ActionsWidget extends ConsumerWidget {
  /// 操作区域的位置
  final ActionsPosition position;
  
  /// 是否显示扩展操作
  final bool showExtendedActions;
  
  /// 构造函数
  const ActionsWidget({
    super.key,
    this.position = ActionsPosition.center,
    this.showExtendedActions = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 居中位置时使用特殊处理，确保完全居中
    if (position == ActionsPosition.center) {
      return Positioned.fill(
        child: Center(
          child: _buildCenterActions(context),
        ),
      );
    }
    
    // 其他位置使用原有的定位逻辑
    return Positioned(
      top: _getTopPosition(context),
      left: _getLeftPosition(context),
      right: _getRightPosition(context),
      bottom: _getBottomPosition(context),
      child: _buildActionsContent(context),
    );
  }
  
  /// 获取顶部位置
  double? _getTopPosition(BuildContext context) {
    switch (position) {
      case ActionsPosition.top:
        return 120; // 在状态栏下方
      case ActionsPosition.center:
        return null; // 居中，不设置top
      case ActionsPosition.bottom:
        return null; // 底部，不设置top
    }
  }
  
  /// 获取左侧位置
  double? _getLeftPosition(BuildContext context) {
    // 居中位置时不设置左右边距，让内容自由居中
    if (position == ActionsPosition.center) {
      return 0;
    }
    return 20; // 其他位置使用20px边距
  }
  
  /// 获取右侧位置
  double? _getRightPosition(BuildContext context) {
    // 居中位置时不设置左右边距，让内容自由居中
    if (position == ActionsPosition.center) {
      return 0;
    }
    return 20; // 其他位置使用20px边距
  }
  
  /// 获取底部位置
  double? _getBottomPosition(BuildContext context) {
    switch (position) {
      case ActionsPosition.top:
        return null;
      case ActionsPosition.center:
        return null; // 居中，不设置bottom
      case ActionsPosition.bottom:
        return 100; // 距离底部100px
    }
  }
  
  /// 构建操作区域内容
  Widget _buildActionsContent(BuildContext context) {
    if (position == ActionsPosition.center) {
      return Center(child: _buildCenterActions(context));
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPrimaryActions(context),
        if (showExtendedActions) ...[
          const SizedBox(height: 16),
          _buildExtendedActions(context),
        ],
      ],
    );
  }
  
  /// 构建居中操作区域
  Widget _buildCenterActions(BuildContext context) {
    // 在中央位置显示天气时钟组件
    return const WeatherClockWidget();
  }
  
  /// 构建主要操作
  Widget _buildPrimaryActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.mic,
          label: '语音',
          onTap: () => _handleVoiceAction(context),
        ),
        _buildActionButton(
          icon: Icons.camera_alt,
          label: '拍照',
          onTap: () => _handleCameraAction(context),
        ),
        _buildActionButton(
          icon: Icons.photo_library,
          label: '相册',
          onTap: () => _handleGalleryAction(context),
        ),
      ],
    );
  }
  
  /// 构建扩展操作
  Widget _buildExtendedActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSmallActionButton(
          icon: Icons.volume_up,
          label: '音量',
          onTap: () => _handleVolumeAction(context),
        ),
        _buildSmallActionButton(
          icon: Icons.brightness_6,
          label: '亮度',
          onTap: () => _handleBrightnessAction(context),
        ),
        _buildSmallActionButton(
          icon: Icons.wifi,
          label: '网络',
          onTap: () => _handleNetworkAction(context),
        ),
        _buildSmallActionButton(
          icon: Icons.more_horiz,
          label: '更多',
          onTap: () => _handleMoreActions(context),
        ),
      ],
    );
  }
  
  
  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.8),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建小型操作按钮
  Widget _buildSmallActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ============ 操作处理方法 ============
  
  /// 处理语音操作
  void _handleVoiceAction(BuildContext context) {
    // TODO: 实现语音输入功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎤 语音功能（待实现）')),
    );
  }
  
  
  /// 处理相机操作
  void _handleCameraAction(BuildContext context) {
    // TODO: 实现相机功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📷 相机功能（待实现）')),
    );
  }
  
  /// 处理相册操作
  void _handleGalleryAction(BuildContext context) {
    // TODO: 实现相册功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🖼️ 相册功能（待实现）')),
    );
  }
  
  /// 处理音量操作
  void _handleVolumeAction(BuildContext context) {
    // TODO: 集成IoT音量控制
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔊 音量控制（待实现）')),
    );
  }
  
  /// 处理亮度操作
  void _handleBrightnessAction(BuildContext context) {
    // TODO: 集成IoT亮度控制
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('💡 亮度控制（待实现）')),
    );
  }
  
  /// 处理网络操作
  void _handleNetworkAction(BuildContext context) {
    // TODO: 显示网络状态和控制
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📶 网络管理（待实现）')),
    );
  }
  
  /// 处理更多操作
  void _handleMoreActions(BuildContext context) {
    // TODO: 显示更多操作菜单
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚙️ 更多功能（待实现）')),
    );
  }
}

/// 操作区域位置枚举
enum ActionsPosition {
  /// 顶部位置（状态栏下方）
  top,
  
  /// 中心位置
  center,
  
  /// 底部位置
  bottom,
}
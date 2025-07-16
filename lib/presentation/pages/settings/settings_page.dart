import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/app_config.dart' as config;

/// 设置页面
/// 
/// 提供统一的配置管理界面，按功能模块分组
/// 用户可以在此页面调整各种配置参数
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用设置'),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('UI界面设置'),
          _buildFloatingChatSettings(),
          
          const SizedBox(height: 24),
          _buildSectionHeader('动画设置'),
          _buildAnimationSettings(),
          
          const SizedBox(height: 24),
          _buildSectionHeader('性能设置'),
          _buildPerformanceSettings(),
          
          const SizedBox(height: 24),
          _buildSectionHeader('网络设置'),
          _buildNetworkSettings(),
          
          const SizedBox(height: 24),
          _buildSectionHeader('音频设置'),
          _buildAudioSettings(),
          
          const SizedBox(height: 24),
          _buildSectionHeader('调试设置'),
          _buildDebugSettings(),
          
          const SizedBox(height: 40),
          _buildResetSection(context),
        ],
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  /// 悬浮聊天设置
  Widget _buildFloatingChatSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigItem(
              '收缩状态尺寸',
              '${config.FloatingChat.collapsedSize}px',
              '悬浮窗收缩时的大小',
            ),
            _buildConfigItem(
              '展开宽度比例',
              '${(config.FloatingChat.expandedWidthRatio * 100).round()}%',
              '悬浮窗展开时的屏幕宽度占比',
            ),
            _buildConfigItem(
              '展开高度比例',
              '${(config.FloatingChat.expandedHeightRatio * 100).round()}%',
              '悬浮窗展开时的屏幕高度占比',
            ),
            _buildConfigToggle(
              '背景模糊效果',
              config.FloatingChat.enableBackgroundBlur,
              '展开时是否启用背景模糊',
            ),
          ],
        ),
      ),
    );
  }

  /// 动画设置
  Widget _buildAnimationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigItem(
              '悬浮窗动画时长',
              '${config.Animation.floatingChatDurationMs}ms',
              '悬浮窗展开/收缩动画的持续时间',
            ),
            _buildConfigItem(
              '页面切换动画',
              config.Animation.pageTransitionDurationMs == 0 ? '已禁用' : '${config.Animation.pageTransitionDurationMs}ms',
              '页面间切换的动画时长',
            ),
            _buildConfigToggle(
              'Material动画',
              config.Animation.enableMaterialAnimations,
              '是否启用Material Design动画效果',
            ),
            _buildConfigToggle(
              '波纹效果',
              config.Animation.enableRippleEffect,
              '点击时的波纹扩散效果',
            ),
          ],
        ),
      ),
    );
  }

  /// 性能设置
  Widget _buildPerformanceSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigToggle(
              '性能监控',
              config.Performance.enableMonitoring,
              '显示性能监控覆盖层',
            ),
            _buildConfigItem(
              '图像质量',
              '${(config.Performance.imageQuality * 100).round()}%',
              '图片渲染质量设置',
            ),
            _buildConfigItem(
              '内存缓存限制',
              '${config.Performance.memoryCacheLimitMB}MB',
              '应用内存缓存的最大容量',
            ),
            _buildConfigItem(
              '并发音频处理',
              '${config.Performance.maxConcurrentAudio}个',
              '同时处理的音频流数量',
            ),
          ],
        ),
      ),
    );
  }

  /// 网络设置
  Widget _buildNetworkSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigItem(
              '连接超时',
              '${config.Network.connectionTimeoutSec}秒',
              'WebSocket连接的超时时间',
            ),
            _buildConfigItem(
              '重连间隔',
              '${config.Network.reconnectIntervalSec}秒',
              '连接断开后的重连等待时间',
            ),
            _buildConfigItem(
              '最大重试次数',
              '${config.Network.maxRetryCount}次',
              '连接失败时的最大重试次数',
            ),
            _buildConfigItem(
              '心跳间隔',
              '${config.Network.heartbeatIntervalSec}秒',
              '保持连接活跃的心跳包间隔',
            ),
          ],
        ),
      ),
    );
  }

  /// 音频设置
  Widget _buildAudioSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigItem(
              '采样率',
              '${config.Audio.sampleRate}Hz',
              '音频录制的采样频率',
            ),
            _buildConfigItem(
              '声道数',
              '${config.Audio.channels}',
              '音频录制的声道配置',
            ),
            _buildConfigItem(
              '帧时长',
              '${config.Audio.frameDurationMs}ms',
              '音频数据包的时长',
            ),
            _buildConfigItem(
              '音频格式',
              config.Audio.format.toUpperCase(),
              '音频编码格式',
            ),
            _buildConfigItem(
              'STT超时',
              '${config.Audio.sttTimeoutSec}秒',
              '语音识别处理的超时时间',
            ),
          ],
        ),
      ),
    );
  }

  /// 调试设置
  Widget _buildDebugSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigToggle(
              '调试日志',
              config.Debug.enableLogging,
              '是否输出详细的调试信息',
            ),
            _buildConfigToggle(
              '网络日志',
              config.Debug.enableNetworkLogging,
              '是否记录网络请求详情',
            ),
            _buildConfigToggle(
              '音频日志',
              config.Debug.enableAudioLogging,
              '是否记录音频处理日志',
            ),
            _buildConfigToggle(
              'UI日志',
              config.Debug.enableUILogging,
              '是否记录界面构建信息',
            ),
            _buildConfigToggle(
              '调试信息显示',
              config.Debug.showDebugInfo,
              '在界面上显示调试信息',
            ),
          ],
        ),
      ),
    );
  }

  /// 重置设置区域
  Widget _buildResetSection(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '重置设置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '将所有设置恢复为默认值。此操作不可撤销。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.restore),
              label: const Text('恢复默认设置'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建配置项显示
  Widget _buildConfigItem(String title, String value, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建开关配置项
  Widget _buildConfigToggle(String title, bool value, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: null, // 当前为只读，未来可以实现动态修改
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  /// 显示重置确认对话框
  void _showResetDialog(BuildContext context) {
    // 暂时只显示提示，实际功能可以后续实现
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('此功能将在后续版本中实现。\n当前配置通过代码管理，重置需要重新编译应用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }
}
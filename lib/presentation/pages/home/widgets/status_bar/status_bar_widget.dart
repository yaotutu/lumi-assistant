import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/config/app_settings.dart';
import '../../../settings/settings_main_page.dart';

/// 状态栏区域组件
/// 
/// 职责：
/// - 始终位于屏幕最顶部区域
/// - 显示应用基础信息和状态
/// - 提供核心功能的快速入口
/// 
/// 特点：
/// - 固定在顶部，不随其他区域变化
/// - 包含应用名称、连接状态、设置入口
/// - 支持用户自定义距离状态栏的间距
class StatusBarWidget extends ConsumerWidget {
  /// 构造函数
  const StatusBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取配置设置
    final settings = ref.watch(appSettingsProvider);
    
    return Positioned(
      top: _calculateTopPosition(context, settings),
      left: 20,
      right: 20,
      height: 50,
      child: _buildStatusBarContent(context),
    );
  }
  
  /// 计算顶部位置
  double _calculateTopPosition(BuildContext context, AppSettings settings) {
    // 获取状态栏高度，确保不被状态栏遮挡
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return statusBarHeight + settings.topBarDistance;
  }
  
  /// 构建状态栏内容
  Widget _buildStatusBarContent(BuildContext context) {
    return Row(
      children: [
        // 应用名称和图标区域
        _buildAppInfoSection(context),
        
        const Spacer(),
        
        // 连接状态指示器
        _buildConnectionStatusIndicator(context),
        
        const SizedBox(width: 12),
        
        // 设置按钮
        _buildSettingsButton(context),
      ],
    );
  }
  
  /// 构建应用信息区域
  Widget _buildAppInfoSection(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAppInfo(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assistant,
              size: 20,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Lumi Assistant',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建连接状态指示器
  Widget _buildConnectionStatusIndicator(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showConnectionStatus(context),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.wifi,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建设置按钮
  Widget _buildSettingsButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToSettings(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.settings,
            color: Colors.white.withValues(alpha: 0.8),
            size: 20,
          ),
        ),
      ),
    );
  }
  
  // ============ 交互功能实现 ============
  
  /// 显示应用信息对话框
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lumi Assistant'),
        content: const Text('智能语音助手\n版本: 1.0.0\n\n为您提供智能对话和设备控制服务'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  /// 显示连接状态提示
  void _showConnectionStatus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🟢 已连接到服务器'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 导航到设置页面
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsMainPage(),
      ),
    );
  }
}
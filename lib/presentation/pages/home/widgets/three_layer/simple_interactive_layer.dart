import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../settings/settings_main_page.dart';
import '../../../../../core/config/app_settings.dart';

/// 简化的交互功能层组件
/// 
/// 职责：
/// - 只包含顶部设置区域的交互功能
/// - 提供设置入口和基本状态显示
/// 
/// 设计原则：
/// - 极简设计，只保留必要功能
/// - 透明区域不阻挡下层显示
/// - 只在顶部显示操作按钮
/// - 支持用户自定义顶部距离
class SimpleInteractiveLayer extends ConsumerWidget {
  /// 构造函数
  const SimpleInteractiveLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取配置设置
    final settings = ref.watch(appSettingsProvider);
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // 顶部设置区域 - 唯一的交互区域
        SafeArea(
          child: _buildTopSettingsBar(context, settings),
        ),
      ],
    );
  }
  
  /// 构建顶部设置栏
  Widget _buildTopSettingsBar(BuildContext context, AppSettings settings) {
    return Positioned(
      top: settings.topBarDistance, // 使用用户配置的距离，默认紧贴顶部
      left: 20,
      right: 20,
      height: 50,
      child: Row(
        children: [
          // 应用名称区域 - 可点击显示应用信息
          GestureDetector(
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
          ),
          
          const Spacer(),
          
          // 连接状态指示器 - 可点击查看详情
          _buildConnectionStatusButton(context),
          
          const SizedBox(width: 12),
          
          // 设置按钮
          _buildActionButton(
            icon: Icons.settings,
            tooltip: '应用设置',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsMainPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 20,
          ),
        ),
      ),
    );
  }
  
  /// 构建连接状态按钮
  Widget _buildConnectionStatusButton(BuildContext context) {
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
  
  // ============ 交互功能实现 ============
  
  /// 显示应用信息
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
  
  /// 显示连接状态
  void _showConnectionStatus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🟢 已连接到服务器'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../settings/settings_main_page.dart';
import '../../../test/mcp_test_page.dart';

/// 交互功能层组件
/// 
/// 职责：
/// - 处理所有可点击的功能组件
/// - 提供日历、天气、设置等交互功能
/// - 管理状态栏和功能入口
/// 
/// 设计原则：
/// - 只包含可交互的元素
/// - 透明区域不阻挡下层显示
/// - 功能组件按区域分布
/// - 响应式布局适配不同屏幕
class InteractiveLayer extends StatelessWidget {
  /// 是否显示调试信息
  final bool showDebugInfo;
  
  /// 构造函数
  const InteractiveLayer({
    super.key,
    this.showDebugInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 顶部状态栏区域 - 可交互
        _buildTopStatusBar(context),
        
        // 左上角功能区域
        _buildTopLeftFunctionArea(context),
        
        // 右上角功能区域  
        _buildTopRightFunctionArea(context),
        
        // 中心功能区域（可选）
        _buildCenterFunctionArea(context),
        
        // 底部功能区域
        _buildBottomFunctionArea(context),
        
        // 侧边功能区域
        _buildSideFunctionArea(context),
      ],
    );
  }
  
  /// 构建顶部状态栏
  Widget _buildTopStatusBar(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      height: 50,
      child: Row(
        children: [
          // 应用品牌区域 - 可点击显示信息
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
          
          // 调试信息（开发模式）
          if (showDebugInfo) _buildDebugButton(context),
          
          // 连接状态指示器 - 可点击查看详情
          _buildConnectionStatusButton(context),
          
          const SizedBox(width: 12),
          
          // MCP测试按钮
          _buildFunctionButton(
            icon: Icons.build_circle,
            tooltip: 'MCP功能测试',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const McpTestPage(),
                ),
              );
            },
          ),
          
          const SizedBox(width: 8),
          
          // 设置按钮
          _buildFunctionButton(
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
  
  /// 构建左上角功能区域
  Widget _buildTopLeftFunctionArea(BuildContext context) {
    return Positioned(
      top: 120,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 快速日历按钮
          _buildQuickActionButton(
            icon: Icons.calendar_today,
            label: '日历',
            onPressed: () => _showCalendarView(context),
          ),
          
          const SizedBox(height: 16),
          
          // 快速天气按钮
          _buildQuickActionButton(
            icon: Icons.wb_sunny,
            label: '天气',
            onPressed: () => _showWeatherView(context),
          ),
        ],
      ),
    );
  }
  
  /// 构建右上角功能区域
  Widget _buildTopRightFunctionArea(BuildContext context) {
    return Positioned(
      top: 120,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 信息面板按钮
          _buildQuickActionButton(
            icon: Icons.info_outline,
            label: '信息',
            onPressed: () => _showInfoPanel(context),
          ),
          
          const SizedBox(height: 16),
          
          // 系统状态按钮
          _buildQuickActionButton(
            icon: Icons.memory,
            label: '系统',
            onPressed: () => _showSystemStatus(context),
          ),
        ],
      ),
    );
  }
  
  /// 构建中心功能区域（可选）
  Widget _buildCenterFunctionArea(BuildContext context) {
    // 中心区域预留给特殊功能，暂时返回空容器
    return const SizedBox.shrink();
  }
  
  /// 构建底部功能区域
  Widget _buildBottomFunctionArea(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 快速操作按钮组
          _buildBottomActionButton(
            icon: Icons.photo_library,
            label: '相册',
            onPressed: () => _showPhotoGallery(context),
          ),
          
          _buildBottomActionButton(
            icon: Icons.schedule,
            label: '计时',
            onPressed: () => _showTimer(context),
          ),
          
          _buildBottomActionButton(
            icon: Icons.notes,
            label: '记事',
            onPressed: () => _showNotes(context),
          ),
        ],
      ),
    );
  }
  
  /// 构建侧边功能区域
  Widget _buildSideFunctionArea(BuildContext context) {
    return Positioned(
      right: 20,
      top: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          // 音量控制
          _buildSideActionButton(
            icon: Icons.volume_up,
            onPressed: () => _showVolumeControl(context),
          ),
          
          const SizedBox(height: 16),
          
          // 亮度控制
          _buildSideActionButton(
            icon: Icons.brightness_6,
            onPressed: () => _showBrightnessControl(context),
          ),
        ],
      ),
    );
  }
  
  /// 构建功能按钮
  Widget _buildFunctionButton({
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
  
  /// 构建快速操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建底部操作按钮
  Widget _buildBottomActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建侧边操作按钮
  Widget _buildSideActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 24,
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
  
  /// 构建调试按钮
  Widget _buildDebugButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bug_report,
            size: 12,
            color: Colors.orange.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
          Text(
            'DEBUG',
            style: TextStyle(
              color: Colors.orange.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
  
  /// 显示日历视图
  void _showCalendarView(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📅 日历功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 显示天气视图
  void _showWeatherView(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌤️ 天气功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 显示信息面板
  void _showInfoPanel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ℹ️ 信息面板功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 显示系统状态
  void _showSystemStatus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚙️ 系统状态功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 显示相册
  void _showPhotoGallery(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🖼️ 相册功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 显示计时器
  void _showTimer(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏱️ 计时器功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 显示记事本
  void _showNotes(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📝 记事本功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 显示音量控制
  void _showVolumeControl(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔊 音量控制功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 显示亮度控制
  void _showBrightnessControl(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔆 亮度控制功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
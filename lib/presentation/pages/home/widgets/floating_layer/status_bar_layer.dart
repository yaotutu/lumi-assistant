import 'package:flutter/material.dart';
import '../../../settings/settings_main_page.dart';
import '../../../test/mcp_test_page.dart';

/// 状态栏浮动层组件
/// 
/// 职责：
/// - 显示应用名称和品牌标识
/// - 提供快速访问设置和功能的入口
/// - 展示网络连接状态和系统信息
/// 
/// 设计特点：
/// - 极简设计，不干扰背景显示
/// - 半透明效果，与背景融合
/// - 响应式图标，适应不同屏幕尺寸
class StatusBarLayer extends StatelessWidget {
  /// 是否显示调试信息
  final bool showDebugInfo;
  
  /// 状态栏透明度
  final double opacity;
  
  /// 构造函数
  const StatusBarLayer({
    super.key,
    this.showDebugInfo = false,
    this.opacity = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 应用品牌区域
          _buildBrandSection(),
          
          // 中间空白区域（可用于显示额外信息）
          const Spacer(),
          
          // 调试信息（开发阶段）
          if (showDebugInfo) _buildDebugInfo(),
          
          // 右侧功能区域
          _buildActionSection(context),
        ],
      ),
    );
  }
  
  /// 构建品牌区域
  Widget _buildBrandSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 应用图标（可选）
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.assistant,
            size: 16,
            color: Colors.white.withValues(alpha: opacity),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 应用名称
        Text(
          'Lumi Assistant',
          style: TextStyle(
            color: Colors.white.withValues(alpha: opacity),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
  
  /// 构建调试信息区域
  Widget _buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
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
  
  /// 构建操作区域
  Widget _buildActionSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 连接状态指示器
        _buildConnectionStatus(),
        
        const SizedBox(width: 12),
        
        // MCP测试按钮
        _buildActionButton(
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
    );
  }
  
  /// 构建连接状态指示器
  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 连接状态指示点
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 4),
          
          // WiFi图标
          Icon(
            Icons.wifi,
            color: Colors.white.withValues(alpha: opacity * 0.8),
            size: 14,
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: opacity * 0.8),
            size: 18,
          ),
        ),
      ),
    );
  }
}

/// 状态栏信息显示组件
/// 
/// 用于在状态栏中显示各种状态信息
class StatusBarInfo extends StatelessWidget {
  /// 信息文本
  final String text;
  
  /// 信息图标
  final IconData? icon;
  
  /// 信息颜色
  final Color color;
  
  /// 构造函数
  const StatusBarInfo({
    super.key,
    required this.text,
    this.icon,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: color.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
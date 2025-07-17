import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/app_settings.dart';
import 'settings_ui_page.dart';
import 'settings_network_page.dart';
import 'settings_audio_page.dart';
import 'settings_theme_page.dart';
import 'settings_debug_page.dart';
import 'mcp_servers_page.dart';

/// 设置主页面 - 分组导航
/// 
/// 将所有设置项按功能分组，提供清晰的导航结构
class SettingsMainPage extends ConsumerWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用设置'),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'reset_all':
                  _showResetAllDialog(context, settings);
                  break;
                case 'export':
                  _showExportDialog(context);
                  break;
                case 'import':
                  _showImportDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset_all',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: Colors.red),
                    SizedBox(width: 8),
                    Text('重置所有设置'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('导出设置'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green),
                    SizedBox(width: 8),
                    Text('导入设置'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsCategoryCard(
            context,
            title: 'UI界面设置',
            subtitle: '悬浮窗尺寸、字体缩放、动画时长等界面相关设置',
            icon: Icons.design_services,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsUIPage()),
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsCategoryCard(
            context,
            title: '网络连接设置',
            subtitle: 'WebSocket服务器地址、HTTP API地址、连接超时等',
            icon: Icons.wifi,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsNetworkPage()),
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsCategoryCard(
            context,
            title: '音频设置',
            subtitle: '音频采样率、声道数、音频帧时长等语音相关设置',
            icon: Icons.mic,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsAudioPage()),
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsCategoryCard(
            context,
            title: 'MCP服务器配置',
            subtitle: '管理内置和外部MCP服务器，配置设备控制功能',
            icon: Icons.settings_remote,
            color: Colors.orange.shade700,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const McpServersPage()),
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsCategoryCard(
            context,
            title: '主题样式',
            subtitle: 'Material设计、动画效果、波纹点击效果等外观设置',
            icon: Icons.palette,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsThemePage()),
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsCategoryCard(
            context,
            title: '开发者选项',
            subtitle: '调试日志、网络日志、音频日志等开发调试设置',
            icon: Icons.bug_report,
            color: Colors.red.shade700,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsDebugPage()),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 应用信息区域
          _buildAppInfoSection(context),
        ],
      ),
    );
  }

  /// 构建设置分类卡片
  Widget _buildSettingsCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// 构建应用信息区域
  Widget _buildAppInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '应用信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('应用名称', 'Lumi Assistant'),
            _buildInfoRow('版本号', '1.0.0'),
            _buildInfoRow('构建版本', '1'),
            _buildInfoRow('Flutter版本', '3.27.0'),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示重置所有设置的确认对话框
  void _showResetAllDialog(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置所有设置'),
        content: const Text('确定要将所有设置恢复为默认值吗？\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              settings.resetAllSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('所有设置已重置为默认值'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }

  /// 显示导出设置对话框
  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出设置'),
        content: const Text('导出设置功能将在后续版本中实现。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  /// 显示导入设置对话框
  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入设置'),
        content: const Text('导入设置功能将在后续版本中实现。'),
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
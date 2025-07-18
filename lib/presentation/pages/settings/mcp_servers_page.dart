import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/services/mcp_config.dart';
import '../../../core/services/unified_mcp_manager.dart';
import '../../widgets/settings/settings_card.dart';

/// MCP服务器配置管理页面
class McpServersPage extends HookConsumerWidget {
  const McpServersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mcpManager = ref.watch(unifiedMcpManagerProvider);
    final refreshTrigger = useState(0);

    // 刷新函数
    void refresh() {
      refreshTrigger.value++;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP服务器配置'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showAddServerDialog(context, ref, refresh),
            icon: const Icon(Icons.add),
            tooltip: '添加外部服务器',
          ),
        ],
      ),
      body: FutureBuilder<void>(
        key: ValueKey(refreshTrigger.value),
        future: mcpManager.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 统计信息卡片
                _buildStatisticsCard(mcpManager),
                const SizedBox(height: 16),
                
                // 服务器列表
                _buildServersSection(context, ref, mcpManager, refresh),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建统计信息卡片
  Widget _buildStatisticsCard(UnifiedMcpManager mcpManager) {
    final stats = mcpManager.getStatistics();
    
    return SettingsCard(
      title: '统计信息',
      color: Colors.blue,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('总服务器', '${stats['total_servers']}'),
              _buildStatItem('运行中', '${stats['running_servers']}'),
              _buildStatItem('内置服务器', '${stats['embedded_servers']}'),
              _buildStatItem('外部服务器', '${stats['external_servers']}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('已启用', '${stats['enabled_servers']}'),
              _buildStatItem('内置工具', '${stats['embedded_tools']}'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 构建服务器列表
  Widget _buildServersSection(
    BuildContext context,
    WidgetRef ref,
    UnifiedMcpManager mcpManager,
    VoidCallback refresh,
  ) {
    final configurations = mcpManager.configurations;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MCP服务器',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        ...configurations.entries.map((entry) {
          final serverId = entry.key;
          final config = entry.value;
          final status = mcpManager.getServerStatus(serverId);
          
          return _buildServerCard(
            context,
            ref,
            serverId,
            config,
            status,
            refresh,
          );
        }).toList(),
      ],
    );
  }

  /// 构建服务器卡片
  Widget _buildServerCard(
    BuildContext context,
    WidgetRef ref,
    String serverId,
    McpServerConfig config,
    McpServerStatus status,
    VoidCallback refresh,
  ) {
    final isEmbedded = config.type == McpServerType.embedded;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务器标题行
            Row(
              children: [
                // 服务器类型图标
                Icon(
                  isEmbedded ? Icons.widgets : Icons.cloud,
                  color: isEmbedded ? Colors.green : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                // 服务器名称
                Expanded(
                  child: Text(
                    config.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 传输模式标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTransportColor(config.transport),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    config.transport.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 状态指示器
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            // 服务器描述
            if (config.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                config.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            
            // 服务器详情
            const SizedBox(height: 12),
            _buildServerDetails(config),
            
            // 操作按钮
            const SizedBox(height: 12),
            _buildServerActions(context, ref, serverId, config, status, refresh),
          ],
        ),
      ),
    );
  }

  /// 构建服务器详情
  Widget _buildServerDetails(McpServerConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // URL信息
        if (config.url != null) ...[
          Row(
            children: [
              Icon(Icons.link, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  config.url!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        
        // 工具列表
        if (config.tools.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.build, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: config.tools.map((tool) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tool,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 构建服务器操作按钮
  Widget _buildServerActions(
    BuildContext context,
    WidgetRef ref,
    String serverId,
    McpServerConfig config,
    McpServerStatus status,
    VoidCallback refresh,
  ) {
    final isEmbedded = config.type == McpServerType.embedded;
    final isRunning = status == McpServerStatus.running;
    final mcpManager = ref.read(unifiedMcpManagerProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 启用/禁用开关
        Text(
          '启用',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 4),
        Switch(
          value: config.enabled,
          onChanged: isEmbedded ? null : (value) async {
            final newConfig = config.copyWith(enabled: value);
            await mcpManager.updateServerConfig(serverId, newConfig);
            await mcpManager.saveUserConfig();
            refresh();
          },
        ),
        
        const SizedBox(width: 8),
        
        // 启动/停止按钮
        if (!isEmbedded) ...[
          ElevatedButton.icon(
            onPressed: config.enabled ? () async {
              if (isRunning) {
                await mcpManager.stopServer(serverId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('服务器 ${config.name} 已停止'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                final success = await mcpManager.startServer(serverId);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('服务器 ${config.name} 启动成功'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('服务器 ${config.name} 启动失败'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
              refresh();
            } : null,
            icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
            label: Text(isRunning ? '停止' : '启动'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRunning ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // 编辑按钮
        if (!isEmbedded) ...[
          IconButton(
            onPressed: () => _showEditServerDialog(context, ref, serverId, config, refresh),
            icon: const Icon(Icons.edit),
            tooltip: '编辑',
          ),
          
          // 删除按钮
          IconButton(
            onPressed: () => _showDeleteConfirmDialog(context, ref, serverId, config, refresh),
            icon: const Icon(Icons.delete),
            color: Colors.red,
            tooltip: '删除',
          ),
        ],
      ],
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.running:
        return Colors.green;
      case McpServerStatus.starting:
        return Colors.orange;
      case McpServerStatus.stopped:
        return Colors.grey;
      case McpServerStatus.disabled:
        return Colors.red;
      case McpServerStatus.error:
        return Colors.red;
      case McpServerStatus.notFound:
        return Colors.red;
    }
  }

  /// 获取状态文本
  String _getStatusText(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.running:
        return '运行中';
      case McpServerStatus.starting:
        return '启动中';
      case McpServerStatus.stopped:
        return '已停止';
      case McpServerStatus.disabled:
        return '已禁用';
      case McpServerStatus.error:
        return '错误';
      case McpServerStatus.notFound:
        return '未找到';
    }
  }

  /// 获取传输模式颜色
  Color _getTransportColor(McpTransportMode transport) {
    switch (transport) {
      case McpTransportMode.streamableHttp:
        return Colors.green;
      case McpTransportMode.stdio:
        return Colors.purple;
    }
  }

  /// 显示添加服务器对话框
  void _showAddServerDialog(BuildContext context, WidgetRef ref, VoidCallback refresh) {
    showDialog(
      context: context,
      builder: (context) => _McpServerConfigDialog(
        onSave: (config) async {
          final mcpManager = ref.read(unifiedMcpManagerProvider);
          mcpManager.addServerConfig(config.id, config);
          try {
            await mcpManager.saveUserConfig();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('MCP服务器配置已保存'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('保存配置失败: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
          refresh();
        },
      ),
    );
  }

  /// 显示编辑服务器对话框
  void _showEditServerDialog(
    BuildContext context,
    WidgetRef ref,
    String serverId,
    McpServerConfig config,
    VoidCallback refresh,
  ) {
    showDialog(
      context: context,
      builder: (context) => _McpServerConfigDialog(
        initialConfig: config,
        onSave: (newConfig) async {
          final mcpManager = ref.read(unifiedMcpManagerProvider);
          await mcpManager.updateServerConfig(serverId, newConfig);
          try {
            await mcpManager.saveUserConfig();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('MCP服务器配置已更新'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('更新配置失败: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
          refresh();
        },
      ),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    String serverId,
    McpServerConfig config,
    VoidCallback refresh,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除服务器'),
        content: Text('确定要删除服务器 "${config.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final mcpManager = ref.read(unifiedMcpManagerProvider);
              await mcpManager.removeServerConfig(serverId);
              await mcpManager.saveUserConfig();
              refresh();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// MCP服务器配置对话框
class _McpServerConfigDialog extends HookWidget {
  final McpServerConfig? initialConfig;
  final Function(McpServerConfig) onSave;

  const _McpServerConfigDialog({
    this.initialConfig,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isEditing = initialConfig != null;
    
    final nameController = useTextEditingController(
      text: initialConfig?.name ?? '',
    );
    final descriptionController = useTextEditingController(
      text: initialConfig?.description ?? '',
    );
    final urlController = useTextEditingController(
      text: initialConfig?.url ?? 'http://192.168.200.68:8200/mcp/',
    );
    final toolsController = useTextEditingController(
      text: initialConfig?.tools.join(', ') ?? '',
    );
    final headersController = useTextEditingController(
      text: initialConfig?.headers?.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\\n') ?? '',
    );
    
    final selectedTransport = useState(
      initialConfig?.transport ?? McpTransportMode.streamableHttp,
    );
    final enabled = useState(initialConfig?.enabled ?? true);
    final autoStart = useState(initialConfig?.autoStart ?? true);
    final priority = useState(initialConfig?.priority ?? 50);
    final isTestingConnection = useState(false);
    final isFetchingTools = useState(false);
    final testResult = useState<String?>(null);
    final discoveredTools = useState<List<String>>([]);

    /// 解析请求头
    Map<String, String>? parseHeaders(String headerText) {
      if (headerText.trim().isEmpty) return null;
      
      final headers = <String, String>{};
      for (final line in headerText.split('\\n')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          headers[parts[0].trim()] = parts[1].trim();
        }
      }
      return headers.isEmpty ? null : headers;
    }

    /// 测试连接到MCP服务器
    Future<void> testConnection() async {
      if (urlController.text.isEmpty) {
        testResult.value = '❌ 请先输入服务器URL';
        return;
      }

      isTestingConnection.value = true;
      testResult.value = null;

      try {
        // 构建临时配置
        final tempConfig = McpServerConfig(
          id: 'temp_test',
          name: 'Test Server',
          description: 'Temporary test server',
          type: McpServerType.external,
          transport: selectedTransport.value,
          url: urlController.text,
          headers: parseHeaders(headersController.text),
          enabled: true,
          autoStart: false,
          capabilities: [],
          tools: [],
          priority: 0,
        );

        // 创建临时客户端
        McpClient? client;
        switch (selectedTransport.value) {
          case McpTransportMode.streamableHttp:
            client = StreamableHttpMcpClient(tempConfig.url!, tempConfig.headers);
            break;
          case McpTransportMode.stdio:
            testResult.value = '❌ Stdio模式不支持连接测试';
            return;
        }

        // 测试连接
        await client.connect();
        testResult.value = '✅ 连接成功';
        
        // 断开连接
        await client.disconnect();
      } catch (e) {
        testResult.value = '❌ 连接失败: $e';
      } finally {
        isTestingConnection.value = false;
      }
    }

    /// 获取工具列表
    Future<void> fetchTools() async {
      if (urlController.text.isEmpty) {
        testResult.value = '❌ 请先输入服务器URL';
        return;
      }

      isFetchingTools.value = true;
      testResult.value = null;
      discoveredTools.value = [];

      try {
        // 构建临时配置
        final tempConfig = McpServerConfig(
          id: 'temp_fetch',
          name: 'Fetch Tools Server',
          description: 'Temporary server for fetching tools',
          type: McpServerType.external,
          transport: selectedTransport.value,
          url: urlController.text,
          headers: parseHeaders(headersController.text),
          enabled: true,
          autoStart: false,
          capabilities: [],
          tools: [],
          priority: 0,
        );

        // 创建临时客户端
        McpClient? client;
        switch (selectedTransport.value) {
          case McpTransportMode.streamableHttp:
            client = StreamableHttpMcpClient(tempConfig.url!, tempConfig.headers);
            break;
          case McpTransportMode.stdio:
            testResult.value = '❌ Stdio模式不支持工具获取';
            return;
        }

        // 连接并获取工具列表
        await client.connect();
        final tools = await client.listTools();
        
        // 解析工具列表
        final toolNames = <String>[];
        for (final tool in tools) {
          if (tool is Map<String, dynamic> && tool.containsKey('name')) {
            toolNames.add(tool['name'].toString());
          }
        }
        
        discoveredTools.value = toolNames;
        toolsController.text = toolNames.join(', ');
        testResult.value = '✅ 成功获取到 ${toolNames.length} 个工具';
        
        // 断开连接
        await client.disconnect();
      } catch (e) {
        testResult.value = '❌ 获取工具列表失败: $e';
      } finally {
        isFetchingTools.value = false;
      }
    }

    return AlertDialog(
      title: Text(isEditing ? '编辑MCP服务器' : '添加MCP服务器'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 基本信息
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '服务器名称',
                  hintText: '例如：我的WebSocket服务器',
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  hintText: '服务器功能描述',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // 传输模式选择
              DropdownButtonFormField<McpTransportMode>(
                value: selectedTransport.value,
                onChanged: (value) {
                  if (value != null) {
                    selectedTransport.value = value;
                  }
                },
                decoration: const InputDecoration(
                  labelText: '传输模式',
                ),
                items: McpTransportMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.name.toUpperCase()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // URL配置
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        labelText: '服务器URL',
                        hintText: _getUrlHint(selectedTransport.value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: isTestingConnection.value ? null : testConnection,
                    icon: isTestingConnection.value 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering, size: 16),
                    label: const Text('测试'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 工具列表
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: toolsController,
                      decoration: const InputDecoration(
                        labelText: '工具列表',
                        hintText: '点击"获取工具"按钮自动获取，或手动输入',
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: isFetchingTools.value ? null : fetchTools,
                    icon: isFetchingTools.value 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download, size: 16),
                    label: const Text('获取工具'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 请求头配置
              TextField(
                controller: headersController,
                decoration: const InputDecoration(
                  labelText: '请求头',
                  hintText: 'key: value\\n每行一个',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // 开关设置
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('启用'),
                      value: enabled.value,
                      onChanged: (value) => enabled.value = value ?? false,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('自动启动'),
                      value: autoStart.value,
                      onChanged: (value) => autoStart.value = value ?? false,
                    ),
                  ),
                ],
              ),
              
              // 优先级设置
              Row(
                children: [
                  const Text('优先级：'),
                  Expanded(
                    child: Slider(
                      value: priority.value.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: priority.value.toString(),
                      onChanged: (value) => priority.value = value.toInt(),
                    ),
                  ),
                ],
              ),
              
              // 测试结果显示
              if (testResult.value != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: testResult.value!.startsWith('✅') 
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: testResult.value!.startsWith('✅') 
                          ? Colors.green
                          : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        testResult.value!.startsWith('✅') 
                            ? Icons.check_circle 
                            : Icons.error,
                        color: testResult.value!.startsWith('✅') 
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          testResult.value!,
                          style: TextStyle(
                            color: testResult.value!.startsWith('✅') 
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // 发现的工具列表显示
              if (discoveredTools.value.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '发现的工具 (${discoveredTools.value.length})',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: discoveredTools.value.map((tool) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tool,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isEmpty || urlController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请填写服务器名称和URL')),
              );
              return;
            }
            
            final id = isEditing 
                ? initialConfig!.id 
                : DateTime.now().millisecondsSinceEpoch.toString();
            
            final tools = toolsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            
            final headers = parseHeaders(headersController.text);
            
            final config = McpServerConfig(
              id: id,
              name: nameController.text,
              description: descriptionController.text,
              type: McpServerType.external,
              transport: selectedTransport.value,
              url: urlController.text,
              headers: headers,
              enabled: enabled.value,
              autoStart: autoStart.value,
              capabilities: [],
              tools: tools,
              priority: priority.value,
            );
            
            onSave(config);
            Navigator.of(context).pop();
          },
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }

  String _getUrlHint(McpTransportMode transport) {
    switch (transport) {
      case McpTransportMode.streamableHttp:
        return 'http://192.168.200.68:8200/mcp/';
      case McpTransportMode.stdio:
        return '不需要URL';
    }
  }
}
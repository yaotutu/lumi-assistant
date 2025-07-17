import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/services/unified_mcp_manager.dart';
import '../../../core/services/mcp_config.dart';

/// MCP 测试页面
/// 
/// 用于测试统一MCP架构的各项功能
class McpTestPage extends HookConsumerWidget {
  const McpTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mcpManager = ref.watch(unifiedMcpManagerProvider);
    final brightnessController = useTextEditingController(text: '50');
    final volumeController = useTextEditingController(text: '50');
    final testResults = useState<List<String>>([]);
    final isLoading = useState(false);

    /// 添加测试结果
    void addResult(String result) {
      testResults.value = [...testResults.value, '${DateTime.now().toString().substring(11, 19)}: $result'];
    }

    /// 清空测试结果
    void clearResults() {
      testResults.value = [];
    }

    /// 测试亮度控制
    Future<void> testBrightness() async {
      isLoading.value = true;
      try {
        final brightness = int.tryParse(brightnessController.text) ?? 50;
        addResult('开始测试亮度控制: $brightness%');
        
        final result = await mcpManager.callTool('set_brightness', {
          'brightness': brightness,
        });
        
        if (result['success'] == true) {
          addResult('✅ 亮度设置成功: ${result['message']}');
        } else {
          addResult('❌ 亮度设置失败: ${result['message']}');
        }
      } catch (e) {
        addResult('❌ 亮度控制异常: $e');
      } finally {
        isLoading.value = false;
      }
    }

    /// 测试音量控制
    Future<void> testVolume() async {
      isLoading.value = true;
      try {
        final volume = double.tryParse(volumeController.text) ?? 50.0;
        addResult('开始测试音量控制: $volume%');
        
        final result = await mcpManager.callTool('adjust_volume', {
          'level': volume,
        });
        
        if (result['success'] == true) {
          addResult('✅ 音量调整成功: ${result['message']}');
        } else {
          addResult('❌ 音量调整失败: ${result['message']}');
        }
      } catch (e) {
        addResult('❌ 音量控制异常: $e');
      } finally {
        isLoading.value = false;
      }
    }

    /// 测试获取系统信息
    Future<void> testSystemInfo() async {
      isLoading.value = true;
      try {
        addResult('开始获取系统信息');
        
        final result = await mcpManager.callTool('get_system_info', {
          'detail_level': 'detailed',
        });
        
        if (result['success'] == true) {
          addResult('✅ 系统信息获取成功');
          addResult(result['message'] ?? '无详细信息');
        } else {
          addResult('❌ 系统信息获取失败: ${result['message']}');
        }
      } catch (e) {
        addResult('❌ 系统信息获取异常: $e');
      } finally {
        isLoading.value = false;
      }
    }

    /// 测试工具列表获取
    Future<void> testToolsList() async {
      isLoading.value = true;
      try {
        addResult('开始获取工具列表');
        
        final tools = await mcpManager.getAvailableTools();
        
        addResult('✅ 工具列表获取成功，共 ${tools.length} 个工具:');
        for (final tool in tools) {
          addResult('  - ${tool.name} (${tool.serverType.name}): ${tool.description}');
        }
      } catch (e) {
        addResult('❌ 工具列表获取异常: $e');
      } finally {
        isLoading.value = false;
      }
    }

    /// 测试服务器状态
    Future<void> testServerStatus() async {
      isLoading.value = true;
      try {
        addResult('开始检查服务器状态');
        
        final configs = mcpManager.configurations;
        for (final entry in configs.entries) {
          final serverId = entry.key;
          final config = entry.value;
          final status = mcpManager.getServerStatus(serverId);
          
          addResult('📊 $serverId (${config.type.name}): $status');
        }
        
        final stats = mcpManager.getStatistics();
        addResult('📈 统计信息: $stats');
      } catch (e) {
        addResult('❌ 服务器状态检查异常: $e');
      } finally {
        isLoading.value = false;
      }
    }

    /// 测试配置创建
    Future<void> testConfigCreation() async {
      addResult('--- 测试配置创建 ---');
      
      // 测试Streamable HTTP配置
      final streamableHttpConfig = McpServerConfig.streamableHttp(
        id: 'test_streamable_http',
        name: 'Test Streamable HTTP',
        description: 'Streamable HTTP测试服务器',
        url: 'http://localhost:8080/mcp/',
        headers: {'Authorization': 'Bearer test-token'},
        tools: ['test_tool'],
      );
      addResult('✅ Streamable HTTP配置创建成功: ${streamableHttpConfig.transport.name}');
      
      // 测试Stdio配置
      final stdioConfig = McpServerConfig.stdio(
        id: 'test_stdio',
        name: 'Test Stdio',
        description: 'Stdio测试服务器',
        command: 'node',
        args: ['server.js'],
        tools: ['test_tool'],
      );
      addResult('✅ Stdio配置创建成功: ${stdioConfig.transport.name}');
      
      // 测试嵌入式配置
      final embeddedConfig = McpServerConfig.embedded(
        id: 'test_embedded',
        name: 'Test Embedded',
        description: '嵌入式测试服务器',
        tools: ['test_tool'],
      );
      addResult('✅ 嵌入式配置创建成功: ${embeddedConfig.transport.name}');
    }
    
    /// 测试传输连接
    Future<void> testTransportConnections() async {
      addResult('--- 测试传输连接 ---');
      
      // 由于是模拟环境，这里主要测试客户端创建逻辑
      try {
        // 测试Streamable HTTP客户端创建
        final streamableClient = StreamableHttpMcpClient('http://localhost:8080/mcp/', {'test': 'header'});
        addResult('✅ Streamable HTTP客户端创建成功');
        
        // 测试Stdio客户端创建
        final stdioClient = StdioMcpClient(
          command: 'node',
          args: ['server.js'],
        );
        addResult('✅ Stdio客户端创建成功');
        
        // 注意：不测试实际连接，因为没有真实的服务器
        addResult('ℹ️ 实际连接测试需要运行相应的MCP服务器');
        addResult('ℹ️ 已移除非标准传输模式，仅支持MCP官方标准的两种模式');
        
      } catch (e) {
        addResult('❌ 传输连接测试失败: $e');
      }
    }

    /// 测试多传输模式
    Future<void> testMultiTransport() async {
      isLoading.value = true;
      try {
        addResult('=== 测试MCP标准传输模式 ===');
        
        // 测试配置不同传输模式的服务器
        await testConfigCreation();
        
        // 测试连接不同的传输模式
        await testTransportConnections();
        
      } catch (e) {
        addResult('❌ 多传输模式测试失败: $e');
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP 统一架构测试'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: clearResults,
            icon: const Icon(Icons.clear),
            tooltip: '清空结果',
          ),
        ],
      ),
      body: Column(
        children: [
          // 控制面板
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'MCP 功能测试',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // 亮度控制测试
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: brightnessController,
                        decoration: const InputDecoration(
                          labelText: '亮度 (0-100)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading.value ? null : testBrightness,
                      child: const Text('测试亮度'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // 音量控制测试
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: volumeController,
                        decoration: const InputDecoration(
                          labelText: '音量 (0-100)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading.value ? null : testVolume,
                      child: const Text('测试音量'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 其他测试按钮
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: isLoading.value ? null : testSystemInfo,
                      child: const Text('系统信息'),
                    ),
                    ElevatedButton(
                      onPressed: isLoading.value ? null : testToolsList,
                      child: const Text('工具列表'),
                    ),
                    ElevatedButton(
                      onPressed: isLoading.value ? null : testServerStatus,
                      child: const Text('服务器状态'),
                    ),
                    ElevatedButton(
                      onPressed: isLoading.value ? null : testMultiTransport,
                      child: const Text('多传输模式'),
                    ),
                  ],
                ),
                
                if (isLoading.value)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
          
          // 测试结果显示
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        '测试结果',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '共 ${testResults.value.length} 条',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: testResults.value.isEmpty
                        ? Center(
                            child: Text(
                              '点击上方按钮开始测试',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: testResults.value.length,
                              itemBuilder: (context, index) {
                                final result = testResults.value[index];
                                final isSuccess = result.contains('✅');
                                final isError = result.contains('❌');
                                final isInfo = result.contains('📊') || result.contains('📈');
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    result,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: isSuccess
                                          ? Colors.green.shade700
                                          : isError
                                              ? Colors.red.shade700
                                              : isInfo
                                                  ? Colors.blue.shade700
                                                  : Colors.black87,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
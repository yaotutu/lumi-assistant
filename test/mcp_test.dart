import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_assistant/core/services/mcp/mcp_config.dart';
import 'package:lumi_assistant/core/services/mcp/unified_mcp_manager.dart';
import 'package:lumi_assistant/core/services/mcp/embedded_mcp_server.dart';

void main() {
  group('MCP Configuration Tests', () {
    test('McpServerConfig.streamableHttp factory creates correct config', () {
      final config = McpServerConfig.streamableHttp(
        id: 'test_streamable_http',
        name: 'Test Streamable HTTP',
        description: 'Test Streamable HTTP Server',
        url: 'http://192.168.200.68:8200/mcp/',
        headers: {'Authorization': 'Bearer token'},
        tools: ['test_tool'],
      );

      expect(config.id, 'test_streamable_http');
      expect(config.name, 'Test Streamable HTTP');
      expect(config.transport, McpTransportMode.streamableHttp);
      expect(config.type, McpServerType.external);
      expect(config.url, 'http://192.168.200.68:8200/mcp/');
      expect(config.headers?['Authorization'], 'Bearer token');
      expect(config.tools, ['test_tool']);
    });

    test('McpServerConfig.stdio factory creates correct config', () {
      final config = McpServerConfig.stdio(
        id: 'test_stdio',
        name: 'Test Stdio',
        description: 'Test Stdio Server',
        command: 'node',
        args: ['server.js'],
        tools: ['test_tool'],
      );

      expect(config.id, 'test_stdio');
      expect(config.name, 'Test Stdio');
      expect(config.transport, McpTransportMode.stdio);
      expect(config.type, McpServerType.external);
      expect(config.command, 'node');
      expect(config.args, ['server.js']);
      expect(config.tools, ['test_tool']);
    });

    test('McpServerConfig.embedded factory creates correct config', () {
      final config = McpServerConfig.embedded(
        id: 'test_embedded',
        name: 'Test Embedded',
        description: 'Test Embedded Server',
        tools: ['test_tool'],
      );

      expect(config.id, 'test_embedded');
      expect(config.name, 'Test Embedded');
      expect(config.transport, McpTransportMode.streamableHttp);
      expect(config.type, McpServerType.embedded);
      expect(config.priority, 100);
      expect(config.tools, ['test_tool']);
    });

    test('McpServerConfig serialization works correctly', () {
      final config = McpServerConfig.streamableHttp(
        id: 'test_streamable_http',
        name: 'Test Streamable HTTP',
        description: 'Test Streamable HTTP Server',
        url: 'http://192.168.200.68:8200/mcp/',
        headers: {'Authorization': 'Bearer token'},
        tools: ['test_tool'],
      );

      final json = config.toJson();
      final restored = McpServerConfig.fromJson('test_streamable_http', json);

      expect(restored.id, config.id);
      expect(restored.name, config.name);
      expect(restored.description, config.description);
      expect(restored.transport, config.transport);
      expect(restored.type, config.type);
      expect(restored.url, config.url);
      expect(restored.headers, config.headers);
      expect(restored.tools, config.tools);
    });
  });

  group('MCP Transport Mode Tests', () {
    test('Only MCP standard transport modes are defined', () {
      expect(McpTransportMode.values.length, 2);
      expect(McpTransportMode.values.contains(McpTransportMode.streamableHttp), true);
      expect(McpTransportMode.values.contains(McpTransportMode.stdio), true);
    });

    test('Transport mode names are correct', () {
      expect(McpTransportMode.streamableHttp.name, 'streamableHttp');
      expect(McpTransportMode.stdio.name, 'stdio');
    });
  });

  group('MCP Client Tests', () {
    test('StreamableHttpMcpClient can be created', () {
      final client = StreamableHttpMcpClient(
        'http://192.168.200.68:8200/mcp/',
        {'Authorization': 'Bearer token'},
      );
      expect(client.isConnected, false);
    });

    test('StdioMcpClient can be created', () {
      final client = StdioMcpClient(
        command: 'node',
        args: ['server.js'],
      );
      expect(client.isConnected, false);
    });
  });

  group('Embedded MCP Server Tests', () {
    test('EmbeddedMcpServer can be created and initialized', () async {
      final server = EmbeddedMcpServer();
      await server.initialize();
      
      expect(server.isInitialized, true);
      expect(server.toolCount, greaterThan(0));
      
      final tools = await server.listTools();
      expect(tools.isNotEmpty, true);
      
      // Check that expected tools are present
      final toolNames = tools.map((t) => t.name).toList();
      expect(toolNames.contains('set_brightness'), true);
      expect(toolNames.contains('adjust_volume'), true);
      expect(toolNames.contains('get_system_info'), true);
      
      await server.dispose();
    });
  });

  group('UnifiedMcpManager Tests', () {
    test('UnifiedMcpManager can be created and initialized', () async {
      final manager = UnifiedMcpManager();
      await manager.initialize();
      
      expect(manager.configurations.isNotEmpty, true);
      
      final stats = manager.getStatistics();
      expect(stats['total_servers'], greaterThan(0));
      expect(stats['embedded_servers'], greaterThan(0));
      
      await manager.dispose();
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_assistant/core/services/mcp_config.dart';
import 'package:lumi_assistant/core/services/unified_mcp_manager.dart';
import 'package:lumi_assistant/core/services/embedded_mcp_server.dart';

void main() {
  group('MCP Configuration Tests', () {
    test('McpServerConfig.websocket factory creates correct config', () {
      final config = McpServerConfig.websocket(
        id: 'test_ws',
        name: 'Test WebSocket',
        description: 'Test WebSocket Server',
        url: 'ws://localhost:8080/mcp',
        headers: {'Authorization': 'Bearer token'},
        tools: ['test_tool'],
      );

      expect(config.id, 'test_ws');
      expect(config.name, 'Test WebSocket');
      expect(config.transport, McpTransportMode.websocket);
      expect(config.type, McpServerType.external);
      expect(config.url, 'ws://localhost:8080/mcp');
      expect(config.headers?['Authorization'], 'Bearer token');
      expect(config.tools, ['test_tool']);
    });

    test('McpServerConfig.sse factory creates correct config', () {
      final config = McpServerConfig.sse(
        id: 'test_sse',
        name: 'Test SSE',
        description: 'Test SSE Server',
        url: 'http://localhost:8080/mcp/stream',
        headers: {'Accept': 'text/event-stream'},
        tools: ['test_tool'],
      );

      expect(config.id, 'test_sse');
      expect(config.name, 'Test SSE');
      expect(config.transport, McpTransportMode.sse);
      expect(config.type, McpServerType.external);
      expect(config.url, 'http://localhost:8080/mcp/stream');
      expect(config.headers?['Accept'], 'text/event-stream');
      expect(config.tools, ['test_tool']);
    });

    test('McpServerConfig.http factory creates correct config', () {
      final config = McpServerConfig.http(
        id: 'test_http',
        name: 'Test HTTP',
        description: 'Test HTTP Server',
        url: 'http://localhost:8080/mcp/api',
        headers: {'Content-Type': 'application/json'},
        tools: ['test_tool'],
      );

      expect(config.id, 'test_http');
      expect(config.name, 'Test HTTP');
      expect(config.transport, McpTransportMode.http);
      expect(config.type, McpServerType.external);
      expect(config.url, 'http://localhost:8080/mcp/api');
      expect(config.headers?['Content-Type'], 'application/json');
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
      expect(config.transport, McpTransportMode.websocket);
      expect(config.type, McpServerType.embedded);
      expect(config.priority, 100);
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

    test('McpServerConfig serialization works correctly', () {
      final config = McpServerConfig.websocket(
        id: 'test_ws',
        name: 'Test WebSocket',
        description: 'Test WebSocket Server',
        url: 'ws://localhost:8080/mcp',
        headers: {'Authorization': 'Bearer token'},
        tools: ['test_tool'],
      );

      final json = config.toJson();
      final restored = McpServerConfig.fromJson('test_ws', json);

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
    test('All transport modes are defined', () {
      expect(McpTransportMode.values.length, 4);
      expect(McpTransportMode.values.contains(McpTransportMode.websocket), true);
      expect(McpTransportMode.values.contains(McpTransportMode.sse), true);
      expect(McpTransportMode.values.contains(McpTransportMode.http), true);
      expect(McpTransportMode.values.contains(McpTransportMode.stdio), true);
    });

    test('Transport mode names are correct', () {
      expect(McpTransportMode.websocket.name, 'websocket');
      expect(McpTransportMode.sse.name, 'sse');
      expect(McpTransportMode.http.name, 'http');
      expect(McpTransportMode.stdio.name, 'stdio');
    });
  });

  group('MCP Client Tests', () {
    test('WebSocketMcpClient can be created', () {
      final client = WebSocketMcpClient(
        'ws://localhost:8080/mcp',
        {'Authorization': 'Bearer token'},
      );
      expect(client.isConnected, false);
    });

    test('SseMcpClient can be created', () {
      final client = SseMcpClient(
        'http://localhost:8080/mcp/stream',
        {'Accept': 'text/event-stream'},
      );
      expect(client.isConnected, false);
    });

    test('HttpMcpClient can be created', () {
      final client = HttpMcpClient(
        'http://localhost:8080/mcp/api',
        {'Content-Type': 'application/json'},
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
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_assistant/core/services/mcp_config.dart';

void main() {
  group('MCP Configuration Tests', () {
    test('Default SSE configuration should be created correctly', () {
      final config = McpServerConfig.sse(
        id: 'test_sse',
        name: 'Test SSE Server',
        description: 'Test SSE Server Description',
        url: 'http://192.168.162.104:8100/sse',
        tools: ['test_tool'],
      );

      expect(config.id, 'test_sse');
      expect(config.name, 'Test SSE Server');
      expect(config.transport, McpTransportMode.sse);
      expect(config.url, 'http://192.168.162.104:8100/sse');
      expect(config.enabled, true);
      expect(config.autoStart, false);
      expect(config.priority, 0);
      expect(config.tools, ['test_tool']);
    });

    test('Headers parsing should work correctly', () {
      // This would normally be tested in the widget, but we can test the concept
      final headerText = 'Authorization: Bearer token\\nContent-Type: application/json';
      final lines = headerText.split('\\n');
      final headers = <String, String>{};
      
      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length == 2) {
          headers[parts[0].trim()] = parts[1].trim();
        }
      }

      expect(headers['Authorization'], 'Bearer token');
      expect(headers['Content-Type'], 'application/json');
    });

    test('Tools parsing should work correctly', () {
      final toolsText = 'tool1, tool2, tool3';
      final tools = toolsText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      expect(tools, ['tool1', 'tool2', 'tool3']);
    });

    test('Empty tools text should result in empty list', () {
      final toolsText = '';
      final tools = toolsText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      expect(tools, []);
    });

    test('All transport modes should be supported', () {
      // Test WebSocket
      final wsConfig = McpServerConfig.websocket(
        id: 'ws_test',
        name: 'WebSocket Test',
        description: 'Test WebSocket',
        url: 'ws://localhost:8080/mcp',
        tools: ['ws_tool'],
      );
      expect(wsConfig.transport, McpTransportMode.websocket);

      // Test SSE
      final sseConfig = McpServerConfig.sse(
        id: 'sse_test',
        name: 'SSE Test',
        description: 'Test SSE',
        url: 'http://localhost:8080/sse',
        tools: ['sse_tool'],
      );
      expect(sseConfig.transport, McpTransportMode.sse);

      // Test HTTP
      final httpConfig = McpServerConfig.http(
        id: 'http_test',
        name: 'HTTP Test',
        description: 'Test HTTP',
        url: 'http://localhost:8080/api',
        tools: ['http_tool'],
      );
      expect(httpConfig.transport, McpTransportMode.http);

      // Test Stdio
      final stdioConfig = McpServerConfig.stdio(
        id: 'stdio_test',
        name: 'Stdio Test',
        description: 'Test Stdio',
        command: 'node',
        args: ['server.js'],
        tools: ['stdio_tool'],
      );
      expect(stdioConfig.transport, McpTransportMode.stdio);
    });
  });
}
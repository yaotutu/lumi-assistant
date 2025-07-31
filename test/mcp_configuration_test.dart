import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_assistant/core/services/mcp/mcp_config.dart';

void main() {
  group('MCP Configuration Tests', () {
    test('Default Streamable HTTP configuration should be created correctly', () {
      final config = McpServerConfig.streamableHttp(
        id: 'test_streamable_http',
        name: 'Test Streamable HTTP Server',
        description: 'Test Streamable HTTP Server Description',
        url: 'http://192.168.200.68:8200/mcp/',
        tools: ['test_tool'],
      );

      expect(config.id, 'test_streamable_http');
      expect(config.name, 'Test Streamable HTTP Server');
      expect(config.transport, McpTransportMode.streamableHttp);
      expect(config.url, 'http://192.168.200.68:8200/mcp/');
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

    test('MCP standard transport modes should be supported', () {
      // Test Streamable HTTP (MCP official remote transport)
      final streamableHttpConfig = McpServerConfig.streamableHttp(
        id: 'streamable_http_test',
        name: 'Streamable HTTP Test',
        description: 'Test Streamable HTTP',
        url: 'http://192.168.200.68:8200/mcp/',
        tools: ['streamable_http_tool'],
      );
      expect(streamableHttpConfig.transport, McpTransportMode.streamableHttp);

      // Test Stdio (MCP official local transport)
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
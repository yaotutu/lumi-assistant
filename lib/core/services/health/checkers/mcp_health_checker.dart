import 'dart:async';
import '../service_health_checker.dart';
import '../../mcp/unified_mcp_manager.dart';

/// MCP 服务健康检查器
/// 
/// 检查 MCP (Model Context Protocol) 服务的状态
class McpHealthChecker implements IServiceHealthChecker {
  final UnifiedMcpManager _mcpManager;
  
  McpHealthChecker(this._mcpManager);
  
  @override
  String get serviceName => 'MCP 设备控制';
  
  @override
  String get description => 'IoT 设备控制协议服务';
  
  @override
  Future<ServiceHealthResult> checkHealth() async {
    try {
      // 获取统计信息
      final stats = _mcpManager.getStatistics();
      final configs = _mcpManager.configurations;
      
      if (configs.isEmpty) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: false,
          message: '没有配置 MCP 服务器',
        );
      }
      
      // 获取启用的服务器数量
      final enabledCount = stats['enabledCount'] as int;
      final totalCount = stats['totalCount'] as int;
      
      if (enabledCount == 0) {
        return ServiceHealthResult(
          serviceName: serviceName,
          description: description,
          isHealthy: false,
          message: '没有启用的 MCP 服务器',
          extras: stats,
        );
      }
      
      // 获取可用工具数量
      final tools = await _mcpManager.getAvailableTools();
      final toolCount = tools.length;
      
      // 判断健康状态
      final isHealthy = toolCount > 0;
      String message;
      
      if (isHealthy) {
        message = '已加载 $toolCount 个工具 ($enabledCount/$totalCount 服务器已启用)';
      } else {
        message = '没有可用工具 ($enabledCount/$totalCount 服务器已启用)';
      }
      
      return ServiceHealthResult(
        serviceName: serviceName,
        description: description,
        isHealthy: isHealthy,
        message: message,
        extras: {
          ...stats,
          'tool_count': toolCount,
        },
      );
      
    } catch (e) {
      return ServiceHealthResult(
        serviceName: serviceName,
        description: description,
        isHealthy: false,
        message: '检查失败: $e',
      );
    }
  }
}
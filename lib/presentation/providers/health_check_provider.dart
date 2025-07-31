import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/services/health/service_health_checker.dart';
import '../../core/services/health/checkers/websocket_health_checker.dart';
import '../../core/services/health/checkers/gotify_health_checker.dart';
import '../../core/services/health/checkers/mcp_health_checker.dart';
import 'gotify_provider.dart';
import '../../core/services/mcp/unified_mcp_manager.dart';

/// 健康检查初始化提供者
/// 
/// 职责：注册所有服务的健康检查器
final healthCheckInitializerProvider = Provider<void>((ref) {
  final healthManager = ServiceHealthManager();
  
  // 注册 WebSocket 健康检查器
  healthManager.registerChecker(
    WebSocketHealthChecker(ref),
  );
  
  // 注册 Gotify 健康检查器
  final gotifyService = ref.watch(gotifyServiceProvider);
  healthManager.registerChecker(
    GotifyHealthChecker(gotifyService),
  );
  
  // 注册 MCP 健康检查器
  final mcpManager = ref.watch(unifiedMcpManagerProvider);
  healthManager.registerChecker(
    McpHealthChecker(mcpManager),
  );
  
  // 未来可以在这里添加更多健康检查器
  // 例如：
  // - 音频服务健康检查
  // - 网络连接健康检查
  // - 存储空间健康检查
  // - 等等
});

/// 手动触发健康检查提供者
/// 
/// 用于在设置页面或其他地方手动触发健康检查
final manualHealthCheckProvider = FutureProvider<List<ServiceHealthResult>>((ref) async {
  // 确保健康检查器已初始化
  ref.read(healthCheckInitializerProvider);
  
  // 执行健康检查
  final healthManager = ServiceHealthManager();
  return await healthManager.performHealthCheck();
});
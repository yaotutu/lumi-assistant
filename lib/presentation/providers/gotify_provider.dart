import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/services/notification/gotify_service.dart';

/// Gotify 服务提供者
/// 
/// 职责：管理 Gotify 服务的生命周期
/// 使用场景：在应用启动时自动初始化 Gotify 服务
/// 
/// 使用方法：
/// ```dart
/// // 在应用启动时启动服务
/// ref.read(gotifyServiceProvider).start();
/// 
/// // 在应用关闭时停止服务  
/// ref.read(gotifyServiceProvider).stop();
/// ```
final gotifyServiceProvider = Provider<GotifyService>((ref) {
  // 获取 Gotify 服务单例
  final service = GotifyService();
  
  // 当 provider 被销毁时停止服务
  ref.onDispose(() {
    service.stop();
  });
  
  return service;
});

/// Gotify 服务初始化提供者
/// 
/// 职责：在应用启动时自动启动 Gotify 服务
/// 依赖：gotifyServiceProvider
/// 
/// 这是一个自动执行的 provider，会在被监听时自动启动服务
final gotifyInitializerProvider = FutureProvider<void>((ref) async {
  // 获取 Gotify 服务
  final service = ref.watch(gotifyServiceProvider);
  
  // 启动服务
  await service.start();
});

/// Gotify 连接状态枚举
enum GotifyConnectionState {
  /// 未连接
  disconnected,
  
  /// 正在连接
  connecting,
  
  /// 已连接
  connected,
  
  /// 连接错误
  error,
}

/// Gotify 连接状态提供者
/// 
/// 职责：追踪 Gotify 服务的连接状态
/// 用途：UI 可以根据连接状态显示不同的指示器
/// 
/// 使用示例：
/// ```dart
/// final connectionState = ref.watch(gotifyConnectionStateProvider);
/// switch (connectionState) {
///   case GotifyConnectionState.connected:
///     return Icon(Icons.cloud_done, color: Colors.green);
///   case GotifyConnectionState.error:
///     return Icon(Icons.cloud_off, color: Colors.red);
///   // ...
/// }
/// ```
final gotifyConnectionStateProvider = StateProvider<GotifyConnectionState>((ref) {
  // 默认状态为未连接
  return GotifyConnectionState.disconnected;
});

/// Gotify 未读消息数量提供者
/// 
/// 职责：追踪未读的 Gotify 通知数量
/// 用途：在 UI 上显示未读消息徽章
/// 
/// 使用示例：
/// ```dart
/// final unreadCount = ref.watch(gotifyUnreadCountProvider);
/// if (unreadCount > 0) {
///   // 显示未读消息徽章
/// }
/// ```
final gotifyUnreadCountProvider = StateProvider<int>((ref) {
  // 默认为 0 条未读消息
  return 0;
});

/// Gotify 服务启用状态提供者
/// 
/// 职责：控制是否启用 Gotify 服务
/// 用途：允许用户在设置中开关 Gotify 功能
/// 
/// 使用示例：
/// ```dart
/// // 在设置页面中
/// Switch(
///   value: ref.watch(gotifyEnabledProvider),
///   onChanged: (value) {
///     ref.read(gotifyEnabledProvider.notifier).state = value;
///     if (value) {
///       ref.read(gotifyServiceProvider).start();
///     } else {
///       ref.read(gotifyServiceProvider).stop();
///     }
///   },
/// )
/// ```
final gotifyEnabledProvider = StateProvider<bool>((ref) {
  // 临时启用以便测试
  // TODO: 后期从持久化存储中读取用户配置
  return true;
});
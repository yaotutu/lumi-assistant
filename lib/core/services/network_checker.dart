import 'dart:async';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 网络连接状态枚举
enum NetworkConnectionState {
  /// 未知状态
  unknown,
  /// 已连接
  connected,
  /// 断开连接
  disconnected,
}

/// 网络状态数据类
class NetworkState {
  final NetworkConnectionState connectionState;
  final String? errorMessage;
  final DateTime? lastCheckedAt;

  const NetworkState({
    required this.connectionState,
    this.errorMessage,
    this.lastCheckedAt,
  });

  NetworkState copyWith({
    NetworkConnectionState? connectionState,
    String? errorMessage,
    DateTime? lastCheckedAt,
  }) {
    return NetworkState(
      connectionState: connectionState ?? this.connectionState,
      errorMessage: errorMessage ?? this.errorMessage,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }

  /// 是否已连接
  bool get isConnected => connectionState == NetworkConnectionState.connected;
  
  /// 是否断开连接
  bool get isDisconnected => connectionState == NetworkConnectionState.disconnected;
}

/// 网络检查服务类
class NetworkChecker extends StateNotifier<NetworkState> {
  Timer? _periodicTimer;

  NetworkChecker() : super(const NetworkState(connectionState: NetworkConnectionState.unknown)) {
    // 初始化时检查一次网络状态
    checkConnection();
    
    // 启动定期检查
    _startPeriodicCheck();
  }

  /// 检查网络连接状态
  Future<void> checkConnection() async {
    print('[NetworkChecker] 开始检查网络连接');
    
    try {
      print('[NetworkChecker] 检查多个域名连接状态');
      // 尝试解析多个知名域名以确保网络连接正常
      final results = await Future.wait([
        _checkHost('google.com'),
        _checkHost('baidu.com'),
        _checkHost('github.com'),
      ]);

      print('[NetworkChecker] 域名检查结果: $results');
      
      // 只要有一个成功就认为网络正常
      final hasConnection = results.any((result) => result);
      
      print('[NetworkChecker] 网络连接状态: ${hasConnection ? "已连接" : "未连接"}');
      
      state = state.copyWith(
        connectionState: hasConnection 
            ? NetworkConnectionState.connected 
            : NetworkConnectionState.disconnected,
        lastCheckedAt: DateTime.now(),
        errorMessage: hasConnection ? null : '网络连接不可用',
      );
    } catch (error) {
      print('[NetworkChecker] 网络检查异常: $error');
      state = state.copyWith(
        connectionState: NetworkConnectionState.disconnected,
        errorMessage: '网络检查失败: $error',
        lastCheckedAt: DateTime.now(),
      );
    }
  }

  /// 检查特定主机的连接
  Future<bool> _checkHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 3));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  /// 启动定期检查
  void _startPeriodicCheck() {
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => checkConnection(),
    );
  }

  /// 停止定期检查
  void _stopPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// 检查特定服务器的连接
  Future<bool> checkServerConnection(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      await socket.close();
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  void dispose() {
    _stopPeriodicCheck();
    super.dispose();
  }
}

/// 网络检查器提供者
final networkCheckerProvider = StateNotifierProvider<NetworkChecker, NetworkState>((ref) {
  return NetworkChecker();
});
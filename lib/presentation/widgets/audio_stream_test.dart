import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/audio_stream_provider.dart';
import '../providers/connection_provider.dart';
import '../../data/models/connection_state.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/websocket_state.dart';

/// 音频流测试组件
/// 用于测试实时音频流传输功能
class AudioStreamTest extends HookConsumerWidget {
  const AudioStreamTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamState = ref.watch(audioStreamProvider);
    final streamNotifier = ref.watch(audioStreamProvider.notifier);
    final connectionState = ref.watch(connectionManagerProvider);
    
    // 流传输时长状态
    final streamingDuration = useState<int>(0);
    
    // 定时器，用于更新流传输时长
    useEffect(() {
      if (streamState.isStreaming) {
        final timer = Stream.periodic(const Duration(milliseconds: 100))
            .listen((_) {
          streamingDuration.value = streamNotifier.streamingDuration;
        });
        return timer.cancel;
      }
      return null;
    }, [streamState.isStreaming]);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '音频流传输测试',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // 连接状态检查
            _buildConnectionCheck(context, connectionState),
            const SizedBox(height: 12),
            
            // 状态信息
            _buildStatusInfo(context, streamState, streamNotifier),
            const SizedBox(height: 16),
            
            // 流传输统计
            if (streamState.streamingStats != null)
              _buildStreamingStats(context, streamState.streamingStats!),
            
            if (streamState.isStreaming)
              _buildStreamingIndicator(context, streamingDuration.value),
            
            const SizedBox(height: 16),
            
            // 控制按钮
            _buildControlButtons(context, streamState, streamNotifier, connectionState),
          ],
        ),
      ),
    );
  }

  /// 构建连接状态检查
  Widget _buildConnectionCheck(BuildContext context, ConnectionManagerState connectionState) {
    final isConnected = connectionState.webSocketState.isConnected;
    final hasHandshake = connectionState.handshakeResult.isCompleted;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isConnected && hasHandshake ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected && hasHandshake ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected && hasHandshake ? Icons.check_circle : Icons.warning,
            color: isConnected && hasHandshake ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isConnected && hasHandshake
                  ? 'WebSocket已连接，握手完成'
                  : 'WebSocket未连接或握手未完成',
              style: TextStyle(
                color: isConnected && hasHandshake ? Colors.green.shade700 : Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建状态信息
  Widget _buildStatusInfo(
    BuildContext context, 
    AudioStreamState state, 
    AudioStreamNotifier notifier
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(state.status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(state.status),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                notifier.statusDescription,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (state.errorMessage != null) ...[ 
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '初始化: ${state.isInitialized ? "是" : "否"} | '
            '权限: ${state.hasPermission ? "已授权" : "未授权"} | '
            '流传输: ${state.isStreaming ? "进行中" : "停止"}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          
          // 调试信息
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '调试信息:\n'
              '流传输状态: ${state.isStreaming}\n'
              '初始化状态: ${state.isInitialized}\n'
              '权限状态: ${state.hasPermission}\n'
              '处理状态: ${state.isProcessing}\n'
              '当前状态: ${state.status}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建流传输统计
  Widget _buildStreamingStats(BuildContext context, Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '流传输统计',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text('流传输时长: ${stats['streaming_duration'] ?? 0}ms'),
          Text('流传输帧数: ${stats['streamed_frames'] ?? 0}'),
          Text('编码帧数: ${stats['encoded_frames'] ?? 0}'),
          Text('缓冲区大小: ${stats['buffer_size'] ?? 0} 字节'),
          if (stats['state'] != null)
            Text('服务状态: ${stats['state']}'),
        ],
      ),
    );
  }

  /// 构建流传输指示器
  Widget _buildStreamingIndicator(BuildContext context, int duration) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          // 流传输动画点
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '音频流传输中... ${(duration / 1000).toStringAsFixed(1)}s',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.stream,
            color: Colors.blue.shade700,
            size: 16,
          ),
        ],
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButtons(
    BuildContext context, 
    AudioStreamState state, 
    AudioStreamNotifier notifier,
    ConnectionManagerState connectionState,
  ) {
    final isConnected = connectionState.webSocketState.isConnected;
    final hasHandshake = connectionState.handshakeResult.isCompleted;
    final canStream = isConnected && hasHandshake;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 连接要求提示
        if (!canStream) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.amber.shade700, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '需要先连接WebSocket并完成握手才能开始音频流传输',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // 按钮行
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // 初始化按钮
            if (!state.isInitialized)
              ElevatedButton.icon(
                onPressed: state.isProcessing ? null : () async {
                  print('用户点击初始化按钮');
                  final success = await notifier.initializeStreaming();
                  print('初始化结果: $success');
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('初始化失败，请检查权限')),
                    );
                  }
                },
                icon: const Icon(Icons.settings),
                label: const Text('初始化'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            
            // 开始流传输按钮
            if (state.isInitialized && !state.isStreaming)
              ElevatedButton.icon(
                onPressed: (state.isProcessing || !canStream) ? null : () async {
                  print('用户点击开始流传输按钮');
                  final success = await notifier.startStreaming();
                  print('开始流传输结果: $success');
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('开始流传输失败，请检查连接和权限')),
                    );
                  }
                },
                icon: const Icon(Icons.stream),
                label: const Text('开始流传输'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            
            // 停止流传输按钮
            if (state.isStreaming)
              ElevatedButton.icon(
                onPressed: () async {
                  print('用户点击停止流传输按钮');
                  final success = await notifier.stopStreaming();
                  print('停止流传输结果: $success');
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('停止流传输失败')),
                    );
                  }
                },
                icon: const Icon(Icons.stop),
                label: const Text('停止流传输'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            
            // 重置按钮
            ElevatedButton.icon(
              onPressed: state.isProcessing ? null : () {
                print('用户点击重置按钮');
                notifier.reset();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重置'),
            ),
          ],
        ),
      ],
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case AudioConstants.stateIdle:
        return Colors.blue;
      case AudioConstants.stateRecording:
        return Colors.green;
      case AudioConstants.stateProcessing:
        return Colors.orange;
      case AudioConstants.stateError:
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(String status) {
    switch (status) {
      case AudioConstants.stateIdle:
        return Icons.check_circle;
      case AudioConstants.stateRecording:
        return Icons.stream;
      case AudioConstants.stateProcessing:
        return Icons.hourglass_empty;
      case AudioConstants.stateError:
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}

/// 音频流测试页面
class AudioStreamTestPage extends StatelessWidget {
  const AudioStreamTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音频流传输测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            AudioStreamTest(),
          ],
        ),
      ),
    );
  }
}
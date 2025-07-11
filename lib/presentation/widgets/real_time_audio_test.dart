import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/real_time_audio_provider.dart';
import '../providers/connection_provider.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/websocket_state.dart';
import '../../data/models/connection_state.dart';

/// 实时音频流处理测试组件
/// 完整测试实时音频流处理功能，包括音频流传输和TTS播放
class RealTimeAudioTest extends HookConsumerWidget {
  const RealTimeAudioTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(realTimeAudioProvider);
    final connectionState = ref.watch(connectionManagerProvider);
    
    // 处理时长状态
    final processingDuration = useState<int>(0);
    final isProcessing = useState<bool>(false);
    
    // 处理时长计时器
    useEffect(() {
      if (audioState.isProcessing) {
        isProcessing.value = true;
        processingDuration.value = 0;
        
        final timer = Stream.periodic(const Duration(milliseconds: 100))
            .listen((_) {
          if (audioState.isProcessing) {
            processingDuration.value += 100;
          }
        });
        return timer.cancel;
      } else {
        isProcessing.value = false;
      }
      return null;
    }, [audioState.isProcessing]);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.waves,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '实时音频流处理测试',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 连接状态检查
            _buildConnectionStatus(context, connectionState),
            const SizedBox(height: 16),
            
            // 处理状态显示
            _buildProcessingStatus(context, audioState, processingDuration.value),
            const SizedBox(height: 16),
            
            // 处理控制区域
            _buildProcessingControlArea(context, ref, audioState, isProcessing.value),
            const SizedBox(height: 16),
            
            // 消息列表
            if (audioState.messages.isNotEmpty)
              _buildMessageList(context, audioState.messages),
            
            const SizedBox(height: 16),
            
            // 处理统计
            if (audioState.stats != null)
              _buildProcessingStats(context, audioState.stats!),
            
            const SizedBox(height: 16),
            
            // 测试说明
            _buildTestInstructions(context),
          ],
        ),
      ),
    );
  }

  /// 构建连接状态
  Widget _buildConnectionStatus(BuildContext context, ConnectionManagerState connectionState) {
    final isReady = connectionState.webSocketState.isConnected &&
        connectionState.handshakeResult.isCompleted;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReady ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isReady ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle : Icons.warning,
            color: isReady ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isReady ? '连接就绪，可以开始实时音频流处理' : '请先连接WebSocket并完成握手',
            style: TextStyle(
              color: isReady ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建处理状态
  Widget _buildProcessingStatus(BuildContext context, RealTimeAudioState state, int duration) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(state.currentState),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(state.currentState),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(state.currentState),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (state.isProcessing) ...[ 
                  const SizedBox(height: 4),
                  Text(
                    '处理时长: ${(duration / 1000).toStringAsFixed(1)}s',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (state.streamDuration > 0) ...[ 
                  const SizedBox(height: 4),
                  Text(
                    '流持续时间: ${(state.streamDuration / 1000).toStringAsFixed(1)}s',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (state.errorMessage != null) ...[ 
                  const SizedBox(height: 4),
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建处理控制区域
  Widget _buildProcessingControlArea(
    BuildContext context, 
    WidgetRef ref, 
    RealTimeAudioState state, 
    bool isProcessing
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // 提示文字
          Text(
            isProcessing ? '正在进行实时音频流处理' : '点击按钮开始实时音频流处理',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          
          // 处理控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 初始化按钮
              if (!state.isInitialized)
                ElevatedButton.icon(
                  onPressed: () async {
                    print('用户点击初始化按钮');
                    final success = await ref.read(realTimeAudioProvider.notifier).initialize();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('初始化失败')),
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
              
              // 开始处理按钮
              if (state.isInitialized && !state.isProcessing)
                ElevatedButton.icon(
                  onPressed: () async {
                    print('用户点击开始处理按钮');
                    final success = await ref.read(realTimeAudioProvider.notifier).startProcessing();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('开始处理失败')),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('开始处理'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              
              // 停止处理按钮
              if (state.isProcessing)
                ElevatedButton.icon(
                  onPressed: () async {
                    print('用户点击停止处理按钮');
                    final success = await ref.read(realTimeAudioProvider.notifier).stopProcessing();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('停止处理失败')),
                      );
                    }
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('停止处理'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              
              // 发送Listen命令按钮
              if (state.isInitialized)
                ElevatedButton.icon(
                  onPressed: () async {
                    print('用户点击发送Listen命令按钮');
                    final success = await ref.read(realTimeAudioProvider.notifier).sendListenCommand('start');
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('发送命令失败')),
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('发送Listen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 状态指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIndicator('已初始化', state.isInitialized),
              const SizedBox(width: 16),
              _buildStatusIndicator('处理中', state.isProcessing),
              const SizedBox(width: 16),
              _buildStatusIndicator('有消息', state.messages.isNotEmpty),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator(String label, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 构建消息列表
  Widget _buildMessageList(BuildContext context, List<String> messages) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '消息日志 (${messages.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton(
                onPressed: () {
                  // 清空消息
                  // ref.read(realTimeAudioProvider.notifier).clearMessages();
                },
                child: const Text('清空'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建处理统计
  Widget _buildProcessingStats(BuildContext context, Map<String, dynamic> stats) {
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
            '处理统计',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text('处理时长: ${stats['stream_duration'] ?? 0}ms'),
          Text('接收帧数: ${stats['received_frames'] ?? 0}'),
          Text('播放帧数: ${stats['played_frames'] ?? 0}'),
          Text('当前状态: ${stats['current_state'] ?? 'unknown'}'),
          Text('正在处理: ${stats['is_processing'] ?? false}'),
          if (stats['stream_stats'] != null) ...[ 
            const SizedBox(height: 8),
            Text('流统计:', style: Theme.of(context).textTheme.labelMedium),
            ...((stats['stream_stats'] as Map<String, dynamic>).entries.map((entry) =>
              Text('  ${entry.key}: ${entry.value}'))),
          ],
          if (stats['playback_stats'] != null) ...[ 
            const SizedBox(height: 8),
            Text('播放统计:', style: Theme.of(context).textTheme.labelMedium),
            ...((stats['playback_stats'] as Map<String, dynamic>).entries.map((entry) =>
              Text('  ${entry.key}: ${entry.value}'))),
          ],
        ],
      ),
    );
  }

  /// 构建测试说明
  Widget _buildTestInstructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '测试说明',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. 确保WebSocket连接和握手完成\n'
            '2. 点击"初始化"按钮初始化音频服务\n'
            '3. 点击"开始处理"按钮开始实时音频流处理\n'
            '4. 点击"发送Listen"按钮发送语音控制命令\n'
            '5. 观察处理状态、消息日志和统计信息\n'
            '6. 点击"停止处理"按钮停止处理',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case AudioConstants.stateIdle:
        return Colors.blue;
      case AudioConstants.stateProcessing:
        return Colors.orange;
      case AudioConstants.stateRecording:
        return Colors.green;
      case AudioConstants.stateError:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(String status) {
    switch (status) {
      case AudioConstants.stateIdle:
        return Icons.pause_circle_outline;
      case AudioConstants.stateProcessing:
        return Icons.autorenew;
      case AudioConstants.stateRecording:
        return Icons.play_circle_outline;
      case AudioConstants.stateError:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  /// 获取状态文本
  String _getStatusText(String status) {
    switch (status) {
      case AudioConstants.stateIdle:
        return '空闲中';
      case AudioConstants.stateProcessing:
        return '处理中';
      case AudioConstants.stateRecording:
        return '录制中';
      case AudioConstants.stateError:
        return '错误';
      default:
        return '未知状态';
    }
  }
}

/// 实时音频流处理测试页面
class RealTimeAudioTestPage extends StatelessWidget {
  const RealTimeAudioTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时音频流处理测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            RealTimeAudioTest(),
          ],
        ),
      ),
    );
  }
}
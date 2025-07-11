import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/audio_playback_provider.dart';
import '../providers/connection_provider.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/websocket_state.dart';
import '../../data/models/connection_state.dart';

/// TTS音频播放测试组件
/// 完整测试TTS音频接收、解码和播放功能
class TtsPlaybackTest extends HookConsumerWidget {
  const TtsPlaybackTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(audioPlaybackProvider);
    final connectionState = ref.watch(connectionManagerProvider);
    
    // 播放时长状态
    final playbackDuration = useState<int>(0);
    final isPlaying = useState<bool>(false);
    
    // 播放时长计时器
    useEffect(() {
      if (playbackState.isPlaying) {
        isPlaying.value = true;
        playbackDuration.value = 0;
        
        final timer = Stream.periodic(const Duration(milliseconds: 100))
            .listen((_) {
          if (playbackState.isPlaying) {
            playbackDuration.value += 100;
          }
        });
        return timer.cancel;
      } else {
        isPlaying.value = false;
      }
      return null;
    }, [playbackState.isPlaying]);

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
                  Icons.volume_up,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'TTS音频播放测试',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 连接状态检查
            _buildConnectionStatus(context, connectionState),
            const SizedBox(height: 16),
            
            // 播放状态显示
            _buildPlaybackStatus(context, playbackState, playbackDuration.value),
            const SizedBox(height: 16),
            
            // 播放控制区域
            _buildPlaybackControlArea(context, ref, playbackState, isPlaying.value),
            const SizedBox(height: 16),
            
            // 播放统计
            if (playbackState.playbackStats != null)
              _buildPlaybackStats(context, playbackState.playbackStats!),
            
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
            isReady ? '连接就绪，可以接收TTS音频' : '请先连接WebSocket并完成握手',
            style: TextStyle(
              color: isReady ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建播放状态
  Widget _buildPlaybackStatus(BuildContext context, AudioPlaybackState state, int duration) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(state.status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(state.status),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(state.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (state.isPlaying) ...[
                  const SizedBox(height: 4),
                  Text(
                    '播放时长: ${(duration / 1000).toStringAsFixed(1)}s',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (state.currentPosition != Duration.zero) ...[
                  const SizedBox(height: 4),
                  Text(
                    '位置: ${_formatDuration(state.currentPosition)} / ${_formatDuration(state.totalDuration)}',
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

  /// 构建播放控制区域
  Widget _buildPlaybackControlArea(
    BuildContext context, 
    WidgetRef ref, 
    AudioPlaybackState state, 
    bool isPlaying
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
            isPlaying ? '正在播放TTS音频' : '点击按钮测试TTS播放',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          
          // 播放控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 初始化按钮
              if (!state.isInitialized)
                ElevatedButton.icon(
                  onPressed: state.isProcessing ? null : () async {
                    print('用户点击初始化按钮');
                    final success = await ref.read(audioPlaybackProvider.notifier).initializePlayback();
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
              
              // 模拟接收TTS数据按钮
              if (state.isInitialized && !state.isPlaying)
                ElevatedButton.icon(
                  onPressed: () async {
                    print('用户点击模拟TTS数据按钮');
                    // 模拟一些Opus音频数据
                    final mockOpusData = _createMockOpusData();
                    final success = await ref.read(audioPlaybackProvider.notifier).receiveTtsAudio(mockOpusData);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('TTS数据接收成功')),
                      );
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('接收TTS数据'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              
              // 播放按钮
              if (state.isInitialized && !state.isPlaying)
                ElevatedButton.icon(
                  onPressed: () async {
                    print('用户点击播放按钮');
                    final success = await ref.read(audioPlaybackProvider.notifier).startPlayback();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('播放失败，请先接收TTS数据')),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('播放'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              
              // 停止按钮
              if (state.isPlaying)
                ElevatedButton.icon(
                  onPressed: () async {
                    print('用户点击停止按钮');
                    final success = await ref.read(audioPlaybackProvider.notifier).stopPlayback();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('停止播放失败')),
                      );
                    }
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('停止'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
              _buildStatusIndicator('初始化', state.isInitialized),
              const SizedBox(width: 16),
              _buildStatusIndicator('播放中', state.isPlaying),
              const SizedBox(width: 16),
              _buildStatusIndicator('处理中', state.isProcessing),
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

  /// 构建播放统计
  Widget _buildPlaybackStats(BuildContext context, Map<String, dynamic> stats) {
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
            '播放统计',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text('播放时长: ${stats['playback_duration'] ?? 0}ms'),
          Text('解码帧数: ${stats['decoded_frames'] ?? 0}'),
          Text('播放帧数: ${stats['played_frames'] ?? 0}'),
          Text('缓冲区大小: ${stats['buffer_size'] ?? 0} 帧'),
          Text('PCM缓冲区大小: ${stats['pcm_buffer_size'] ?? 0} 样本'),
          if (stats['state'] != null)
            Text('播放状态: ${stats['state']}'),
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
            '1. 确保WebSocket连接正常\n'
            '2. 点击"初始化"按钮初始化播放器\n'
            '3. 点击"接收TTS数据"模拟音频数据\n'
            '4. 点击"播放"按钮开始播放\n'
            '5. 观察播放状态和统计信息',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 创建模拟Opus数据
  List<int> _createMockOpusData() {
    // 创建一些模拟的Opus音频数据
    // 这里只是为了测试，实际应用中会从WebSocket接收真实的Opus数据
    final mockData = List.generate(1024, (index) => index % 256);
    return mockData;
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(String status) {
    switch (status) {
      case AudioConstants.stateIdle:
        return Icons.play_circle_outline;
      case AudioConstants.stateRecording:
        return Icons.volume_up;
      case AudioConstants.stateProcessing:
        return Icons.hourglass_empty;
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
        return '待机中';
      case AudioConstants.stateRecording:
        return '播放中';
      case AudioConstants.stateProcessing:
        return '处理中';
      case AudioConstants.stateError:
        return '错误';
      default:
        return '未知状态';
    }
  }
}

/// TTS播放测试页面
class TtsPlaybackTestPage extends StatelessWidget {
  const TtsPlaybackTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS音频播放测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            TtsPlaybackTest(),
          ],
        ),
      ),
    );
  }
}
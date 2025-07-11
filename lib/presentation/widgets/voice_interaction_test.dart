import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/audio_stream_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/chat_provider.dart';
import '../../data/models/connection_state.dart';
import '../../data/models/chat_state.dart';
import '../../data/models/websocket_state.dart';
import 'voice_input_widget.dart';
import '../../core/constants/audio_constants.dart';

/// 语音交互测试组件
/// 完整测试语音输入和交互功能
class VoiceInteractionTest extends HookConsumerWidget {
  const VoiceInteractionTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamState = ref.watch(audioStreamProvider);
    final connectionState = ref.watch(connectionManagerProvider);
    final chatState = ref.watch(chatProvider);
    
    // 录制时长状态
    final recordingDuration = useState<int>(0);
    final isRecording = useState<bool>(false);
    
    // 录制时长计时器
    useEffect(() {
      if (streamState.isStreaming) {
        isRecording.value = true;
        recordingDuration.value = 0;
        
        final timer = Stream.periodic(const Duration(milliseconds: 100))
            .listen((_) {
          if (streamState.isStreaming) {
            recordingDuration.value += 100;
          }
        });
        return timer.cancel;
      } else {
        isRecording.value = false;
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
            Row(
              children: [
                Icon(
                  Icons.record_voice_over,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '语音交互测试',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 连接状态检查
            _buildConnectionStatus(context, connectionState),
            const SizedBox(height: 16),
            
            // 语音状态显示
            _buildVoiceStatus(context, streamState, recordingDuration.value),
            const SizedBox(height: 16),
            
            // 语音输入区域
            _buildVoiceInputArea(context, ref, streamState, isRecording.value),
            const SizedBox(height: 16),
            
            // 测试说明
            _buildTestInstructions(context),
            
            // 聊天状态
            if (chatState.isReceiving) ...[ 
              const SizedBox(height: 16),
              _buildChatStatus(context, chatState),
            ],
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
            isReady ? '连接就绪，可以开始语音交互' : '请先连接WebSocket并完成握手',
            style: TextStyle(
              color: isReady ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建语音状态
  Widget _buildVoiceStatus(BuildContext context, AudioStreamState state, int duration) {
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
                if (state.isStreaming) ...[
                  const SizedBox(height: 4),
                  Text(
                    '录制时长: ${(duration / 1000).toStringAsFixed(1)}s',
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

  /// 构建语音输入区域
  Widget _buildVoiceInputArea(
    BuildContext context, 
    WidgetRef ref, 
    AudioStreamState state, 
    bool isRecording
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
            isRecording ? '正在录制，松开结束' : '长按开始录制',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          
          // 语音输入按钮
          Center(
            child: VoiceInputWidget(
              size: 80,
              onVoiceStart: () {
                print('[VoiceInteractionTest] 语音录制开始');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('开始录制语音')),
                );
              },
              onVoiceEnd: () {
                print('[VoiceInteractionTest] 语音录制结束');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('录制结束，等待服务器响应')),
                );
              },
              onVoiceCancel: () {
                print('[VoiceInteractionTest] 语音录制取消');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('录制已取消')),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 状态指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: state.isInitialized ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '初始化',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: state.hasPermission ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '权限',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: state.isStreaming ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '录制',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
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
            '2. 长按语音按钮开始录制\n'
            '3. 说话时保持按住状态\n'
            '4. 松开按钮结束录制\n'
            '5. 等待服务器处理和响应',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建聊天状态
  Widget _buildChatStatus(BuildContext context, ChatState chatState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '正在等待AI响应...',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
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
        return Icons.mic_none;
      case AudioConstants.stateRecording:
        return Icons.mic;
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
        return '录制中';
      case AudioConstants.stateProcessing:
        return '处理中';
      case AudioConstants.stateError:
        return '错误';
      default:
        return '未知状态';
    }
  }
}

/// 语音交互测试页面
class VoiceInteractionTestPage extends StatelessWidget {
  const VoiceInteractionTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语音交互测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            VoiceInteractionTest(),
          ],
        ),
      ),
    );
  }
}
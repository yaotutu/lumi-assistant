import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/audio_recording_provider.dart';
import '../../core/constants/audio_constants.dart';
import 'dart:typed_data';

/// 音频录制测试组件
/// 用于测试音频录制功能
class AudioRecordingTest extends HookConsumerWidget {
  const AudioRecordingTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(audioRecordingProvider);
    final recordingNotifier = ref.watch(audioRecordingProvider.notifier);
    
    // 录制数据状态
    final recordedData = useState<Uint8List?>(null);
    final recordingDuration = useState<int>(0);
    
    // 定时器，用于更新录制时长
    useEffect(() {
      if (recordingState.isRecording) {
        final timer = Stream.periodic(const Duration(milliseconds: 100))
            .listen((_) {
          recordingDuration.value = recordingNotifier.recordingDuration;
        });
        return timer.cancel;
      }
      return null;
    }, [recordingState.isRecording]);

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
              '音频录制测试',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // 状态信息
            _buildStatusInfo(context, recordingState, recordingNotifier),
            const SizedBox(height: 16),
            
            // 录制统计
            if (recordingState.recordingStats != null)
              _buildRecordingStats(context, recordingState.recordingStats!),
            
            if (recordingState.isRecording)
              _buildRecordingIndicator(context, recordingDuration.value),
            
            const SizedBox(height: 16),
            
            // 控制按钮
            _buildControlButtons(context, recordingState, recordingNotifier, recordedData),
            
            // 录制结果
            if (recordedData.value != null)
              _buildRecordingResult(context, recordedData.value!),
          ],
        ),
      ),
    );
  }

  /// 构建状态信息
  Widget _buildStatusInfo(
    BuildContext context, 
    AudioRecordingState state, 
    AudioRecordingNotifier notifier
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
            '权限: ${state.hasPermission ? "已授权" : "未授权"} | '
            '初始化: ${state.isInitialized ? "是" : "否"}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建录制统计
  Widget _buildRecordingStats(BuildContext context, Map<String, dynamic> stats) {
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
            '录制统计',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text('录制帧数: ${stats['recordedFrames'] ?? 0}'),
          Text('编码帧数: ${stats['encodedFrames'] ?? 0}'),
          Text('录制时长: ${stats['recordingDuration'] ?? 0}ms'),
          if (stats['currentPath'] != null)
            Text('文件路径: ${stats['currentPath']}'),
        ],
      ),
    );
  }

  /// 构建录制指示器
  Widget _buildRecordingIndicator(BuildContext context, int duration) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          // 录制动画点
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '录制中... ${(duration / 1000).toStringAsFixed(1)}s',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButtons(
    BuildContext context, 
    AudioRecordingState state, 
    AudioRecordingNotifier notifier,
    ValueNotifier<Uint8List?> recordedData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 调试信息
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '调试信息:\n'
            '初始化状态: ${state.isInitialized}\n'
            '录制状态: ${state.isRecording}\n'
            '权限状态: ${state.hasPermission}\n'
            '处理状态: ${state.isProcessing}\n'
            '当前状态: ${state.status}',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(height: 8),
        
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
                  final success = await notifier.initializeRecording();
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
            
            // 录制按钮
            if (state.isInitialized && !state.isRecording)
              ElevatedButton.icon(
                onPressed: state.isProcessing ? null : () async {
                  print('用户点击开始录制按钮');
                  final success = await notifier.startRecording();
                  print('开始录制结果: $success');
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('录制失败，请检查权限和设备')),
                    );
                  }
                },
                icon: const Icon(Icons.mic),
                label: const Text('开始录制'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            
            // 停止按钮
            if (state.isRecording)
              ElevatedButton.icon(
                onPressed: () async {
                  print('用户点击停止录制按钮');
                  final data = await notifier.stopRecording();
                  recordedData.value = data;
                  if (data != null) {
                    print('录制停止成功，获得数据: ${data.length} bytes');
                  }
                },
                icon: const Icon(Icons.stop),
                label: const Text('停止录制'),
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
                recordedData.value = null;
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重置'),
            ),
            
            // 请求权限按钮
            if (!state.hasPermission)
              ElevatedButton.icon(
                onPressed: state.isProcessing ? null : () async {
                  print('用户点击请求权限按钮');
                  final success = await notifier.requestPermissions();
                  print('请求权限结果: $success');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? '权限获取成功' : '权限获取失败')),
                    );
                  }
                },
                icon: const Icon(Icons.security),
                label: const Text('请求权限'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 构建录制结果
  Widget _buildRecordingResult(BuildContext context, Uint8List data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '录制成功！',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('Opus数据大小: ${data.length} bytes'),
          Text('数据格式: Opus编码音频'),
          const SizedBox(height: 8),
          Text(
            '数据预览: ${data.take(20).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}${data.length > 20 ? '...' : ''}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.grey.shade600,
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
        return Colors.red;
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
        return Icons.mic;
      case AudioConstants.stateProcessing:
        return Icons.hourglass_empty;
      case AudioConstants.stateError:
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}

/// 音频录制测试页面
class AudioRecordingTestPage extends StatelessWidget {
  const AudioRecordingTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音频录制测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            AudioRecordingTest(),
          ],
        ),
      ),
    );
  }
}
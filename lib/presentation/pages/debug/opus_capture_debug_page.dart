import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/services/opus_data_capture_service.dart';
import '../../../core/services/websocket_service.dart';
import '../../providers/connection_provider.dart';

/// Opus数据捕获调试页面
class OpusCaptureDebugPage extends HookConsumerWidget {
  const OpusCaptureDebugPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCapturing = useState(false);
    final captureStats = useState<Map<String, dynamic>>({});
    
    // 定时更新统计信息
    useEffect(() {
      final timer = Stream.periodic(const Duration(milliseconds: 500)).listen((_) {
        captureStats.value = OpusDataCaptureService.getCaptureStatistics();
      });
      return timer.cancel;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opus数据捕获调试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '捕获状态',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isCapturing.value ? Icons.fiber_manual_record : Icons.stop_circle,
                          color: isCapturing.value ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCapturing.value ? '正在捕获' : '已停止',
                          style: TextStyle(
                            color: isCapturing.value ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 统计信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '统计信息',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow('数据包数量', '${captureStats.value['total_samples'] ?? 0}'),
                    _buildStatRow('总字节数', '${captureStats.value['total_bytes'] ?? 0}'),
                    _buildStatRow('平均大小', '${captureStats.value['average_size'] ?? 0} 字节'),
                    _buildStatRow('会话ID', '${captureStats.value['session_id'] ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 控制按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isCapturing.value ? null : () async {
                      final sessionId = 'debug_${DateTime.now().millisecondsSinceEpoch}';
                      
                      // 开始捕获
                      OpusDataCaptureService.startCapture(sessionId: sessionId);
                      isCapturing.value = true;
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('开始捕获opus数据，正在发送测试消息...')),
                      );
                      
                      // 自动发送测试消息给服务端，触发语音回复
                      try {
                        final webSocketService = ref.read(webSocketServiceProvider.notifier);
                        final testMessage = {
                          'type': 'chat',
                          'text': '你好',
                          'timestamp': DateTime.now().millisecondsSinceEpoch,
                        };
                        
                        await webSocketService.sendMessage(testMessage);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('测试消息已发送，等待服务端语音回复...')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('发送测试消息失败: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('开始捕获'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !isCapturing.value ? null : () {
                      OpusDataCaptureService.stopCapture();
                      isCapturing.value = false;
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('停止捕获opus数据')),
                      );
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('停止捕获'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 保存和清空按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final savedFiles = await OpusDataCaptureService.saveCapturedData();
                        if (savedFiles.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('保存了 ${savedFiles.length} 个文件')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('没有数据需要保存')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('保存失败: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('保存数据'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      OpusDataCaptureService.clearCapturedData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已清空捕获数据')),
                      );
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('清空数据'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 使用说明
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使用说明',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. 点击"开始捕获"按钮，系统会自动发送"你好"消息给服务端\n'
                      '2. 服务端会回复语音数据，系统自动捕获这些opus数据\n'
                      '3. 观察统计信息中的数据包数量变化\n'
                      '4. 点击"停止捕获"按钮停止记录\n'
                      '5. 点击"保存数据"将捕获的opus文件保存到设备存储\n'
                      '6. 保存的.opus文件可用于后续的播放测试和分析',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
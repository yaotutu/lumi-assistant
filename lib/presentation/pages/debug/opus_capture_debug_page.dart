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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态和统计信息合并卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCapturing.value ? Icons.fiber_manual_record : Icons.stop_circle,
                          color: isCapturing.value ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCapturing.value ? '正在捕获' : '已停止',
                          style: TextStyle(
                            color: isCapturing.value ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '数据包: ${captureStats.value['total_samples'] ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactStatRow('总字节', '${captureStats.value['total_bytes'] ?? 0}'),
                        ),
                        Expanded(
                          child: _buildCompactStatRow('平均大小', '${captureStats.value['average_size'] ?? 0}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 控制按钮 - 紧凑布局
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCapturing.value ? null : () async {
                      final sessionId = 'debug_${DateTime.now().millisecondsSinceEpoch}';
                      
                      // 开始捕获
                      OpusDataCaptureService.startCapture(sessionId: sessionId);
                      isCapturing.value = true;
                      
                      // 自动发送测试消息给服务端，触发语音回复
                      try {
                        final webSocketService = ref.read(webSocketServiceProvider.notifier);
                        final testMessage = {
                          'type': 'listen',
                          'state': 'detect',
                          'text': '你好',
                          'source': 'text',
                        };
                        
                        await webSocketService.sendMessage(testMessage);
                      } catch (e) {
                        print('发送测试消息失败: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('开始捕获'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: !isCapturing.value ? null : () {
                      OpusDataCaptureService.stopCapture();
                      isCapturing.value = false;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('停止'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 保存和清空按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final savedFiles = await OpusDataCaptureService.saveCapturedData();
                        print('保存了 ${savedFiles.length} 个文件');
                      } catch (e) {
                        print('保存失败: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('保存'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      OpusDataCaptureService.clearCapturedData();
                      print('已清空捕获数据');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('清空'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 简化的使用说明
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '操作步骤：开始捕获 → 等待回复 → 停止捕获 → 保存数据',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
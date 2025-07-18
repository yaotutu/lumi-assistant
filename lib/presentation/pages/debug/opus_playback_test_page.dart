import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/audio_service_android_style.dart';
import '../../../core/services/audio_service_simple.dart';

/// Opus播放测试页面
/// 
/// 用于测试不同音频库播放opus数据的效果
/// 可以加载保存的opus文件并进行播放测试
class OpusPlaybackTestPage extends HookConsumerWidget {
  const OpusPlaybackTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opusFiles = useState<List<File>>([]);
    final selectedFile = useState<File?>(null);
    final isLoading = useState(false);
    final testResults = useState<Map<String, String>>({});
    final currentlyTesting = useState<String>('');

    // 音频服务实例
    final audioServiceAndroid = useMemoized(() => AudioServiceAndroidStyle());
    final audioServiceSimple = useMemoized(() => AudioServiceSimple());

    // 加载opus文件列表
    useEffect(() {
      _loadOpusFiles().then((files) {
        opusFiles.value = files;
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opus播放测试'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文件选择区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Opus文件',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            isLoading.value = true;
                            final files = await _loadOpusFiles();
                            opusFiles.value = files;
                            isLoading.value = false;
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('刷新'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoading.value)
                      const Center(child: CircularProgressIndicator())
                    else if (opusFiles.value.isEmpty)
                      const Text(
                        '没有找到opus文件。请先使用Opus捕获功能保存一些文件。',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: opusFiles.value.length,
                          itemBuilder: (context, index) {
                            final file = opusFiles.value[index];
                            final isSelected = selectedFile.value?.path == file.path;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () => selectedFile.value = file,
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? Colors.purple : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected ? Colors.purple.shade50 : Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.path.split('/').last,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      FutureBuilder<int>(
                                        future: file.length(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Text(
                                              '${snapshot.data} 字节',
                                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                                            );
                                          }
                                          return const Text('...', style: TextStyle(fontSize: 10));
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.purple,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            '已选择',
                                            style: TextStyle(color: Colors.white, fontSize: 10),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 播放测试区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '播放测试',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    if (selectedFile.value == null)
                      const Text(
                        '请先选择一个opus文件',
                        style: TextStyle(color: Colors.grey),
                      )
                    else ...[
                      Text('已选择文件: ${selectedFile.value!.path.split('/').last}'),
                      const SizedBox(height: 16),
                      
                      // 测试按钮
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: currentlyTesting.value.isNotEmpty ? null : () async {
                                await _testAudioService(
                                  'AndroidStyle',
                                  audioServiceAndroid,
                                  selectedFile.value!,
                                  currentlyTesting,
                                  testResults,
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('测试 AndroidStyle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: currentlyTesting.value.isNotEmpty ? null : () async {
                                await _testAudioService(
                                  'Simple',
                                  audioServiceSimple,
                                  selectedFile.value!,
                                  currentlyTesting,
                                  testResults,
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('测试 Simple'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (currentlyTesting.value.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text('正在测试: ${currentlyTesting.value}'),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 测试结果区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '测试结果',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (testResults.value.isEmpty)
                      const Text(
                        '暂无测试结果',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Column(
                        children: testResults.value.entries.map((entry) {
                          final isSuccess = entry.value.contains('成功');
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSuccess ? Icons.check_circle : Icons.error,
                                  color: isSuccess ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        entry.value,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // 简化说明
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '选择opus文件 → 测试播放效果 → 观察结果',
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

  /// 加载opus文件列表
  static Future<List<File>> _loadOpusFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final captureDir = Directory('${directory.path}/opus_captures');
      
      if (!await captureDir.exists()) {
        return [];
      }
      
      final files = await captureDir.list().where((entity) {
        return entity is File && entity.path.endsWith('.opus');
      }).cast<File>().toList();
      
      // 按修改时间排序，最新的在前
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return files;
    } catch (e) {
      print('[OpusPlaybackTest] 加载文件失败: $e');
      return [];
    }
  }

  /// 测试音频服务播放opus文件
  static Future<void> _testAudioService(
    String serviceName,
    dynamic audioService,
    File opusFile,
    ValueNotifier<String> currentlyTesting,
    ValueNotifier<Map<String, String>> testResults,
  ) async {
    currentlyTesting.value = serviceName;
    
    try {
      // 读取opus文件数据
      final opusData = await opusFile.readAsBytes();
      print('[OpusPlaybackTest] 测试 $serviceName: ${opusData.length} 字节');
      
      // 尝试播放
      await audioService.playOpusAudio(Uint8List.fromList(opusData));
      
      // 等待一段时间以确保播放完成
      await Future.delayed(const Duration(seconds: 2));
      
      final result = '播放成功 - 文件大小: ${opusData.length} 字节';
      testResults.value = {
        ...testResults.value,
        serviceName: result,
      };
      
      print('[OpusPlaybackTest] $serviceName 测试成功');
    } catch (error) {
      final result = '播放失败: $error';
      testResults.value = {
        ...testResults.value,
        serviceName: result,
      };
      
      print('[OpusPlaybackTest] $serviceName 测试失败: $error');
    } finally {
      currentlyTesting.value = '';
    }
  }
}
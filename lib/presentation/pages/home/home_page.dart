import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/connection_status_widget.dart';
import '../../widgets/handshake_status_widget.dart';
import '../chat/chat_page.dart';
import 'widgets/background_layer.dart';
import 'widgets/app_status_bar.dart';
import 'widgets/time_panel.dart';
import 'widgets/interaction_layer.dart';
import 'widgets/floating_actions.dart';
import '../../../core/services/audio_test_service.dart';
import '../../widgets/audio_recording_test.dart';
import '../../widgets/audio_stream_test.dart';
import '../../widgets/voice_interaction_test.dart';
import '../../widgets/tts_playback_test.dart';
import '../../widgets/real_time_audio_test.dart';
import '../../widgets/audio_test_widget.dart';

/// 应用主页 - 里程碑4：基础UI框架（重构后）
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // 底层：背景图片和基础装饰
          const BackgroundLayer(),
          
          // 底层：固定UI元素（时间、状态等）
          _buildBaseUILayer(context, ref),
          
          // 中间层：主要交互区域（为聊天、语音等预留）
          const InteractionLayer(),
          
          // 顶层：浮动操作按钮
          FloatingActions(
            onSettingsTap: () => _showSettings(context),
            onMainActionTap: () => _startChat(context),
            onAudioTestTap: () => _showAudioPlaybackTest(context),
            onAudioStreamTap: () => _showStreamTest(context),
            onVoiceInteractionTap: () => _showVoiceInteractionTest(context),
            onTtsPlaybackTap: () => _showTtsPlaybackTest(context),
            onRealTimeAudioTap: () => _showRealTimeAudioTest(context),
            onServerSwitchTap: null,
          ),
        ],
      ),
    );
  }

  /// 构建底层固定UI元素
  Widget _buildBaseUILayer(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          // 顶部状态栏（轻量化）
          AppStatusBar(
            onConnectionTap: () => _showConnectionDetails(context),
            onHandshakeTap: () => _showHandshakeDetails(context),
          ),
          
          const Spacer(),
          
          // 底部时间信息（固定在底部）
          const TimePanel(),
        ],
      ),
    );
  }
  
  /// 显示连接详情对话框
  void _showConnectionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: const ConnectionStatusCard(),
        ),
      ),
    );
  }

  /// 显示握手详情对话框
  void _showHandshakeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: const HandshakeStatusCard(),
        ),
      ),
    );
  }

  /// 显示设置界面
  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('设置功能将在后续里程碑中实现'),
        action: SnackBarAction(
          label: '确定',
          onPressed: () {},
        ),
      ),
    );
  }

  /// 开始聊天
  void _startChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatPage(),
      ),
    );
  }

  /// 显示音频测试对话框
  void _showAudioTest(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: AudioTestDialog(ref: ref),
        ),
      ),
    );
  }

  /// 显示音频播放测试对话框
  void _showAudioPlaybackTest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('音频播放测试'),
        content: const AudioTestWidget(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示录制测试页面
  void _showRecordingTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AudioRecordingTestPage(),
      ),
    );
  }

  /// 显示音频流测试页面
  void _showStreamTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AudioStreamTestPage(),
      ),
    );
  }

  /// 显示语音交互测试页面
  void _showVoiceInteractionTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VoiceInteractionTestPage(),
      ),
    );
  }

  /// 显示TTS播放测试页面
  void _showTtsPlaybackTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TtsPlaybackTestPage(),
      ),
    );
  }

  /// 显示实时音频流处理测试页面
  void _showRealTimeAudioTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RealTimeAudioTestPage(),
      ),
    );
  }

}

/// 音频测试对话框
class AudioTestDialog extends StatelessWidget {
  final WidgetRef ref;

  const AudioTestDialog({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.volume_up,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '音频播放测试',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 说明文字
          Text(
            '测试本地音频文件播放功能，确保音频系统正常工作。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 播放按钮
          Column(
            children: [
              // MP3播放按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _playMp3(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('播放 MP3 文件 (01.mp3)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // WAV播放按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _playWav(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('播放 WAV 文件 (02.wav)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Opus播放按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _playOpus(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('播放 Opus 文件 (03.opus)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 停止按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _stopAudio(context),
                  icon: const Icon(Icons.stop),
                  label: const Text('停止播放'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 关闭按钮
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ),
        ],
      ),
    );
  }

  /// 播放MP3文件
  void _playMp3(BuildContext context) async {
    try {
      final audioTestService = ref.read(audioTestServiceProvider);
      await audioTestService.playMp3();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('开始播放 MP3 文件')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放 MP3 失败: $e')),
        );
      }
    }
  }

  /// 播放WAV文件
  void _playWav(BuildContext context) async {
    try {
      final audioTestService = ref.read(audioTestServiceProvider);
      await audioTestService.playWav();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('开始播放 WAV 文件')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放 WAV 失败: $e')),
        );
      }
    }
  }

  /// 播放Opus文件
  void _playOpus(BuildContext context) async {
    try {
      final audioTestService = ref.read(audioTestServiceProvider);
      await audioTestService.playOpus();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('开始播放 Opus 文件')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放 Opus 失败: $e')),
        );
      }
    }
  }

  /// 停止播放
  void _stopAudio(BuildContext context) async {
    try {
      final audioTestService = ref.read(audioTestServiceProvider);
      await audioTestService.stop();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('音频播放已停止')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('停止播放失败: $e')),
        );
      }
    }
  }
}
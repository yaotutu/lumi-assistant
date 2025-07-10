import 'package:just_audio/just_audio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 音频测试服务
/// 
/// 用于测试本地音频文件播放功能
class AudioTestService {
  static const String tag = 'AudioTestService';
  
  // 音频播放器
  AudioPlayer? _audioPlayer;
  
  // 是否已初始化
  bool _isInitialized = false;

  /// 初始化音频测试服务
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[$tag] 音频测试服务已初始化，跳过');
      return;
    }

    try {
      print('[$tag] 开始初始化音频测试服务');
      
      // 初始化音频播放器
      _audioPlayer = AudioPlayer();
      
      _isInitialized = true;
      print('[$tag] 音频测试服务初始化完成');
      
    } catch (e) {
      print('[$tag] 音频测试服务初始化失败: $e');
      rethrow;
    }
  }

  /// 播放MP3文件
  Future<void> playMp3() async {
    await _playAssetFile('assets/audio/01.mp3', 'MP3');
  }

  /// 播放WAV文件
  Future<void> playWav() async {
    await _playAssetFile('assets/audio/02.wav', 'WAV');
  }

  /// 播放Opus文件
  Future<void> playOpus() async {
    await _playAssetFile('assets/audio/03.opus', 'Opus');
  }

  /// 播放资源文件
  Future<void> _playAssetFile(String assetPath, String fileType) async {
    if (!_isInitialized) {
      print('[$tag] 音频测试服务未初始化，先进行初始化');
      await initialize();
    }

    try {
      print('[$tag] 开始播放$fileType文件: $assetPath');
      
      if (_audioPlayer == null) {
        throw Exception('音频播放器未初始化');
      }

      // 设置音频源
      await _audioPlayer!.setAsset(assetPath);
      
      // 播放音频
      await _audioPlayer!.play();
      
      print('[$tag] $fileType文件播放开始');
    } catch (e) {
      print('[$tag] 播放$fileType文件失败: $e');
      rethrow;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        print('[$tag] 音频播放停止');
      }
    } catch (e) {
      print('[$tag] 停止音频播放失败: $e');
    }
  }

  /// 获取播放状态
  bool get isPlaying {
    return _audioPlayer?.playing ?? false;
  }

  /// 获取播放进度流
  Stream<Duration>? get positionStream {
    return _audioPlayer?.positionStream;
  }

  /// 获取播放状态流
  Stream<PlayerState>? get playerStateStream {
    return _audioPlayer?.playerStateStream;
  }

  /// 释放资源
  Future<void> dispose() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.dispose();
        _audioPlayer = null;
      }
      
      _isInitialized = false;
      print('[$tag] 音频测试服务资源释放完成');
    } catch (e) {
      print('[$tag] 音频测试服务资源释放失败: $e');
    }
  }
}

/// 音频测试服务Provider
final audioTestServiceProvider = Provider<AudioTestService>((ref) {
  final service = AudioTestService();
  
  // 在Provider被销毁时清理资源
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
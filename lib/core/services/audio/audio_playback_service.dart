import 'dart:typed_data';
import 'dart:io';
import 'android_native_audio_service.dart';

/// 跨平台音频播放服务接口
/// 
/// 设计目标：
/// 1. 为不同平台提供统一的音频播放接口
/// 2. Android使用原生AudioTrack实现
/// 3. iOS预留接口，方便未来扩展
/// 4. 支持Opus音频流的实时播放
abstract class AudioPlaybackService {
  /// 播放器是否已初始化
  bool get isInitialized;
  
  /// 当前播放状态
  AudioPlaybackState get playbackState;
  
  /// 初始化音频播放器
  /// 
  /// [channels] 声道数，1=单声道，2=立体声
  /// [sampleRate] 采样率，通常为16000
  /// [bitDepth] 位深度，通常为16
  Future<void> initialize({
    int channels = 1,
    int sampleRate = 16000,
    int bitDepth = 16,
  });
  
  /// 开始播放（准备接收音频数据）
  Future<void> startPlayback();
  
  /// 播放Opus音频数据
  /// 
  /// [opusData] Opus编码的音频数据
  /// 这是主要的播放接口，会自动解码Opus并播放PCM
  Future<void> playOpusAudio(Uint8List opusData);
  
  /// 直接播放PCM音频数据（可选接口）
  /// 
  /// [pcmData] 原始PCM音频数据
  Future<void> playPcmAudio(Uint8List pcmData);
  
  /// 暂停播放
  Future<void> pausePlayback();
  
  /// 恢复播放
  Future<void> resumePlayback();
  
  /// 停止播放
  Future<void> stopPlayback();
  
  /// 设置音量
  /// 
  /// [volume] 音量值，范围 [0.0, 1.0]
  Future<void> setVolume(double volume);
  
  /// 释放资源
  Future<void> dispose();
  
  /// 获取播放器详细状态信息（调试用）
  Map<String, dynamic> getStatusInfo();
}

/// 音频播放状态枚举
enum AudioPlaybackState {
  /// 未初始化
  uninitialized,
  /// 已初始化但未播放
  initialized,
  /// 正在播放
  playing,
  /// 已暂停
  paused,
  /// 已停止
  stopped,
  /// 错误状态
  error,
}

/// 跨平台音频播放服务工厂
/// 
/// 根据当前平台自动选择合适的实现
class AudioPlaybackServiceFactory {
  /// 创建适合当前平台的音频播放服务实例
  static AudioPlaybackService createService() {
    if (Platform.isAndroid) {
      return AndroidNativeAudioService();
    } else if (Platform.isIOS) {
      return _IOSAudioService();
    } else {
      throw UnsupportedError('当前平台 ${Platform.operatingSystem} 不支持音频播放');
    }
  }
  
  /// 检查当前平台是否支持音频播放
  static bool get isPlatformSupported {
    return Platform.isAndroid || Platform.isIOS;
  }
  
  /// 获取当前平台支持的功能描述
  static String get platformCapabilities {
    if (Platform.isAndroid) {
      return 'Android原生AudioTrack - 完整支持';
    } else if (Platform.isIOS) {
      return 'iOS AVAudioEngine - 待实现';
    } else {
      return '不支持的平台';
    }
  }
}

// Android平台音频服务实现已移至 android_native_audio_service.dart

/// iOS平台音频服务实现（预留接口）
/// 
/// 未来可以使用以下技术栈实现：
/// - AVAudioEngine (iOS 8.0+)
/// - AVAudioPlayerNode
/// - AVAudioFormat  
/// - MethodChannel与Swift/Objective-C原生代码通信
class _IOSAudioService implements AudioPlaybackService {
  @override
  bool get isInitialized => false;
  
  @override
  AudioPlaybackState get playbackState => AudioPlaybackState.uninitialized;
  
  @override
  Future<void> initialize({int channels = 1, int sampleRate = 16000, int bitDepth = 16}) async {
    throw UnsupportedError('iOS音频播放功能待实现。'
        '需要实现：'
        '1. 创建iOS原生音频播放器（Swift/Objective-C）'
        '2. 使用AVAudioEngine进行PCM播放'
        '3. 实现MethodChannel通信'
        '4. 集成Opus解码功能');
  }
  
  @override
  Future<void> startPlayback() async {
    throw UnsupportedError('iOS音频播放功能待实现');
  }
  
  @override
  Future<void> playOpusAudio(Uint8List opusData) async {
    throw UnsupportedError('iOS音频播放功能待实现');
  }
  
  @override
  Future<void> playPcmAudio(Uint8List pcmData) async {
    throw UnsupportedError('iOS音频播放功能待实现');
  }
  
  @override
  Future<void> pausePlayback() async {
    throw UnsupportedError('iOS音频播放功能待实现');
  }
  
  @override
  Future<void> resumePlayback() async {
    throw UnsupportedError('iOS音频播放功能待实现');
  }
  
  @override
  Future<void> stopPlayback() async {
    throw UnsupportedError('iOS音频播放功能待实现');
  }
  
  @override
  Future<void> setVolume(double volume) async {
    throw UnsupportedError('iOS音频播放功能待实现');
  }
  
  @override
  Future<void> dispose() async {
    // iOS资源清理逻辑
  }
  
  @override
  Map<String, dynamic> getStatusInfo() {
    return {
      'platform': 'iOS',
      'status': 'not_implemented',
      'message': 'iOS音频播放功能待实现',
      'isInitialized': false,
      'playbackState': 'uninitialized',
      'future_implementation': {
        'native_layer': 'Swift/Objective-C AVAudioEngine',
        'communication': 'MethodChannel',
        'audio_format': 'PCM16 @ 16kHz',
        'opus_support': 'Native Opus decoding'
      }
    };
  }
}
import 'dart:typed_data';
import 'package:opus_dart/opus_dart.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'audio_playback_service.dart';
import 'native_audio_player.dart';

/// Android平台原生音频播放服务
/// 
/// 基于自实现的NativeAudioPlayer，提供完整的Opus音频播放支持
/// - 使用Android AudioTrack进行PCM播放
/// - 集成Opus解码功能
/// - 支持实时音频流播放
/// - 完整的状态管理和错误处理
class AndroidNativeAudioService implements AudioPlaybackService {
  static const String _tag = 'AndroidNativeAudioService';
  
  // 音频参数配置
  static const int _sampleRate = 16000;     // 采样率16kHz
  static const int _channels = 1;           // 单声道
  static const int _frameDuration = 60;     // 帧时长60ms
  
  /// 原生PCM播放器实例
  NativeAudioPlayer? _nativePlayer;
  
  /// Opus解码器
  SimpleOpusDecoder? _opusDecoder;
  
  /// 播放器状态
  bool _isInitialized = false;
  AudioPlaybackState _currentState = AudioPlaybackState.uninitialized;
  
  /// 音频统计信息
  int _framesPlayed = 0;
  int _bytesProcessed = 0;
  DateTime? _lastPlayTime;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  AudioPlaybackState get playbackState => _currentState;
  
  @override
  Future<void> initialize({
    int channels = 1,
    int sampleRate = 16000,
    int bitDepth = 16,
  }) async {
    if (_isInitialized) {
      print('[$_tag] 服务已初始化，跳过');
      return;
    }
    
    try {
      print('[$_tag] 开始初始化Android原生音频服务');
      
      // 1. 初始化Opus库（如果尚未初始化）
      await _initializeOpus();
      
      // 2. 创建Opus解码器
      _opusDecoder = SimpleOpusDecoder(
        sampleRate: sampleRate,
        channels: channels,
      );
      print('[$_tag] Opus解码器创建成功');
      
      // 3. 创建原生播放器
      _nativePlayer = NativeAudioPlayer();
      await _nativePlayer!.initialize(
        nChannels: channels,
        sampleRate: sampleRate,
        pcmType: PCMType.pcm16,
      );
      print('[$_tag] 原生播放器初始化成功');
      
      _isInitialized = true;
      _currentState = AudioPlaybackState.initialized;
      
      print('[$_tag] Android原生音频服务初始化完成');
      
    } catch (e) {
      print('[$_tag] 初始化失败: $e');
      _currentState = AudioPlaybackState.error;
      _cleanup();
      rethrow;
    }
  }
  
  /// 初始化Opus库
  Future<void> _initializeOpus() async {
    try {
      // 检查是否已经初始化过
      try {
        getOpusVersion();
        print('[$_tag] Opus库已初始化');
        return;
      } catch (e) {
        // 未初始化，继续初始化流程
      }
      
      // 初始化Opus库
      initOpus(await opus_flutter.load());
      print('[$_tag] Opus库初始化成功: ${getOpusVersion()}');
      
    } catch (e) {
      print('[$_tag] Opus库初始化失败: $e');
      throw Exception('Opus库初始化失败: $e');
    }
  }
  
  @override
  Future<void> startPlayback() async {
    _ensureInitialized();
    
    try {
      if (_nativePlayer == null) {
        throw Exception('原生播放器未初始化');
      }
      
      await _nativePlayer!.play();
      _currentState = AudioPlaybackState.playing;
      _lastPlayTime = DateTime.now();
      
      print('[$_tag] 播放已启动');
      
    } catch (e) {
      print('[$_tag] 启动播放失败: $e');
      _currentState = AudioPlaybackState.error;
      rethrow;
    }
  }
  
  @override
  Future<void> playOpusAudio(Uint8List opusData) async {
    _ensureInitialized();
    
    try {
      if (_opusDecoder == null) {
        throw Exception('Opus解码器未初始化');
      }
      
      if (_nativePlayer == null) {
        throw Exception('原生播放器未初始化');
      }
      
      // 1. 解码Opus数据为PCM
      final Int16List pcmData = _opusDecoder!.decode(input: opusData);
      
      // 2. 转换为字节数组（小端字节序）
      final Uint8List pcmBytes = Uint8List(pcmData.length * 2);
      final ByteData bytes = ByteData.view(pcmBytes.buffer);
      
      for (int i = 0; i < pcmData.length; i++) {
        bytes.setInt16(i * 2, pcmData[i], Endian.little);
      }
      
      // 3. 确保播放器处于播放状态
      if (_currentState != AudioPlaybackState.playing) {
        await startPlayback();
      }
      
      // 4. 发送PCM数据到播放器
      await _nativePlayer!.feed(pcmBytes);
      
      // 5. 更新统计信息
      _framesPlayed++;
      _bytesProcessed += opusData.length;
      _lastPlayTime = DateTime.now();
      
    } catch (e) {
      print('[$_tag] 播放Opus音频失败: $e');
      _currentState = AudioPlaybackState.error;
      rethrow;
    }
  }
  
  @override
  Future<void> playPcmAudio(Uint8List pcmData) async {
    _ensureInitialized();
    
    try {
      if (_nativePlayer == null) {
        throw Exception('原生播放器未初始化');
      }
      
      // 确保播放器处于播放状态
      if (_currentState != AudioPlaybackState.playing) {
        await startPlayback();
      }
      
      // 直接发送PCM数据到播放器
      await _nativePlayer!.feed(pcmData);
      
      // 更新统计信息
      _framesPlayed++;
      _bytesProcessed += pcmData.length;
      _lastPlayTime = DateTime.now();
      
    } catch (e) {
      print('[$_tag] 播放PCM音频失败: $e');
      _currentState = AudioPlaybackState.error;
      rethrow;
    }
  }
  
  @override
  Future<void> pausePlayback() async {
    _ensureInitialized();
    
    try {
      if (_nativePlayer == null) {
        throw Exception('原生播放器未初始化');
      }
      
      await _nativePlayer!.pause();
      _currentState = AudioPlaybackState.paused;
      
      print('[$_tag] 播放已暂停');
      
    } catch (e) {
      print('[$_tag] 暂停播放失败: $e');
      _currentState = AudioPlaybackState.error;
      rethrow;
    }
  }
  
  @override
  Future<void> resumePlayback() async {
    _ensureInitialized();
    
    try {
      if (_nativePlayer == null) {
        throw Exception('原生播放器未初始化');
      }
      
      await _nativePlayer!.resume();
      _currentState = AudioPlaybackState.playing;
      
      print('[$_tag] 播放已恢复');
      
    } catch (e) {
      print('[$_tag] 恢复播放失败: $e');
      _currentState = AudioPlaybackState.error;
      rethrow;
    }
  }
  
  @override
  Future<void> stopPlayback() async {
    _ensureInitialized();
    
    try {
      if (_nativePlayer == null) {
        throw Exception('原生播放器未初始化');
      }
      
      await _nativePlayer!.stop();
      _currentState = AudioPlaybackState.stopped;
      
      print('[$_tag] 播放已停止');
      
    } catch (e) {
      print('[$_tag] 停止播放失败: $e');
      _currentState = AudioPlaybackState.error;
      rethrow;
    }
  }
  
  @override
  Future<void> setVolume(double volume) async {
    _ensureInitialized();
    
    try {
      if (_nativePlayer == null) {
        throw Exception('原生播放器未初始化');
      }
      
      await _nativePlayer!.setVolume(volume);
      
      print('[$_tag] 音量已设置: $volume');
      
    } catch (e) {
      print('[$_tag] 设置音量失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> dispose() async {
    print('[$_tag] 开始释放资源');
    
    await _cleanup();
    
    _isInitialized = false;
    _currentState = AudioPlaybackState.uninitialized;
    
    print('[$_tag] 资源释放完成');
  }
  
  /// 清理资源
  Future<void> _cleanup() async {
    try {
      // 停止播放
      if (_nativePlayer != null) {
        try {
          await _nativePlayer!.stop();
          await _nativePlayer!.release();
        } catch (e) {
          print('[$_tag] 清理播放器失败: $e');
        }
        _nativePlayer = null;
      }
      
      // 清理解码器
      _opusDecoder = null;
      
      // 重置统计信息
      _framesPlayed = 0;
      _bytesProcessed = 0;
      _lastPlayTime = null;
      
    } catch (e) {
      print('[$_tag] 资源清理失败: $e');
    }
  }
  
  @override
  Map<String, dynamic> getStatusInfo() {
    return {
      'platform': 'Android',
      'service': 'NativeAudioPlayer',
      'isInitialized': _isInitialized,
      'playbackState': _currentState.toString(),
      'nativePlayer': {
        'initialized': _nativePlayer?.isInited ?? false,
        'playing': _nativePlayer?.isPlaying ?? false,
        'paused': _nativePlayer?.isPaused ?? false,
        'stopped': _nativePlayer?.isStopped ?? false,
      },
      'opusDecoder': {
        'initialized': _opusDecoder != null,
        'sampleRate': _sampleRate,
        'channels': _channels,
        'frameDuration': _frameDuration,
      },
      'statistics': {
        'framesPlayed': _framesPlayed,
        'bytesProcessed': _bytesProcessed,
        'lastPlayTime': _lastPlayTime?.toIso8601String(),
        'uptimeSeconds': _lastPlayTime != null 
            ? DateTime.now().difference(_lastPlayTime!).inSeconds 
            : 0,
      },
      'capabilities': {
        'opusDecoding': true,
        'pcmPlayback': true,
        'realTimeStreaming': true,
        'volumeControl': true,
        'pauseResume': true,
      }
    };
  }
  
  /// 确保服务已初始化
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('Android原生音频服务未初始化，请先调用 initialize()');
    }
  }
  
  /// 获取播放统计信息
  Map<String, dynamic> get playbackStats {
    return {
      'framesPlayed': _framesPlayed,
      'bytesProcessed': _bytesProcessed,
      'lastPlayTime': _lastPlayTime?.toIso8601String(),
      'isActive': _currentState == AudioPlaybackState.playing,
    };
  }
}
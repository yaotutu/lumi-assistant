import 'dart:async';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
import 'package:opus_dart/opus_dart.dart';
import '../constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 音频播放服务
/// 负责TTS音频数据的接收、解码和播放
/// 支持Opus解码和实时音频播放
class AudioPlaybackService {
  static const String tag = 'AudioPlaybackService';

  // 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Opus解码器
  SimpleOpusDecoder? _opusDecoder;
  
  // 播放状态
  bool _isPlaying = false;
  bool _isInitialized = false;
  String _currentState = AudioConstants.stateIdle;
  
  // 音频数据缓冲区
  final List<Uint8List> _audioBuffer = [];
  final List<int> _pcmBuffer = [];
  
  // 播放控制
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  
  // 临时文件管理
  String? _currentTempFile;
  
  // 播放统计
  int _playedFrames = 0;
  int _decodedFrames = 0;
  DateTime? _playbackStartTime;
  
  // 回调函数
  void Function(String state)? onStateChanged;
  void Function(Map<String, dynamic> stats)? onStatsUpdated;
  void Function(String error)? onError;
  void Function(Duration position, Duration duration)? onPositionChanged;

  /// 初始化音频播放服务
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[$tag] 音频播放服务已初始化，跳过');
      return;
    }

    try {
      print('[$tag] 初始化音频播放服务');
      
      // 初始化Opus解码器
      await _initializeOpusDecoder();
      
      // 设置音频播放器
      await _setupAudioPlayer();
      
      _isInitialized = true;
      _currentState = AudioConstants.stateIdle;
      
      print('[$tag] 音频播放服务初始化完成');
    } catch (e) {
      print('[$tag] 音频播放服务初始化失败: $e');
      rethrow;
    }
  }

  /// 初始化Opus解码器
  Future<void> _initializeOpusDecoder() async {
    try {
      _opusDecoder = SimpleOpusDecoder(
        sampleRate: AudioConstants.sampleRate,
        channels: AudioConstants.channels,
      );
      
      print('[$tag] Opus解码器初始化成功');
    } catch (e) {
      print('[$tag] Opus解码器初始化失败: $e');
      throw AppException.system(
        message: 'Opus解码器初始化失败',
        code: AudioConstants.errorCodeOpusInit.toString(),
        component: 'AudioPlaybackService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 设置音频播放器
  Future<void> _setupAudioPlayer() async {
    try {
      // 监听播放状态变化
      _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
        print('[$tag] 播放器状态变化: $state');
        _updatePlaybackState(state);
      });

      // 监听播放位置变化
      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        final duration = _audioPlayer.duration ?? Duration.zero;
        onPositionChanged?.call(position, duration);
      });

      print('[$tag] 音频播放器设置完成');
    } catch (e) {
      print('[$tag] 音频播放器设置失败: $e');
      throw AppException.system(
        message: '音频播放器设置失败',
        code: AudioConstants.errorCodePlayerInit.toString(),
        component: 'AudioPlaybackService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 接收TTS音频数据
  Future<void> receiveTtsAudio(Uint8List opusData) async {
    try {
      if (!_isInitialized) {
        throw AppException.system(
          message: '音频播放服务未初始化',
          code: AudioConstants.errorCodeNotInitialized.toString(),
          component: 'AudioPlaybackService',
        );
      }

      print('[$tag] 接收到TTS音频数据: ${opusData.length} 字节');
      
      // 添加到缓冲区
      _audioBuffer.add(opusData);
      
      // 解码音频数据
      await _decodeOpusData(opusData);
      
      // 更新统计信息
      _updateStats();
      
    } catch (e) {
      print('[$tag] 接收TTS音频数据失败: $e');
      onError?.call('接收TTS音频数据失败: $e');
    }
  }

  /// 解码Opus音频数据
  Future<void> _decodeOpusData(Uint8List opusData) async {
    try {
      if (_opusDecoder == null) {
        throw AppException.system(
          message: 'Opus解码器未初始化',
          code: AudioConstants.errorCodeOpusInit.toString(),
          component: 'AudioPlaybackService',
        );
      }

      // 解码Opus数据为PCM
      final pcmData = _opusDecoder!.decode(input: opusData);
      
      // 添加到PCM缓冲区
      _pcmBuffer.addAll(pcmData);
      _decodedFrames++;
      
      print('[$tag] 解码Opus数据成功: ${pcmData.length} 样本');
      
    } catch (e) {
      print('[$tag] 解码Opus数据失败: $e');
      throw AppException.system(
        message: 'Opus解码失败',
        code: AudioConstants.errorCodeOpusDecode.toString(),
        component: 'AudioPlaybackService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 开始播放TTS音频
  Future<bool> startPlayback() async {
    try {
      if (!_isInitialized) {
        print('[$tag] 音频播放服务未初始化');
        return false;
      }

      if (_pcmBuffer.isEmpty) {
        print('[$tag] 没有音频数据可播放');
        return false;
      }

      print('[$tag] 开始播放TTS音频');
      
      // 将PCM数据写入临时文件
      final tempFile = await _createTempAudioFile();
      
      // 播放音频文件
      await _audioPlayer.setAudioSource(AudioSource.file(tempFile));
      await _audioPlayer.play();
      
      _isPlaying = true;
      _playbackStartTime = DateTime.now();
      _currentState = AudioConstants.stateRecording; // 使用recording表示播放中
      
      onStateChanged?.call(_currentState);
      
      print('[$tag] TTS音频播放开始成功');
      return true;
      
    } catch (e) {
      print('[$tag] 开始播放TTS音频失败: $e');
      _currentState = AudioConstants.stateError;
      onStateChanged?.call(_currentState);
      onError?.call('播放失败: $e');
      return false;
    }
  }

  /// 停止播放TTS音频
  Future<bool> stopPlayback() async {
    try {
      print('[$tag] 停止播放TTS音频');
      
      await _audioPlayer.stop();
      
      _isPlaying = false;
      _currentState = AudioConstants.stateIdle;
      
      // 清理临时文件
      await _cleanupTempFile();
      
      onStateChanged?.call(_currentState);
      
      print('[$tag] TTS音频播放停止成功');
      return true;
      
    } catch (e) {
      print('[$tag] 停止播放TTS音频失败: $e');
      onError?.call('停止播放失败: $e');
      return false;
    }
  }

  /// 暂停播放
  Future<bool> pausePlayback() async {
    try {
      await _audioPlayer.pause();
      _currentState = AudioConstants.stateProcessing; // 使用processing表示暂停
      onStateChanged?.call(_currentState);
      return true;
    } catch (e) {
      print('[$tag] 暂停播放失败: $e');
      return false;
    }
  }

  /// 恢复播放
  Future<bool> resumePlayback() async {
    try {
      await _audioPlayer.play();
      _currentState = AudioConstants.stateRecording; // 使用recording表示播放中
      onStateChanged?.call(_currentState);
      return true;
    } catch (e) {
      print('[$tag] 恢复播放失败: $e');
      return false;
    }
  }

  /// 创建临时音频文件
  Future<String> _createTempAudioFile() async {
    try {
      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final tempFile = '${tempDir.path}/tts_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      // 创建WAV文件
      await _createWavFile(tempFile, _pcmBuffer);
      
      _currentTempFile = tempFile;
      return tempFile;
      
    } catch (e) {
      print('[$tag] 创建临时音频文件失败: $e');
      rethrow;
    }
  }

  /// 创建WAV文件
  Future<void> _createWavFile(String filePath, List<int> pcmData) async {
    try {
      final file = File(filePath);
      final sink = file.openWrite();
      
      // 写入WAV头部
      final wavHeader = _createWavHeader(pcmData.length);
      sink.add(wavHeader);
      
      // 写入PCM数据
      final pcmBytes = _convertPcmToBytes(pcmData);
      sink.add(pcmBytes);
      
      await sink.close();
      
      print('[$tag] WAV文件创建成功: $filePath');
      
    } catch (e) {
      print('[$tag] 创建WAV文件失败: $e');
      rethrow;
    }
  }

  /// 创建WAV文件头部
  Uint8List _createWavHeader(int dataLength) {
    final header = ByteData(44);
    
    // RIFF标识
    header.setUint32(0, 0x52494646, Endian.little); // "RIFF"
    header.setUint32(4, 36 + dataLength * 2, Endian.little); // 文件大小
    header.setUint32(8, 0x57415645, Endian.little); // "WAVE"
    
    // fmt子块
    header.setUint32(12, 0x666d7420, Endian.little); // "fmt "
    header.setUint32(16, 16, Endian.little); // fmt子块大小
    header.setUint16(20, 1, Endian.little); // 音频格式(PCM)
    header.setUint16(22, AudioConstants.channels, Endian.little); // 声道数
    header.setUint32(24, AudioConstants.sampleRate, Endian.little); // 采样率
    header.setUint32(28, AudioConstants.sampleRate * AudioConstants.channels * 2, Endian.little); // 字节率
    header.setUint16(32, AudioConstants.channels * 2, Endian.little); // 块对齐
    header.setUint16(34, 16, Endian.little); // 位深度
    
    // data子块
    header.setUint32(36, 0x64617461, Endian.little); // "data"
    header.setUint32(40, dataLength * 2, Endian.little); // 数据大小
    
    return header.buffer.asUint8List();
  }

  /// 转换PCM数据为字节数组
  Uint8List _convertPcmToBytes(List<int> pcmData) {
    final bytes = ByteData(pcmData.length * 2);
    for (int i = 0; i < pcmData.length; i++) {
      bytes.setInt16(i * 2, pcmData[i], Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  /// 更新播放状态
  void _updatePlaybackState(PlayerState state) {
    switch (state.processingState) {
      case ProcessingState.idle:
        _isPlaying = false;
        _currentState = AudioConstants.stateIdle;
        break;
      case ProcessingState.loading:
        _isPlaying = false;
        _currentState = AudioConstants.stateProcessing;
        break;
      case ProcessingState.buffering:
        _isPlaying = false;
        _currentState = AudioConstants.stateProcessing;
        break;
      case ProcessingState.ready:
        _isPlaying = state.playing;
        _currentState = state.playing ? AudioConstants.stateRecording : AudioConstants.stateIdle;
        break;
      case ProcessingState.completed:
        _isPlaying = false;
        _currentState = AudioConstants.stateIdle;
        _cleanupTempFile();
        break;
    }
    
    onStateChanged?.call(_currentState);
  }

  /// 更新统计信息
  void _updateStats() {
    final stats = {
      'playing': _isPlaying,
      'decoded_frames': _decodedFrames,
      'played_frames': _playedFrames,
      'buffer_size': _audioBuffer.length,
      'pcm_buffer_size': _pcmBuffer.length,
      'state': _currentState,
      'playback_duration': _playbackStartTime != null
          ? DateTime.now().difference(_playbackStartTime!).inMilliseconds
          : 0,
    };
    
    onStatsUpdated?.call(stats);
  }

  /// 清理临时文件
  Future<void> _cleanupTempFile() async {
    if (_currentTempFile != null) {
      try {
        final file = File(_currentTempFile!);
        if (await file.exists()) {
          await file.delete();
          print('[$tag] 临时文件已删除: $_currentTempFile');
        }
        _currentTempFile = null;
      } catch (e) {
        print('[$tag] 删除临时文件失败: $e');
      }
    }
  }

  /// 清空缓冲区
  void clearBuffer() {
    _audioBuffer.clear();
    _pcmBuffer.clear();
    _decodedFrames = 0;
    _playedFrames = 0;
    print('[$tag] 音频缓冲区已清空');
  }

  /// 获取播放统计信息
  Map<String, dynamic> get playbackStats {
    return {
      'is_playing': _isPlaying,
      'is_initialized': _isInitialized,
      'current_state': _currentState,
      'decoded_frames': _decodedFrames,
      'played_frames': _playedFrames,
      'buffer_size': _audioBuffer.length,
      'pcm_buffer_size': _pcmBuffer.length,
      'playback_duration': _playbackStartTime != null
          ? DateTime.now().difference(_playbackStartTime!).inMilliseconds
          : 0,
    };
  }

  /// 获取当前播放状态
  String get currentState => _currentState;
  
  /// 是否正在播放
  bool get isPlaying => _isPlaying;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 销毁服务
  Future<void> dispose() async {
    print('[$tag] 销毁音频播放服务');
    
    // 停止播放
    await stopPlayback();
    
    // 取消订阅
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    
    // 释放播放器
    await _audioPlayer.dispose();
    
    // 清理缓冲区
    clearBuffer();
    
    // 释放解码器
    _opusDecoder = null;
    
    _isInitialized = false;
    
    print('[$tag] 音频播放服务已销毁');
  }
}
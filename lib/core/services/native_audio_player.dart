import 'dart:async';
import 'package:flutter/services.dart';

/// PCM格式类型
enum PCMType {
  /// PCM格式: 8位整数
  pcm8,
  /// PCM格式: 16位整数 
  pcm16,
  /// PCM格式: 32位浮点数
  pcm32,
}

/// 播放状态
enum PlayState {
  /// 停止播放
  stopped,
  /// 正在播放
  playing,
  /// 暂停播放
  paused,
}

/// 原生音频播放器 - 替代flutter_pcm_player
/// 
/// 基于自实现的原生AudioTrack，提供与flutter_pcm_player相同的API接口
/// 优势：
/// 1. 完全控制实现，可以针对性优化
/// 2. 减少第三方依赖，提高稳定性
/// 3. 更好的错误处理和调试能力
class NativeAudioPlayer {
  static const MethodChannel _channel = MethodChannel('lumi_assistant/native_audio');

  bool _isInited = false;
  PlayState _playState = PlayState.stopped;

  /// 播放器是否已初始化
  bool get isInited => _isInited;

  /// 当前播放状态
  PlayState get playState => _playState;

  /// 是否正在播放
  bool get isPlaying => _playState == PlayState.playing;

  /// 是否已暂停
  bool get isPaused => _playState == PlayState.paused;

  /// 是否已停止
  bool get isStopped => _playState == PlayState.stopped;

  /// 初始化播放器
  /// 
  /// [nChannels] 声道数，1=单声道，2=立体声
  /// [sampleRate] 采样率，通常为16000
  /// [pcmType] PCM格式，通常为PCM16
  Future<void> initialize({
    int nChannels = 1,
    int sampleRate = 16000,
    PCMType pcmType = PCMType.pcm16,
  }) async {
    try {
      // 先释放旧的实例
      await release();

      await _channel.invokeMethod("initialize", {
        'nChannels': nChannels,
        'sampleRate': sampleRate,
        'pcmType': pcmType.index,
      });
      
      _playState = PlayState.stopped;
      _isInited = true;
      
      print('[NativeAudioPlayer] 初始化成功: channels=$nChannels, sampleRate=$sampleRate, pcmType=$pcmType');
    } catch (e) {
      print('[NativeAudioPlayer] 初始化失败: $e');
      _isInited = false;
      rethrow;
    }
  }

  /// 释放播放器资源
  Future<void> release() async {
    if (!_isInited) return;

    try {
      await stop();
      await _channel.invokeMethod("release");
      
      _playState = PlayState.stopped;
      _isInited = false;
      
      print('[NativeAudioPlayer] 资源已释放');
    } catch (e) {
      print('[NativeAudioPlayer] 释放资源失败: $e');
      // 即使失败也要重置状态
      _playState = PlayState.stopped;
      _isInited = false;
    }
  }

  /// 开始播放
  /// 
  /// 抛出异常如果播放器未初始化或启动失败
  Future<void> play() async {
    _ensureInited();

    try {
      final state = await _channel.invokeMethod("play");
      _playState = PlayState.values[state];
      
      if (_playState != PlayState.playing) {
        throw Exception('播放器启动失败，当前状态: $_playState');
      }
      
      print('[NativeAudioPlayer] 播放已启动');
    } catch (e) {
      print('[NativeAudioPlayer] 启动播放失败: $e');
      rethrow;
    }
  }

  /// 停止播放
  /// 
  /// 停止播放会清空缓冲的音频数据
  Future<void> stop() async {
    _ensureInited();

    try {
      final state = await _channel.invokeMethod("stop");
      _playState = PlayState.values[state];
      
      if (_playState == PlayState.playing) {
        throw Exception('播放器停止失败，当前状态: $_playState');
      }
      
      print('[NativeAudioPlayer] 播放已停止');
    } catch (e) {
      print('[NativeAudioPlayer] 停止播放失败: $e');
      rethrow;
    }
  }

  /// 暂停播放
  /// 
  /// 暂停播放不会清空缓冲的音频数据
  Future<void> pause() async {
    _ensureInited();

    try {
      final state = await _channel.invokeMethod("pause");
      _playState = PlayState.values[state];
      
      if (_playState != PlayState.paused) {
        throw Exception('播放器暂停失败，当前状态: $_playState');
      }
      
      print('[NativeAudioPlayer] 播放已暂停');
    } catch (e) {
      print('[NativeAudioPlayer] 暂停播放失败: $e');
      rethrow;
    }
  }

  /// 恢复播放
  /// 
  /// 从暂停状态恢复播放
  Future<void> resume() async {
    _ensureInited();

    try {
      final state = await _channel.invokeMethod("resume");
      _playState = PlayState.values[state];
      
      if (_playState != PlayState.playing) {
        throw Exception('播放器恢复失败，当前状态: $_playState');
      }
      
      print('[NativeAudioPlayer] 播放已恢复');
    } catch (e) {
      print('[NativeAudioPlayer] 恢复播放失败: $e');
      rethrow;
    }
  }

  /// 喂入PCM音频数据
  /// 
  /// [data] 原始PCM音频字节数组，格式必须与初始化时指定的pcmType一致
  /// 数据大小不应过小以避免音频断断续续
  Future<void> feed(Uint8List data) async {
    _ensureInited();

    try {
      final state = await _channel.invokeMethod("feed", {
        'data': data,
      });
      _playState = PlayState.values[state];
      
      // 不打印详细日志避免日志过多，只在出错时打印
    } catch (e) {
      print('[NativeAudioPlayer] 喂入音频数据失败: $e');
      rethrow;
    }
  }

  /// 设置音量
  /// 
  /// [volume] 音量值，范围 [0.0, 1.0]
  Future<void> setVolume(double volume) async {
    _ensureInited();

    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      final state = await _channel.invokeMethod("setVolume", {
        'volume': clampedVolume,
      });
      _playState = PlayState.values[state];
      
      print('[NativeAudioPlayer] 音量已设置: $clampedVolume');
    } catch (e) {
      print('[NativeAudioPlayer] 设置音量失败: $e');
      rethrow;
    }
  }

  /// 确保播放器已初始化
  void _ensureInited() {
    if (!_isInited) {
      throw Exception('播放器未初始化，请先调用 initialize()');
    }
  }

  /// 获取播放器状态信息（调试用）
  Map<String, dynamic> getStatusInfo() {
    return {
      'isInited': _isInited,
      'playState': _playState.toString(),
      'isPlaying': isPlaying,
      'isPaused': isPaused,
      'isStopped': isStopped,
    };
  }
}
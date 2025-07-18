import 'dart:typed_data';
import 'package:opus_dart/opus_dart.dart';
import 'package:flutter_pcm_player/flutter_pcm_player.dart';

/// 音频服务 - 完全按照Android客户端实现方式
/// 
/// 参考Android客户端AudioUtil类的实现：
/// - 单例播放器，只初始化一次
/// - 使用feed()方法持续喂数据
/// - Opus解码配置完全一致
class AudioServiceAndroidStyle {
  static const int sampleRate = 16000;     // 采样率16kHz - 与Android客户端一致
  static const int channels = 1;            // 单声道 - 与Android客户端一致  
  static const int frameDuration = 60;     // 帧时长60ms - 与Android客户端一致

  /// Opus解码器 - 用于播放（与Android客户端配置一致）
  static final _decoder = SimpleOpusDecoder(
    sampleRate: sampleRate,
    channels: channels,
  );

  /// PCM播放器实例 - 单例模式
  static FlutterPcmPlayer? _pcmPlayer;
  static bool _isPlayerInitialized = false;
  static bool _isInitializing = false;

  /// 初始化播放器 - 完全按照Android客户端方式
  static Future<void> initPlayer() async {
    if (_isPlayerInitialized || _isInitializing) {
      return;
    }

    try {
      _isInitializing = true;
      
      // 创建播放器实例
      _pcmPlayer = FlutterPcmPlayer();
      
      // 初始化播放器
      await _pcmPlayer!.initialize();
      
      // 开始播放（准备接收数据）
      await _pcmPlayer!.play();
      
      _isPlayerInitialized = true;
      
    } catch (e) {
      print('[AudioServiceAndroidStyle] PCM播放器初始化失败: $e');
      _pcmPlayer = null;
      _isPlayerInitialized = false;
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  /// 播放Opus音频数据 - 完全按照Android客户端AudioUtil.playOpusData实现
  Future<void> playOpusAudio(Uint8List opusData) async {
    try {
      // 1. 检查播放器状态 - 与Android客户端逻辑一致
      if (!_isPlayerInitialized || _pcmPlayer == null) {
        await initPlayer();
      }

      // 2. 解码Opus数据为PCM - 与Android客户端完全一致
      final Int16List pcmData = _decoder.decode(input: opusData);

      // 3. 转换为字节数组（小端字节序）- 与Android客户端完全一致
      final Uint8List pcmBytes = Uint8List(pcmData.length * 2);
      final ByteData bytes = ByteData.view(pcmBytes.buffer);
      
      for (int i = 0; i < pcmData.length; i++) {
        bytes.setInt16(i * 2, pcmData[i], Endian.little);
      }

      // 4. 发送到播放器 - 使用feed方法，与Android客户端一致
      if (_pcmPlayer != null) {
        await _pcmPlayer!.feed(pcmBytes);
      }
      
    } catch (e) {
      print('[AudioServiceAndroidStyle] 播放Opus音频失败: $e');
      print('[AudioServiceAndroidStyle] 错误类型: ${e.runtimeType}');
      
      // 错误恢复 - 尝试重新初始化播放器
      try {
        print('[AudioServiceAndroidStyle] 尝试重新初始化播放器');
        _isPlayerInitialized = false;
        _pcmPlayer = null;
        await initPlayer();
        
        // 重试播放
        if (_pcmPlayer != null) {
          print('[AudioServiceAndroidStyle] 重试播放Opus音频');
          final Int16List pcmData = _decoder.decode(input: opusData);
          final Uint8List pcmBytes = Uint8List(pcmData.length * 2);
          final ByteData bytes = ByteData.view(pcmBytes.buffer);
          
          for (int i = 0; i < pcmData.length; i++) {
            bytes.setInt16(i * 2, pcmData[i], Endian.little);
          }
          
          await _pcmPlayer!.feed(pcmBytes);
          print('[AudioServiceAndroidStyle] 重试播放成功');
        }
      } catch (retryError) {
        print('[AudioServiceAndroidStyle] 重试播放失败: $retryError');
        rethrow;
      }
    }
  }

  /// 停止播放 - 与Android客户端方式一致
  Future<void> stop() async {
    try {
      if (_pcmPlayer != null) {
        print('[AudioServiceAndroidStyle] 停止PCM播放器');
        await _pcmPlayer!.stop();
      }
    } catch (e) {
      print('[AudioServiceAndroidStyle] 停止播放失败: $e');
    }
  }

  /// 释放资源 - 与Android客户端方式一致
  Future<void> dispose() async {
    try {
      if (_pcmPlayer != null) {
        print('[AudioServiceAndroidStyle] 释放PCM播放器资源');
        await _pcmPlayer!.stop();
        _pcmPlayer = null;
        _isPlayerInitialized = false;
      }
    } catch (e) {
      print('[AudioServiceAndroidStyle] 释放资源失败: $e');
    }
  }

  /// 获取播放器状态
  bool get isInitialized => _isPlayerInitialized;
  
  /// 获取播放器实例（用于调试）
  FlutterPcmPlayer? get player => _pcmPlayer;
}
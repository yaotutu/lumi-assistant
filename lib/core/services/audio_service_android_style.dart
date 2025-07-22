import 'dart:typed_data';
import 'package:opus_dart/opus_dart.dart';
import 'native_audio_player.dart';
import '../utils/loggers.dart';

/// 音频服务 - Android原生实现 (简化版本)
/// 
/// 📱 专为Android平台优化的Opus音频播放服务
/// 🚀 使用原生AudioTrack，性能卓越，延迟极低
/// ✅ 完全替代第三方audio库，减少依赖风险
/// 
/// 核心特性：
/// - 原生AudioTrack播放，无中间层损耗
/// - Opus实时解码，支持音频流
/// - 单例模式，资源利用最优
/// - 简洁API，专注核心功能
class AudioServiceAndroidStyle {
  static const int sampleRate = 16000;     // 采样率16kHz - 与Android客户端一致
  static const int channels = 1;            // 单声道 - 与Android客户端一致  
  static const int frameDuration = 60;     // 帧时长60ms - 与Android客户端一致

  /// Opus解码器 - 用于播放（与Android客户端配置一致）
  static final _decoder = SimpleOpusDecoder(
    sampleRate: sampleRate,
    channels: channels,
  );

  /// 原生PCM播放器实例 - 单例模式
  static NativeAudioPlayer? _pcmPlayer;
  static bool _isPlayerInitialized = false;
  static bool _isInitializing = false;

  /// 初始化播放器 - 完全按照Android客户端方式
  static Future<void> initPlayer() async {
    if (_isPlayerInitialized || _isInitializing) {
      return;
    }

    try {
      _isInitializing = true;
      
      // 创建原生播放器实例
      _pcmPlayer = NativeAudioPlayer();
      
      // 初始化播放器 - 使用与Android客户端一致的参数
      await _pcmPlayer!.initialize(
        nChannels: channels,
        sampleRate: sampleRate,
        pcmType: PCMType.pcm16,
      );
      
      // 开始播放（准备接收数据）
      await _pcmPlayer!.play();
      
      _isPlayerInitialized = true;
      
    } catch (e) {
      Loggers.audio.severe('PCM播放器初始化失败', e);
      _pcmPlayer = null;
      _isPlayerInitialized = false;
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  /// 播放Opus音频数据 - 核心功能，简洁高效
  Future<void> playOpusAudio(Uint8List opusData) async {
    try {
      // 1. 确保播放器已初始化
      if (!_isPlayerInitialized || _pcmPlayer == null) {
        await initPlayer();
      }

      // 2. Opus解码为PCM16
      final Int16List pcmData = _decoder.decode(input: opusData);

      // 3. 转换为字节数组（小端字节序）
      final Uint8List pcmBytes = Uint8List(pcmData.length * 2);
      final ByteData bytes = ByteData.view(pcmBytes.buffer);
      
      for (int i = 0; i < pcmData.length; i++) {
        bytes.setInt16(i * 2, pcmData[i], Endian.little);
      }

      // 4. 发送到原生播放器
      await _pcmPlayer!.feed(pcmBytes);
      
    } catch (e) {
      Loggers.audio.severe('播放失败', e);
      rethrow;
    }
  }

  /// 停止播放 - 与Android客户端方式一致
  Future<void> stop() async {
    try {
      if (_pcmPlayer != null) {
        Loggers.audio.info('停止PCM播放器');
        await _pcmPlayer!.stop();
      }
    } catch (e) {
      Loggers.audio.severe('停止播放失败', e);
    }
  }

  /// 释放资源 - 与Android客户端方式一致
  Future<void> dispose() async {
    try {
      if (_pcmPlayer != null) {
        Loggers.audio.info('释放PCM播放器资源');
        await _pcmPlayer!.stop();
        _pcmPlayer = null;
        _isPlayerInitialized = false;
      }
    } catch (e) {
      Loggers.audio.severe('释放资源失败', e);
    }
  }

  /// 获取播放器状态
  bool get isInitialized => _isPlayerInitialized;
  
  /// 获取播放器实例（用于调试）
  NativeAudioPlayer? get player => _pcmPlayer;
}
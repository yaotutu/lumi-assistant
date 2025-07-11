import 'dart:typed_data';
import 'package:opus_dart/opus_dart.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_pcm_player/flutter_pcm_player.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import '../constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
import 'permission_service.dart';

/// 音频播放服务
/// 
/// 负责处理从服务器接收的音频数据（Opus格式）并播放
/// 参考xiaozhi-android-client项目的音频处理实现
class AudioService {
  static const String tag = 'AudioService';
  
  // 权限服务
  final PermissionService _permissionService = PermissionService();
  
  // 音频状态
  String _currentState = AudioConstants.stateIdle;
  
  // FlutterPcmPlayer实例 - 参考xiaozhi-android-client
  FlutterPcmPlayer? _pcmPlayer;
  bool _isPlayerInitialized = false;
  
  // Opus解码器 - 使用静态初始化，参考xiaozhi-android-client
  static final SimpleOpusDecoder _decoder = SimpleOpusDecoder(
    sampleRate: AudioConstants.sampleRate,
    channels: AudioConstants.channels,
  );
  
  // 音频会话
  AudioSession? _audioSession;
  
  // 是否已初始化
  bool _isInitialized = false;

  /// 初始化音频服务
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[$tag] 音频服务已初始化，跳过');
      return;
    }

    try {
      print('[$tag] 开始初始化音频服务');
      _currentState = AudioConstants.stateProcessing;
      
      // 1. 检查麦克风权限
      await _checkAudioPermissions();
      
      // 2. 初始化音频会话
      await _initializeAudioSession();
      
      // 3. 初始化PCM播放器
      await _initializePCMPlayer();
      
      // 4. Opus解码器已静态初始化
      print('[$tag] Opus解码器使用静态初始化');
      
      _isInitialized = true;
      _currentState = AudioConstants.stateIdle;
      print('[$tag] 音频服务初始化完成');
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      print('[$tag] 音频服务初始化失败: $e');
      throw AppException.system(
        message: '音频服务初始化失败',
        code: AudioConstants.errorCodeAudioSessionFailed.toString(),
        component: 'AudioService',
        details: {'error': e.toString()},
      );
    }
  }
  
  /// 检查音频权限
  Future<void> _checkAudioPermissions() async {
    try {
      final permissions = await _permissionService.checkAudioPermissions();
      
      if (!permissions['microphone']!) {
        throw AppException.system(
          message: '麦克风权限未授予',
          code: AudioConstants.errorCodePermissionDenied.toString(),
          component: 'AudioService',
          details: {'permission': 'microphone'},
        );
      }
      
      print('[$tag] 音频权限检查完成');
    } catch (e) {
      print('[$tag] 音频权限检查失败: $e');
      rethrow;
    }
  }

  /// 初始化音频会话
  Future<void> _initializeAudioSession() async {
    try {
      _audioSession = await AudioSession.instance;
      
      // 配置音频会话为播放模式
      await _audioSession!.configure(const AudioSessionConfiguration(
        // iOS配置 - 语音通话模式
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        
        // Android配置 - 语音通话模式
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        
        // 通用配置
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ));
      
      print('[$tag] 音频会话配置完成');
    } catch (e) {
      print('[$tag] 音频会话配置失败: $e');
      throw Exception('音频会话配置失败: $e');
    }
  }

  /// 初始化音频播放器 - 参考xiaozhi-android-client
  Future<void> _initializePCMPlayer() async {
    try {
      // 停止任何现有的播放器
      await _stopPCMPlayer();
      
      print('[$tag] 使用简单方式初始化PCM播放器');
      
      // 创建新的播放器实例 - 完全按照官方示例的简单方式
      _pcmPlayer = FlutterPcmPlayer();
      await _pcmPlayer!.initialize();
      await _pcmPlayer!.play();
      
      _isPlayerInitialized = true;
      print('[$tag] PCM播放器初始化成功');
    } catch (e) {
      print('[$tag] PCM播放器初始化失败: $e');
      _isPlayerInitialized = false;
      throw Exception('PCM播放器初始化失败: $e');
    }
  }


  /// 播放Opus音频数据
  /// 
  /// [opusData] - Opus编码的音频数据（原始Opus帧）
  /// 参考xiaozhi-android-client的实现
  Future<void> playOpusAudio(Uint8List opusData) async {
    if (!_isInitialized) {
      print('[$tag] 音频服务未初始化，先进行初始化');
      await initialize();
    }

    try {
      print('[$tag] 开始播放Opus音频，数据大小: ${opusData.length} bytes');
      
      // 1. 检查Opus数据是否有效
      if (opusData.isEmpty) {
        print('[$tag] 音频数据为空，跳过播放');
        return;
      }
      
      // 2. Opus解码为PCM数据
      final pcmData = _decodeOpusToPcm(opusData);
      if (pcmData.isEmpty) {
        print('[$tag] Opus解码失败，跳过播放');
        return;
      }
      
      // 3. 直接播放PCM数据
      await _playPCMData(pcmData);
      
    } catch (e) {
      print('[$tag] 播放音频失败: $e');
      // 播放失败时尝试重新初始化播放器
      try {
        print('[$tag] 尝试重新初始化播放器');
        await _initializePCMPlayer();
      } catch (reinitError) {
        print('[$tag] 重新初始化播放器失败: $reinitError');
      }
    }
  }

  /// Opus解码为PCM数据
  /// 完全参考xiaozhi-android-client的实现
  Uint8List _decodeOpusToPcm(Uint8List opusData) {
    try {
      // 解码Opus数据为Int16数组
      final Int16List pcmInt16 = _decoder.decode(input: opusData);
      print('[$tag] Opus解码完成，PCM样本数: ${pcmInt16.length}');
      
      // 准备PCM数据（按照xiaozhi-android-client的方式）
      final Uint8List pcmBytes = Uint8List(pcmInt16.length * 2);
      final ByteData bytes = ByteData.view(pcmBytes.buffer);
      
      // 使用小端字节序
      for (int i = 0; i < pcmInt16.length; i++) {
        bytes.setInt16(i * 2, pcmInt16[i], Endian.little);
      }
      
      return pcmBytes;
    } catch (e) {
      print('[$tag] Opus解码失败: $e');
      return Uint8List(0);
    }
  }

  /// 播放PCM数据 - 完全参考xiaozhi-android-client
  Future<void> _playPCMData(Uint8List pcmData) async {
    try {
      // 如果播放器未初始化，先初始化
      if (!_isPlayerInitialized || _pcmPlayer == null) {
        await _initializePCMPlayer();
      }
      
      print('[$tag] 开始播放PCM数据，大小: ${pcmData.length} bytes');
      
      // 直接发送到播放器
      if (_pcmPlayer != null) {
        await _pcmPlayer!.feed(pcmData);
      }
      
      print('[$tag] PCM数据播放完成');
    } catch (e) {
      print('[$tag] 播放失败: $e');
      
      // 简单重置并重新初始化
      await _stopPCMPlayer();
      await _initializePCMPlayer();
    }
  }

  /// 停止播放 - 参考xiaozhi-android-client
  Future<void> _stopPCMPlayer() async {
    if (_pcmPlayer != null) {
      try {
        await _pcmPlayer!.stop();
        print('[$tag] 播放器已停止');
      } catch (e) {
        print('[$tag] 停止播放失败: $e');
      }
      _pcmPlayer = null;
      _isPlayerInitialized = false;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _stopPCMPlayer();
      print('[$tag] 音频播放停止');
    } catch (e) {
      print('[$tag] 停止音频播放失败: $e');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    try {
      // 停止并释放PCM播放器
      await _stopPCMPlayer();
      
      // 停止并释放播放器
      await _stopPCMPlayer();
      
      // Opus解码器是静态的，不需要手动释放
      
      // 释放其他资源
      _audioSession = null;
      _isInitialized = false;
      _currentState = AudioConstants.stateIdle;
      
      print('[$tag] 音频服务资源释放完成');
    } catch (e) {
      print('[$tag] 音频服务资源释放失败: $e');
    }
  }
  
  /// 获取当前音频状态
  String get currentState => _currentState;
  
  /// 获取是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 请求音频权限
  Future<bool> requestAudioPermissions() async {
    try {
      final permissions = await _permissionService.requestAudioPermissions();
      return permissions['microphone'] ?? false;
    } catch (e) {
      print('[$tag] 请求音频权限失败: $e');
      return false;
    }
  }

  /// 处理PCM数据流
  void _processPCMData(Uint8List pcmData) async {
    try {
      // 直接播放PCM数据
      await _playPCMData(pcmData);
    } catch (e) {
      print('[$tag] 处理PCM数据失败: $e');
    }
  }


  /// 辅助方法：int32转字节数组（小端）
  List<int> _int32ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }

  /// 辅助方法：int16转字节数组（小端）
  List<int> _int16ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
    ];
  }
}

/// 音频服务Provider
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  
  // 在Provider被销毁时清理资源
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
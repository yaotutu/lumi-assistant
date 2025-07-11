import 'dart:typed_data';
import 'package:opus_dart/opus_dart.dart';
import 'package:flutter_pcm_player/flutter_pcm_player.dart';
import 'package:audio_session/audio_session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import '../constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
import 'permission_service.dart';

/// 音频播放服务V3
/// 
/// 完全按照Android客户端的简化实现
/// 使用flutter_pcm_player直接播放PCM数据，不创建WAV文件
class AudioServiceV3 {
  static const String tag = 'AudioServiceV3';
  
  // 权限服务
  final PermissionService _permissionService = PermissionService();
  
  // 音频状态
  String _currentState = AudioConstants.stateIdle;
  
  // FlutterPcmPlayer实例 - 按照Android客户端方式
  FlutterPcmPlayer? _pcmPlayer;
  bool _isPlayerInitialized = false;
  
  // Opus解码器 - 使用静态初始化
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
      print('[$tag] 开始初始化音频服务V3（按照Android客户端方式）');
      _currentState = AudioConstants.stateProcessing;
      
      // 1. 检查麦克风权限
      await _checkAudioPermissions();
      
      // 2. 初始化音频会话（参考Android客户端）
      await _initializeAudioSession();
      
      // 3. 初始化PCM播放器
      await _initializePCMPlayer();
      
      // 4. Opus解码器已静态初始化
      print('[$tag] Opus解码器使用静态初始化');
      
      _isInitialized = true;
      _currentState = AudioConstants.stateIdle;
      print('[$tag] 音频服务V3初始化完成');
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      print('[$tag] 音频服务V3初始化失败: $e');
      throw AppException.system(
        message: '音频服务初始化失败',
        code: AudioConstants.errorCodeAudioSessionFailed.toString(),
        component: 'AudioServiceV3',
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
          component: 'AudioServiceV3',
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
  /// 完全参考Android客户端的配置
  Future<void> _initializeAudioSession() async {
    try {
      _audioSession = await AudioSession.instance;
      
      // 配置音频会话（参考Android客户端）
      await _audioSession!.configure(const AudioSessionConfiguration(
        // iOS配置 - 语音通话模式
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        
        // Android配置 - 语音通话模式
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
          flags: AndroidAudioFlags.audibilityEnforced,
        ),
        
        // 通用配置
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientExclusive,
        androidWillPauseWhenDucked: false,
      ));
      
      print('[$tag] 音频会话配置完成（参考Android客户端）');
    } catch (e) {
      print('[$tag] 音频会话配置失败: $e');
      throw Exception('音频会话配置失败: $e');
    }
  }

  /// 初始化PCM播放器 - 完全按照Android客户端方式
  Future<void> _initializePCMPlayer() async {
    try {
      // 停止任何现有的播放器
      await _stopPCMPlayer();
      
      print('[$tag] 使用Android客户端方式初始化PCM播放器');
      
      // 创建新的播放器实例
      _pcmPlayer = FlutterPcmPlayer();
      
      // 按照Android客户端的方式：初始化后立即开始播放循环
      await _pcmPlayer!.initialize();
      await _pcmPlayer!.play();  // 开始播放循环
      
      _isPlayerInitialized = true;
      print('[$tag] PCM播放器初始化成功，播放循环已启动');
    } catch (e) {
      print('[$tag] PCM播放器初始化失败: $e');
      _isPlayerInitialized = false;
      throw Exception('PCM播放器初始化失败: $e');
    }
  }

  /// 播放Opus音频数据
  /// 完全按照Android客户端的实现
  Future<void> playOpusAudio(Uint8List opusData) async {
    print('[$tag] ===== 开始播放Opus音频（Android客户端方式）=====');
    print('[$tag] 音频数据大小: ${opusData.length} bytes');
    
    if (!_isInitialized) {
      print('[$tag] 音频服务未初始化，先进行初始化');
      await initialize();
    }

    try {
      // 1. 检查Opus数据是否有效
      if (opusData.isEmpty) {
        print('[$tag] 音频数据为空，跳过播放');
        return;
      }
      
      // 2. Opus解码为PCM数据
      print('[$tag] 开始Opus解码');
      final pcmData = _decodeOpusToPcm(opusData);
      if (pcmData.isEmpty) {
        print('[$tag] Opus解码失败，跳过播放');
        return;
      }
      print('[$tag] Opus解码成功，PCM数据大小: ${pcmData.length} bytes');
      
      // 3. 直接播放PCM数据（按照Android客户端方式）
      print('[$tag] 开始播放PCM数据');
      await _playPCMData(pcmData);
      
      print('[$tag] ===== 播放Opus音频结束 =====');
      
    } catch (e) {
      print('[$tag] 播放音频失败: $e');
      print('[$tag] 错误类型: ${e.runtimeType}');
      
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
  /// 完全按照Android客户端的实现
  Uint8List _decodeOpusToPcm(Uint8List opusData) {
    try {
      print('[$tag] 开始Opus解码，输入数据大小: ${opusData.length} bytes');
      
      // 检查Opus数据是否有效（最小长度检查）
      if (opusData.length < 2) {
        print('[$tag] Opus数据太短，无法解码');
        return Uint8List(0);
      }
      
      // 解码Opus数据为Int16数组
      final Int16List pcmInt16 = _decoder.decode(input: opusData);
      print('[$tag] Opus解码完成，PCM样本数: ${pcmInt16.length}');
      
      if (pcmInt16.isEmpty) {
        print('[$tag] Opus解码结果为空');
        return Uint8List(0);
      }
      
      // 调试：检查PCM数据的统计信息
      int nonZeroCount = 0;
      int maxValue = 0;
      for (int i = 0; i < pcmInt16.length; i++) {
        if (pcmInt16[i] != 0) nonZeroCount++;
        maxValue = pcmInt16[i].abs() > maxValue ? pcmInt16[i].abs() : maxValue;
      }
      print('[$tag] PCM数据统计: 非零样本数=$nonZeroCount, 最大值=$maxValue');
      
      // 完全按照Android客户端的方式转换PCM数据
      final Uint8List pcmBytes = Uint8List(pcmInt16.length * 2);
      final ByteData bytes = ByteData.view(pcmBytes.buffer);
      
      // 使用小端字节序转换Int16到字节（严格按照Android客户端）
      for (int i = 0; i < pcmInt16.length; i++) {
        bytes.setInt16(i * 2, pcmInt16[i], Endian.little);
      }
      
      print('[$tag] PCM数据准备完成，输出大小: ${pcmBytes.length} bytes');
      print('[$tag] 使用Android客户端方式进行PCM数据转换');
      
      return pcmBytes;
    } catch (e) {
      print('[$tag] Opus解码失败: $e');
      print('[$tag] 错误类型: ${e.runtimeType}');
      return Uint8List(0);
    }
  }

  /// 播放PCM数据 - 完全按照Android客户端方式
  Future<void> _playPCMData(Uint8List pcmData) async {
    try {
      print('[$tag] 开始播放PCM数据，大小: ${pcmData.length} bytes');
      
      // 如果播放器未初始化，先初始化
      if (!_isPlayerInitialized || _pcmPlayer == null) {
        print('[$tag] 播放器未初始化，开始初始化');
        await _initializePCMPlayer();
      }
      
      // 直接发送音频数据到播放器（按照Android客户端方式）
      if (_pcmPlayer != null) {
        await _pcmPlayer!.feed(pcmData);
        print('[$tag] PCM数据已发送到播放器');
      }
      
    } catch (e) {
      print('[$tag] 播放失败: $e');
      print('[$tag] 错误类型: ${e.runtimeType}');
      
      // 简单重置并重新初始化（按照Android客户端方式）
      try {
        print('[$tag] 尝试重置播放器');
        await _stopPCMPlayer();
        await _initializePCMPlayer();
        
        // 重新尝试播放
        if (_pcmPlayer != null) {
          await _pcmPlayer!.feed(pcmData);
          print('[$tag] 重试播放成功');
        }
      } catch (retryError) {
        print('[$tag] 重试播放失败: $retryError');
      }
    }
  }

  /// 停止播放 - 按照Android客户端方式
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
      
      // 释放其他资源
      _audioSession = null;
      _isInitialized = false;
      _currentState = AudioConstants.stateIdle;
      
      print('[$tag] 音频服务V3资源释放完成');
    } catch (e) {
      print('[$tag] 音频服务V3资源释放失败: $e');
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
}

/// 音频服务V3 Provider
final audioServiceV3Provider = Provider<AudioServiceV3>((ref) {
  final service = AudioServiceV3();
  
  // 在Provider被销毁时清理资源
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
import 'dart:typed_data';
import 'dart:io';
import 'package:opus_dart/opus_dart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
import 'permission_service.dart';

/// 改进的音频播放服务
/// 
/// 使用just_audio代替flutter_pcm_player来解决AudioTrack初始化问题
class AudioServiceV2 {
  static const String tag = 'AudioServiceV2';
  
  // 权限服务
  final PermissionService _permissionService = PermissionService();
  
  // 音频状态
  String _currentState = AudioConstants.stateIdle;
  
  // JustAudio播放器实例
  AudioPlayer? _audioPlayer;
  
  // Opus解码器 - 使用静态初始化
  static final SimpleOpusDecoder _decoder = SimpleOpusDecoder(
    sampleRate: AudioConstants.sampleRate,
    channels: AudioConstants.channels,
  );
  
  // 临时文件目录
  Directory? _tempDir;
  
  // 是否已初始化
  bool _isInitialized = false;
  
  // 音频文件计数器
  int _audioFileCounter = 0;

  /// 初始化音频服务
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[$tag] 音频服务已初始化，跳过');
      return;
    }

    try {
      print('[$tag] 开始初始化音频服务V2');
      _currentState = AudioConstants.stateProcessing;
      
      // 1. 检查麦克风权限
      await _checkAudioPermissions();
      
      // 2. 获取临时目录
      _tempDir = await getTemporaryDirectory();
      print('[$tag] 临时目录: ${_tempDir!.path}');
      
      // 3. 初始化音频播放器
      await _initializeAudioPlayer();
      
      // 4. Opus解码器已静态初始化
      print('[$tag] Opus解码器使用静态初始化');
      
      _isInitialized = true;
      _currentState = AudioConstants.stateIdle;
      print('[$tag] 音频服务V2初始化完成');
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      print('[$tag] 音频服务V2初始化失败: $e');
      throw AppException.system(
        message: '音频服务初始化失败',
        code: AudioConstants.errorCodeAudioSessionFailed.toString(),
        component: 'AudioServiceV2',
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
          component: 'AudioServiceV2',
          details: {'permission': 'microphone'},
        );
      }
      
      print('[$tag] 音频权限检查完成');
    } catch (e) {
      print('[$tag] 音频权限检查失败: $e');
      rethrow;
    }
  }

  /// 初始化音频播放器
  Future<void> _initializeAudioPlayer() async {
    try {
      print('[$tag] 初始化JustAudio播放器');
      
      // 停止任何现有的播放器
      await _stopAudioPlayer();
      
      // 创建新的播放器实例
      _audioPlayer = AudioPlayer();
      
      print('[$tag] JustAudio播放器初始化成功');
    } catch (e) {
      print('[$tag] JustAudio播放器初始化失败: $e');
      throw Exception('JustAudio播放器初始化失败: $e');
    }
  }

  /// 播放Opus音频数据
  Future<void> playOpusAudio(Uint8List opusData) async {
    print('[$tag] ===== 开始播放Opus音频 =====');
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
      
      // 打印音频数据的前16个字节用于调试
      final headerLength = opusData.length < 16 ? opusData.length : 16;
      final headerHex = opusData.take(headerLength)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');
      print('[$tag] 音频数据头部(hex): $headerHex');
      
      // 2. Opus解码为PCM数据
      print('[$tag] 开始Opus解码');
      final pcmData = _decodeOpusToPcm(opusData);
      if (pcmData.isEmpty) {
        print('[$tag] Opus解码失败，跳过播放');
        return;
      }
      print('[$tag] Opus解码成功，PCM数据大小: ${pcmData.length} bytes');
      
      // 3. 创建WAV文件并播放
      print('[$tag] 创建WAV文件');
      final wavFile = await _createWavFile(pcmData);
      
      // 4. 播放WAV文件
      print('[$tag] 播放WAV文件');
      await _playWavFile(wavFile);
      
      print('[$tag] ===== 播放Opus音频结束 =====');
      
    } catch (e) {
      print('[$tag] 播放音频失败: $e');
      print('[$tag] 错误类型: ${e.runtimeType}');
    }
  }

  /// Opus解码为PCM数据
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
      
      // 使用ByteData确保正确的字节序转换（修复噪音问题）
      final Uint8List pcmBytes = Uint8List(pcmInt16.length * 2);
      final ByteData byteData = ByteData.view(pcmBytes.buffer);
      
      // 使用小端字节序，确保与WAV格式一致
      for (int i = 0; i < pcmInt16.length; i++) {
        byteData.setInt16(i * 2, pcmInt16[i], Endian.little);
      }
      
      // 音频平滑处理：仅对较长的音频片段进行处理
      if (pcmInt16.length > 64) {
        _applySmoothingToPCM(byteData, pcmInt16.length);
      }
      
      print('[$tag] PCM数据准备完成，输出大小: ${pcmBytes.length} bytes');
      print('[$tag] 使用ByteData.setInt16确保正确字节序，并应用音频平滑');
      
      return pcmBytes;
    } catch (e) {
      print('[$tag] Opus解码失败: $e');
      print('[$tag] 错误类型: ${e.runtimeType}');
      return Uint8List(0);
    }
  }

  /// 创建WAV文件
  Future<File> _createWavFile(Uint8List pcmData) async {
    try {
      // 创建文件名
      final fileName = 'audio_${_audioFileCounter++}.wav';
      final filePath = '${_tempDir!.path}/$fileName';
      final file = File(filePath);
      
      // 创建WAV文件头
      final wavHeader = _createWavHeader(pcmData.length);
      
      // 写入WAV文件
      final wavData = Uint8List.fromList([...wavHeader, ...pcmData]);
      await file.writeAsBytes(wavData);
      
      print('[$tag] WAV文件创建成功: $filePath');
      return file;
    } catch (e) {
      print('[$tag] 创建WAV文件失败: $e');
      rethrow;
    }
  }

  /// 创建WAV文件头（优化版本）
  List<int> _createWavHeader(int dataLength) {
    final header = <int>[];
    
    // RIFF chunk
    header.addAll('RIFF'.codeUnits);
    header.addAll(_int32ToBytes(36 + dataLength)); // 文件长度 - 8
    header.addAll('WAVE'.codeUnits);
    
    // fmt chunk - 优化参数
    header.addAll('fmt '.codeUnits);
    header.addAll(_int32ToBytes(16)); // PCM格式块长度
    header.addAll(_int16ToBytes(1)); // 音频格式 (PCM)
    header.addAll(_int16ToBytes(1)); // 声道数：单声道
    header.addAll(_int32ToBytes(16000)); // 采样率：16000Hz
    header.addAll(_int32ToBytes(32000)); // 字节率：16000 * 1 * 2 = 32000
    header.addAll(_int16ToBytes(2)); // 块对齐：1声道 * 2字节 = 2
    header.addAll(_int16ToBytes(16)); // 每个样本的位数
    
    // data chunk
    header.addAll('data'.codeUnits);
    header.addAll(_int32ToBytes(dataLength)); // 数据长度
    
    return header;
  }

  /// 播放WAV文件（高度优化版本 - 最小化操作）
  Future<void> _playWavFile(File wavFile) async {
    try {
      // 确保播放器可用
      if (_audioPlayer == null) {
        await _initializeAudioPlayer();
      }
      
      print('[$tag] 开始播放WAV文件: ${wavFile.path}');
      
      try {
        // 直接设置音频源并播放，减少不必要的停止操作
        await _audioPlayer!.setFilePath(wavFile.path);
        await _audioPlayer!.play();
        
        // 等待播放完成，但设置超时避免卡死
        await _audioPlayer!.playerStateStream
            .where((state) => state.processingState == ProcessingState.completed)
            .timeout(const Duration(seconds: 5))
            .first;
        
        print('[$tag] WAV文件播放完成');
        
      } catch (playError) {
        print('[$tag] 播放过程中出错: $playError');
        
        // 简化错误处理：只重新初始化播放器
        await _stopAudioPlayer();
        await _initializeAudioPlayer();
        
        // 简单重试一次
        await _audioPlayer!.setFilePath(wavFile.path);
        await _audioPlayer!.play();
        
        print('[$tag] 重试播放完成');
      }
      
      // 异步删除临时文件，不等待完成
      Future.microtask(() async {
        try {
          await wavFile.delete();
        } catch (e) {
          print('[$tag] 删除临时文件失败: $e');
        }
      });
      
    } catch (e) {
      print('[$tag] 播放WAV文件失败: $e');
      rethrow;
    }
  }

  /// 停止播放
  Future<void> _stopAudioPlayer() async {
    if (_audioPlayer != null) {
      try {
        await _audioPlayer!.stop();
        await _audioPlayer!.dispose();
        print('[$tag] 音频播放器已停止并释放');
      } catch (e) {
        print('[$tag] 停止音频播放器失败: $e');
      }
      _audioPlayer = null;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _stopAudioPlayer();
      print('[$tag] 音频播放停止');
    } catch (e) {
      print('[$tag] 停止音频播放失败: $e');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    try {
      // 停止并释放播放器
      await _stopAudioPlayer();
      
      // 清理临时文件
      if (_tempDir != null) {
        try {
          final files = await _tempDir!.list().toList();
          for (final file in files) {
            if (file.path.endsWith('.wav')) {
              await file.delete();
            }
          }
          print('[$tag] 临时音频文件已清理');
        } catch (e) {
          print('[$tag] 清理临时文件失败: $e');
        }
      }
      
      // 重置状态
      _isInitialized = false;
      _currentState = AudioConstants.stateIdle;
      
      print('[$tag] 音频服务V2资源释放完成');
    } catch (e) {
      print('[$tag] 音频服务V2资源释放失败: $e');
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

  /// 对PCM数据应用平滑处理，减少音频片段间的刺啦声
  /// 使用最简化的处理方式
  void _applySmoothingToPCM(ByteData byteData, int sampleCount) {
    try {
      // 使用极短的淡入淡出长度
      const int fadeLength = 4; // 极短淡入淡出长度
      
      // 仅对音频开头进行极轻微淡入处理
      for (int i = 0; i < math.min(fadeLength, sampleCount); i++) {
        final currentSample = byteData.getInt16(i * 2, Endian.little);
        final fadeRatio = (i + 1) / (fadeLength + 1); // 简化淡入计算
        final fadedSample = (currentSample * fadeRatio).round();
        byteData.setInt16(i * 2, fadedSample, Endian.little);
      }
      
      // 仅对音频结尾进行极轻微淡出处理
      for (int i = 0; i < math.min(fadeLength, sampleCount); i++) {
        final sampleIndex = sampleCount - 1 - i;
        final currentSample = byteData.getInt16(sampleIndex * 2, Endian.little);
        final fadeRatio = (i + 1) / (fadeLength + 1); // 简化淡出计算
        final fadedSample = (currentSample * fadeRatio).round();
        byteData.setInt16(sampleIndex * 2, fadedSample, Endian.little);
      }
      
      print('[$tag] 应用极轻度音频平滑处理，淡入淡出长度: $fadeLength 样本');
    } catch (e) {
      print('[$tag] 音频平滑处理失败: $e');
    }
  }
}

/// 音频服务V2 Provider
final audioServiceV2Provider = Provider<AudioServiceV2>((ref) {
  final service = AudioServiceV2();
  
  // 在Provider被销毁时清理资源
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
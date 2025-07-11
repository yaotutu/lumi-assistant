import 'dart:typed_data';
import 'dart:io';
import 'package:opus_dart/opus_dart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import '../constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
import 'permission_service.dart';

/// 简化的音频播放服务
/// 
/// 完全按照Android客户端AudioUtil.playOpusData的逻辑实现
/// 使用最简单的方式处理音频数据
class AudioServiceSimple {
  static const String tag = 'AudioServiceSimple';
  
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
      print('[$tag] 开始初始化简化音频服务');
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
      print('[$tag] 简化音频服务初始化完成');
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      print('[$tag] 简化音频服务初始化失败: $e');
      throw AppException.system(
        message: '音频服务初始化失败',
        code: AudioConstants.errorCodeAudioSessionFailed.toString(),
        component: 'AudioServiceSimple',
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
          component: 'AudioServiceSimple',
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
  /// 完全按照Android客户端AudioUtil.playOpusData的逻辑
  Future<void> playOpusAudio(Uint8List opusData) async {
    print('[$tag] ===== 开始播放Opus音频（完全按照Android客户端）=====');
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
      
      // 2. 解码Opus数据（完全按照Android客户端方式）
      print('[$tag] 开始Opus解码');
      final Int16List pcmData = _decoder.decode(input: opusData);
      print('[$tag] Opus解码完成，PCM样本数: ${pcmData.length}');
      
      if (pcmData.isEmpty) {
        print('[$tag] Opus解码结果为空，跳过播放');
        return;
      }
      
      // 3. 准备PCM数据（完全按照Android客户端示例直接方式）
      final Uint8List pcmBytes = Uint8List(pcmData.length * 2);
      final ByteData bytes = ByteData.view(pcmBytes.buffer);
      
      // 使用小端字节序（完全按照Android客户端）
      for (int i = 0; i < pcmData.length; i++) {
        bytes.setInt16(i * 2, pcmData[i], Endian.little);
      }
      
      print('[$tag] PCM数据准备完成，大小: ${pcmBytes.length} bytes');
      
      // 4. 创建WAV文件并播放（因为JustAudio不能直接播放PCM，所以需要包装成WAV）
      final wavFile = await _createSimpleWavFile(pcmBytes);
      await _playWavFileSimple(wavFile);
      
      print('[$tag] ===== 播放Opus音频结束 =====');
      
    } catch (e) {
      print('[$tag] 播放音频失败: $e');
      
      // 简单重置并重新初始化（按照Android客户端方式）
      try {
        print('[$tag] 尝试重新初始化播放器');
        await _initializeAudioPlayer();
      } catch (reinitError) {
        print('[$tag] 重新初始化播放器失败: $reinitError');
      }
    }
  }

  /// 创建简单的WAV文件
  Future<File> _createSimpleWavFile(Uint8List pcmData) async {
    try {
      // 创建文件名
      final fileName = 'audio_${_audioFileCounter++}.wav';
      final filePath = '${_tempDir!.path}/$fileName';
      final file = File(filePath);
      
      // 创建最简单的WAV文件头
      final wavHeader = _createSimpleWavHeader(pcmData.length);
      
      // 写入WAV文件
      final wavData = Uint8List.fromList([...wavHeader, ...pcmData]);
      await file.writeAsBytes(wavData);
      
      print('[$tag] 简单WAV文件创建成功: $filePath');
      return file;
    } catch (e) {
      print('[$tag] 创建简单WAV文件失败: $e');
      rethrow;
    }
  }

  /// 创建最简单的WAV文件头
  List<int> _createSimpleWavHeader(int dataLength) {
    final header = <int>[];
    
    // RIFF chunk
    header.addAll('RIFF'.codeUnits);
    header.addAll(_int32ToBytes(36 + dataLength));
    header.addAll('WAVE'.codeUnits);
    
    // fmt chunk
    header.addAll('fmt '.codeUnits);
    header.addAll(_int32ToBytes(16));
    header.addAll(_int16ToBytes(1)); // PCM
    header.addAll(_int16ToBytes(1)); // 单声道
    header.addAll(_int32ToBytes(16000)); // 16kHz
    header.addAll(_int32ToBytes(32000)); // 字节率
    header.addAll(_int16ToBytes(2)); // 块对齐
    header.addAll(_int16ToBytes(16)); // 16位
    
    // data chunk
    header.addAll('data'.codeUnits);
    header.addAll(_int32ToBytes(dataLength));
    
    return header;
  }

  /// 最简单的WAV文件播放方式
  Future<void> _playWavFileSimple(File wavFile) async {
    try {
      print('[$tag] 开始播放WAV文件: ${wavFile.path}');
      
      // 确保播放器可用
      if (_audioPlayer == null) {
        await _initializeAudioPlayer();
      }
      
      // 直接播放，不等待完成（避免超时问题）
      await _audioPlayer!.setFilePath(wavFile.path);
      await _audioPlayer!.play();
      
      print('[$tag] WAV文件播放已启动');
      
      // 异步等待播放完成并清理文件
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          await wavFile.delete();
          print('[$tag] 临时文件已删除');
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
      
      print('[$tag] 简化音频服务资源释放完成');
    } catch (e) {
      print('[$tag] 简化音频服务资源释放失败: $e');
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
}

/// 简化音频服务 Provider
final audioServiceSimpleProvider = Provider<AudioServiceSimple>((ref) {
  final service = AudioServiceSimple();
  
  // 在Provider被销毁时清理资源
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
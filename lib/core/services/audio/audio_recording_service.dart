import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../constants/audio_constants.dart';
import '../../../data/models/common/exceptions.dart';
import '../device/permission_service.dart';
import '../../utils/loggers.dart';

/// 音频录制服务
/// 负责处理音频录制、PCM数据获取和Opus编码
/// 参考xiaozhi-android-client项目的音频录制实现
class AudioRecordingService {
  static const String tag = 'AudioRecordingService';
  
  // 录制器实例
  final AudioRecorder _recorder = AudioRecorder();
  
  // 权限服务
  final PermissionService _permissionService = PermissionService();
  
  // Opus编码器
  SimpleOpusEncoder? _opusEncoder;
  
  // 录制状态
  bool _isRecording = false;
  bool _isInitialized = false;
  String _currentState = AudioConstants.stateIdle;
  
  // 录制配置
  late RecordConfig _recordConfig;
  
  // 数据流控制器
  StreamController<Uint8List>? _rawDataController;
  StreamController<Uint8List>? _opusDataController;
  
  // 录制文件路径
  String? _currentRecordingPath;
  
  // 录制统计
  int _recordedFrames = 0;
  int _encodedFrames = 0;
  DateTime? _recordingStartTime;

  /// 初始化录制服务
  Future<void> initialize() async {
    if (_isInitialized) {
      Loggers.audio.info('录制服务已初始化，跳过');
      return;
    }

    try {
      Loggers.audio.info('开始初始化音频录制服务');
      _currentState = AudioConstants.stateProcessing;
      
      // 1. 检查权限
      await _checkPermissions();
      
      // 2. 初始化Opus编码器
      await _initializeOpusEncoder();
      
      // 3. 配置录制参数
      _setupRecordConfig();
      
      // 4. 初始化数据流控制器
      _initializeStreamControllers();
      
      _isInitialized = true;
      _currentState = AudioConstants.stateIdle;
      Loggers.audio.info('音频录制服务初始化完成');
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      Loggers.audio.severe('音频录制服务初始化失败', e);
      throw AppException.system(
        message: '音频录制服务初始化失败',
        code: AudioConstants.errorCodeRecordingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 检查权限
  Future<void> _checkPermissions() async {
    try {
      final permissions = await _permissionService.checkAudioPermissions();
      
      if (!permissions['microphone']!) {
        throw AppException.system(
          message: '麦克风权限未授予',
          code: AudioConstants.errorCodePermissionDenied.toString(),
          component: 'AudioRecordingService',
          details: {'permission': 'microphone'},
        );
      }
      
      Loggers.audio.info('音频权限检查通过');
    } catch (e) {
      Loggers.audio.severe('音频权限检查失败', e);
      rethrow;
    }
  }

  /// 初始化Opus编码器
  Future<void> _initializeOpusEncoder() async {
    try {
      _opusEncoder = SimpleOpusEncoder(
        sampleRate: AudioConstants.sampleRate,
        channels: AudioConstants.channels,
        application: Application.voip,
      );
      
      Loggers.audio.info('Opus编码器初始化完成');
      Loggers.audio.fine('编码器配置: ${AudioConstants.opusConfig}');
    } catch (e) {
      Loggers.audio.severe('Opus编码器初始化失败', e);
      throw AppException.system(
        message: 'Opus编码器初始化失败',
        code: AudioConstants.errorCodeEncodingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 设置录制配置
  void _setupRecordConfig() {
    _recordConfig = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: AudioConstants.sampleRate,
      numChannels: AudioConstants.channels,
      bitRate: AudioConstants.bitrate,
      autoGain: true,
      echoCancel: true,
      noiseSuppress: true,
    );
    
    Loggers.audio.info('录制配置设置完成');
    Loggers.audio.fine('配置详情: 采样率=${AudioConstants.sampleRate}Hz, 声道=${AudioConstants.channels}, 比特率=${AudioConstants.bitrate}bps');
  }

  /// 初始化数据流控制器
  void _initializeStreamControllers() {
    _rawDataController?.close();
    _opusDataController?.close();
    
    _rawDataController = StreamController<Uint8List>.broadcast();
    _opusDataController = StreamController<Uint8List>.broadcast();
    
    Loggers.audio.fine('数据流控制器初始化完成');
  }

  /// 开始录制
  Future<void> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isRecording) {
      Loggers.audio.info('录制已在进行中，忽略重复请求');
      return;
    }

    try {
      Loggers.audio.info('开始录制音频');
      _currentState = AudioConstants.stateRecording;
      
      // 重置统计数据
      _recordedFrames = 0;
      _encodedFrames = 0;
      _recordingStartTime = DateTime.now();
      
      // 获取临时文件路径
      final tempDir = await getTemporaryDirectory();
      _currentRecordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      // 检查权限
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw AppException.system(
          message: '录音权限被拒绝',
          code: AudioConstants.errorCodePermissionDenied.toString(),
          component: 'AudioRecordingService',
          details: {'permission': 'microphone'},
        );
      }
      
      // 开始录制
      await _recorder.start(
        _recordConfig,
        path: _currentRecordingPath!,
      );
      
      _isRecording = true;
      Loggers.audio.info('录制开始成功，文件路径: $_currentRecordingPath');
      
      // 启动数据处理循环
      _startDataProcessingLoop();
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      Loggers.audio.severe('开始录制失败', e);
      throw AppException.system(
        message: '开始录制失败',
        code: AudioConstants.errorCodeRecordingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 停止录制
  Future<void> stopRecording() async {
    if (!_isRecording) {
      Loggers.audio.info('录制未在进行中，忽略停止请求');
      return;
    }

    try {
      Loggers.audio.info('停止录制音频');
      
      // 停止录制
      await _recorder.stop();
      
      _isRecording = false;
      _currentState = AudioConstants.stateIdle;
      
      // 打印录制统计
      final duration = _recordingStartTime != null 
          ? DateTime.now().difference(_recordingStartTime!).inMilliseconds
          : 0;
      
      Loggers.audio.info('录制停止成功');
      Loggers.audio.info('录制统计: 时长=${duration}ms, 帧数=$_recordedFrames, 编码帧=$_encodedFrames');
      
      // 注意：不在这里清理文件！文件将在processRecordedFile()之后清理
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      Loggers.audio.severe('停止录制失败', e);
      throw AppException.system(
        message: '停止录制失败',
        code: AudioConstants.errorCodeRecordingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 启动数据处理循环
  void _startDataProcessingLoop() {
    // 注意：record库不支持实时流数据获取
    // 这里我们使用定时器模拟数据处理
    // 实际的数据处理需要在录制完成后进行
    Loggers.audio.fine('启动数据处理循环');
    
    // 这里可以添加实时数据处理逻辑
    // 但record库主要用于文件录制，不支持实时流
    // 如果需要实时流处理，可能需要使用其他库如flutter_sound
  }

  /// 处理录制的音频文件，返回Opus帧列表
  Future<List<Uint8List>> processRecordedFile() async {
    if (_currentRecordingPath == null || !File(_currentRecordingPath!).existsSync()) {
      throw AppException.system(
        message: '录制文件不存在',
        code: AudioConstants.errorCodeRecordingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'path': _currentRecordingPath},
      );
    }

    try {
      Loggers.audio.info('处理录制文件: $_currentRecordingPath');
      
      // 读取WAV文件
      final file = File(_currentRecordingPath!);
      final bytes = await file.readAsBytes();
      
      // 解析WAV文件头部，获取数据块位置
      final pcmData = _extractPCMFromWAV(bytes);
      if (pcmData.isEmpty) {
        throw AppException.system(
          message: '无法从WAV文件中提取有效的PCM数据',
          code: AudioConstants.errorCodeRecordingFailed.toString(),
          component: 'AudioRecordingService',
          details: {'fileSize': bytes.length},
        );
      }
      
      Loggers.audio.fine('PCM数据提取完成，大小: ${pcmData.length} bytes');
      
      // 验证PCM数据格式
      if (!_validatePCMData(pcmData)) {
        throw AppException.system(
          message: 'PCM数据格式验证失败',
          code: AudioConstants.errorCodeRecordingFailed.toString(),
          component: 'AudioRecordingService',
          details: {'pcmSize': pcmData.length},
        );
      }
      
      // 将PCM数据转换为Opus帧列表
      final opusFrames = await _encodePCMToOpusFrames(pcmData);
      
      // 处理完成后清理文件
      await _cleanupRecordingFile();
      
      return opusFrames;
      
    } catch (e) {
      Loggers.audio.severe('处理录制文件失败', e);
      throw AppException.system(
        message: '处理录制文件失败',
        code: AudioConstants.errorCodeProcessingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 将PCM数据编码为Opus帧列表
  Future<List<Uint8List>> _encodePCMToOpusFrames(Uint8List pcmData) async {
    if (_opusEncoder == null) {
      throw AppException.system(
        message: 'Opus编码器未初始化',
        code: AudioConstants.errorCodeEncodingFailed.toString(),
        component: 'AudioRecordingService',
        details: {},
      );
    }

    try {
      Loggers.audio.fine('开始PCM到Opus编码，PCM数据大小: ${pcmData.length} bytes');
      
      // 将字节数组转换为Int16数组（与AudioStreamService保持一致的处理方式）
      final int16Data = Int16List(pcmData.length ~/ 2);
      for (int i = 0; i < int16Data.length; i++) {
        // 小端字节序，与AudioStreamService._encodeAndSendFrame保持一致
        int16Data[i] = (pcmData[i * 2] | (pcmData[i * 2 + 1] << 8));
      }
      
      Loggers.audio.fine('PCM样本数: ${int16Data.length}');
      
      // 分帧编码（与AudioStreamService保持一致的帧大小）
      final frameSize = 960; // 60ms at 16kHz = 960 samples，与AudioStreamService保持一致
      final opusFrames = <Uint8List>[];
      
      for (int i = 0; i < int16Data.length; i += frameSize) {
        final end = (i + frameSize < int16Data.length) ? i + frameSize : int16Data.length;
        final frameData = int16Data.sublist(i, end);
        
        // 如果帧不够完整，填充0（与AudioStreamService处理方式一致）
        if (frameData.length < frameSize) {
          final paddedFrame = Int16List(frameSize);
          paddedFrame.setRange(0, frameData.length, frameData);
          final opusFrame = _opusEncoder!.encode(input: paddedFrame);
          opusFrames.add(opusFrame);
        } else {
          final opusFrame = _opusEncoder!.encode(input: frameData);
          opusFrames.add(opusFrame);
        }
        
        _encodedFrames++;
      }
      
      Loggers.audio.info('Opus编码完成，生成帧数: ${opusFrames.length}');
      return opusFrames;
      
    } catch (e) {
      Loggers.audio.severe('PCM到Opus编码失败', e);
      throw AppException.system(
        message: 'PCM到Opus编码失败',
        code: AudioConstants.errorCodeEncodingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 从WAV文件中提取PCM数据
  Uint8List _extractPCMFromWAV(Uint8List wavBytes) {
    try {
      if (wavBytes.length < 44) {
        Loggers.audio.severe('WAV文件太小，长度: ${wavBytes.length}');
        return Uint8List(0);
      }
      
      // 验证WAV文件头
      final riffHeader = String.fromCharCodes(wavBytes.sublist(0, 4));
      final waveHeader = String.fromCharCodes(wavBytes.sublist(8, 12));
      
      if (riffHeader != 'RIFF' || waveHeader != 'WAVE') {
        Loggers.audio.severe('不是有效的WAV文件: RIFF=$riffHeader, WAVE=$waveHeader');
        return Uint8List(0);
      }
      
      // 查找data块
      int offset = 12; // 跳过RIFF头部
      while (offset < wavBytes.length - 8) {
        final chunkId = String.fromCharCodes(wavBytes.sublist(offset, offset + 4));
        final chunkSize = _readLittleEndian32(wavBytes, offset + 4);
        
        Loggers.audio.fine('发现块: $chunkId, 大小: $chunkSize, 偏移: $offset');
        
        if (chunkId == 'data') {
          // 找到数据块
          final dataStart = offset + 8;
          final dataEnd = dataStart + chunkSize;
          
          if (dataEnd <= wavBytes.length) {
            final pcmData = wavBytes.sublist(dataStart, dataEnd);
            Loggers.audio.fine('成功提取PCM数据: ${pcmData.length} bytes (从偏移 $dataStart 到 $dataEnd)');
            return pcmData;
          } else {
            Loggers.audio.severe('数据块超出文件边界: dataEnd=$dataEnd, fileLength=${wavBytes.length}');
            return Uint8List(0);
          }
        }
        
        // 移动到下一个块
        offset += 8 + chunkSize;
        // 确保偶数对齐
        if (chunkSize % 2 != 0) {
          offset += 1;
        }
      }
      
      Loggers.audio.severe('未找到data块');
      return Uint8List(0);
    } catch (e) {
      Loggers.audio.severe('解析WAV文件失败', e);
      return Uint8List(0);
    }
  }
  
  /// 读取小端32位整数
  int _readLittleEndian32(Uint8List bytes, int offset) {
    return bytes[offset] |
           (bytes[offset + 1] << 8) |
           (bytes[offset + 2] << 16) |
           (bytes[offset + 3] << 24);
  }
  
  /// 验证PCM数据格式
  bool _validatePCMData(Uint8List pcmData) {
    try {
      // 检查数据长度是否为偶数（16位PCM）
      if (pcmData.length % 2 != 0) {
        Loggers.audio.severe('PCM数据长度不是偶数: ${pcmData.length}');
        return false;
      }
      
      // 检查最小长度（至少一帧的数据）
      final minFrameSize = (AudioConstants.sampleRate * AudioConstants.frameDurationMs) ~/ 1000 * 2;
      if (pcmData.length < minFrameSize) {
        Loggers.audio.severe('PCM数据太短: ${pcmData.length} < $minFrameSize');
        return false;
      }
      
      // 检查采样率对应的数据长度合理性
      final expectedSamples = pcmData.length ~/ 2;
      final durationMs = (expectedSamples * 1000) / AudioConstants.sampleRate;
      
      Loggers.audio.fine('PCM数据验证通过: ${pcmData.length} bytes, $expectedSamples samples, ${durationMs.toInt()}ms');
      
      // 检查录制时长是否合理（0.1秒到60秒之间）
      if (durationMs < 100 || durationMs > 60000) {
        Loggers.audio.severe('录制时长不合理: ${durationMs}ms');
        return false;
      }
      
      return true;
    } catch (e) {
      Loggers.audio.severe('PCM数据验证失败', e);
      return false;
    }
  }

  /// 清理录制文件
  Future<void> _cleanupRecordingFile() async {
    if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
      try {
        await File(_currentRecordingPath!).delete();
        Loggers.audio.fine('清理录制文件成功: $_currentRecordingPath');
      } catch (e) {
        Loggers.audio.severe('清理录制文件失败', e);
      }
      _currentRecordingPath = null;
    }
  }

  /// 获取录制状态
  bool get isRecording => _isRecording;
  
  /// 获取初始化状态
  bool get isInitialized => _isInitialized;
  
  /// 获取当前状态
  String get currentState => _currentState;
  
  /// 获取原始数据流
  Stream<Uint8List>? get rawDataStream => _rawDataController?.stream;
  
  /// 获取Opus数据流
  Stream<Uint8List>? get opusDataStream => _opusDataController?.stream;
  
  /// 获取录制统计
  Map<String, dynamic> get recordingStats => {
    'isRecording': _isRecording,
    'recordedFrames': _recordedFrames,
    'encodedFrames': _encodedFrames,
    'recordingDuration': _recordingStartTime != null 
        ? DateTime.now().difference(_recordingStartTime!).inMilliseconds
        : 0,
    'currentPath': _currentRecordingPath,
  };

  /// 释放资源
  Future<void> dispose() async {
    try {
      // 停止录制
      if (_isRecording) {
        await stopRecording();
      }
      
      // 关闭数据流
      await _rawDataController?.close();
      await _opusDataController?.close();
      
      // 释放Opus编码器
      _opusEncoder?.destroy();
      _opusEncoder = null;
      
      // 清理文件
      await _cleanupRecordingFile();
      
      // 释放录制器
      _recorder.dispose();
      
      _isInitialized = false;
      _currentState = AudioConstants.stateIdle;
      
      Loggers.audio.info('音频录制服务资源释放完成');
    } catch (e) {
      Loggers.audio.severe('音频录制服务资源释放失败', e);
    }
  }
}
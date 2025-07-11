import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
import 'permission_service.dart';

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
      print('[$tag] 录制服务已初始化，跳过');
      return;
    }

    try {
      print('[$tag] 开始初始化音频录制服务');
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
      print('[$tag] 音频录制服务初始化完成');
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      print('[$tag] 音频录制服务初始化失败: $e');
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
      
      print('[$tag] 音频权限检查通过');
    } catch (e) {
      print('[$tag] 音频权限检查失败: $e');
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
      
      print('[$tag] Opus编码器初始化完成');
      print('[$tag] 编码器配置: ${AudioConstants.opusConfig}');
    } catch (e) {
      print('[$tag] Opus编码器初始化失败: $e');
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
    
    print('[$tag] 录制配置设置完成');
    print('[$tag] 配置详情: 采样率=${AudioConstants.sampleRate}Hz, 声道=${AudioConstants.channels}, 比特率=${AudioConstants.bitrate}bps');
  }

  /// 初始化数据流控制器
  void _initializeStreamControllers() {
    _rawDataController?.close();
    _opusDataController?.close();
    
    _rawDataController = StreamController<Uint8List>.broadcast();
    _opusDataController = StreamController<Uint8List>.broadcast();
    
    print('[$tag] 数据流控制器初始化完成');
  }

  /// 开始录制
  Future<void> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isRecording) {
      print('[$tag] 录制已在进行中，忽略重复请求');
      return;
    }

    try {
      print('[$tag] 开始录制音频');
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
      print('[$tag] 录制开始成功，文件路径: $_currentRecordingPath');
      
      // 启动数据处理循环
      _startDataProcessingLoop();
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      print('[$tag] 开始录制失败: $e');
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
      print('[$tag] 录制未在进行中，忽略停止请求');
      return;
    }

    try {
      print('[$tag] 停止录制音频');
      
      // 停止录制
      await _recorder.stop();
      
      _isRecording = false;
      _currentState = AudioConstants.stateIdle;
      
      // 打印录制统计
      final duration = _recordingStartTime != null 
          ? DateTime.now().difference(_recordingStartTime!).inMilliseconds
          : 0;
      
      print('[$tag] 录制停止成功');
      print('[$tag] 录制统计: 时长=${duration}ms, 帧数=$_recordedFrames, 编码帧=$_encodedFrames');
      
      // 注意：不在这里清理文件！文件将在processRecordedFile()之后清理
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      print('[$tag] 停止录制失败: $e');
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
    print('[$tag] 启动数据处理循环');
    
    // 这里可以添加实时数据处理逻辑
    // 但record库主要用于文件录制，不支持实时流
    // 如果需要实时流处理，可能需要使用其他库如flutter_sound
  }

  /// 处理录制的音频文件
  Future<Uint8List> processRecordedFile() async {
    if (_currentRecordingPath == null || !File(_currentRecordingPath!).existsSync()) {
      throw AppException.system(
        message: '录制文件不存在',
        code: AudioConstants.errorCodeRecordingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'path': _currentRecordingPath},
      );
    }

    try {
      print('[$tag] 处理录制文件: $_currentRecordingPath');
      
      // 读取WAV文件
      final file = File(_currentRecordingPath!);
      final bytes = await file.readAsBytes();
      
      // 跳过WAV头部，获取PCM数据
      // WAV头部通常是44字节
      const wavHeaderSize = 44;
      if (bytes.length <= wavHeaderSize) {
        throw AppException.system(
          message: '录制文件太小，可能损坏',
          code: AudioConstants.errorCodeRecordingFailed.toString(),
          component: 'AudioRecordingService',
          details: {'fileSize': bytes.length},
        );
      }
      
      final pcmData = bytes.sublist(wavHeaderSize);
      print('[$tag] PCM数据提取完成，大小: ${pcmData.length} bytes');
      
      // 将PCM数据转换为Opus编码
      final opusData = await _encodePCMToOpus(Uint8List.fromList(pcmData));
      
      // 处理完成后清理文件
      await _cleanupRecordingFile();
      
      return opusData;
      
    } catch (e) {
      print('[$tag] 处理录制文件失败: $e');
      throw AppException.system(
        message: '处理录制文件失败',
        code: AudioConstants.errorCodeProcessingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 将PCM数据编码为Opus
  Future<Uint8List> _encodePCMToOpus(Uint8List pcmData) async {
    if (_opusEncoder == null) {
      throw AppException.system(
        message: 'Opus编码器未初始化',
        code: AudioConstants.errorCodeEncodingFailed.toString(),
        component: 'AudioRecordingService',
        details: {},
      );
    }

    try {
      print('[$tag] 开始PCM到Opus编码，PCM数据大小: ${pcmData.length} bytes');
      
      // 将字节数组转换为Int16数组
      final int16Data = <int>[];
      for (int i = 0; i < pcmData.length; i += 2) {
        if (i + 1 < pcmData.length) {
          // 小端字节序
          final value = pcmData[i] | (pcmData[i + 1] << 8);
          // 转换为有符号16位整数
          final signedValue = value > 32767 ? value - 65536 : value;
          int16Data.add(signedValue);
        }
      }
      
      print('[$tag] PCM样本数: ${int16Data.length}');
      
      // 分帧编码
      final frameSize = (AudioConstants.sampleRate * AudioConstants.frameDurationMs) ~/ 1000;
      final opusFrames = <Uint8List>[];
      
      for (int i = 0; i < int16Data.length; i += frameSize) {
        final end = (i + frameSize < int16Data.length) ? i + frameSize : int16Data.length;
        final frame = Int16List.fromList(int16Data.sublist(i, end));
        
        // 如果帧不够完整，填充0
        if (frame.length < frameSize) {
          final paddedFrame = Int16List(frameSize);
          paddedFrame.setRange(0, frame.length, frame);
          final opusFrame = _opusEncoder!.encode(input: paddedFrame);
          opusFrames.add(opusFrame);
        } else {
          final opusFrame = _opusEncoder!.encode(input: frame);
          opusFrames.add(opusFrame);
        }
        
        _encodedFrames++;
      }
      
      // 合并所有Opus帧
      final totalLength = opusFrames.fold<int>(0, (sum, frame) => sum + frame.length);
      final result = Uint8List(totalLength);
      int offset = 0;
      
      for (final frame in opusFrames) {
        result.setRange(offset, offset + frame.length, frame);
        offset += frame.length;
      }
      
      print('[$tag] Opus编码完成，编码帧数: ${opusFrames.length}, 总大小: ${result.length} bytes');
      
      return result;
      
    } catch (e) {
      print('[$tag] PCM到Opus编码失败: $e');
      throw AppException.system(
        message: 'PCM到Opus编码失败',
        code: AudioConstants.errorCodeEncodingFailed.toString(),
        component: 'AudioRecordingService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 清理录制文件
  Future<void> _cleanupRecordingFile() async {
    if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
      try {
        await File(_currentRecordingPath!).delete();
        print('[$tag] 清理录制文件成功: $_currentRecordingPath');
      } catch (e) {
        print('[$tag] 清理录制文件失败: $e');
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
      
      print('[$tag] 音频录制服务资源释放完成');
    } catch (e) {
      print('[$tag] 音频录制服务资源释放失败: $e');
    }
  }
}
import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:opus_dart/opus_dart.dart';
import '../constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
import 'permission_service.dart';
import 'websocket_service.dart';

/// 音频流传输服务
/// 负责实时音频流的录制、编码和传输
/// 基于xiaozhi-android-client的音频流处理模式
class AudioStreamService {
  static const String tag = 'AudioStreamService';
  
  // 核心服务
  final AudioRecorder _recorder = AudioRecorder();
  final PermissionService _permissionService = PermissionService();
  final WebSocketService _webSocketService;
  
  // Opus编码器
  SimpleOpusEncoder? _opusEncoder;
  
  // 流控制
  bool _isStreaming = false;
  bool _isInitialized = false;
  String _currentState = AudioConstants.stateIdle;
  
  // 录制配置
  late RecordConfig _recordConfig;
  
  // 流数据控制器
  StreamController<Uint8List>? _audioStreamController;
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  
  // 音频缓冲区
  final List<int> _audioBuffer = [];
  static const int _frameSize = 960; // 60ms at 16kHz = 960 samples
  
  // 统计信息
  int _streamedFrames = 0;
  int _encodedFrames = 0;
  DateTime? _streamingStartTime;
  
  // 回调函数
  void Function(String state)? onStateChanged;
  void Function(Map<String, dynamic> stats)? onStatsUpdated;
  void Function(String error)? onError;

  AudioStreamService(this._webSocketService);

  /// 初始化音频流服务
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[$tag] 音频流服务已初始化，跳过');
      return;
    }

    try {
      print('[$tag] 初始化音频流服务');
      
      // 检查权限
      await _checkPermissions();
      
      // 如果Opus编码器尚未初始化，则初始化
      if (_opusEncoder == null) {
        await _initializeOpusEncoder();
      }
      
      // 设置录制配置
      _setupRecordConfig();
      
      // 初始化流控制器
      _initializeStreamController();
      
      _isInitialized = true;
      _currentState = AudioConstants.stateIdle;
      
      print('[$tag] 音频流服务初始化完成');
    } catch (e) {
      print('[$tag] 音频流服务初始化失败: $e');
      rethrow;
    }
  }

  /// 检查音频权限
  Future<void> _checkPermissions() async {
    try {
      // 先检查当前权限状态
      final permissions = await _permissionService.checkAudioPermissions();
      
      // 如果麦克风权限未授权，则请求权限
      if (!(permissions['microphone'] ?? false)) {
        print('[$tag] 麦克风权限未授权，尝试请求权限');
        final granted = await _permissionService.requestMicrophonePermission();
        if (!granted) {
          throw AppException.system(
            message: '需要麦克风权限才能进行音频流传输',
            code: AudioConstants.errorCodePermissionDenied.toString(),
            component: 'AudioStreamService',
            details: {'permission': 'microphone'},
          );
        }
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
        component: 'AudioStreamService',
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
    
    print('[$tag] 音频流录制配置设置完成');
    print('[$tag] 配置详情: 采样率=${AudioConstants.sampleRate}Hz, 声道=${AudioConstants.channels}, 帧大小=$_frameSize');
  }

  /// 初始化流控制器
  void _initializeStreamController() {
    _audioStreamController?.close();
    _audioStreamController = StreamController<Uint8List>.broadcast();
    
    print('[$tag] 音频流控制器初始化完成');
  }

  /// 开始音频流传输
  Future<void> startStreaming() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isStreaming) {
      print('[$tag] 音频流传输已在进行中，忽略重复请求');
      return;
    }

    try {
      print('[$tag] 开始音频流传输');
      _currentState = AudioConstants.stateRecording;
      _notifyStateChanged(_currentState);
      
      // 重置统计数据
      _streamedFrames = 0;
      _encodedFrames = 0;
      _streamingStartTime = DateTime.now();
      _audioBuffer.clear();
      
      // 发送Listen开始消息
      await _sendListenControlMessage('start');
      
      // 开始录制流
      await _startRecordingStream();
      
      _isStreaming = true;
      print('[$tag] 音频流传输开始成功');
      
      // 启动统计更新
      _startStatsUpdate();
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      _notifyStateChanged(_currentState);
      print('[$tag] 开始音频流传输失败: $e');
      _notifyError('开始音频流传输失败: $e');
      rethrow;
    }
  }

  /// 停止音频流传输
  Future<void> stopStreaming() async {
    if (!_isStreaming) {
      print('[$tag] 音频流传输未在进行中，忽略停止请求');
      return;
    }

    try {
      print('[$tag] 停止音频流传输');
      
      // 发送Listen停止消息
      await _sendListenControlMessage('stop');
      
      // 停止录制流
      await _stopRecordingStream();
      
      _isStreaming = false;
      _currentState = AudioConstants.stateIdle;
      _notifyStateChanged(_currentState);
      
      // 打印统计信息
      final duration = _streamingStartTime != null 
          ? DateTime.now().difference(_streamingStartTime!).inMilliseconds 
          : 0;
      
      print('[$tag] 音频流传输停止成功');
      print('[$tag] 传输统计: 时长=${duration}ms, 流帧数=$_streamedFrames, 编码帧数=$_encodedFrames');
      
    } catch (e) {
      _currentState = AudioConstants.stateError;
      _notifyStateChanged(_currentState);
      print('[$tag] 停止音频流传输失败: $e');
      _notifyError('停止音频流传输失败: $e');
      rethrow;
    }
  }

  /// 发送Listen控制消息
  Future<void> _sendListenControlMessage(String state) async {
    try {
      final message = {
        'type': 'listen',
        'state': state,
        'mode': 'manual',
        'audio_params': {
          'format': 'opus',
          'sample_rate': AudioConstants.sampleRate,
          'channels': AudioConstants.channels,
          'frame_duration': AudioConstants.frameDuration,
        },
      };
      
      await _webSocketService.sendMessage(message);
      print('[$tag] 发送Listen控制消息: $state');
    } catch (e) {
      print('[$tag] 发送Listen控制消息失败: $e');
      rethrow;
    }
  }

  /// 开始录制流
  Future<void> _startRecordingStream() async {
    try {
      // 检查权限
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw AppException.system(
          message: '录音权限被拒绝',
          code: AudioConstants.errorCodePermissionDenied.toString(),
          component: 'AudioStreamService',
          details: {'permission': 'microphone'},
        );
      }
      
      // 开始录制到流
      final stream = await _recorder.startStream(_recordConfig);
      
      // 监听音频流数据
      _audioStreamSubscription = stream.listen(
        _processAudioData,
        onError: (error) {
          print('[$tag] 音频流数据错误: $error');
          _notifyError('音频流数据错误: $error');
        },
        onDone: () {
          print('[$tag] 音频流数据结束');
        },
      );
      
      print('[$tag] 录制流开始成功');
    } catch (e) {
      print('[$tag] 开始录制流失败: $e');
      rethrow;
    }
  }

  /// 停止录制流
  Future<void> _stopRecordingStream() async {
    try {
      await _audioStreamSubscription?.cancel();
      await _recorder.stop();
      _audioStreamSubscription = null;
      
      print('[$tag] 录制流停止成功');
    } catch (e) {
      print('[$tag] 停止录制流失败: $e');
      rethrow;
    }
  }

  /// 处理音频数据
  void _processAudioData(Uint8List data) {
    try {
      // 将数据添加到缓冲区
      _audioBuffer.addAll(data);
      _streamedFrames++;
      
      // 检查是否有足够的数据形成一帧
      while (_audioBuffer.length >= _frameSize * 2) { // 2 bytes per sample (16-bit)
        // 提取一帧数据
        final frameData = _audioBuffer.sublist(0, _frameSize * 2);
        _audioBuffer.removeRange(0, _frameSize * 2);
        
        // 编码并发送
        _encodeAndSendFrame(Uint8List.fromList(frameData));
      }
    } catch (e) {
      print('[$tag] 处理音频数据失败: $e');
      _notifyError('处理音频数据失败: $e');
    }
  }

  /// 编码并发送音频帧
  void _encodeAndSendFrame(Uint8List frameData) {
    try {
      if (_opusEncoder == null) {
        print('[$tag] Opus编码器未初始化');
        return;
      }
      
      // 将Uint8List转换为Int16List (PCM 16-bit)
      final int16Data = Int16List(frameData.length ~/ 2);
      for (int i = 0; i < int16Data.length; i++) {
        int16Data[i] = (frameData[i * 2] | (frameData[i * 2 + 1] << 8));
      }
      
      // 编码为Opus
      final encodedData = _opusEncoder!.encode(input: int16Data);
      _encodedFrames++;
      
      // 通过WebSocket发送二进制数据
      _webSocketService.sendBinaryData(encodedData);
      
      // 更新流控制器
      _audioStreamController?.add(encodedData);
      
    } catch (e) {
      print('[$tag] 编码并发送音频帧失败: $e');
      _notifyError('编码并发送音频帧失败: $e');
    }
  }

  /// 启动统计更新
  void _startStatsUpdate() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isStreaming) {
        timer.cancel();
        return;
      }
      
      final duration = _streamingStartTime != null 
          ? DateTime.now().difference(_streamingStartTime!).inMilliseconds 
          : 0;
      
      final stats = {
        'streaming_duration': duration,
        'streamed_frames': _streamedFrames,
        'encoded_frames': _encodedFrames,
        'buffer_size': _audioBuffer.length,
        'state': _currentState,
      };
      
      _notifyStatsUpdated(stats);
    });
  }

  /// 通知状态变化
  void _notifyStateChanged(String state) {
    onStateChanged?.call(state);
  }

  /// 通知统计更新
  void _notifyStatsUpdated(Map<String, dynamic> stats) {
    onStatsUpdated?.call(stats);
  }

  /// 通知错误
  void _notifyError(String error) {
    onError?.call(error);
  }

  /// 获取当前状态
  String get currentState => _currentState;

  /// 获取流传输状态
  bool get isStreaming => _isStreaming;

  /// 获取初始化状态
  bool get isInitialized => _isInitialized;

  /// 获取音频流
  Stream<Uint8List>? get audioStream => _audioStreamController?.stream;

  /// 获取当前统计信息
  Map<String, dynamic> get currentStats {
    final duration = _streamingStartTime != null 
        ? DateTime.now().difference(_streamingStartTime!).inMilliseconds 
        : 0;
    
    return {
      'streaming_duration': duration,
      'streamed_frames': _streamedFrames,
      'encoded_frames': _encodedFrames,
      'buffer_size': _audioBuffer.length,
      'state': _currentState,
      'is_streaming': _isStreaming,
      'is_initialized': _isInitialized,
    };
  }

  /// 释放资源
  Future<void> dispose() async {
    try {
      // 停止流传输
      if (_isStreaming) {
        await stopStreaming();
      }
      
      // 取消订阅
      await _audioStreamSubscription?.cancel();
      
      // 关闭流控制器
      await _audioStreamController?.close();
      
      // 释放Opus编码器
      _opusEncoder?.destroy();
      _opusEncoder = null;
      
      // 释放录制器
      _recorder.dispose();
      
      // 清理缓冲区
      _audioBuffer.clear();
      
      _isInitialized = false;
      _isStreaming = false;
      
      print('[$tag] 音频流服务资源释放完成');
    } catch (e) {
      print('[$tag] 音频流服务资源释放失败: $e');
    }
  }
}
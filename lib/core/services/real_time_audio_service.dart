import 'dart:async';
import 'dart:typed_data';
import '../constants/audio_constants.dart';
import 'audio_stream_service.dart';
import 'audio_playback_service.dart';
import 'websocket_service.dart';
import '../utils/loggers.dart';

/// 实时音频流处理服务
/// 集成音频流传输和TTS播放功能，实现全双工音频通信
/// 支持连续音频流处理和自动状态管理
class RealTimeAudioService {
  static const String tag = 'RealTimeAudioService';

  // 依赖服务
  final AudioStreamService _streamService;
  final AudioPlaybackService _playbackService;
  final WebSocketService _webSocketService;
  
  // 服务状态
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _currentState = AudioConstants.stateIdle;
  
  // 音频流控制
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;
  Timer? _processingTimer;
  
  // 统计信息
  int _receivedFrames = 0;
  int _playedFrames = 0;
  DateTime? _streamStartTime;
  
  // 回调函数
  void Function(String state)? onStateChanged;
  void Function(Map<String, dynamic> stats)? onStatsUpdated;
  void Function(String error)? onError;
  void Function(String message)? onMessage;

  RealTimeAudioService({
    required AudioStreamService streamService,
    required AudioPlaybackService playbackService,
    required WebSocketService webSocketService,
  }) : _streamService = streamService,
       _playbackService = playbackService,
       _webSocketService = webSocketService {
    _setupWebSocketListener();
  }

  /// 初始化实时音频服务
  Future<void> initialize() async {
    if (_isInitialized) {
      Loggers.audio.fine('服务已初始化，跳过');
      return;
    }

    try {
      Loggers.audio.info('开始初始化实时音频服务');
      
      // 初始化音频流服务
      await _streamService.initialize();
      
      // 初始化音频播放服务
      await _playbackService.initialize();
      
      _isInitialized = true;
      _currentState = AudioConstants.stateIdle;
      
      Loggers.audio.info('实时音频服务初始化完成');
      onStateChanged?.call(_currentState);
      
    } catch (e) {
      Loggers.audio.severe('初始化失败', e);
      _currentState = AudioConstants.stateError;
      onStateChanged?.call(_currentState);
      onError?.call('初始化失败: $e');
      rethrow;
    }
  }

  /// 开始实时音频流处理
  Future<bool> startRealTimeProcessing() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (_isProcessing) {
        Loggers.audio.info('实时音频流处理已在进行中');
        return true;
      }

      Loggers.audio.info('开始实时音频流处理');
      
      // 启动音频流传输
      await _streamService.startStreaming();
      Loggers.audio.fine('音频流传输已启动');

      _isProcessing = true;
      _streamStartTime = DateTime.now();
      _currentState = AudioConstants.stateProcessing;
      
      // 启动处理循环
      _startProcessingLoop();
      
      onStateChanged?.call(_currentState);
      onMessage?.call('实时音频流处理已启动');
      
      Loggers.audio.info('实时音频流处理启动成功');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('启动实时音频流处理失败', e);
      _currentState = AudioConstants.stateError;
      onStateChanged?.call(_currentState);
      onError?.call('启动失败: $e');
      return false;
    }
  }

  /// 停止实时音频流处理
  Future<bool> stopRealTimeProcessing() async {
    try {
      if (!_isProcessing) {
        Loggers.audio.fine('实时音频流处理未在进行中');
        return true;
      }

      Loggers.audio.info('停止实时音频流处理');
      
      // 停止处理循环
      _stopProcessingLoop();
      
      // 停止音频流传输
      await _streamService.stopStreaming();
      
      // 停止音频播放
      await _playbackService.stopPlayback();
      
      _isProcessing = false;
      _currentState = AudioConstants.stateIdle;
      
      onStateChanged?.call(_currentState);
      onMessage?.call('实时音频流处理已停止');
      
      Loggers.audio.info('实时音频流处理停止成功');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('停止实时音频流处理失败', e);
      onError?.call('停止失败: $e');
      return false;
    }
  }

  /// 设置WebSocket监听器
  void _setupWebSocketListener() {
    _webSocketSubscription = _webSocketService.messageStream.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        Loggers.audio.severe('WebSocket监听错误: $error');
        onError?.call('WebSocket错误: $error');
      },
    );
  }

  /// 处理WebSocket消息
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    try {
      final type = message['type'] as String?;
      
      switch (type) {
        case 'tts':
          _handleTtsMessage(message);
          break;
        case 'stt':
          _handleSttMessage(message);
          break;
        case 'listen':
          _handleListenMessage(message);
          break;
        case 'error':
          _handleErrorMessage(message);
          break;
        default:
          Loggers.audio.fine('未知消息类型: $type');
      }
    } catch (e) {
      Loggers.audio.severe('处理WebSocket消息失败', e);
      onError?.call('消息处理失败: $e');
    }
  }

  /// 处理TTS消息
  void _handleTtsMessage(Map<String, dynamic> message) {
    try {
      final state = message['state'] as String?;
      final text = message['text'] as String?;
      
      Loggers.audio.fine('接收TTS消息: state=$state, text=$text');
      
      switch (state) {
        case 'start':
          onMessage?.call('开始接收TTS音频');
          break;
        case 'sentence_start':
          if (text != null) {
            onMessage?.call('TTS: $text');
          }
          break;
        case 'sentence_end':
          // 句子结束，可能需要播放音频
          break;
        case 'stop':
          onMessage?.call('TTS音频接收完成');
          break;
      }
      
    } catch (e) {
      Loggers.audio.severe('处理TTS消息失败', e);
    }
  }

  /// 处理STT消息
  void _handleSttMessage(Map<String, dynamic> message) {
    try {
      final text = message['text'] as String?;
      final confidence = message['confidence'] as double?;
      final isFinal = message['is_final'] as bool? ?? false;
      
      if (text != null) {
        Loggers.audio.fine('接收STT消息: text=$text, confidence=$confidence, final=$isFinal');
        
        if (isFinal) {
          onMessage?.call('识别结果: $text');
        } else {
          onMessage?.call('正在识别: $text');
        }
      }
      
    } catch (e) {
      Loggers.audio.severe('处理STT消息失败', e);
    }
  }

  /// 处理Listen消息
  void _handleListenMessage(Map<String, dynamic> message) {
    try {
      final state = message['state'] as String?;
      
      Loggers.audio.fine('接收Listen消息: state=$state');
      
      switch (state) {
        case 'start':
          onMessage?.call('开始语音识别');
          break;
        case 'stop':
          onMessage?.call('停止语音识别');
          break;
        case 'detect':
          onMessage?.call('检测到语音活动');
          break;
      }
      
    } catch (e) {
      Loggers.audio.severe('处理Listen消息失败', e);
    }
  }

  /// 处理错误消息
  void _handleErrorMessage(Map<String, dynamic> message) {
    try {
      final error = message['message'] as String?;
      final code = message['code'] as int?;
      
      Loggers.audio.severe('接收错误消息: error=$error, code=$code');
      
      if (error != null) {
        onError?.call('服务器错误: $error');
      }
      
    } catch (e) {
      Loggers.audio.severe('处理错误消息失败', e);
    }
  }

  /// 启动处理循环
  void _startProcessingLoop() {
    _processingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateStats();
    });
  }

  /// 停止处理循环
  void _stopProcessingLoop() {
    _processingTimer?.cancel();
    _processingTimer = null;
  }

  /// 更新统计信息
  void _updateStats() {
    if (!_isProcessing) return;

    final stats = {
      'is_processing': _isProcessing,
      'current_state': _currentState,
      'received_frames': _receivedFrames,
      'played_frames': _playedFrames,
      'stream_duration': _streamStartTime != null
          ? DateTime.now().difference(_streamStartTime!).inMilliseconds
          : 0,
      'stream_stats': _streamService.currentStats,
      'playback_stats': {}, // _playbackService.playbackStats, // Android风格音频服务不提供统计信息
    };
    
    onStatsUpdated?.call(stats);
  }

  /// 处理接收到的音频数据
  Future<void> handleReceivedAudio(Uint8List audioData) async {
    try {
      if (!_isInitialized) {
        Loggers.audio.fine('服务未初始化，忽略音频数据');
        return;
      }

      _receivedFrames++;
      
      // 将音频数据传递给播放服务（Android风格）
      await _playbackService.playOpusAudio(audioData);
      
      // Android风格的音频服务自动处理播放
      // if (!_playbackService.isPlaying) { // Android风格服务没有isPlaying属性
      //   await _playbackService.startPlayback();
        _playedFrames++;
      // }
      
    } catch (e) {
      Loggers.audio.severe('处理接收音频失败', e);
      onError?.call('音频处理失败: $e');
    }
  }

  /// 发送语音控制命令
  Future<bool> sendListenCommand(String command, {String? text}) async {
    try {
      // 检查WebSocket连接状态
      // 注意：这里我们通过发送尝试来检查连接状态，而不是直接访问state
      final message = {
        'type': 'listen',
        'state': command,
        'mode': 'auto',
        if (text != null) 'text': text,
      };

      await _webSocketService.sendMessage(message);
      Loggers.audio.fine('发送Listen命令: $command');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('发送Listen命令失败', e);
      onError?.call('发送命令失败: $e');
      return false;
    }
  }

  /// 获取当前状态
  String get currentState => _currentState;
  
  /// 是否正在处理
  bool get isProcessing => _isProcessing;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取统计信息
  Map<String, dynamic> get stats {
    return {
      'is_initialized': _isInitialized,
      'is_processing': _isProcessing,
      'current_state': _currentState,
      'received_frames': _receivedFrames,
      'played_frames': _playedFrames,
      'stream_duration': _streamStartTime != null
          ? DateTime.now().difference(_streamStartTime!).inMilliseconds
          : 0,
    };
  }

  /// 销毁服务
  Future<void> dispose() async {
    Loggers.audio.info('销毁实时音频服务');
    
    // 停止处理
    await stopRealTimeProcessing();
    
    // 取消订阅
    await _webSocketSubscription?.cancel();
    
    // 销毁依赖服务
    await _streamService.dispose();
    await _playbackService.dispose();
    
    _isInitialized = false;
    
    Loggers.audio.info('实时音频服务已销毁');
  }
}
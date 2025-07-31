import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/services/audio/audio_stream_service.dart';
import '../../core/services/websocket/websocket_service.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/common/exceptions.dart';
import '../../core/utils/loggers.dart';

/// 音频流状态
class AudioStreamState {
  final bool isStreaming;
  final bool isInitialized;
  final bool hasPermission;
  final String status;
  final String? errorMessage;
  final bool isProcessing;
  final Map<String, dynamic>? streamingStats;

  const AudioStreamState({
    required this.isStreaming,
    required this.isInitialized,
    required this.hasPermission,
    required this.status,
    this.errorMessage,
    required this.isProcessing,
    this.streamingStats,
  });

  /// 创建初始状态
  const AudioStreamState.initial()
      : isStreaming = false,
        isInitialized = false,
        hasPermission = false,
        status = AudioConstants.stateIdle,
        errorMessage = null,
        isProcessing = false,
        streamingStats = null;

  /// 创建加载状态
  const AudioStreamState.loading()
      : isStreaming = false,
        isInitialized = false,
        hasPermission = false,
        status = AudioConstants.stateProcessing,
        errorMessage = null,
        isProcessing = true,
        streamingStats = null;

  /// 创建错误状态
  const AudioStreamState.error(String message)
      : isStreaming = false,
        isInitialized = false,
        hasPermission = false,
        status = AudioConstants.stateError,
        errorMessage = message,
        isProcessing = false,
        streamingStats = null;

  /// 创建流传输状态
  const AudioStreamState.streaming(Map<String, dynamic> stats)
      : isStreaming = true,
        isInitialized = true,
        hasPermission = true,
        status = AudioConstants.stateRecording,
        errorMessage = null,
        isProcessing = false,
        streamingStats = stats;

  /// 创建准备就绪状态
  const AudioStreamState.ready()
      : isStreaming = false,
        isInitialized = true,
        hasPermission = true,
        status = AudioConstants.stateIdle,
        errorMessage = null,
        isProcessing = false,
        streamingStats = null;

  /// 复制状态
  AudioStreamState copyWith({
    bool? isStreaming,
    bool? isInitialized,
    bool? hasPermission,
    String? status,
    String? errorMessage,
    bool? isProcessing,
    Map<String, dynamic>? streamingStats,
  }) {
    return AudioStreamState(
      isStreaming: isStreaming ?? this.isStreaming,
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      streamingStats: streamingStats ?? this.streamingStats,
    );
  }

  @override
  String toString() {
    return 'AudioStreamState('
        'isStreaming: $isStreaming, '
        'isInitialized: $isInitialized, '
        'hasPermission: $hasPermission, '
        'status: $status, '
        'errorMessage: $errorMessage, '
        'isProcessing: $isProcessing, '
        'streamingStats: $streamingStats'
        ')';
  }
}

/// 音频流状态管理Notifier
class AudioStreamNotifier extends StateNotifier<AudioStreamState> {
  static const String tag = 'AudioStreamNotifier';

  final AudioStreamService _streamService;

  AudioStreamNotifier(this._streamService) : super(const AudioStreamState.initial()) {
    // 设置回调函数
    _streamService.onStateChanged = _handleStateChanged;
    _streamService.onStatsUpdated = _handleStatsUpdated;
    _streamService.onError = _handleError;
    
    // 初始化时检查权限状态
    _checkInitialPermissions();
  }

  /// 检查初始权限状态
  void _checkInitialPermissions() async {
    try {
      // 这里可以添加权限检查逻辑
      // 暂时跳过，权限检查在实际使用时进行
      state = state.copyWith(hasPermission: true);
    } catch (e) {
      Loggers.audio.severe('检查权限失败', e);
      state = AudioStreamState.error('检查权限失败');
    }
  }

  /// 初始化音频流服务
  Future<bool> initializeStreaming() async {
    try {
      state = const AudioStreamState.loading();
      
      // 初始化流服务
      await _streamService.initialize();
      
      state = const AudioStreamState.ready();
      Loggers.audio.info('音频流服务初始化成功');
      return true;
    } catch (e) {
      Loggers.audio.severe('初始化音频流服务失败', e);
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '音频流服务初始化失败';
      state = AudioStreamState.error(errorMessage);
      return false;
    }
  }

  /// 开始音频流传输
  Future<bool> startStreaming() async {
    try {
      if (!state.isInitialized) {
        final success = await initializeStreaming();
        if (!success) {
          return false;
        }
      }
      
      // 如果已经在流传输，更新UI状态
      if (_streamService.isStreaming) {
        Loggers.audio.info('音频流传输已在进行中，更新UI状态');
        final stats = _streamService.currentStats;
        state = AudioStreamState.streaming(stats);
        return true;
      }
      
      // 开始流传输
      await _streamService.startStreaming();
      
      return true;
    } catch (e) {
      Loggers.audio.severe('开始音频流传输失败', e);
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '开始音频流传输失败';
      state = AudioStreamState.error(errorMessage);
      return false;
    }
  }

  /// 停止音频流传输
  Future<bool> stopStreaming() async {
    try {
      if (!state.isStreaming) {
        Loggers.audio.fine('音频流传输未在进行中，无需停止');
        return true;
      }
      
      // 停止流传输
      await _streamService.stopStreaming();
      
      state = const AudioStreamState.ready();
      Loggers.audio.info('音频流传输停止成功');
      
      return true;
    } catch (e) {
      Loggers.audio.severe('停止音频流传输失败', e);
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '停止音频流传输失败';
      state = AudioStreamState.error(errorMessage);
      return false;
    }
  }

  /// 处理状态变化
  void _handleStateChanged(String newState) {
    Loggers.audio.info('音频流状态变化: $newState');
    
    // 根据服务状态更新UI状态
    switch (newState) {
      case AudioConstants.stateRecording:
        if (!state.isStreaming) {
          final stats = _streamService.currentStats;
          state = AudioStreamState.streaming(stats);
        }
        break;
      case AudioConstants.stateIdle:
        if (state.isStreaming) {
          state = const AudioStreamState.ready();
        }
        break;
      case AudioConstants.stateError:
        state = AudioStreamState.error('音频流传输错误');
        break;
    }
  }

  /// 处理统计信息更新
  void _handleStatsUpdated(Map<String, dynamic> stats) {
    if (state.isStreaming) {
      state = AudioStreamState.streaming(stats);
    }
  }

  /// 处理错误
  void _handleError(String error) {
    Loggers.audio.severe('音频流错误: $error');
    state = AudioStreamState.error(error);
  }

  /// 获取当前状态描述
  String get statusDescription {
    switch (state.status) {
      case AudioConstants.stateIdle:
        return '音频流服务准备就绪';
      case AudioConstants.stateRecording:
        return '正在进行音频流传输...';
      case AudioConstants.stateProcessing:
        return '正在处理...';
      case AudioConstants.stateError:
        return state.errorMessage ?? '音频流服务错误';
      default:
        return '未知状态';
    }
  }

  /// 获取流传输时长（毫秒）
  int get streamingDuration {
    return state.streamingStats?['streaming_duration'] ?? 0;
  }

  /// 获取流传输帧数
  int get streamedFrames {
    return state.streamingStats?['streamed_frames'] ?? 0;
  }

  /// 获取编码帧数
  int get encodedFrames {
    return state.streamingStats?['encoded_frames'] ?? 0;
  }

  /// 获取缓冲区大小
  int get bufferSize {
    return state.streamingStats?['buffer_size'] ?? 0;
  }

  /// 重置状态
  void reset() {
    state = const AudioStreamState.initial();
    _checkInitialPermissions();
  }

  /// 重新初始化
  Future<void> reinitialize() async {
    reset();
    await initializeStreaming();
  }

  /// 清理资源
  @override
  void dispose() {
    _streamService.dispose();
    super.dispose();
  }
}

/// 音频流传输服务Provider
final audioStreamServiceProvider = Provider<AudioStreamService>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider.notifier);
  final service = AudioStreamService(webSocketService);
  
  // 在Provider被销毁时清理资源
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// 音频流状态Provider
final audioStreamProvider = StateNotifierProvider<AudioStreamNotifier, AudioStreamState>((ref) {
  final streamService = ref.watch(audioStreamServiceProvider);
  
  final notifier = AudioStreamNotifier(streamService);
  
  ref.onDispose(() {
    notifier.dispose();
  });
  
  return notifier;
});

/// 音频流状态快捷访问Provider
final audioStreamStateProvider = Provider<AudioStreamState>((ref) {
  return ref.watch(audioStreamProvider);
});

/// 音频流传输状态Provider
final audioStreamActiveProvider = Provider<bool>((ref) {
  return ref.watch(audioStreamProvider).isStreaming;
});

/// 音频流初始化状态Provider
final audioStreamInitializedProvider = Provider<bool>((ref) {
  return ref.watch(audioStreamProvider).isInitialized;
});

/// 音频流错误状态Provider
final audioStreamErrorProvider = Provider<String?>((ref) {
  return ref.watch(audioStreamProvider).errorMessage;
});

/// 音频流统计信息Provider
final audioStreamStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(audioStreamProvider).streamingStats;
});
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:typed_data';
import '../../core/services/audio_playback_service.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/exceptions.dart';

/// 音频播放状态
class AudioPlaybackState {
  final bool isPlaying;
  final bool isInitialized;
  final String status;
  final String? errorMessage;
  final bool isProcessing;
  final Map<String, dynamic>? playbackStats;
  final Duration currentPosition;
  final Duration totalDuration;

  const AudioPlaybackState({
    required this.isPlaying,
    required this.isInitialized,
    required this.status,
    this.errorMessage,
    required this.isProcessing,
    this.playbackStats,
    required this.currentPosition,
    required this.totalDuration,
  });

  /// 创建初始状态
  const AudioPlaybackState.initial()
      : isPlaying = false,
        isInitialized = false,
        status = AudioConstants.stateIdle,
        errorMessage = null,
        isProcessing = false,
        playbackStats = null,
        currentPosition = Duration.zero,
        totalDuration = Duration.zero;

  /// 创建加载状态
  const AudioPlaybackState.loading()
      : isPlaying = false,
        isInitialized = false,
        status = AudioConstants.stateProcessing,
        errorMessage = null,
        isProcessing = true,
        playbackStats = null,
        currentPosition = Duration.zero,
        totalDuration = Duration.zero;

  /// 创建错误状态
  const AudioPlaybackState.error(String message)
      : isPlaying = false,
        isInitialized = false,
        status = AudioConstants.stateError,
        errorMessage = message,
        isProcessing = false,
        playbackStats = null,
        currentPosition = Duration.zero,
        totalDuration = Duration.zero;

  /// 创建就绪状态
  const AudioPlaybackState.ready()
      : isPlaying = false,
        isInitialized = true,
        status = AudioConstants.stateIdle,
        errorMessage = null,
        isProcessing = false,
        playbackStats = null,
        currentPosition = Duration.zero,
        totalDuration = Duration.zero;

  /// 复制状态
  AudioPlaybackState copyWith({
    bool? isPlaying,
    bool? isInitialized,
    String? status,
    String? errorMessage,
    bool? isProcessing,
    Map<String, dynamic>? playbackStats,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return AudioPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      playbackStats: playbackStats ?? this.playbackStats,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  @override
  String toString() {
    return 'AudioPlaybackState('
        'isPlaying: $isPlaying, '
        'isInitialized: $isInitialized, '
        'status: $status, '
        'errorMessage: $errorMessage, '
        'isProcessing: $isProcessing, '
        'playbackStats: $playbackStats, '
        'currentPosition: $currentPosition, '
        'totalDuration: $totalDuration'
        ')';
  }
}

/// 音频播放状态管理Notifier
class AudioPlaybackNotifier extends StateNotifier<AudioPlaybackState> {
  static const String tag = 'AudioPlaybackNotifier';

  final AudioPlaybackService _playbackService;

  AudioPlaybackNotifier(this._playbackService) : super(const AudioPlaybackState.initial()) {
    // 设置回调函数
    _playbackService.onStateChanged = _handleStateChanged;
    _playbackService.onStatsUpdated = _handleStatsUpdated;
    _playbackService.onError = _handleError;
    _playbackService.onPositionChanged = _handlePositionChanged;
  }

  /// 初始化音频播放服务
  Future<bool> initializePlayback() async {
    try {
      state = const AudioPlaybackState.loading();
      
      // 初始化播放服务
      await _playbackService.initialize();
      
      state = const AudioPlaybackState.ready();
      print('[$tag] 音频播放服务初始化成功');
      return true;
      
    } catch (e) {
      print('[$tag] 初始化音频播放服务失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '音频播放服务初始化失败';
      state = AudioPlaybackState.error(errorMessage);
      return false;
    }
  }

  /// 接收TTS音频数据
  Future<bool> receiveTtsAudio(List<int> opusData) async {
    try {
      if (!state.isInitialized) {
        final success = await initializePlayback();
        if (!success) {
          return false;
        }
      }

      // 转换数据格式
      final audioData = Uint8List.fromList(opusData);
      
      // 发送到播放服务
      await _playbackService.receiveTtsAudio(audioData);
      
      print('[$tag] 接收TTS音频数据成功: ${opusData.length} 字节');
      return true;
      
    } catch (e) {
      print('[$tag] 接收TTS音频数据失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '接收TTS音频数据失败';
      state = state.copyWith(errorMessage: errorMessage);
      return false;
    }
  }

  /// 开始播放TTS音频
  Future<bool> startPlayback() async {
    try {
      if (!state.isInitialized) {
        final success = await initializePlayback();
        if (!success) {
          return false;
        }
      }

      final success = await _playbackService.startPlayback();
      if (success) {
        print('[$tag] 开始播放TTS音频成功');
      } else {
        print('[$tag] 开始播放TTS音频失败');
      }
      return success;
      
    } catch (e) {
      print('[$tag] 开始播放TTS音频失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '开始播放失败';
      state = state.copyWith(errorMessage: errorMessage);
      return false;
    }
  }

  /// 停止播放TTS音频
  Future<bool> stopPlayback() async {
    try {
      final success = await _playbackService.stopPlayback();
      if (success) {
        print('[$tag] 停止播放TTS音频成功');
      } else {
        print('[$tag] 停止播放TTS音频失败');
      }
      return success;
      
    } catch (e) {
      print('[$tag] 停止播放TTS音频失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '停止播放失败';
      state = state.copyWith(errorMessage: errorMessage);
      return false;
    }
  }

  /// 暂停播放
  Future<bool> pausePlayback() async {
    try {
      final success = await _playbackService.pausePlayback();
      if (success) {
        print('[$tag] 暂停播放成功');
      }
      return success;
      
    } catch (e) {
      print('[$tag] 暂停播放失败: $e');
      return false;
    }
  }

  /// 恢复播放
  Future<bool> resumePlayback() async {
    try {
      final success = await _playbackService.resumePlayback();
      if (success) {
        print('[$tag] 恢复播放成功');
      }
      return success;
      
    } catch (e) {
      print('[$tag] 恢复播放失败: $e');
      return false;
    }
  }

  /// 清空缓冲区
  void clearBuffer() {
    _playbackService.clearBuffer();
    print('[$tag] 音频缓冲区已清空');
  }

  /// 重置播放状态
  void reset() {
    state = const AudioPlaybackState.initial();
    clearBuffer();
    print('[$tag] 播放状态已重置');
  }

  /// 处理状态变化
  void _handleStateChanged(String newState) {
    print('[$tag] 播放状态变化: $newState');
    state = state.copyWith(
      status: newState,
      isPlaying: newState == AudioConstants.stateRecording,
    );
  }

  /// 处理统计信息更新
  void _handleStatsUpdated(Map<String, dynamic> stats) {
    print('[$tag] 播放统计更新: $stats');
    state = state.copyWith(playbackStats: stats);
  }

  /// 处理错误
  void _handleError(String error) {
    print('[$tag] 播放错误: $error');
    state = state.copyWith(
      errorMessage: error,
      status: AudioConstants.stateError,
    );
  }

  /// 处理位置变化
  void _handlePositionChanged(Duration position, Duration duration) {
    state = state.copyWith(
      currentPosition: position,
      totalDuration: duration,
    );
  }

  /// 获取当前播放时长
  int get playbackDuration {
    return state.playbackStats?['playback_duration'] ?? 0;
  }

  /// 获取状态描述
  String get statusDescription {
    switch (state.status) {
      case AudioConstants.stateIdle:
        return state.isInitialized ? '准备就绪' : '未初始化';
      case AudioConstants.stateRecording:
        return '播放中';
      case AudioConstants.stateProcessing:
        return '处理中';
      case AudioConstants.stateError:
        return '错误';
      default:
        return '未知状态';
    }
  }

  @override
  void dispose() {
    _playbackService.dispose();
    super.dispose();
  }
}

/// 音频播放服务提供者
final audioPlaybackServiceProvider = Provider<AudioPlaybackService>((ref) {
  return AudioPlaybackService();
});

/// 音频播放状态提供者
final audioPlaybackProvider = StateNotifierProvider<AudioPlaybackNotifier, AudioPlaybackState>((ref) {
  final playbackService = ref.watch(audioPlaybackServiceProvider);
  return AudioPlaybackNotifier(playbackService);
});
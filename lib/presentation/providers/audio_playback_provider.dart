import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:typed_data';
// import '../../core/services/audio_playback_service.dart'; // 使用Android风格实现
import '../../core/services/audio_service_android_style.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
import '../../core/utils/loggers.dart';

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

  final AudioServiceAndroidStyle _playbackService;

  AudioPlaybackNotifier(this._playbackService) : super(const AudioPlaybackState.initial()) {
    // Android风格的音频服务不使用回调函数
    // 直接使用同步调用方式
  }

  /// 初始化音频播放服务
  Future<bool> initializePlayback() async {
    try {
      state = const AudioPlaybackState.loading();
      
      // 初始化播放服务（Android风格音频服务不需要明确初始化）
      // await _playbackService.initialize();
      
      state = const AudioPlaybackState.ready();
      Loggers.audio.info('音频播放服务初始化成功');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('初始化音频播放服务失败', e);
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
      
      // 直接播放音频数据（Android风格）
      await _playbackService.playOpusAudio(audioData);
      
      Loggers.audio.fine('接收TTS音频数据成功: ${opusData.length} 字节');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('接收TTS音频数据失败', e);
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

      // Android风格的音频服务不需要单独启动播放
      Loggers.audio.fine('Android风格音频服务自动管理播放');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('开始播放TTS音频失败', e);
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
      // Android风格的音频服务自动管理停止
      Loggers.audio.fine('Android风格音频服务自动管理停止');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('停止播放TTS音频失败', e);
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
      // Android风格的音频服务不支持暂停操作
      Loggers.audio.fine('Android风格音频服务不支持暂停');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('暂停播放失败', e);
      return false;
    }
  }

  /// 恢复播放
  Future<bool> resumePlayback() async {
    try {
      // Android风格的音频服务不支持恢复操作
      Loggers.audio.fine('Android风格音频服务不支持恢复');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('恢复播放失败', e);
      return false;
    }
  }

  /// 清空缓冲区
  void clearBuffer() {
    // Android风格的音频服务不需要手动清理缓冲区
    Loggers.audio.fine('Android风格音频服务自动管理缓冲区');
  }

  /// 重置播放状态
  void reset() {
    state = const AudioPlaybackState.initial();
    clearBuffer();
    Loggers.audio.info('播放状态已重置');
  }

  // 已删除未使用的回调处理方法（Android风格音频服务不使用回调）

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
    // 使用Future处理dispose的异步操作
    Future.microtask(() async {
      await _playbackService.dispose();
    });
    super.dispose();
  }
}

/// 音频播放服务提供者
final audioPlaybackServiceProvider = Provider<AudioServiceAndroidStyle>((ref) {
  return AudioServiceAndroidStyle();
});

/// 音频播放状态提供者
final audioPlaybackProvider = StateNotifierProvider<AudioPlaybackNotifier, AudioPlaybackState>((ref) {
  final playbackService = ref.watch(audioPlaybackServiceProvider);
  return AudioPlaybackNotifier(playbackService);
});
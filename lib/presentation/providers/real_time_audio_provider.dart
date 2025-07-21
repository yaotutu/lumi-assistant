import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/services/real_time_audio_service.dart';
// import '../../core/services/websocket_service.dart'; // 暂未使用
import '../../core/constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
// import 'audio_stream_provider.dart'; // 暂未使用
// import 'audio_playback_provider.dart'; // 暂未使用

/// 实时音频流处理状态
class RealTimeAudioState {
  final bool isInitialized;
  final bool isProcessing;
  final String currentState;
  final String? errorMessage;
  final Map<String, dynamic>? stats;
  final List<String> messages;
  final int receivedFrames;
  final int playedFrames;
  final int streamDuration;

  const RealTimeAudioState({
    required this.isInitialized,
    required this.isProcessing,
    required this.currentState,
    this.errorMessage,
    this.stats,
    required this.messages,
    required this.receivedFrames,
    required this.playedFrames,
    required this.streamDuration,
  });

  /// 创建初始状态
  const RealTimeAudioState.initial()
      : isInitialized = false,
        isProcessing = false,
        currentState = AudioConstants.stateIdle,
        errorMessage = null,
        stats = null,
        messages = const [],
        receivedFrames = 0,
        playedFrames = 0,
        streamDuration = 0;

  /// 创建加载状态
  const RealTimeAudioState.loading()
      : isInitialized = false,
        isProcessing = false,
        currentState = AudioConstants.stateProcessing,
        errorMessage = null,
        stats = null,
        messages = const [],
        receivedFrames = 0,
        playedFrames = 0,
        streamDuration = 0;

  /// 创建错误状态
  const RealTimeAudioState.error(String message)
      : isInitialized = false,
        isProcessing = false,
        currentState = AudioConstants.stateError,
        errorMessage = message,
        stats = null,
        messages = const [],
        receivedFrames = 0,
        playedFrames = 0,
        streamDuration = 0;

  /// 创建就绪状态
  const RealTimeAudioState.ready()
      : isInitialized = true,
        isProcessing = false,
        currentState = AudioConstants.stateIdle,
        errorMessage = null,
        stats = null,
        messages = const [],
        receivedFrames = 0,
        playedFrames = 0,
        streamDuration = 0;

  /// 复制状态
  RealTimeAudioState copyWith({
    bool? isInitialized,
    bool? isProcessing,
    String? currentState,
    String? errorMessage,
    Map<String, dynamic>? stats,
    List<String>? messages,
    int? receivedFrames,
    int? playedFrames,
    int? streamDuration,
  }) {
    return RealTimeAudioState(
      isInitialized: isInitialized ?? this.isInitialized,
      isProcessing: isProcessing ?? this.isProcessing,
      currentState: currentState ?? this.currentState,
      errorMessage: errorMessage ?? this.errorMessage,
      stats: stats ?? this.stats,
      messages: messages ?? this.messages,
      receivedFrames: receivedFrames ?? this.receivedFrames,
      playedFrames: playedFrames ?? this.playedFrames,
      streamDuration: streamDuration ?? this.streamDuration,
    );
  }

  @override
  String toString() {
    return 'RealTimeAudioState('
        'isInitialized: $isInitialized, '
        'isProcessing: $isProcessing, '
        'currentState: $currentState, '
        'errorMessage: $errorMessage, '
        'messages: ${messages.length}, '
        'receivedFrames: $receivedFrames, '
        'playedFrames: $playedFrames, '
        'streamDuration: $streamDuration'
        ')';
  }
}

/// 实时音频流处理状态管理Notifier
class RealTimeAudioNotifier extends StateNotifier<RealTimeAudioState> {
  static const String tag = 'RealTimeAudioNotifier';

  final RealTimeAudioService _audioService;

  RealTimeAudioNotifier(this._audioService) : super(const RealTimeAudioState.initial()) {
    // 设置回调函数
    _audioService.onStateChanged = _handleStateChanged;
    _audioService.onStatsUpdated = _handleStatsUpdated;
    _audioService.onError = _handleError;
    _audioService.onMessage = _handleMessage;
  }

  /// 初始化实时音频服务
  Future<bool> initialize() async {
    try {
      state = const RealTimeAudioState.loading();
      
      // 初始化音频服务
      await _audioService.initialize();
      
      state = const RealTimeAudioState.ready();
      print('[$tag] 实时音频服务初始化成功');
      return true;
      
    } catch (e) {
      print('[$tag] 初始化实时音频服务失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '实时音频服务初始化失败';
      state = RealTimeAudioState.error(errorMessage);
      return false;
    }
  }

  /// 开始实时音频流处理
  Future<bool> startProcessing() async {
    try {
      if (!state.isInitialized) {
        final success = await initialize();
        if (!success) {
          return false;
        }
      }

      final success = await _audioService.startRealTimeProcessing();
      if (success) {
        print('[$tag] 开始实时音频流处理成功');
      } else {
        print('[$tag] 开始实时音频流处理失败');
      }
      return success;
      
    } catch (e) {
      print('[$tag] 开始实时音频流处理失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '开始处理失败';
      state = state.copyWith(errorMessage: errorMessage);
      return false;
    }
  }

  /// 停止实时音频流处理
  Future<bool> stopProcessing() async {
    try {
      final success = await _audioService.stopRealTimeProcessing();
      if (success) {
        print('[$tag] 停止实时音频流处理成功');
      } else {
        print('[$tag] 停止实时音频流处理失败');
      }
      return success;
      
    } catch (e) {
      print('[$tag] 停止实时音频流处理失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '停止处理失败';
      state = state.copyWith(errorMessage: errorMessage);
      return false;
    }
  }

  /// 发送语音控制命令
  Future<bool> sendListenCommand(String command, {String? text}) async {
    try {
      final success = await _audioService.sendListenCommand(command, text: text);
      if (success) {
        print('[$tag] 发送Listen命令成功: $command');
      } else {
        print('[$tag] 发送Listen命令失败: $command');
      }
      return success;
      
    } catch (e) {
      print('[$tag] 发送Listen命令失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '发送命令失败';
      state = state.copyWith(errorMessage: errorMessage);
      return false;
    }
  }

  /// 清空消息列表
  void clearMessages() {
    state = state.copyWith(messages: []);
    print('[$tag] 消息列表已清空');
  }

  /// 重置状态
  void reset() {
    state = const RealTimeAudioState.initial();
    print('[$tag] 状态已重置');
  }

  /// 处理状态变化
  void _handleStateChanged(String newState) {
    print('[$tag] 状态变化: $newState');
    
    final isProcessing = newState == AudioConstants.stateProcessing || 
                        newState == AudioConstants.stateRecording;
    
    state = state.copyWith(
      currentState: newState,
      isProcessing: isProcessing,
    );
  }

  /// 处理统计信息更新
  void _handleStatsUpdated(Map<String, dynamic> stats) {
    print('[$tag] 统计信息更新: $stats');
    
    state = state.copyWith(
      stats: stats,
      receivedFrames: stats['received_frames'] as int? ?? 0,
      playedFrames: stats['played_frames'] as int? ?? 0,
      streamDuration: stats['stream_duration'] as int? ?? 0,
    );
  }

  /// 处理错误
  void _handleError(String error) {
    print('[$tag] 错误: $error');
    
    final newMessages = List<String>.from(state.messages);
    newMessages.add('[错误] $error');
    
    state = state.copyWith(
      errorMessage: error,
      currentState: AudioConstants.stateError,
      messages: newMessages,
    );
  }

  /// 处理消息
  void _handleMessage(String message) {
    print('[$tag] 消息: $message');
    
    final newMessages = List<String>.from(state.messages);
    newMessages.add('[${DateTime.now().toString().substring(11, 19)}] $message');
    
    // 限制消息数量
    if (newMessages.length > 50) {
      newMessages.removeAt(0);
    }
    
    state = state.copyWith(messages: newMessages);
  }

  /// 获取当前处理时长
  int get processingDuration {
    return state.streamDuration;
  }

  /// 获取状态描述
  String get statusDescription {
    switch (state.currentState) {
      case AudioConstants.stateIdle:
        return state.isInitialized ? '准备就绪' : '未初始化';
      case AudioConstants.stateProcessing:
        return '处理中';
      case AudioConstants.stateRecording:
        return '录制中';
      case AudioConstants.stateError:
        return '错误';
      default:
        return '未知状态';
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

/// 实时音频服务提供者
final realTimeAudioServiceProvider = Provider<RealTimeAudioService>((ref) {
  // final streamService = ref.watch(audioStreamServiceProvider); // 暂未使用
  // final playbackService = ref.watch(audioPlaybackServiceProvider); // 暂未使用
  // final webSocketService = ref.watch(webSocketServiceProvider.notifier); // 暂未使用
  
  // 临时跳过RealTimeAudioService，因为类型不匹配
  // 需要重构RealTimeAudioService以支持Android风格音频服务
  throw UnimplementedError('RealTimeAudioService需要重构以支持Android风格音频服务');
  
  /*return RealTimeAudioService(
    streamService: streamService,
    playbackService: playbackService, // 类型不匹配：需要AudioPlaybackService但得到AudioServiceAndroidStyle
    webSocketService: webSocketService,
  );*/
});

/// 实时音频状态提供者
final realTimeAudioProvider = StateNotifierProvider<RealTimeAudioNotifier, RealTimeAudioState>((ref) {
  final audioService = ref.watch(realTimeAudioServiceProvider);
  return RealTimeAudioNotifier(audioService);
});
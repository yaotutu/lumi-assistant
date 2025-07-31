import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:typed_data';
import '../../core/services/audio/audio_recording_service.dart';
import '../../core/services/device/permission_service.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/exceptions.dart';
import '../../core/utils/loggers.dart';

/// 音频录制状态
class AudioRecordingState {
  final bool isRecording;
  final bool isInitialized;
  final bool hasPermission;
  final String status;
  final String? errorMessage;
  final bool isProcessing;
  final Map<String, dynamic>? recordingStats;

  const AudioRecordingState({
    required this.isRecording,
    required this.isInitialized,
    required this.hasPermission,
    required this.status,
    this.errorMessage,
    required this.isProcessing,
    this.recordingStats,
  });

  /// 创建初始状态
  const AudioRecordingState.initial()
      : isRecording = false,
        isInitialized = false,
        hasPermission = false,
        status = AudioConstants.stateIdle,
        errorMessage = null,
        isProcessing = false,
        recordingStats = null;

  /// 创建加载状态
  const AudioRecordingState.loading()
      : isRecording = false,
        isInitialized = false,
        hasPermission = false,
        status = AudioConstants.stateProcessing,
        errorMessage = null,
        isProcessing = true,
        recordingStats = null;

  /// 创建错误状态
  const AudioRecordingState.error(String message)
      : isRecording = false,
        isInitialized = false,
        hasPermission = false,
        status = AudioConstants.stateError,
        errorMessage = message,
        isProcessing = false,
        recordingStats = null;

  /// 创建录制状态
  const AudioRecordingState.recording(Map<String, dynamic> stats)
      : isRecording = true,
        isInitialized = true,
        hasPermission = true,
        status = AudioConstants.stateRecording,
        errorMessage = null,
        isProcessing = false,
        recordingStats = stats;

  /// 创建准备就绪状态
  const AudioRecordingState.ready()
      : isRecording = false,
        isInitialized = true,
        hasPermission = true,
        status = AudioConstants.stateIdle,
        errorMessage = null,
        isProcessing = false,
        recordingStats = null;

  /// 复制状态
  AudioRecordingState copyWith({
    bool? isRecording,
    bool? isInitialized,
    bool? hasPermission,
    String? status,
    String? errorMessage,
    bool? isProcessing,
    Map<String, dynamic>? recordingStats,
  }) {
    return AudioRecordingState(
      isRecording: isRecording ?? this.isRecording,
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      recordingStats: recordingStats ?? this.recordingStats,
    );
  }

  @override
  String toString() {
    return 'AudioRecordingState('
        'isRecording: $isRecording, '
        'isInitialized: $isInitialized, '
        'hasPermission: $hasPermission, '
        'status: $status, '
        'errorMessage: $errorMessage, '
        'isProcessing: $isProcessing, '
        'recordingStats: $recordingStats'
        ')';
  }
}

/// 音频录制状态管理Notifier
class AudioRecordingNotifier extends StateNotifier<AudioRecordingState> {
  static const String tag = 'AudioRecordingNotifier';

  final AudioRecordingService _recordingService;
  final PermissionService _permissionService;

  AudioRecordingNotifier(this._recordingService, this._permissionService)
      : super(const AudioRecordingState.initial()) {
    // 初始化时检查权限状态
    _checkInitialPermissions();
  }

  /// 检查初始权限状态
  void _checkInitialPermissions() {
    _checkPermissions();
  }

  /// 检查权限状态
  Future<void> _checkPermissions() async {
    try {
      final permissions = await _permissionService.checkAudioPermissions();
      final hasPermission = permissions['microphone'] ?? false;
      
      if (hasPermission) {
        state = state.copyWith(
          hasPermission: true,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          hasPermission: false,
          errorMessage: '需要麦克风权限才能进行录音',
        );
      }
    } catch (e) {
      Loggers.audio.severe('检查权限失败', e);
      state = AudioRecordingState.error('检查权限失败');
    }
  }

  /// 请求录制权限
  Future<bool> requestPermissions() async {
    try {
      state = const AudioRecordingState.loading();
      
      final permissions = await _permissionService.requestAudioPermissions();
      final hasPermission = permissions['microphone'] ?? false;
      
      if (hasPermission) {
        state = state.copyWith(
          hasPermission: true,
          isProcessing: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = AudioRecordingState.error('录音权限被拒绝');
        return false;
      }
    } catch (e) {
      Loggers.audio.severe('请求权限失败', e);
      state = AudioRecordingState.error('请求权限失败');
      return false;
    }
  }

  /// 初始化录制服务
  Future<bool> initializeRecording() async {
    try {
      state = const AudioRecordingState.loading();
      
      // 先检查权限
      if (!state.hasPermission) {
        final hasPermission = await requestPermissions();
        if (!hasPermission) {
          return false;
        }
      }
      
      // 初始化录制服务
      await _recordingService.initialize();
      
      state = const AudioRecordingState.ready();
      Loggers.audio.info('录制服务初始化成功');
      return true;
    } catch (e) {
      Loggers.audio.severe('初始化录制服务失败', e);
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '录制服务初始化失败';
      state = AudioRecordingState.error(errorMessage);
      return false;
    }
  }

  /// 开始录制
  Future<bool> startRecording() async {
    try {
      if (!state.isInitialized) {
        final success = await initializeRecording();
        if (!success) {
          return false;
        }
      }
      
      // 如果已经在录制，直接返回成功
      if (_recordingService.isRecording) {
        Loggers.audio.info('录制已在进行中，更新UI状态');
        Loggers.audio.fine('录制服务状态: isRecording=${_recordingService.isRecording}');
        // 强制更新状态到录制中
        final stats = _recordingService.recordingStats;
        Loggers.audio.fine('录制统计信息: $stats');
        state = AudioRecordingState.recording(stats);
        Loggers.audio.fine('UI状态已更新为录制中: ${state.isRecording}');
        _updateRecordingStats();
        return true;
      }
      
      // 开始录制
      await _recordingService.startRecording();
      
      // 立即更新状态到录制中
      final stats = _recordingService.recordingStats;
      state = AudioRecordingState.recording(stats);
      
      // 启动定时器获取统计信息
      _updateRecordingStats();
      
      return true;
    } catch (e) {
      Loggers.audio.severe('开始录制失败', e);
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '开始录制失败';
      state = AudioRecordingState.error(errorMessage);
      return false;
    }
  }

  /// 停止录制并返回编码后的Opus帧列表
  Future<List<Uint8List>?> stopRecording() async {
    try {
      if (!state.isRecording) {
        Loggers.audio.fine('录制未在进行中，无需停止');
        return null;
      }
      
      state = state.copyWith(
        isProcessing: true,
        status: AudioConstants.stateProcessing,
      );
      
      // 停止录制
      await _recordingService.stopRecording();
      
      // 处理录制的文件并获取Opus帧列表
      final opusFrames = await _recordingService.processRecordedFile();
      
      state = const AudioRecordingState.ready();
      Loggers.audio.info('录制停止成功，获得Opus帧数: ${opusFrames.length}');
      
      return opusFrames;
    } catch (e) {
      Loggers.audio.severe('停止录制失败', e);
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '停止录制失败';
      state = AudioRecordingState.error(errorMessage);
      return null;
    }
  }

  /// 更新录制统计信息
  void _updateRecordingStats() {
    // 检查录制服务是否真的在录制
    if (!_recordingService.isRecording) {
      Loggers.audio.fine('录制服务未在录制，停止更新统计信息');
      return;
    }
    
    final stats = _recordingService.recordingStats;
    state = AudioRecordingState.recording(stats);
    
    // 如果还在录制，继续更新统计信息
    if (_recordingService.isRecording) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _updateRecordingStats();
      });
    }
  }

  /// 获取当前状态描述
  String get statusDescription {
    switch (state.status) {
      case AudioConstants.stateIdle:
        return '录制服务准备就绪';
      case AudioConstants.stateRecording:
        return '正在录制...';
      case AudioConstants.stateProcessing:
        return '正在处理...';
      case AudioConstants.stateError:
        return state.errorMessage ?? '录制服务错误';
      default:
        return '未知状态';
    }
  }

  /// 获取录制时长（毫秒）
  int get recordingDuration {
    return state.recordingStats?['recordingDuration'] ?? 0;
  }

  /// 获取录制帧数
  int get recordedFrames {
    return state.recordingStats?['recordedFrames'] ?? 0;
  }

  /// 获取编码帧数
  int get encodedFrames {
    return state.recordingStats?['encodedFrames'] ?? 0;
  }

  /// 重置状态
  void reset() {
    state = const AudioRecordingState.initial();
    _checkInitialPermissions();
  }

  /// 重新初始化
  Future<void> reinitialize() async {
    reset();
    await initializeRecording();
  }

  /// 清理资源
  @override
  void dispose() {
    _recordingService.dispose();
    super.dispose();
  }
}

/// 音频录制服务Provider
final audioRecordingServiceProvider = Provider<AudioRecordingService>((ref) {
  final service = AudioRecordingService();
  
  // 在Provider被销毁时清理资源
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// 音频录制状态Provider
final audioRecordingProvider = StateNotifierProvider<AudioRecordingNotifier, AudioRecordingState>((ref) {
  final recordingService = ref.watch(audioRecordingServiceProvider);
  final permissionService = PermissionService();
  
  final notifier = AudioRecordingNotifier(recordingService, permissionService);
  
  ref.onDispose(() {
    notifier.dispose();
  });
  
  return notifier;
});

/// 音频录制状态快捷访问Provider
final audioRecordingStateProvider = Provider<AudioRecordingState>((ref) {
  return ref.watch(audioRecordingProvider);
});

/// 录制权限状态Provider
final recordingPermissionProvider = Provider<bool>((ref) {
  return ref.watch(audioRecordingProvider).hasPermission;
});

/// 录制初始化状态Provider
final recordingInitializedProvider = Provider<bool>((ref) {
  return ref.watch(audioRecordingProvider).isInitialized;
});

/// 录制中状态Provider
final recordingActiveProvider = Provider<bool>((ref) {
  return ref.watch(audioRecordingProvider).isRecording;
});

/// 录制错误状态Provider
final recordingErrorProvider = Provider<String?>((ref) {
  return ref.watch(audioRecordingProvider).errorMessage;
});

/// 录制统计信息Provider
final recordingStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(audioRecordingProvider).recordingStats;
});
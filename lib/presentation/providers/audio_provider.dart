import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:typed_data';
import '../../core/services/audio_service.dart';
import '../../core/services/audio_service_android_style.dart';
import '../../core/services/permission_service.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/exceptions.dart';

/// 音频状态管理Provider
/// 负责管理音频播放状态、权限请求和用户交互
class AudioState {
  final String status;
  final bool isInitialized;
  final bool hasPermission;
  final String? errorMessage;
  final bool isPlaying;
  final bool isLoading;

  const AudioState({
    required this.status,
    required this.isInitialized,
    required this.hasPermission,
    this.errorMessage,
    required this.isPlaying,
    required this.isLoading,
  });

  /// 创建初始状态
  const AudioState.initial()
      : status = AudioConstants.stateIdle,
        isInitialized = false,
        hasPermission = false,
        errorMessage = null,
        isPlaying = false,
        isLoading = false;

  /// 创建加载状态
  const AudioState.loading()
      : status = AudioConstants.stateProcessing,
        isInitialized = false,
        hasPermission = false,
        errorMessage = null,
        isPlaying = false,
        isLoading = true;

  /// 创建错误状态
  const AudioState.error(String message)
      : status = AudioConstants.stateError,
        isInitialized = false,
        hasPermission = false,
        errorMessage = message,
        isPlaying = false,
        isLoading = false;

  /// 创建准备就绪状态
  const AudioState.ready()
      : status = AudioConstants.stateIdle,
        isInitialized = true,
        hasPermission = true,
        errorMessage = null,
        isPlaying = false,
        isLoading = false;

  /// 创建播放状态
  const AudioState.playing()
      : status = AudioConstants.statePlaying,
        isInitialized = true,
        hasPermission = true,
        errorMessage = null,
        isPlaying = true,
        isLoading = false;

  /// 复制状态
  AudioState copyWith({
    String? status,
    bool? isInitialized,
    bool? hasPermission,
    String? errorMessage,
    bool? isPlaying,
    bool? isLoading,
  }) {
    return AudioState(
      status: status ?? this.status,
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      errorMessage: errorMessage ?? this.errorMessage,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() {
    return 'AudioState('
        'status: $status, '
        'isInitialized: $isInitialized, '
        'hasPermission: $hasPermission, '
        'errorMessage: $errorMessage, '
        'isPlaying: $isPlaying, '
        'isLoading: $isLoading'
        ')';
  }
}

/// 音频状态管理Notifier
class AudioNotifier extends StateNotifier<AudioState> {
  static const String tag = 'AudioNotifier';

  final AudioService _audioService;
  final PermissionService _permissionService;

  AudioNotifier(this._audioService, this._permissionService) 
      : super(const AudioState.initial()) {
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
          errorMessage: '需要麦克风权限才能使用语音功能',
        );
      }
    } catch (e) {
      print('[$tag] 检查权限失败: $e');
      state = AudioState.error('检查权限失败');
    }
  }

  /// 请求音频权限
  Future<bool> requestPermissions() async {
    try {
      state = const AudioState.loading();
      
      final permissions = await _permissionService.requestAudioPermissions();
      final hasPermission = permissions['microphone'] ?? false;
      
      if (hasPermission) {
        state = state.copyWith(
          hasPermission: true,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = AudioState.error('权限被拒绝，无法使用语音功能');
        return false;
      }
    } catch (e) {
      print('[$tag] 请求权限失败: $e');
      state = AudioState.error('请求权限失败');
      return false;
    }
  }

  /// 初始化音频服务
  Future<bool> initializeAudio() async {
    try {
      state = const AudioState.loading();
      
      // 先检查权限
      if (!state.hasPermission) {
        final hasPermission = await requestPermissions();
        if (!hasPermission) {
          return false;
        }
      }
      
      // 初始化音频服务
      await _audioService.initialize();
      
      state = const AudioState.ready();
      print('[$tag] 音频服务初始化成功');
      return true;
    } catch (e) {
      print('[$tag] 初始化音频服务失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '音频服务初始化失败';
      state = AudioState.error(errorMessage);
      return false;
    }
  }

  /// 播放音频数据
  Future<void> playAudioData(Uint8List opusData) async {
    try {
      if (!state.isInitialized) {
        final success = await initializeAudio();
        if (!success) {
          return;
        }
      }
      
      state = state.copyWith(
        isPlaying: true,
        status: AudioConstants.statePlaying,
      );
      
      await _audioService.playOpusAudio(opusData);
      
      state = state.copyWith(
        isPlaying: false,
        status: AudioConstants.stateIdle,
      );
    } catch (e) {
      print('[$tag] 播放音频失败: $e');
      final errorMessage = e is AppException 
          ? e.userFriendlyMessage 
          : '音频播放失败';
      state = AudioState.error(errorMessage);
    }
  }

  /// 停止音频播放
  Future<void> stopAudio() async {
    try {
      await _audioService.stop();
      state = state.copyWith(
        isPlaying: false,
        status: AudioConstants.stateIdle,
      );
    } catch (e) {
      print('[$tag] 停止音频失败: $e');
    }
  }

  /// 获取当前状态描述
  String get statusDescription {
    switch (state.status) {
      case AudioConstants.stateIdle:
        return '音频服务准备就绪';
      case AudioConstants.stateProcessing:
        return '正在处理...';
      case AudioConstants.statePlaying:
        return '正在播放';
      case AudioConstants.stateError:
        return state.errorMessage ?? '音频服务错误';
      default:
        return '未知状态';
    }
  }

  /// 重置状态
  void reset() {
    state = const AudioState.initial();
    _checkInitialPermissions();
  }

  /// 重新初始化
  Future<void> reinitialize() async {
    reset();
    await initializeAudio();
  }
}

/// 音频状态Provider
final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final permissionService = PermissionService();
  
  return AudioNotifier(audioService, permissionService);
});

/// 音频状态快捷访问Provider
final audioStateProvider = Provider<AudioState>((ref) {
  return ref.watch(audioProvider);
});

/// 音频权限状态Provider
final audioPermissionProvider = Provider<bool>((ref) {
  return ref.watch(audioProvider).hasPermission;
});

/// 音频初始化状态Provider
final audioInitializedProvider = Provider<bool>((ref) {
  return ref.watch(audioProvider).isInitialized;
});

/// 音频播放状态Provider
final audioPlayingProvider = Provider<bool>((ref) {
  return ref.watch(audioProvider).isPlaying;
});

/// 音频错误状态Provider
final audioErrorProvider = Provider<String?>((ref) {
  return ref.watch(audioProvider).errorMessage;
});

/// Android客户端风格音频服务Provider
final audioServiceAndroidStyleProvider = Provider<AudioServiceAndroidStyle>((ref) {
  return AudioServiceAndroidStyle();
});
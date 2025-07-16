/// 虚拟人物状态管理
/// 
/// 使用Riverpod管理虚拟人物的全局状态
/// 包括表情、状态、动画控制等功能
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/virtual_character/models/virtual_character_state.dart';
import '../widgets/virtual_character/models/character_enums.dart';
import '../../core/utils/emotion_mapper.dart';

/// 虚拟人物状态通知器
/// 
/// 管理虚拟人物的状态变化，包括：
/// - 表情更新（来自后端emotion字段）
/// - 状态切换（idle/listening/thinking/speaking/sleeping）
/// - 动画控制
/// - 配置管理
class VirtualCharacterNotifier extends StateNotifier<VirtualCharacterState> {
  /// 构造函数，初始化为待机状态
  VirtualCharacterNotifier() : super(VirtualCharacterState.idle());
  
  /// 更新表情
  /// 
  /// 当收到后端返回的emotion字段时调用
  /// 
  /// 参数：
  /// - [emotion] 表情类型字符串
  void updateEmotion(String emotion) {
    if (state.emotion != emotion) {
      state = state.copyWith(emotion: emotion);
    }
  }
  
  /// 更新状态
  /// 
  /// 当虚拟人物状态发生变化时调用
  /// 
  /// 参数：
  /// - [status] 新的状态类型
  void updateStatus(CharacterStatus status) {
    if (state.status != status) {
      // 根据状态自动调整动画和缩放
      bool isAnimating = status != CharacterStatus.idle;
      double scale = _getScaleForStatus(status);
      
      state = state.copyWith(
        status: status,
        isAnimating: isAnimating,
        scale: scale,
      );
    }
  }
  
  /// 同时更新表情和状态
  /// 
  /// 用于处理后端返回的完整消息
  /// 
  /// 参数：
  /// - [emotion] 表情类型字符串
  /// - [status] 状态类型
  void updateEmotionAndStatus(String emotion, CharacterStatus status) {
    bool isAnimating = status != CharacterStatus.idle;
    double scale = _getScaleForStatus(status);
    
    state = state.copyWith(
      emotion: emotion,
      status: status,
      isAnimating: isAnimating,
      scale: scale,
    );
  }
  
  /// 设置到待机状态
  /// 
  /// 参数：
  /// - [emotion] 表情类型（可选，默认为当前表情）
  void setIdle({String? emotion}) {
    state = VirtualCharacterState.idle(
      emotion: emotion ?? state.emotion,
      rendererConfig: state.rendererConfig,
    );
  }
  
  /// 设置到听取状态
  /// 
  /// 参数：
  /// - [emotion] 表情类型（可选，默认为当前表情）
  void setListening({String? emotion}) {
    state = VirtualCharacterState.listening(
      emotion: emotion ?? state.emotion,
      rendererConfig: state.rendererConfig,
    );
  }
  
  /// 设置到思考状态
  /// 
  /// 参数：
  /// - [emotion] 表情类型（可选，默认为thinking）
  void setThinking({String? emotion}) {
    state = VirtualCharacterState.thinking(
      emotion: emotion ?? 'thinking',
      rendererConfig: state.rendererConfig,
    );
  }
  
  /// 设置到说话状态
  /// 
  /// 参数：
  /// - [emotion] 表情类型（必需）
  void setSpeaking(String emotion) {
    state = VirtualCharacterState.speaking(
      emotion: emotion,
      rendererConfig: state.rendererConfig,
    );
  }
  
  /// 设置到休眠状态
  void setSleeping() {
    state = VirtualCharacterState.sleeping(
      rendererConfig: state.rendererConfig,
    );
  }
  
  /// 触发动画
  /// 
  /// 临时启动动画效果
  void triggerAnimation() {
    // 临时设置动画状态
    state = state.copyWith(isAnimating: true);
    
    // 1秒后恢复正常状态
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        state = state.copyWith(
          isAnimating: state.status != CharacterStatus.idle,
        );
      }
    });
  }
  
  /// 开始动画
  void startAnimation() {
    state = state.copyWith(isAnimating: true);
  }
  
  /// 停止动画
  void stopAnimation() {
    state = state.copyWith(isAnimating: false);
  }
  
  /// 设置缩放比例
  /// 
  /// 参数：
  /// - [scale] 缩放比例
  void setScale(double scale) {
    state = state.copyWith(scale: scale);
  }
  
  /// 设置状态文本
  /// 
  /// 参数：
  /// - [statusText] 状态文本（null表示使用默认文本）
  void setStatusText(String? statusText) {
    state = state.copyWith(statusText: statusText);
  }
  
  /// 更新渲染器配置
  /// 
  /// 参数：
  /// - [config] 新的配置信息
  void updateRendererConfig(Map<String, dynamic> config) {
    final newConfig = Map<String, dynamic>.from(state.rendererConfig);
    newConfig.addAll(config);
    state = state.copyWith(rendererConfig: newConfig);
  }
  
  /// 重置到默认状态
  void reset() {
    state = VirtualCharacterState.idle();
  }
  
  /// 根据状态获取对应的缩放比例
  double _getScaleForStatus(CharacterStatus status) {
    switch (status) {
      case CharacterStatus.idle:
        return 1.0;
      case CharacterStatus.listening:
        return 1.1;
      case CharacterStatus.thinking:
        return 1.0;
      case CharacterStatus.speaking:
        return 1.0;
      case CharacterStatus.sleeping:
        return 0.8;
    }
  }
}

/// 虚拟人物状态提供器
/// 
/// 全局状态管理，可在整个应用中访问虚拟人物状态
final virtualCharacterProvider = StateNotifierProvider<VirtualCharacterNotifier, VirtualCharacterState>((ref) {
  return VirtualCharacterNotifier();
});

/// 虚拟人物表情选择器
/// 
/// 仅监听表情变化，用于性能优化
final virtualCharacterEmotionProvider = Provider<String>((ref) {
  return ref.watch(virtualCharacterProvider).emotion;
});

/// 虚拟人物状态选择器
/// 
/// 仅监听状态变化，用于性能优化
final virtualCharacterStatusProvider = Provider<CharacterStatus>((ref) {
  return ref.watch(virtualCharacterProvider).status;
});

/// 虚拟人物动画状态选择器
/// 
/// 仅监听动画状态变化，用于性能优化
final virtualCharacterAnimationProvider = Provider<bool>((ref) {
  return ref.watch(virtualCharacterProvider).isAnimating;
});

/// 虚拟人物缩放选择器
/// 
/// 仅监听缩放变化，用于性能优化
final virtualCharacterScaleProvider = Provider<double>((ref) {
  return ref.watch(virtualCharacterProvider).scale;
});

/// 虚拟人物工具函数
class VirtualCharacterUtils {
  /// 根据聊天状态自动设置虚拟人物状态
  /// 
  /// 参数：
  /// - [ref] WidgetRef实例
  /// - [isConnected] 是否已连接
  /// - [isListening] 是否正在听取
  /// - [isThinking] 是否正在思考
  /// - [isSpeaking] 是否正在说话
  static void updateFromChatState(
    WidgetRef ref, {
    required bool isConnected,
    required bool isListening,
    required bool isThinking,
    required bool isSpeaking,
  }) {
    final notifier = ref.read(virtualCharacterProvider.notifier);
    
    if (!isConnected) {
      notifier.setSleeping();
    } else if (isSpeaking) {
      // 说话状态，表情需要从外部传入
      notifier.updateStatus(CharacterStatus.speaking);
    } else if (isThinking) {
      notifier.setThinking();
    } else if (isListening) {
      notifier.setListening();
    } else {
      notifier.setIdle();
    }
  }
  
  /// 处理后端消息更新虚拟人物状态
  /// 
  /// 参数：
  /// - [ref] WidgetRef实例
  /// - [messageType] 消息类型
  /// - [emotion] 表情类型（可选）
  static void handleBackendMessage(
    WidgetRef ref, {
    required String messageType,
    String? emotion,
  }) {
    final notifier = ref.read(virtualCharacterProvider.notifier);
    
    switch (messageType) {
      case 'hello':
        notifier.setIdle(emotion: emotion ?? 'happy');
        break;
      case 'listen':
        notifier.setListening(emotion: emotion);
        break;
      case 'stt':
        notifier.setThinking(emotion: emotion);
        break;
      case 'llm':
        if (emotion != null) {
          notifier.setSpeaking(emotion);
        }
        break;
      case 'tts':
        notifier.setSpeaking(emotion ?? 'happy');
        break;
      default:
        notifier.setIdle(emotion: emotion);
        break;
    }
  }
  
  /// 获取虚拟人物状态描述
  /// 
  /// 参数：
  /// - [state] 虚拟人物状态
  /// 
  /// 返回：
  /// - 状态描述字符串
  static String getStateDescription(VirtualCharacterState state) {
    final emotionName = EmotionMapper.getEmotionDisplayName(state.emotion);
    final statusName = state.status.statusText;
    final animationStatus = state.isAnimating ? '动画中' : '静态';
    
    return '$emotionName • $statusName • $animationStatus';
  }
  
  /// 检查状态是否有效
  /// 
  /// 参数：
  /// - [state] 虚拟人物状态
  /// 
  /// 返回：
  /// - true 如果状态有效
  /// - false 如果状态无效
  static bool isStateValid(VirtualCharacterState state) {
    return EmotionMapper.supportsEmotion(state.emotion) &&
           state.scale > 0 &&
           state.scale <= 2.0;
  }
}
/// 悬浮聊天主容器
/// 
/// 实现可收缩/展开的悬浮聊天界面
/// 收缩状态：右下角小型虚拟人物
/// 展开状态：左右分割布局 (聊天内容70% + 虚拟人物30%)
library;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/virtual_character_provider.dart';
import '../../providers/audio_stream_provider.dart';
import '../../providers/chat_provider.dart';
import '../../../data/models/chat_ui_model.dart';
import '../chat/chat_interface.dart';
import '../../../core/utils/emotion_mapper.dart';
import '../../../core/utils/screen_utils.dart';
import 'voice_input_button.dart';
import '../virtual_character/models/character_enums.dart';

/// 悬浮聊天状态
enum FloatingChatState {
  /// 收缩状态 - 只显示小型虚拟人物
  collapsed,
  /// 展开状态 - 显示完整聊天界面
  expanded,
}

/// 悬浮聊天主容器
/// 
/// 功能特性：
/// - 收缩/展开状态切换
/// - 左右分割布局 (聊天70% + 虚拟人物30%)
/// - 响应式设计，适配横竖屏
/// - 平滑动画过渡
/// - 背景模糊效果
class FloatingChatWidget extends HookConsumerWidget {
  /// 初始状态
  final FloatingChatState initialState;
  
  /// 是否启用背景模糊
  final bool enableBackgroundBlur;
  
  /// 自定义位置偏移
  final Offset? positionOffset;
  
  /// 收缩状态下的虚拟人物大小
  final double collapsedSize;
  
  /// 展开状态下的最大宽度比例
  final double expandedWidthRatio;
  
  /// 展开状态下的最大高度比例
  final double expandedHeightRatio;
  
  /// 构造函数
  const FloatingChatWidget({
    super.key,
    this.initialState = FloatingChatState.collapsed,
    this.enableBackgroundBlur = true,
    this.positionOffset,
    this.collapsedSize = 80.0,
    this.expandedWidthRatio = 0.9,
    this.expandedHeightRatio = 0.7,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取屏幕信息
    final screenSize = MediaQuery.of(context).size;
    final layoutParams = ScreenUtils.getFloatingChatLayoutParams(context);
    final isLandscape = screenSize.width > screenSize.height;
    
    // 检查是否应该显示悬浮聊天图标
    if (!ScreenUtils.shouldShowFloatingChatIcon(context)) {
      return const SizedBox.shrink();
    }
    
    // 聊天状态管理
    final chatState = useState(initialState);
    
    // 语音输入状态管理
    final voiceInputState = useState(VoiceInputState.idle);
    
    // 监听聊天provider状态变化，当STT响应到达时重置语音输入状态
    ref.listen(chatProvider, (previous, next) {
      // 当收到新的用户消息且是语音输入时，重置语音输入状态
      if (previous != null && 
          next.messages.length > previous.messages.length &&
          voiceInputState.value == VoiceInputState.processing) {
        final latestMessage = next.messages.last;
        if (latestMessage.isUser && 
            (latestMessage.metadata?['isVoiceInput'] ?? false)) {
          print('[FloatingChatWidget] 检测到STT响应，重置语音输入状态');
          voiceInputState.value = VoiceInputState.idle;
          final characterNotifier = ref.read(virtualCharacterProvider.notifier);
          characterNotifier.updateStatus(CharacterStatus.idle);
        }
      }
    });
    
    // 简化动画控制器
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200), // 固定较短的动画时间
      initialValue: initialState == FloatingChatState.expanded ? 1.0 : 0.0,
    );
    
    // 简化动画
    final expandAnimation = useMemoized(() => animationController, [animationController]);
    
    // 位置动画
    final positionAnimation = useMemoized(() => Tween<Offset>(
      begin: _getCollapsedPosition(screenSize, isLandscape, layoutParams),
      end: _getExpandedPosition(screenSize, isLandscape, layoutParams),
    ).animate(animationController), [animationController, screenSize, isLandscape, layoutParams]);
    
    // 大小动画
    final sizeAnimation = useMemoized(() => Tween<Size>(
      begin: Size(layoutParams.collapsedSize, layoutParams.collapsedSize),
      end: _getExpandedSize(screenSize, isLandscape, layoutParams),
    ).animate(animationController), [animationController, screenSize, isLandscape, layoutParams]);
    
    // 状态切换处理
    final toggleChatState = useCallback(() {
      if (chatState.value == FloatingChatState.collapsed) {
        chatState.value = FloatingChatState.expanded;
        animationController.forward();
      } else {
        chatState.value = FloatingChatState.collapsed;
        animationController.reverse();
      }
    }, [chatState, animationController]);
    
    // 语音输入处理函数 - 使用AudioStreamService（与正常聊天页面一致）
    final startRecording = useCallback(() async {
      if (voiceInputState.value == VoiceInputState.idle) {
        try {
          print('[FloatingChatWidget] 开始录音 - 调用AudioStreamService');
          
          // 获取音频流服务
          final audioStreamState = ref.read(audioStreamProvider);
          final audioStreamNotifier = ref.read(audioStreamProvider.notifier);
          
          // 如果服务未初始化，先初始化
          if (!audioStreamState.isInitialized) {
            print('[FloatingChatWidget] 初始化AudioStreamService');
            await audioStreamNotifier.initializeStreaming();
          }
          
          // 启动实时音频流传输
          await audioStreamNotifier.startStreaming();
          
          voiceInputState.value = VoiceInputState.recording;
          final characterNotifier = ref.read(virtualCharacterProvider.notifier);
          characterNotifier.updateStatus(CharacterStatus.listening);
          print('[FloatingChatWidget] 录音启动成功');
          
        } catch (e) {
          print('[FloatingChatWidget] 录音启动异常: $e');
          // 可以在这里添加错误处理
        }
      }
    }, [voiceInputState, ref]);
    
    final stopRecording = useCallback(() async {
      if (voiceInputState.value == VoiceInputState.recording) {
        try {
          print('[FloatingChatWidget] 停止录音 - 调用AudioStreamService');
          
          voiceInputState.value = VoiceInputState.processing;
          final characterNotifier = ref.read(virtualCharacterProvider.notifier);
          characterNotifier.updateStatus(CharacterStatus.thinking);
          
          // 获取音频流服务并停止流传输
          final audioStreamNotifier = ref.read(audioStreamProvider.notifier);
          await audioStreamNotifier.stopStreaming();
          
          print('[FloatingChatWidget] 录音停止成功，音频流已发送');
          
          // AudioStreamService会自动处理音频数据的发送，无需手动发送
          // 保持processing状态，等待服务器STT响应
          // STT响应会通过chat_provider处理并更新UI
          
          // 设置超时保护，如果5秒内没有STT响应则重置状态
          Future.delayed(const Duration(seconds: 5), () {
            if (voiceInputState.value == VoiceInputState.processing) {
              print('[FloatingChatWidget] STT处理超时，重置状态');
              voiceInputState.value = VoiceInputState.idle;
              characterNotifier.updateStatus(CharacterStatus.idle);
            }
          });
          
        } catch (e) {
          print('[FloatingChatWidget] 录音停止异常: $e');
          voiceInputState.value = VoiceInputState.idle;
          final characterNotifier = ref.read(virtualCharacterProvider.notifier);
          characterNotifier.updateStatus(CharacterStatus.idle);
        }
      }
    }, [voiceInputState, ref]);
    
    // 虚拟人物点击处理
    final onCharacterTap = useCallback(() {
      if (chatState.value == FloatingChatState.collapsed) {
        toggleChatState();
      } else {
        // 已展开状态下单击虚拟人物触发动画
        final characterNotifier = ref.read(virtualCharacterProvider.notifier);
        characterNotifier.triggerAnimation();
      }
    }, [chatState, toggleChatState, ref]);
    
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final currentPosition = positionAnimation.value;
        final currentSize = sizeAnimation.value;
        final currentExpansion = expandAnimation.value;
        
        return Stack(
          children: [
            // 展开状态时显示全屏背景，用于检测外部点击
            if (chatState.value == FloatingChatState.expanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    // 点击外部区域关闭窗口
                    print('[FloatingChatWidget] 点击外部区域，关闭悬浮聊天窗口');
                    toggleChatState();
                  },
                  child: Container(
                    // 简化背景效果
                    color: enableBackgroundBlur
                        ? Colors.black.withValues(alpha: 0.1 * currentExpansion)
                        : Colors.transparent,
                  ),
                ),
              ),
            
            // 悬浮聊天窗口主体
            Positioned(
              left: currentPosition.dx,
              top: currentPosition.dy,
              child: Container(
                width: currentSize.width,
                height: currentSize.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // 简化阴影效果  
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: chatState.value == FloatingChatState.collapsed
                      ? _buildCollapsedContent(context, ref, onCharacterTap, layoutParams)
                      : _buildExpandedContent(context, ref, onCharacterTap, toggleChatState, isLandscape, layoutParams, voiceInputState.value, startRecording, stopRecording),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// 构建收缩状态内容
  Widget _buildCollapsedContent(BuildContext context, WidgetRef ref, VoidCallback onTap, FloatingChatLayoutParams layoutParams) {
    print('[FloatingChatWidget] 构建收缩状态内容，尺寸: ${layoutParams.collapsedSize}');
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400.withValues(alpha: 0.9),
            Colors.purple.shade400.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            // 使用全部可用空间，不设置固定尺寸限制
            width: double.infinity,
            height: double.infinity,
            // 只设置最小边距，确保emoji有足够空间
            padding: EdgeInsets.all(4),
            child: Center(
              child: Text(
                '🙂',
                style: TextStyle(
                  // 使用相对于容器大小的字体
                  fontSize: layoutParams.collapsedSize * 0.5, // 容器大小的50%
                  color: Colors.white,
                  height: 1.0, // 设置行高为1.0，避免额外空间
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 构建展开状态内容
  Widget _buildExpandedContent(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onCharacterTap,
    VoidCallback onClose,
    bool isLandscape,
    FloatingChatLayoutParams layoutParams,
    VoiceInputState voiceInputState,
    VoidCallback onStartRecording,
    VoidCallback onStopRecording,
  ) {
    if (enableBackgroundBlur) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildExpandedLayout(context, ref, onCharacterTap, onClose, isLandscape, layoutParams, voiceInputState, onStartRecording, onStopRecording),
      );
    } else {
      return _buildExpandedLayout(context, ref, onCharacterTap, onClose, isLandscape, layoutParams, voiceInputState, onStartRecording, onStopRecording);
    }
  }
  
  /// 构建展开状态布局
  Widget _buildExpandedLayout(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onCharacterTap,
    VoidCallback onClose,
    bool isLandscape,
    FloatingChatLayoutParams layoutParams,
    VoiceInputState voiceInputState,
    VoidCallback onStartRecording,
    VoidCallback onStopRecording,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: layoutParams.showFullChatInterface
          ? _buildLargeScreenLayout(context, ref, onCharacterTap, onClose, isLandscape, layoutParams, voiceInputState, onStartRecording, onStopRecording)
          : _buildSmallScreenLayout(context, ref, onCharacterTap, onClose, isLandscape, layoutParams, voiceInputState, onStartRecording, onStopRecording),
    );
  }
  
  /// 构建大屏幕布局（左右分割）
  Widget _buildLargeScreenLayout(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onCharacterTap,
    VoidCallback onClose,
    bool isLandscape,
    FloatingChatLayoutParams layoutParams,
    VoiceInputState voiceInputState,
    VoidCallback onStartRecording,
    VoidCallback onStopRecording,
  ) {
    return Row(
      children: [
        // 左侧聊天面板 (70%)
        Expanded(
          flex: 7,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: ChatInterface(
              mode: ChatInterfaceMode.compact,
              isLandscape: isLandscape,
              onClose: onClose,
              enableVoiceInput: false, // 禁用语音输入，因为虚拟人物区域处理语音
              enableTextInput: true,
            ),
          ),
        ),
        
        // 分隔线
        if (layoutParams.showCharacterOnRight) ...[
          Container(
            width: 1,
            color: Colors.grey.shade300,
          ),
          
          // 右侧虚拟人物区域 (30%)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade100,
                    Colors.purple.shade100,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: _buildCharacterArea(context, ref, onCharacterTap, voiceInputState, onStartRecording, onStopRecording),
            ),
          ),
        ],
      ],
    );
  }
  
  /// 构建小屏幕布局（简化版）
  Widget _buildSmallScreenLayout(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onCharacterTap,
    VoidCallback onClose,
    bool isLandscape,
    FloatingChatLayoutParams layoutParams,
    VoiceInputState voiceInputState,
    VoidCallback onStartRecording,
    VoidCallback onStopRecording,
  ) {
    return Column(
      children: [
        // 顶部聊天区域（简化版）
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: ChatInterface(
              mode: ChatInterfaceMode.compact,
              isLandscape: isLandscape,
              onClose: onClose,
              enableVoiceInput: false, // 禁用语音输入，虚拟人物区域处理
              enableTextInput: false, // 小屏幕禁用文本输入，专注语音
            ),
          ),
        ),
        
        // 分隔线
        Container(
          height: 1,
          color: Colors.grey.shade300,
        ),
        
        // 下方虚拟人物区域
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade100,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: _buildCharacterArea(context, ref, onCharacterTap, voiceInputState, onStartRecording, onStopRecording),
          ),
        ),
      ],
    );
  }
  
  /// 构建虚拟人物区域
  Widget _buildCharacterArea(
    BuildContext context, 
    WidgetRef ref, 
    VoidCallback onTap,
    VoiceInputState voiceInputState,
    VoidCallback onStartRecording,
    VoidCallback onStopRecording,
  ) {
    final characterState = ref.watch(virtualCharacterProvider);
    
    print('[FloatingChatWidget] 构建虚拟人物区域 - 表情: ${characterState.emotion}, 状态: ${characterState.status}, 语音状态: ${voiceInputState.name}');
    
    // 根据语音输入状态调整显示效果
    final isRecording = voiceInputState == VoiceInputState.recording;
    final isProcessing = voiceInputState == VoiceInputState.processing;
    
    return Container(
      decoration: BoxDecoration(
        // 录音时添加特殊背景效果
        border: isRecording 
            ? Border.all(color: Colors.red.withValues(alpha: 0.5), width: 3)
            : null,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          // 单击：原有功能
          onTap: onTap,
          // 长按开始：开始录音
          onLongPressStart: (_) {
            print('[FloatingChatWidget] 长按开始，开始录音');
            onStartRecording();
          },
          // 长按结束：停止录音
          onLongPressEnd: (_) {
            print('[FloatingChatWidget] 长按结束，停止录音');
            onStopRecording();
          },
          // 长按取消：也要停止录音
          onLongPressCancel: () {
            print('[FloatingChatWidget] 长按取消，停止录音');
            onStopRecording();
          },
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 主要表情显示
                Text(
                  characterState.emotion.isNotEmpty 
                    ? _getEmotionEmoji(characterState.emotion)
                    : '🙂',
                  style: TextStyle(
                    fontSize: 64, // 大字体，充分利用空间
                    color: Colors.white,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // 语音输入状态提示
                if (isRecording || isProcessing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRecording 
                          ? Colors.red.withValues(alpha: 0.8) 
                          : Colors.orange.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isRecording ? '正在录音' : '处理中',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                // 操作提示（仅在空闲状态显示）
                if (voiceInputState == VoiceInputState.idle)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '长按说话',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 获取收缩状态位置
  Offset _getCollapsedPosition(Size screenSize, bool isLandscape, FloatingChatLayoutParams layoutParams) {
    final defaultX = screenSize.width - layoutParams.collapsedSize - 20;
    final defaultY = screenSize.height - layoutParams.collapsedSize - 100;
    
    if (positionOffset != null) {
      return Offset(
        defaultX + positionOffset!.dx,
        defaultY + positionOffset!.dy,
      );
    }
    
    return Offset(defaultX, defaultY);
  }
  
  /// 获取展开状态位置
  Offset _getExpandedPosition(Size screenSize, bool isLandscape, FloatingChatLayoutParams layoutParams) {
    final expandedSize = _getExpandedSize(screenSize, isLandscape, layoutParams);
    
    // 根据layoutParams决定是否居中显示
    if (layoutParams.centerContent) {
      final safeMargin = 20.0; // 安全边距
      final x = (screenSize.width - expandedSize.width) / 2;
      final y = (screenSize.height - expandedSize.height) / 2;
      
      // 确保不会超出屏幕边界
      final safeX = x.clamp(safeMargin, screenSize.width - expandedSize.width - safeMargin);
      final safeY = y.clamp(safeMargin, screenSize.height - expandedSize.height - safeMargin);
      
      return Offset(safeX, safeY);
    } else {
      // 非居中模式，可以根据需要调整位置
      return Offset(20.0, 20.0);
    }
  }
  
  /// 获取展开状态大小
  Size _getExpandedSize(Size screenSize, bool isLandscape, FloatingChatLayoutParams layoutParams) {
    final maxWidth = screenSize.width * layoutParams.expandedWidthRatio;
    final maxHeight = screenSize.height * layoutParams.expandedHeightRatio;
    
    // 根据屏幕模式调整尺寸，优先保证中间区域正常显示
    if (isLandscape) {
      return Size(
        maxWidth.clamp(600, 1200),  // 大屏幕可以更宽
        maxHeight.clamp(400, 800),  // 高度限制
      );
    } else {
      return Size(
        maxWidth.clamp(300, 600),   // 竖屏宽度限制
        maxHeight.clamp(400, 900),  // 竖屏高度可以更高
      );
    }
  }
  
  /// 获取表情对应的emoji
  String _getEmotionEmoji(String emotion) {
    try {
      return EmotionMapper.getEmoji(emotion);
    } catch (e) {
      print('[FloatingChatWidget] 获取表情emoji失败: $e, 使用默认表情');
      return '🙂';
    }
  }
}
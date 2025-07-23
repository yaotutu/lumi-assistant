/// 语音输入按钮组件
/// 
/// 支持按住说话、松开停止的语音输入功能
/// 专门用于悬浮聊天界面
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 语音输入状态
enum VoiceInputState {
  /// 空闲状态
  idle,
  /// 正在录音
  recording,
  /// 处理中
  processing,
}

/// 语音输入按钮
/// 
/// 功能特性：
/// - 按住开始录音，松开停止录音
/// - 状态指示（空闲、录音、处理中）
/// - 触觉反馈
/// - 音频可视化效果
class VoiceInputButton extends HookConsumerWidget {
  /// 按钮大小
  final double size;
  
  /// 录音开始回调
  final VoidCallback? onRecordStart;
  
  /// 录音停止回调
  final VoidCallback? onRecordStop;
  
  /// 构造函数
  const VoiceInputButton({
    super.key,
    this.size = 60.0,
    this.onRecordStart,
    this.onRecordStop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状态管理
    final currentState = useState(VoiceInputState.idle);
    final isPressed = useState(false);
    
    // 动画控制器
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    
    // 录音动画
    final recordingAnimation = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );
    
    // 脉冲动画
    final pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: recordingAnimation,
      curve: Curves.easeInOut,
    ));
    
    // 颜色动画
    final colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
    
    // 监听状态变化
    useEffect(() {
      if (currentState.value == VoiceInputState.recording) {
        animationController.forward();
        recordingAnimation.repeat(reverse: true);
      } else {
        animationController.reverse();
        recordingAnimation.stop();
      }
      return null;
    }, [currentState.value]);
    
    /// 开始录音
    void handleRecordStart() {
      if (currentState.value != VoiceInputState.idle) return;
      
      HapticFeedback.lightImpact();
      currentState.value = VoiceInputState.recording;
      isPressed.value = true;
      onRecordStart?.call();
    }
    
    /// 停止录音
    void handleRecordStop() {
      if (currentState.value != VoiceInputState.recording) return;
      
      HapticFeedback.lightImpact();
      currentState.value = VoiceInputState.processing;
      isPressed.value = false;
      onRecordStop?.call();
      
      // 模拟处理时间
      Future.delayed(const Duration(milliseconds: 500), () {
        currentState.value = VoiceInputState.idle;
      });
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([animationController, recordingAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: currentState.value == VoiceInputState.recording 
              ? pulseAnimation.value 
              : (isPressed.value ? 0.95 : 1.0),
          child: GestureDetector(
            onTapDown: (_) => handleRecordStart(),
            onTapUp: (_) => handleRecordStop(),
            onTapCancel: () => handleRecordStop(),
            onLongPressStart: (_) => handleRecordStart(),
            onLongPressEnd: (_) => handleRecordStop(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colorAnimation.value?.withValues(alpha: 0.9) ?? Colors.blue.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (colorAnimation.value ?? Colors.blue).withValues(alpha: 0.3),
                    blurRadius: currentState.value == VoiceInputState.recording ? 20 : 10,
                    spreadRadius: currentState.value == VoiceInputState.recording ? 5 : 0,
                  ),
                ],
              ),
              child: Center(
                child: _buildButtonIcon(currentState.value),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// 构建按钮图标
  Widget _buildButtonIcon(VoiceInputState state) {
    IconData iconData;
    Color iconColor = Colors.white;
    
    switch (state) {
      case VoiceInputState.idle:
        iconData = Icons.mic;
        break;
      case VoiceInputState.recording:
        iconData = Icons.mic;
        break;
      case VoiceInputState.processing:
        iconData = Icons.hourglass_empty;
        break;
    }
    
    if (state == VoiceInputState.processing) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    }
    
    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }
}
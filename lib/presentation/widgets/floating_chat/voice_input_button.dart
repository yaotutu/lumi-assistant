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

/// 语音输入按钮组件
class VoiceInputButton extends HookConsumerWidget {
  /// 开始录音回调
  final VoidCallback? onStartRecording;
  
  /// 停止录音回调
  final VoidCallback? onStopRecording;
  
  /// 当前状态
  final VoiceInputState state;
  
  /// 是否禁用
  final bool disabled;
  
  /// 按钮大小
  final double size;
  
  /// 构造函数
  const VoiceInputButton({
    super.key,
    this.onStartRecording,
    this.onStopRecording,
    this.state = VoiceInputState.idle,
    this.disabled = false,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 动画控制器
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    
    // 缩放动画
    final scaleAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
    );
    
    // 监听状态变化，更新动画
    useEffect(() {
      if (state == VoiceInputState.recording) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [state]);
    
    return GestureDetector(
      onTapDown: disabled ? null : (_) {
        // 按下时开始录音
        HapticFeedback.lightImpact(); // 触觉反馈
        onStartRecording?.call();
      },
      onTapUp: disabled ? null : (_) {
        // 松开时停止录音
        HapticFeedback.lightImpact(); // 触觉反馈
        onStopRecording?.call();
      },
      onTapCancel: disabled ? null : () {
        // 取消时也要停止录音
        onStopRecording?.call();
      },
      child: Transform.scale(
        scale: scaleAnimation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            gradient: _getGradient(),
            boxShadow: [
              BoxShadow(
                color: _getShadowColor().withValues(alpha: 0.3),
                blurRadius: state == VoiceInputState.recording ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: state == VoiceInputState.recording
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIcon(),
                    size: size * 0.4,
                    color: Colors.white,
                  ),
                  if (size > 60) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getText(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12, // 使用固定小字体，会被全局fontScale缩放
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 获取渐变背景
  LinearGradient _getGradient() {
    switch (state) {
      case VoiceInputState.idle:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: disabled
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [Colors.blue.shade400, Colors.purple.shade400],
        );
      case VoiceInputState.recording:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade400, Colors.pink.shade400],
        );
      case VoiceInputState.processing:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade400, Colors.amber.shade400],
        );
    }
  }
  
  /// 获取阴影颜色
  Color _getShadowColor() {
    switch (state) {
      case VoiceInputState.idle:
        return disabled ? Colors.grey : Colors.blue;
      case VoiceInputState.recording:
        return Colors.red;
      case VoiceInputState.processing:
        return Colors.orange;
    }
  }
  
  /// 获取图标
  IconData _getIcon() {
    switch (state) {
      case VoiceInputState.idle:
        return Icons.mic;
      case VoiceInputState.recording:
        return Icons.mic;
      case VoiceInputState.processing:
        return Icons.hourglass_empty;
    }
  }
  
  /// 获取文本
  String _getText() {
    switch (state) {
      case VoiceInputState.idle:
        return '按住说话';
      case VoiceInputState.recording:
        return '正在录音';
      case VoiceInputState.processing:
        return '处理中';
    }
  }
}

/// 语音输入提示组件
class VoiceInputHint extends StatelessWidget {
  /// 当前状态
  final VoiceInputState state;
  
  /// 构造函数
  const VoiceInputHint({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(state),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor().withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBorderColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 16,
              color: _getTextColor(),
            ),
            const SizedBox(width: 8),
            Text(
              _getText(),
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 12, // 使用固定小字体，会被全局fontScale缩放
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 获取背景颜色
  Color _getBackgroundColor() {
    switch (state) {
      case VoiceInputState.idle:
        return Colors.grey.shade100;
      case VoiceInputState.recording:
        return Colors.red.shade50;
      case VoiceInputState.processing:
        return Colors.orange.shade50;
    }
  }
  
  /// 获取边框颜色
  Color _getBorderColor() {
    switch (state) {
      case VoiceInputState.idle:
        return Colors.grey;
      case VoiceInputState.recording:
        return Colors.red;
      case VoiceInputState.processing:
        return Colors.orange;
    }
  }
  
  /// 获取文本颜色
  Color _getTextColor() {
    switch (state) {
      case VoiceInputState.idle:
        return Colors.grey.shade700;
      case VoiceInputState.recording:
        return Colors.red.shade700;
      case VoiceInputState.processing:
        return Colors.orange.shade700;
    }
  }
  
  /// 获取图标
  IconData _getIcon() {
    switch (state) {
      case VoiceInputState.idle:
        return Icons.mic_outlined;
      case VoiceInputState.recording:
        return Icons.fiber_manual_record;
      case VoiceInputState.processing:
        return Icons.sync;
    }
  }
  
  /// 获取文本
  String _getText() {
    switch (state) {
      case VoiceInputState.idle:
        return '按住麦克风说话';
      case VoiceInputState.recording:
        return '正在录音，松开停止';
      case VoiceInputState.processing:
        return '正在处理语音';
    }
  }
}
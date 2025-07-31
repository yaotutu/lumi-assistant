import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/audio_stream_provider.dart';
import '../providers/connection_provider.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/websocket_state.dart';
import '../../core/services/audio/voice_interrupt_service.dart';
import '../../core/utils/loggers.dart';

/// 语音输入组件
/// 提供按住说话和录制状态可视化功能
class VoiceInputWidget extends HookConsumerWidget {
  final VoidCallback? onVoiceStart;
  final VoidCallback? onVoiceEnd;
  final VoidCallback? onVoiceCancel;
  final bool isEnabled;
  final double size;

  const VoiceInputWidget({
    super.key,
    this.onVoiceStart,
    this.onVoiceEnd,
    this.onVoiceCancel,
    this.isEnabled = true,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamState = ref.watch(audioStreamProvider);
    final streamNotifier = ref.watch(audioStreamProvider.notifier);
    final connectionState = ref.watch(connectionManagerProvider);
    
    // 按住状态
    final isPressed = useState(false);
    final pressStartTime = useState<DateTime?>(null);
    
    // 移除自动初始化逻辑 - 现在在应用启动时预初始化
    
    // 计算是否可以使用语音功能
    final canUseVoice = connectionState.webSocketState.isConnected &&
        connectionState.handshakeResult.isCompleted &&
        streamState.isInitialized &&
        streamState.hasPermission &&
        isEnabled;

    // 监听流传输状态变化
    useEffect(() {
      if (streamState.isStreaming && !isPressed.value) {
        // 如果不是按住状态但在流传输，说明出现了状态不同步
        streamNotifier.stopStreaming();
      }
      return null;
    }, [streamState.isStreaming, isPressed.value]);

    return GestureDetector(
      onTapDown: canUseVoice ? (details) => _onPressStart(
        context, ref, streamNotifier, streamState, isPressed, pressStartTime
      ) : null,
      onTapUp: (details) => _onPressEnd(
        context, ref, streamNotifier, isPressed, pressStartTime
      ),
      onTapCancel: () => _onPressCancel(
        context, ref, streamNotifier, isPressed, pressStartTime
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getButtonColor(streamState, isPressed.value, canUseVoice),
          shape: BoxShape.circle,
          boxShadow: _getButtonShadow(streamState, isPressed.value),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 录制状态指示器
            if (streamState.isStreaming)
              _buildRecordingIndicator(context, streamState),
            
            // 主图标
            Icon(
              _getButtonIcon(streamState, canUseVoice),
              color: Colors.white,
              size: size * 0.4,
            ),
            
            // 不可用状态遮罩
            if (!canUseVoice)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 获取按钮颜色
  Color _getButtonColor(AudioStreamState state, bool isPressed, bool canUse) {
    if (!canUse) return Colors.grey;
    
    if (state.isStreaming) {
      return isPressed ? Colors.red.shade600 : Colors.red.shade500;
    }
    
    if (isPressed) {
      return Colors.blue.shade600;
    }
    
    return Colors.blue.shade500;
  }

  /// 获取按钮阴影
  List<BoxShadow> _getButtonShadow(AudioStreamState state, bool isPressed) {
    if (state.isStreaming) {
      return [
        BoxShadow(
          color: Colors.red.withValues(alpha: 0.5),
          blurRadius: isPressed ? 12 : 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: Colors.blue.withValues(alpha: 0.3),
        blurRadius: isPressed ? 12 : 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// 获取按钮图标
  IconData _getButtonIcon(AudioStreamState state, bool canUse) {
    if (!canUse) return Icons.mic_off;
    if (state.isStreaming) return Icons.mic;
    return Icons.mic_none;
  }

  /// 构建录制指示器
  Widget _buildRecordingIndicator(BuildContext context, AudioStreamState state) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return CustomPaint(
          painter: RecordingIndicatorPainter(
            progress: value,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          size: Size(size, size),
        );
      },
    );
  }

  /// 按下开始
  void _onPressStart(
    BuildContext context,
    WidgetRef ref,
    AudioStreamNotifier streamNotifier,
    AudioStreamState streamState,
    ValueNotifier<bool> isPressed,
    ValueNotifier<DateTime?> pressStartTime,
  ) async {
    Loggers.ui.userAction('语音输入按下开始');
    
    isPressed.value = true;
    pressStartTime.value = DateTime.now();
    
    // 确保已初始化（应用启动时应该已经初始化了）
    if (!streamState.isInitialized) {
      final success = await streamNotifier.initializeStreaming();
      if (!success) {
        Loggers.ui.severe('语音输入初始化失败');
        if (context.mounted) {
          _showError(context, '语音功能初始化失败');
        }
        isPressed.value = false;
        pressStartTime.value = null;
        return;
      }
    }

    // 🎯 核心功能：语音录制前自动打断正在播放的AI语音
    // 用户开始说话时，立即停止AI正在播放的语音
    try {
      Loggers.ui.info('语音录制前执行自动语音打断');
      final voiceInterruptService = ref.read(voiceInterruptServiceProvider);
      await voiceInterruptService.autoInterruptBeforeSend();
    } catch (e) {
      Loggers.ui.severe('语音录制前的打断失败', e);
      // 继续录制流程，不因为打断失败而阻止用户录制
    }

    // 开始录制
    final success = await streamNotifier.startStreaming();
    if (!success) {
      Loggers.ui.severe('开始录制失败');
      if (context.mounted) {
        _showError(context, '开始录制失败');
      }
      isPressed.value = false;
      pressStartTime.value = null;
      return;
    }

    Loggers.ui.info('录制开始成功');
    onVoiceStart?.call();
    
    // 触觉反馈
    // HapticFeedback.lightImpact();
  }

  /// 按下结束
  void _onPressEnd(
    BuildContext context,
    WidgetRef ref,
    AudioStreamNotifier streamNotifier,
    ValueNotifier<bool> isPressed,
    ValueNotifier<DateTime?> pressStartTime,
  ) async {
    Loggers.ui.userAction('语音输入按下结束');
    
    if (!isPressed.value) return;
    
    isPressed.value = false;
    final startTime = pressStartTime.value;
    pressStartTime.value = null;

    // 检查录制时长
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      if (duration.inMilliseconds < 500) {
        Loggers.ui.info('录制时间过短，取消录制');
        await streamNotifier.stopStreaming();
        
        // 🎯 通知语音打断服务录制已取消（时间过短）
        try {
          final voiceInterruptService = ref.read(voiceInterruptServiceProvider);
          await voiceInterruptService.cancelRecording(reason: 'duration_too_short');
        } catch (e) {
          Loggers.ui.severe('通知语音打断服务失败', e);
        }
        
        if (context.mounted) {
          _showError(context, '录制时间过短，请长按录制');
        }
        onVoiceCancel?.call();
        return;
      }
    }

    // 停止录制
    final success = await streamNotifier.stopStreaming();
    if (!success) {
      Loggers.ui.severe('停止录制失败');
      if (context.mounted) {
        _showError(context, '停止录制失败');
      }
      return;
    }

    Loggers.ui.info('录制结束成功');
    onVoiceEnd?.call();
  }

  /// 按下取消
  void _onPressCancel(
    BuildContext context,
    WidgetRef ref,
    AudioStreamNotifier streamNotifier,
    ValueNotifier<bool> isPressed,
    ValueNotifier<DateTime?> pressStartTime,
  ) async {
    Loggers.ui.userAction('语音输入按下取消');
    
    if (!isPressed.value) return;
    
    isPressed.value = false;
    pressStartTime.value = null;

    // 取消录制
    await streamNotifier.stopStreaming();
    
    // 🎯 通知语音打断服务录制已取消
    try {
      final voiceInterruptService = ref.read(voiceInterruptServiceProvider);
      await voiceInterruptService.cancelRecording(reason: 'user_cancel');
    } catch (e) {
      Loggers.ui.severe('通知语音打断服务失败', e);
    }
    
    Loggers.ui.info('录制已取消');
    onVoiceCancel?.call();
  }

  /// 显示错误提示
  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// 录制指示器画笔
class RecordingIndicatorPainter extends CustomPainter {
  final double progress;
  final Color color;

  RecordingIndicatorPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 绘制脉冲圆环
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 + 0.4 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius * (0.8 + 0.2 * progress), paint);
    
    // 绘制内圆点
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant RecordingIndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// 语音状态指示器
class VoiceStatusIndicator extends StatelessWidget {
  final AudioStreamState state;
  final double size;

  const VoiceStatusIndicator({
    super.key,
    required this.state,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(),
              color: Colors.white,
              size: size * 0.3,
            ),
            const SizedBox(height: 4),
            Text(
              _getStatusText(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14, // 使用固定字体，会被全局fontScale缩放
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (state.status) {
      case AudioConstants.stateIdle:
        return Colors.grey;
      case AudioConstants.stateRecording:
        return Colors.green;
      case AudioConstants.stateProcessing:
        return Colors.orange;
      case AudioConstants.stateError:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (state.status) {
      case AudioConstants.stateIdle:
        return Icons.mic_none;
      case AudioConstants.stateRecording:
        return Icons.mic;
      case AudioConstants.stateProcessing:
        return Icons.hourglass_empty;
      case AudioConstants.stateError:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusText() {
    switch (state.status) {
      case AudioConstants.stateIdle:
        return '待机';
      case AudioConstants.stateRecording:
        return '录制中';
      case AudioConstants.stateProcessing:
        return '处理中';
      case AudioConstants.stateError:
        return '错误';
      default:
        return '未知';
    }
  }
}
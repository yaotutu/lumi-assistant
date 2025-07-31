import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../websocket/websocket_service.dart' show WebSocketService, webSocketServiceProvider;
import 'audio_service_android_style.dart';
import 'audio_playback_service.dart';
import '../../../data/models/websocket_state.dart';
import '../../utils/loggers.dart';

/// 语音打断服务
/// 
/// 管理语音对话的打断功能，提供统一的打断接口
/// 参考Android客户端的实现模式，支持多种打断场景
class VoiceInterruptService {
  static const String tag = 'VoiceInterruptService';
  
  final Ref _ref;
  
  // 当前音频播放状态
  bool _isAudioPlaying = false;
  bool _isRecording = false;
  
  // 打断状态回调
  void Function(bool isPlaying)? onAudioStateChanged;
  void Function(String message)? onInterruptMessage;

  VoiceInterruptService(this._ref);

  /// 获取WebSocket服务
  WebSocketService get _webSocketService => _ref.read(webSocketServiceProvider.notifier);

  /// 语音打断 - 完整流程
  /// 
  /// 参考Android客户端实现，包含以下步骤：
  /// 1. 立即停止本地音频播放
  /// 2. 发送abort消息通知服务器
  /// 3. 发送停止监听消息
  /// 4. 更新UI状态
  Future<bool> interruptVoice({String reason = 'user_interrupt'}) async {
    Loggers.audio.info('===== 开始语音打断流程 =====');
    Loggers.audio.info('打断原因: $reason');
    
    try {
      // 1. 立即停止本地音频播放
      Loggers.audio.fine('步骤1: 停止本地音频播放');
      await _stopLocalAudio();
      
      // 2. 发送abort消息给服务器
      Loggers.audio.fine('步骤2: 发送abort消息给服务器');
      try {
        await _webSocketService.sendAbortMessage(reason: reason);
      } catch (e) {
        Loggers.audio.severe('发送abort消息失败', e);
        // 继续执行，不因为网络问题阻断整个流程
      }
      
      // 3. 发送停止监听消息
      Loggers.audio.fine('步骤3: 发送停止监听消息');
      try {
        await _webSocketService.sendStopListenMessage();
      } catch (e) {
        Loggers.audio.severe('发送停止监听消息失败', e);
      }
      
      // 4. 更新状态
      _isAudioPlaying = false;
      _isRecording = false;
      
      // 5. 通知UI
      onAudioStateChanged?.call(false);
      onInterruptMessage?.call('语音已打断');
      
      Loggers.audio.info('===== 语音打断流程完成 =====');
      return true;
      
    } catch (e) {
      Loggers.audio.severe('语音打断失败', e);
      onInterruptMessage?.call('语音打断失败: $e');
      return false;
    }
  }

  /// 停止本地音频播放
  Future<void> _stopLocalAudio() async {
    try {
      // 停止Android风格音频服务
      await AudioServiceAndroidStyle.stop();
      Loggers.audio.fine('Android风格音频服务已停止');
      
      // 停止跨平台音频服务（如果有）
      try {
        final audioService = AudioPlaybackServiceFactory.createService();
        if (audioService.isInitialized) {
          await audioService.stopPlayback();
          Loggers.audio.fine('跨平台音频服务已停止');
        }
      } catch (e) {
        Loggers.audio.severe('停止跨平台音频服务失败', e);
        // 不阻断流程
      }
      
    } catch (e) {
      Loggers.audio.severe('停止本地音频失败', e);
      rethrow;
    }
  }

  /// 快速打断 - 仅停止本地播放
  /// 
  /// 用于需要立即响应的场景，如用户开始说话
  Future<void> quickInterrupt() async {
    Loggers.audio.info('执行快速打断');
    try {
      await _stopLocalAudio();
      _isAudioPlaying = false;
      onAudioStateChanged?.call(false);
      onInterruptMessage?.call('音频已停止');
    } catch (e) {
      Loggers.audio.severe('快速打断失败', e);
    }
  }

  /// 取消语音录制
  /// 
  /// 参考Android客户端的上滑取消功能
  Future<void> cancelRecording({String reason = 'user_cancel'}) async {
    Loggers.audio.info('取消语音录制，原因: $reason');
    
    try {
      // 发送停止监听消息
      await _webSocketService.sendStopListenMessage();
      
      // 更新状态
      _isRecording = false;
      onInterruptMessage?.call('录制已取消');
      
    } catch (e) {
      Loggers.audio.severe('取消录制失败', e);
    }
  }

  /// 发送消息前的自动打断
  /// 
  /// 在用户发送新消息前自动停止当前音频播放
  /// 这是Android客户端的标准行为
  Future<void> autoInterruptBeforeSend() async {
    Loggers.audio.info('发送消息前自动打断音频播放');
    
    if (_isAudioPlaying) {
      await interruptVoice(reason: 'new_message_sending');
    }
  }

  /// 页面退出时的清理打断
  /// 
  /// 确保页面退出时没有音频在后台继续播放
  Future<void> cleanupOnExit() async {
    Loggers.audio.info('页面退出清理，停止所有音频播放');
    
    try {
      await _stopLocalAudio();
      _isAudioPlaying = false;
      _isRecording = false;
    } catch (e) {
      Loggers.audio.severe('退出清理失败', e);
    }
  }

  /// 设置音频播放状态
  void setAudioPlayingState(bool isPlaying) {
    _isAudioPlaying = isPlaying;
    onAudioStateChanged?.call(isPlaying);
  }

  /// 设置录制状态
  void setRecordingState(bool isRecording) {
    _isRecording = isRecording;
  }

  /// 获取当前状态
  bool get isAudioPlaying => _isAudioPlaying;
  bool get isRecording => _isRecording;
  
  /// 是否有任何音频活动
  bool get hasAudioActivity => _isAudioPlaying || _isRecording;

  /// 获取状态描述（调试用）
  Map<String, dynamic> getStatusInfo() {
    final webSocketState = _ref.read(webSocketServiceProvider);
    return {
      'isAudioPlaying': _isAudioPlaying,
      'isRecording': _isRecording,
      'hasActivity': hasAudioActivity,
      'websocketConnected': webSocketState.isConnected,
    };
  }
}

/// 语音打断服务提供者
final voiceInterruptServiceProvider = Provider<VoiceInterruptService>((ref) {
  return VoiceInterruptService(ref);
});
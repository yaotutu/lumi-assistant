/// 音频处理相关常量配置
/// 用于定义音频录制、编码、播放等相关参数
class AudioConstants {
  AudioConstants._();

  // Opus音频编码参数
  static const int sampleRate = 16000;  // 采样率：16kHz
  static const int channels = 1;        // 声道数：单声道
  static const int frameDurationMs = 60; // 帧时长：60毫秒
  static const int frameDuration = 60;    // 帧时长：60毫秒 (用于WebSocket协议)
  static const int bitrate = 32000;     // 码率：32kbps
  
  // Opus编码配置
  static const Map<String, dynamic> opusConfig = {
    'sampleRate': sampleRate,
    'channels': channels,
    'frameDuration': frameDurationMs,
    'application': 'voip',  // 语音通话优化
    'bitrate': bitrate,
    'complexity': 10,       // 最高质量编码
    'enableDtx': false,     // 禁用DTX以保持音频流连续性
    'enableFec': true,      // 启用前向纠错
  };
  
  // 音频质量配置
  static const Map<String, Map<String, dynamic>> qualityProfiles = {
    'low': {
      'bitrate': 16000,
      'complexity': 5,
      'frameDuration': 60,
    },
    'medium': {
      'bitrate': 32000,
      'complexity': 8,
      'frameDuration': 60,
    },
    'high': {
      'bitrate': 64000,
      'complexity': 10,
      'frameDuration': 40,
    },
  };
  
  // 音频缓冲区配置
  static const int bufferSize = 2048;           // 缓冲区大小
  static const int maxBufferCount = 5;         // 最大缓冲区数量
  static const int recordingBufferSize = 4096; // 录音缓冲区大小
  
  // 音频会话配置
  static const Map<String, dynamic> sessionConfig = {
    'category': 'playAndRecord',    // 播放和录制模式
    'mode': 'voiceChat',           // 语音聊天模式
    'options': [
      'defaultToSpeaker',          // 默认使用扬声器
      'allowBluetooth',            // 允许蓝牙音频
      'allowBluetoothA2dp',        // 允许蓝牙A2DP
      'allowAirPlay',              // 允许AirPlay
    ],
  };
  
  // 超时配置
  static const Duration recordingTimeout = Duration(seconds: 30);     // 录音超时
  static const Duration playbackTimeout = Duration(seconds: 60);      // 播放超时
  static const Duration connectionTimeout = Duration(seconds: 10);    // 连接超时
  static const Duration processingTimeout = Duration(seconds: 5);     // 处理超时
  
  // 错误代码
  static const int errorCodePermissionDenied = 1001;         // 权限被拒绝
  static const int errorCodeRecordingFailed = 1002;          // 录音失败
  static const int errorCodePlaybackFailed = 1003;           // 播放失败
  static const int errorCodeEncodingFailed = 1004;           // 编码失败
  static const int errorCodeDecodingFailed = 1005;           // 解码失败
  static const int errorCodeAudioSessionFailed = 1006;       // 音频会话失败
  static const int errorCodeInvalidFormat = 1007;            // 无效格式
  static const int errorCodeInsufficientBuffer = 1008;       // 缓冲区不足
  static const int errorCodeDeviceNotAvailable = 1009;       // 设备不可用
  static const int errorCodeInterrupted = 1010;              // 音频中断
  static const int errorCodeProcessingFailed = 1011;         // 处理失败
  
  // 音频状态
  static const String stateIdle = 'idle';                    // 空闲状态
  static const String stateRecording = 'recording';          // 录音中
  static const String statePlaying = 'playing';              // 播放中
  static const String stateProcessing = 'processing';        // 处理中
  static const String stateError = 'error';                  // 错误状态
  
  // 音频格式
  static const String formatOpus = 'opus';                   // Opus格式
  static const String formatPcm = 'pcm';                     // PCM格式
  static const String formatMp3 = 'mp3';                     // MP3格式
  static const String formatWav = 'wav';                     // WAV格式
  
  // 音频文件配置
  static const String audioDirectory = 'audio';             // 音频文件目录
  static const String tempDirectory = 'temp';               // 临时文件目录
  static const int maxFileSize = 10 * 1024 * 1024;         // 最大文件大小：10MB
  static const int maxRecordingDuration = 300;             // 最大录音时长：5分钟
  
  // 音频增益配置
  static const double defaultGain = 1.0;                    // 默认增益
  static const double maxGain = 3.0;                        // 最大增益
  static const double minGain = 0.1;                        // 最小增益
  
  // 音频质量检测
  static const double minVolume = 0.01;                     // 最小音量阈值
  static const double maxVolume = 1.0;                      // 最大音量阈值
  static const int silenceThreshold = 100;                 // 静音检测阈值（毫秒）
  
  // 实时处理配置
  static const int processingChunkSize = 1024;             // 处理块大小
  static const int maxProcessingLatency = 100;             // 最大处理延迟（毫秒）
  static const int targetLatency = 50;                     // 目标延迟（毫秒）
}
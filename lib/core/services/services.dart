/// 核心服务导出文件
/// 
/// 统一导出所有服务，方便其他模块引用
library;

// 音频服务
export 'audio/android_native_audio_service.dart';
export 'audio/audio_playback_service.dart';
export 'audio/audio_recording_service.dart';
export 'audio/audio_service_android_style.dart';
export 'audio/audio_stream_service.dart';
export 'audio/native_audio_player.dart';
export 'audio/opus_data_capture_service.dart';
export 'audio/real_time_audio_service.dart';
export 'audio/voice_interrupt_service.dart';

// 网络服务
export 'network/network_checker.dart';
export 'network/handshake_service.dart';

// WebSocket服务
export 'websocket/websocket_service.dart';

// 通知服务
export 'notification/gotify_service.dart';
export 'notification/gotify_auth_service.dart';
export 'notification/unified_notification_service.dart';

// 设备服务
export 'device/device_control_service.dart';
export 'device/device_info_service.dart';
export 'device/permission_service.dart';

// MCP服务
export 'mcp/embedded_mcp_server.dart';
export 'mcp/mcp_config.dart';
export 'mcp/mcp_error_handler.dart';
export 'mcp/unified_mcp_manager.dart';

// 配置服务
export 'config/app_configuration.dart';
export 'config/app_initializer.dart';
export 'config/web_config_service.dart';

// 照片源服务（保持原有结构）
export 'photo_sources/photo_source_adapter.dart';
export 'photo_sources/photo_source_manager.dart';
export 'photo_sources/bing_wallpaper_adapter.dart';
export 'photo_sources/local_asset_adapter.dart';
export 'photo_sources/picsum_adapter.dart';
export 'photo_sources/placeholder_adapter.dart';
export 'photo_sources/unsplash_api_adapter.dart';
export 'photo_sources/unsplash_source_adapter.dart';
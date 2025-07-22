import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../utils/loggers.dart';

/// 设备控制服务 - 处理设备级别的操作
class DeviceControlService {
  /// 调整音量
  /// [level] 音量级别 0-100
  static Future<Map<String, dynamic>> adjustVolume(double level) async {
    // 确保音量级别在有效范围内
    level = level.clamp(0.0, 100.0);
    
    try {
      // 将0-100转换为0.0-1.0
      final volumeLevel = level / 100.0;
      
      // 使用volume_controller包设置音量
      VolumeController().setVolume(volumeLevel);
      
      return {
        'success': true,
        'volume': level,
        'message': '音量已调整到${level.toInt()}%'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'VOLUME_ADJUST_ERROR',
        'message': '调整音量时发生错误: $e'
      };
    }
  }

  /// 获取当前音量
  static Future<Map<String, dynamic>> getCurrentVolume() async {
    try {
      // 使用volume_controller包获取音量
      final volumeLevel = await VolumeController().getVolume();
      final volumePercent = (volumeLevel * 100).round().toDouble();
      
      return {
        'success': true,
        'volume': volumePercent,
        'message': '当前音量为${volumePercent.toInt()}%'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'VOLUME_GET_ERROR',
        'message': '获取音量时发生错误: $e'
      };
    }
  }

  /// 设置屏幕亮度
  /// [brightness] 亮度级别 0-100，参考ESP32实现
  static Future<Map<String, dynamic>> setBrightness(int brightness) async {
    try {
      // 参考ESP32实现：严格限制亮度范围在0-100
      if (brightness > 100) brightness = 100;
      if (brightness < 0) brightness = 0;
      
      // 将0-100转换为0.0-1.0，遵循ESP32的百分比制
      final brightnessLevel = brightness / 100.0;
      
      Loggers.mcp.info('设置屏幕亮度: $brightness% (${brightnessLevel.toStringAsFixed(2)})');
      
      // 使用screen_brightness包设置亮度
      await ScreenBrightness().setScreenBrightness(brightnessLevel);
      
      return {
        'success': true,
        'brightness': brightness,
        'message': '屏幕亮度已设置为$brightness%'
      };
    } catch (e) {
      Loggers.mcp.severe('设置屏幕亮度失败', e);
      return {
        'success': false,
        'error': 'BRIGHTNESS_SET_ERROR',
        'message': '设置屏幕亮度时发生错误: $e'
      };
    }
  }

  /// 获取当前屏幕亮度
  static Future<Map<String, dynamic>> getCurrentBrightness() async {
    try {
      // 使用screen_brightness包获取当前亮度
      final brightnessLevel = await ScreenBrightness().current;
      final brightnessPercent = (brightnessLevel * 100).round();
      
      Loggers.mcp.info('当前屏幕亮度: $brightnessPercent%');
      
      return {
        'success': true,
        'brightness': brightnessPercent,
        'message': '当前屏幕亮度为$brightnessPercent%'
      };
    } catch (e) {
      Loggers.mcp.severe('获取屏幕亮度失败', e);
      return {
        'success': false,
        'error': 'BRIGHTNESS_GET_ERROR',
        'message': '获取屏幕亮度时发生错误: $e'
      };
    }
  }

  /// 获取系统信息
  /// [detailLevel] 信息详细程度：basic为基础信息，detailed为详细信息
  static Future<Map<String, dynamic>> getSystemInfo([String detailLevel = 'basic']) async {
    try {
      Loggers.mcp.fine('获取系统信息，详细程度: $detailLevel');
      
      Map<String, dynamic> systemInfo = {};
      
      if (detailLevel == 'basic') {
        // 基础系统信息
        systemInfo = {
          'platform': '移动设备',
          'app_name': 'Lumi Assistant',
          'app_version': '1.0.0',
          'device_type': 'Android设备',
        };
      } else {
        // 详细系统信息
        systemInfo = {
          'platform': '移动设备',
          'app_name': 'Lumi Assistant',
          'app_version': '1.0.0',
          'device_type': 'Android设备',
          'flutter_version': '支持的Flutter版本',
          'dart_version': '支持的Dart版本',
          'audio_support': '支持音量控制',
          'brightness_support': '支持亮度控制',
          'mcp_support': '支持MCP协议',
          'available_features': ['音量控制', '亮度控制', '语音交互', 'MCP工具调用'],
        };
      }
      
      // 构建友好的信息字符串
      final infoText = StringBuffer();
      infoText.writeln('=== 系统信息 ===');
      
      systemInfo.forEach((key, value) {
        if (value is List) {
          infoText.writeln('$key: ${value.join(', ')}');
        } else {
          infoText.writeln('$key: $value');
        }
      });
      
      return {
        'success': true,
        'info': infoText.toString().trim(),
        'data': systemInfo,
        'message': '系统信息获取成功'
      };
    } catch (e) {
      Loggers.mcp.severe('获取系统信息失败', e);
      return {
        'success': false,
        'error': 'SYSTEM_INFO_ERROR',
        'message': '获取系统信息时发生错误: $e'
      };
    }
  }
}


/// 设备控制服务提供者
final deviceControlServiceProvider = Provider<DeviceControlService>((ref) {
  return DeviceControlService();
});
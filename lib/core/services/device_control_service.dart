import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'mcp_types.dart';

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
      
      print('[设备控制] 设置屏幕亮度: $brightness% (${brightnessLevel.toStringAsFixed(2)})');
      
      // 使用screen_brightness包设置亮度
      await ScreenBrightness().setScreenBrightness(brightnessLevel);
      
      return {
        'success': true,
        'brightness': brightness,
        'message': '屏幕亮度已设置为${brightness}%'
      };
    } catch (e) {
      print('[设备控制] 设置屏幕亮度失败: $e');
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
      
      print('[设备控制] 当前屏幕亮度: $brightnessPercent%');
      
      return {
        'success': true,
        'brightness': brightnessPercent,
        'message': '当前屏幕亮度为${brightnessPercent}%'
      };
    } catch (e) {
      print('[设备控制] 获取屏幕亮度失败: $e');
      return {
        'success': false,
        'error': 'BRIGHTNESS_GET_ERROR',
        'message': '获取屏幕亮度时发生错误: $e'
      };
    }
  }
}

/// MCP工具执行器 - 处理来自服务器的MCP工具调用
class McpToolExecutor {
  static Future<Map<String, dynamic>> executeOperation(
    String toolName,
    Map<String, dynamic> args,
  ) async {
    switch (toolName) {
      case 'adjust_volume':
        return await _adjustVolume(args);
      case 'get_current_volume':
        return await _getCurrentVolume(args);
      case 'set_brightness':
        return await _setBrightness(args);
      case 'get_current_brightness':
        return await _getCurrentBrightness(args);
      default:
        throw Exception('未知的MCP工具: $toolName');
    }
  }

  /// 调整音量操作
  static Future<Map<String, dynamic>> _adjustVolume(Map<String, dynamic> args) async {
    try {
      // 使用类型安全的转换，统一为整数百分比
      final level = McpTypeValidator.toIntPercentage(args['level'] ?? 50).toDouble();
      
      print('[设备控制] 调整音量到 $level%');
      
      final result = await DeviceControlService.adjustVolume(level);
      
      if (result['success'] == true) {
        print('[设备控制] 音量调整成功: ${result['message']}');
        
        // 为AI提供更友好的反馈
        String feedback = _getVolumeFeedback(level);
        
        return {
          'success': true,
          'result': feedback,
          'volume': result['volume'],
          'message': result['message']
        };
      } else {
        print('[设备控制] 音量调整失败: ${result['message']}');
        return {
          'success': false,
          'error': result['error'],
          'message': result['message']
        };
      }
    } catch (e) {
      print('[设备控制] 调整音量时发生异常: $e');
      return {
        'success': false,
        'error': 'EXECUTION_ERROR',
        'message': '执行音量调整时发生错误: $e'
      };
    }
  }
  
  /// 获取音量反馈信息
  static String _getVolumeFeedback(double level) {
    if (level == 0) {
      return '已静音';
    } else if (level <= 25) {
      return '音量已调整为小声模式，当前音量${level.toInt()}%';
    } else if (level <= 50) {
      return '音量已调整为适中模式，当前音量${level.toInt()}%';
    } else if (level <= 75) {
      return '音量已调整为大声模式，当前音量${level.toInt()}%';
    } else {
      return '音量已调整为最大模式，当前音量${level.toInt()}%';
    }
  }

  /// 获取当前音量操作
  static Future<Map<String, dynamic>> _getCurrentVolume(Map<String, dynamic> args) async {
    try {
      print('[设备控制] 获取当前音量');
      
      final result = await DeviceControlService.getCurrentVolume();
      
      if (result['success'] == true) {
        final volume = result['volume'] as double;
        print('[设备控制] 当前音量: ${volume.toInt()}%');
        
        // 为AI提供更友好的反馈
        String feedback = _getCurrentVolumeFeedback(volume);
        
        return {
          'success': true,
          'result': feedback,
          'volume': volume,
          'message': result['message']
        };
      } else {
        print('[设备控制] 获取音量失败: ${result['message']}');
        return {
          'success': false,
          'error': result['error'],
          'message': result['message']
        };
      }
    } catch (e) {
      print('[设备控制] 获取音量时发生异常: $e');
      return {
        'success': false,
        'error': 'EXECUTION_ERROR',
        'message': '获取音量时发生错误: $e'
      };
    }
  }
  
  /// 获取当前音量反馈信息
  static String _getCurrentVolumeFeedback(double level) {
    if (level == 0) {
      return '设备当前处于静音状态';
    } else if (level <= 25) {
      return '设备当前为小声模式，音量${level.toInt()}%';
    } else if (level <= 50) {
      return '设备当前为适中音量，音量${level.toInt()}%';
    } else if (level <= 75) {
      return '设备当前为大声模式，音量${level.toInt()}%';
    } else {
      return '设备当前为最大音量，音量${level.toInt()}%';
    }
  }

  /// 设置屏幕亮度操作 - 参考ESP32的set_brightness实现
  static Future<Map<String, dynamic>> _setBrightness(Map<String, dynamic> args) async {
    try {
      // 使用类型安全的转换，确保为整数百分比
      final brightness = McpTypeValidator.toIntPercentage(args['brightness'] ?? 50);
      
      print('[设备控制] 设置屏幕亮度: $brightness%');
      
      final result = await DeviceControlService.setBrightness(brightness);
      
      if (result['success'] == true) {
        print('[设备控制] 屏幕亮度设置成功: ${result['message']}');
        
        // 为AI提供友好的反馈，参考ESP32的反馈方式
        String feedback = _getBrightnessFeedback(brightness);
        
        return {
          'success': true,
          'result': feedback,
          'brightness': result['brightness'],
          'message': result['message']
        };
      } else {
        print('[设备控制] 屏幕亮度设置失败: ${result['message']}');
        return {
          'success': false,
          'error': result['error'],
          'message': result['message']
        };
      }
    } catch (e) {
      print('[设备控制] 设置屏幕亮度时发生异常: $e');
      return {
        'success': false,
        'error': 'EXECUTION_ERROR',
        'message': '执行屏幕亮度设置时发生错误: $e'
      };
    }
  }

  /// 获取当前屏幕亮度操作 - 参考ESP32的brightness属性查询
  static Future<Map<String, dynamic>> _getCurrentBrightness(Map<String, dynamic> args) async {
    try {
      print('[设备控制] 获取当前屏幕亮度');
      
      final result = await DeviceControlService.getCurrentBrightness();
      
      if (result['success'] == true) {
        final brightness = result['brightness'] as int;
        print('[设备控制] 当前屏幕亮度: $brightness%');
        
        // 为AI提供友好的反馈
        String feedback = _getCurrentBrightnessFeedback(brightness);
        
        return {
          'success': true,
          'result': feedback,
          'brightness': brightness,
          'message': result['message']
        };
      } else {
        print('[设备控制] 获取屏幕亮度失败: ${result['message']}');
        return {
          'success': false,
          'error': result['error'],
          'message': result['message']
        };
      }
    } catch (e) {
      print('[设备控制] 获取屏幕亮度时发生异常: $e');
      return {
        'success': false,
        'error': 'EXECUTION_ERROR',
        'message': '获取屏幕亮度时发生错误: $e'
      };
    }
  }

  /// 获取亮度反馈信息 - 参考ESP32的描述方式
  static String _getBrightnessFeedback(int brightness) {
    if (brightness <= 10) {
      return '屏幕亮度已设置为最低模式，当前亮度${brightness}%';
    } else if (brightness <= 25) {
      return '屏幕亮度已设置为较低模式，当前亮度${brightness}%';
    } else if (brightness <= 50) {
      return '屏幕亮度已设置为适中模式，当前亮度${brightness}%';
    } else if (brightness <= 75) {
      return '屏幕亮度已设置为较高模式，当前亮度${brightness}%';
    } else {
      return '屏幕亮度已设置为最高模式，当前亮度${brightness}%';
    }
  }

  /// 获取当前亮度反馈信息
  static String _getCurrentBrightnessFeedback(int brightness) {
    if (brightness <= 10) {
      return '屏幕当前为最低亮度，亮度${brightness}%';
    } else if (brightness <= 25) {
      return '屏幕当前为较低亮度，亮度${brightness}%';
    } else if (brightness <= 50) {
      return '屏幕当前为适中亮度，亮度${brightness}%';
    } else if (brightness <= 75) {
      return '屏幕当前为较高亮度，亮度${brightness}%';
    } else {
      return '屏幕当前为最高亮度，亮度${brightness}%';
    }
  }
}

/// MCP工具定义 - 遵循MCP协议标准
class McpToolDefinitions {
  /// 获取音量控制工具定义 - MCP标准格式
  static List<Map<String, dynamic>> getVolumeTools() {
    return [
      {
        'name': 'adjust_volume',
        'description': '调整设备音量大小。支持具体数值（0-100）、相对调整（+10、-20）、以及语义化指令（静音、小声、适中、大声、最大）。',
        'inputSchema': McpParameterBuilder()
          .addPercentage('level', '目标音量级别，范围0-100。0表示静音，25表示小声，50表示适中音量，75表示大声，100表示最大音量。', required: true)
          .build()
      },
      {
        'name': 'get_current_volume',
        'description': '获取设备当前的音量级别。用于查询音量状态或在调整音量前检查当前值。',
        'inputSchema': McpParameterBuilder().build()
      }
    ];
  }

  /// 获取屏幕亮度控制工具定义 - 严格遵循ESP32的MCP实现规范
  static List<Map<String, dynamic>> getScreenBrightnessTools() {
    return [
      {
        'name': 'set_brightness',
        'description': '设置屏幕亮度。参考ESP32实现：Set the brightness of the screen. An integer between 0 and 100，支持具体数值（0-100）、语义化指令（最暗、较暗、适中、较亮、最亮）。',
        'inputSchema': McpParameterBuilder()
          .addPercentage('brightness', '屏幕亮度百分比，范围0-100。0表示最暗，25表示较暗，50表示适中亮度，75表示较亮，100表示最亮。', required: true)
          .build()
      },
      {
        'name': 'get_current_brightness',
        'description': '获取屏幕当前亮度级别。参考ESP32实现：Current brightness percentage属性查询，用于查询屏幕亮度状态或在调整亮度前检查当前值。',
        'inputSchema': McpParameterBuilder().build()
      }
    ];
  }

  /// 获取所有设备控制工具（音量+屏幕亮度）
  static List<Map<String, dynamic>> getAllDeviceTools() {
    return [
      ...getVolumeTools(),
      ...getScreenBrightnessTools(),
    ];
  }
}

/// 设备控制服务提供者
final deviceControlServiceProvider = Provider<DeviceControlService>((ref) {
  return DeviceControlService();
});
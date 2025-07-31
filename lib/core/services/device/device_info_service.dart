import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../constants/app_constants.dart';
import '../../../data/models/chat/message_model.dart';

/// 设备信息服务
class DeviceInfoService {
  static DeviceInfoService? _instance;
  DeviceInfo? _cachedDeviceInfo;

  DeviceInfoService._internal();

  factory DeviceInfoService() {
    _instance ??= DeviceInfoService._internal();
    return _instance!;
  }

  /// 获取设备信息
  Future<DeviceInfo> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo!;
    }

    try {
      final platform = _getPlatformName();
      final osVersion = await _getOsVersion();
      final model = await _getDeviceModel();
      final screenSize = await _getScreenSize();
      final deviceName = await _getDeviceName();
      final timezone = DateTime.now().timeZoneOffset.toString();
      final locale = Platform.localeName;

      _cachedDeviceInfo = DeviceInfo(
        platform: platform,
        model: model,
        osVersion: osVersion,
        appVersion: AppConstants.appVersion,
        screenSize: screenSize,
        deviceName: deviceName,
        timezone: timezone,
        locale: locale,
      );

      return _cachedDeviceInfo!;
    } catch (error) {
      // 如果获取设备信息失败，返回默认信息
      return DeviceInfo(
        platform: _getPlatformName(),
        model: 'Unknown',
        osVersion: 'Unknown',
        appVersion: AppConstants.appVersion,
      );
    }
  }

  /// 获取平台名称
  String _getPlatformName() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }

  /// 获取操作系统版本
  Future<String> _getOsVersion() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidVersion();
      } else if (Platform.isIOS) {
        return await _getIOSVersion();
      } else {
        return Platform.operatingSystemVersion;
      }
    } catch (error) {
      return 'Unknown';
    }
  }

  /// 获取Android版本信息
  Future<String> _getAndroidVersion() async {
    try {
      const platform = MethodChannel('flutter.native/deviceinfo');
      final result = await platform.invokeMethod('getAndroidVersion');
      return result ?? 'Unknown';
    } catch (error) {
      return 'Android';
    }
  }

  /// 获取iOS版本信息
  Future<String> _getIOSVersion() async {
    try {
      const platform = MethodChannel('flutter.native/deviceinfo');
      final result = await platform.invokeMethod('getIOSVersion');
      return result ?? 'Unknown';
    } catch (error) {
      return 'iOS';
    }
  }

  /// 获取设备型号
  Future<String> _getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidModel();
      } else if (Platform.isIOS) {
        return await _getIOSModel();
      } else {
        return 'Unknown';
      }
    } catch (error) {
      return 'Unknown';
    }
  }

  /// 获取Android设备型号
  Future<String> _getAndroidModel() async {
    try {
      const platform = MethodChannel('flutter.native/deviceinfo');
      final result = await platform.invokeMethod('getAndroidModel');
      return result ?? 'Android Device';
    } catch (error) {
      return 'Android Device';
    }
  }

  /// 获取iOS设备型号
  Future<String> _getIOSModel() async {
    try {
      const platform = MethodChannel('flutter.native/deviceinfo');
      final result = await platform.invokeMethod('getIOSModel');
      return result ?? 'iOS Device';
    } catch (error) {
      return 'iOS Device';
    }
  }

  /// 获取屏幕尺寸信息
  Future<String> _getScreenSize() async {
    try {
      const platform = MethodChannel('flutter.native/deviceinfo');
      final result = await platform.invokeMethod('getScreenSize');
      return result ?? 'Unknown';
    } catch (error) {
      return 'Unknown';
    }
  }

  /// 获取设备名称
  Future<String> _getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidDeviceName();
      } else if (Platform.isIOS) {
        return await _getIOSDeviceName();
      } else {
        return Platform.localHostname;
      }
    } catch (error) {
      return 'Unknown';
    }
  }

  /// 获取Android设备名称
  Future<String> _getAndroidDeviceName() async {
    try {
      const platform = MethodChannel('flutter.native/deviceinfo');
      final result = await platform.invokeMethod('getAndroidDeviceName');
      return result ?? 'Android Device';
    } catch (error) {
      return 'Android Device';
    }
  }

  /// 获取iOS设备名称
  Future<String> _getIOSDeviceName() async {
    try {
      const platform = MethodChannel('flutter.native/deviceinfo');
      final result = await platform.invokeMethod('getIOSDeviceName');
      return result ?? 'iOS Device';
    } catch (error) {
      return 'iOS Device';
    }
  }

  /// 清除缓存的设备信息
  void clearCache() {
    _cachedDeviceInfo = null;
  }

  /// 获取基本设备信息（用于快速创建，不包含详细信息）
  DeviceInfo getBasicDeviceInfo() {
    return DeviceInfo(
      platform: _getPlatformName(),
      model: 'Unknown',
      osVersion: 'Unknown',
      appVersion: AppConstants.appVersion,
    );
  }
}
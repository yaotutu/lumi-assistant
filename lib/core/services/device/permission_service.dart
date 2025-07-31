import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/common/exceptions.dart';
import '../../constants/audio_constants.dart';

/// 权限管理服务
/// 负责处理应用所需的各种权限请求和状态管理
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// 检查麦克风权限状态
  Future<bool> checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      throw AppException.system(
        message: '检查麦克风权限失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 请求麦克风权限
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      throw AppException.system(
        message: '请求麦克风权限失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 检查存储权限状态
  Future<bool> checkStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      throw AppException.system(
        message: '检查存储权限失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 请求存储权限
  Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      throw AppException.system(
        message: '请求存储权限失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 检查通知权限状态
  Future<bool> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      throw AppException.system(
        message: '检查通知权限失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 请求通知权限
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      throw AppException.system(
        message: '请求通知权限失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 检查音频相关的所有权限
  Future<Map<String, bool>> checkAudioPermissions() async {
    try {
      final results = <String, bool>{};
      
      // 检查麦克风权限
      results['microphone'] = await checkMicrophonePermission();
      
      // 检查存储权限（用于保存音频文件）
      results['storage'] = await checkStoragePermission();
      
      return results;
    } catch (e) {
      throw AppException.system(
        message: '检查音频权限失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 请求音频相关的所有权限
  Future<Map<String, bool>> requestAudioPermissions() async {
    try {
      final results = <String, bool>{};
      
      // 请求麦克风权限
      results['microphone'] = await requestMicrophonePermission();
      
      // 请求存储权限
      results['storage'] = await requestStoragePermission();
      
      return results;
    } catch (e) {
      throw AppException.system(
        message: '请求音频权限失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 检查权限是否被永久拒绝
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      throw AppException.system(
        message: '检查权限状态失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 获取权限状态描述
  String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '权限已授予';
      case PermissionStatus.denied:
        return '权限被拒绝';
      case PermissionStatus.permanentlyDenied:
        return '权限被永久拒绝';
      case PermissionStatus.restricted:
        return '权限受限';
      case PermissionStatus.limited:
        return '权限受限';
      case PermissionStatus.provisional:
        return '权限临时授予';
    }
  }

  /// 获取权限名称
  String getPermissionName(Permission permission) {
    if (permission == Permission.microphone) {
      return '麦克风';
    } else if (permission == Permission.storage) {
      return '存储';
    } else if (permission == Permission.notification) {
      return '通知';
    } else {
      return '未知权限';
    }
  }

  /// 检查是否需要显示权限说明
  Future<bool> shouldShowRequestPermissionRationale(Permission permission) async {
    try {
      return await permission.shouldShowRequestRationale;
    } catch (e) {
      throw AppException.system(
        message: '检查权限说明状态失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 打开应用设置页面
  Future<bool> openApplicationSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      throw AppException.system(
        message: '打开应用设置失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }

  /// 请求权限并处理结果
  Future<PermissionRequestResult> requestPermissionWithResult(
    Permission permission,
  ) async {
    try {
      final permissionName = getPermissionName(permission);
      
      // 检查当前状态
      final currentStatus = await permission.status;
      
      if (currentStatus.isGranted) {
        return PermissionRequestResult(
          permission: permission,
          status: currentStatus,
          isGranted: true,
          message: '$permissionName权限已授予',
        );
      }
      
      // 如果权限被永久拒绝，提示用户去设置中开启
      if (currentStatus.isPermanentlyDenied) {
        return PermissionRequestResult(
          permission: permission,
          status: currentStatus,
          isGranted: false,
          message: '$permissionName权限被永久拒绝，请在设置中开启',
          shouldOpenSettings: true,
        );
      }
      
      // 请求权限
      final newStatus = await permission.request();
      
      return PermissionRequestResult(
        permission: permission,
        status: newStatus,
        isGranted: newStatus.isGranted,
        message: newStatus.isGranted 
            ? '$permissionName权限已授予'
            : '$permissionName权限被拒绝',
      );
    } catch (e) {
      final permissionName = getPermissionName(permission);
      throw AppException.system(
        message: '请求$permissionName权限失败',
        code: AudioConstants.errorCodePermissionDenied.toString(),
        component: 'PermissionService',
        details: {'error': e.toString()},
      );
    }
  }
}

/// 权限请求结果
class PermissionRequestResult {
  final Permission permission;
  final PermissionStatus status;
  final bool isGranted;
  final String message;
  final bool shouldOpenSettings;

  const PermissionRequestResult({
    required this.permission,
    required this.status,
    required this.isGranted,
    required this.message,
    this.shouldOpenSettings = false,
  });

  @override
  String toString() {
    return 'PermissionRequestResult('
        'permission: $permission, '
        'status: $status, '
        'isGranted: $isGranted, '
        'message: $message, '
        'shouldOpenSettings: $shouldOpenSettings'
        ')';
  }
}
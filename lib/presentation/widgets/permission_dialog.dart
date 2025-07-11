import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/services/permission_service.dart';
import '../../core/constants/audio_constants.dart';

/// 权限请求对话框
/// 用于请求音频相关权限并提供用户友好的说明
class PermissionDialog extends HookConsumerWidget {
  final String title;
  final String description;
  final String? permissionType;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const PermissionDialog({
    Key? key,
    required this.title,
    required this.description,
    this.permissionType,
    this.onPermissionGranted,
    this.onPermissionDenied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.mic,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '权限仅用于语音交互功能，我们不会存储或上传您的语音数据。',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPermissionDenied?.call();
          },
          child: const Text('暂不授权'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _requestPermission(context);
          },
          child: const Text('授权'),
        ),
      ],
    );
  }

  /// 请求权限
  Future<void> _requestPermission(BuildContext context) async {
    try {
      final permissionService = PermissionService();
      final permissions = await permissionService.requestAudioPermissions();
      
      if (permissions['microphone'] ?? false) {
        onPermissionGranted?.call();
      } else {
        // 显示权限被拒绝的提示
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
        onPermissionDenied?.call();
      }
    } catch (e) {
      print('权限请求失败: $e');
      if (context.mounted) {
        _showPermissionErrorDialog(context);
      }
      onPermissionDenied?.call();
    }
  }

  /// 显示权限被拒绝的对话框
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('权限被拒绝'),
        content: const Text('语音功能需要麦克风权限才能使用。您可以在设置中重新开启权限。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 显示权限错误的对话框
  void _showPermissionErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('权限请求失败'),
        content: const Text('权限请求过程中发生错误，请稍后重试。'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 打开应用设置
  Future<void> _openAppSettings() async {
    try {
      final permissionService = PermissionService();
      await permissionService.openApplicationSettings();
    } catch (e) {
      print('打开应用设置失败: $e');
    }
  }
}

/// 麦克风权限请求对话框
class MicrophonePermissionDialog extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const MicrophonePermissionDialog({
    Key? key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionDialog(
      title: '麦克风权限',
      description: 'Lumi Assistant需要麦克风权限来实现语音交互功能。'
          '您可以通过语音与AI助手进行对话，享受更便捷的交互体验。',
      permissionType: 'microphone',
      onPermissionGranted: onPermissionGranted,
      onPermissionDenied: onPermissionDenied,
    );
  }
}

/// 音频权限检查和请求Widget
class AudioPermissionChecker extends HookConsumerWidget {
  final Widget child;
  final bool autoRequest;

  const AudioPermissionChecker({
    Key? key,
    required this.child,
    this.autoRequest = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _checkPermissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final hasPermission = snapshot.data ?? false;
        
        if (!hasPermission && autoRequest) {
          // 自动显示权限请求对话框
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPermissionDialog(context);
          });
        }

        return child;
      },
    );
  }

  /// 检查权限
  Future<bool> _checkPermissions() async {
    try {
      final permissionService = PermissionService();
      final permissions = await permissionService.checkAudioPermissions();
      return permissions['microphone'] ?? false;
    } catch (e) {
      print('检查权限失败: $e');
      return false;
    }
  }

  /// 显示权限请求对话框
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MicrophonePermissionDialog(),
    );
  }
}

/// 权限状态指示器
class PermissionStatusIndicator extends HookConsumerWidget {
  final bool showText;

  const PermissionStatusIndicator({
    Key? key,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, bool>>(
      future: _getPermissionStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final permissions = snapshot.data ?? {};
        final hasMicrophone = permissions['microphone'] ?? false;
        final hasStorage = permissions['storage'] ?? false;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasMicrophone ? Icons.mic : Icons.mic_off,
              color: hasMicrophone ? Colors.green : Colors.red,
              size: 16,
            ),
            if (showText) ...[
              const SizedBox(width: 4),
              Text(
                hasMicrophone ? '麦克风已授权' : '麦克风未授权',
                style: TextStyle(
                  color: hasMicrophone ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// 获取权限状态
  Future<Map<String, bool>> _getPermissionStatus() async {
    try {
      final permissionService = PermissionService();
      return await permissionService.checkAudioPermissions();
    } catch (e) {
      print('获取权限状态失败: $e');
      return {};
    }
  }
}

/// 权限请求按钮
class PermissionRequestButton extends HookConsumerWidget {
  final String text;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const PermissionRequestButton({
    Key? key,
    this.text = '请求权限',
    this.onSuccess,
    this.onFailure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _requestPermissions(context),
      icon: const Icon(Icons.security),
      label: Text(text),
    );
  }

  /// 请求权限
  Future<void> _requestPermissions(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => MicrophonePermissionDialog(
        onPermissionGranted: onSuccess,
        onPermissionDenied: onFailure,
      ),
    );
  }
}
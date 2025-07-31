import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/services/web_config_service.dart';

/// Web配置页面
/// 显示Web配置服务的地址和二维码
class WebConfigPage extends StatefulWidget {
  const WebConfigPage({super.key});

  @override
  State<WebConfigPage> createState() => _WebConfigPageState();
}

class _WebConfigPageState extends State<WebConfigPage> {
  final WebConfigService _service = WebConfigService();
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _startService();
  }

  @override
  void dispose() {
    _service.stop();
    super.dispose();
  }

  Future<void> _startService() async {
    setState(() {
      _isStarting = true;
    });

    await _service.start();

    setState(() {
      _isStarting = false;
    });
  }

  void _copyToClipboard() {
    if (_service.serverUrl != null) {
      Clipboard.setData(ClipboardData(text: _service.serverUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('地址已复制到剪贴板'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web配置'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isStarting
            ? const CircularProgressIndicator()
            : _service.isRunning
                ? _buildContent()
                : _buildError(),
      ),
    );
  }

  Widget _buildContent() {
    final url = _service.serverUrl ?? '';
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.computer,
          size: 64,
          color: Colors.blue,
        ),
        const SizedBox(height: 24),
        const Text(
          '请在电脑或手机浏览器中访问：',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                url,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: _copyToClipboard,
                tooltip: '复制地址',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QrImageView(
            data: url,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '扫描二维码快速访问',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 48),
        const Card(
          margin: EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '使用说明',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '1. 确保手机/电脑与本设备在同一局域网\n'
                  '2. 使用浏览器访问上方地址\n'
                  '3. 在网页中修改配置并保存\n'
                  '4. 配置会立即生效，无需重启应用',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          '启动Web配置服务失败',
          style: TextStyle(
            fontSize: 18,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _startService,
          child: const Text('重试'),
        ),
      ],
    );
  }
}
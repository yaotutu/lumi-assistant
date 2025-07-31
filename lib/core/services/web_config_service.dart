import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../config/app_settings.dart';
import '../utils/app_logger.dart';

/// Web配置服务
/// 提供局域网Web界面配置功能
class WebConfigService {
  static final WebConfigService _instance = WebConfigService._internal();
  factory WebConfigService() => _instance;
  WebConfigService._internal();

  HttpServer? _server;
  bool _isRunning = false;
  String? _serverUrl;

  /// 服务是否正在运行
  bool get isRunning => _isRunning;
  
  /// 服务器地址
  String? get serverUrl => _serverUrl;

  /// 启动Web配置服务
  Future<String?> start() async {
    if (_isRunning) {
      return _serverUrl;
    }

    try {
      // 创建路由
      final router = Router();
      
      // 主页
      router.get('/', _handleHomePage);
      
      // API端点
      router.get('/api/config', _handleGetConfig);
      router.post('/api/config', _handleSaveConfig);
      
      // 创建处理器
      final handler = Pipeline()
          .addMiddleware(logRequests())
          .addMiddleware(_corsMiddleware())
          .addHandler(router.call);

      // 启动服务器
      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        8888,
      );
      
      // 获取本地IP
      final ip = await _getLocalIp();
      _serverUrl = 'http://$ip:8888';
      _isRunning = true;
      
      AppLogger.getLogger('WebConfig').info('🌐 Web配置服务已启动: $_serverUrl');
      
      return _serverUrl;
    } catch (e) {
      AppLogger.getLogger('WebConfig').severe('❌ 启动Web配置服务失败', e);
      return null;
    }
  }

  /// 停止Web配置服务
  Future<void> stop() async {
    if (!_isRunning) return;
    
    await _server?.close();
    _server = null;
    _isRunning = false;
    _serverUrl = null;
    
    AppLogger.getLogger('WebConfig').info('🛑 Web配置服务已停止');
  }

  /// 获取本地IP地址
  Future<String> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      AppLogger.getLogger('WebConfig').warning('获取本地IP失败', e);
    }
    return '127.0.0.1';
  }

  /// CORS中间件
  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        final response = await handler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
          ...response.headers,
        });
      };
    };
  }

  /// 处理主页请求
  Response _handleHomePage(Request request) {
    final html = '''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lumi Assistant 配置</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
            color: #333;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2196F3;
            margin-bottom: 30px;
            text-align: center;
        }
        .section {
            margin-bottom: 30px;
            padding: 20px;
            background: #f9f9f9;
            border-radius: 8px;
        }
        .section h2 {
            margin-top: 0;
            color: #666;
            font-size: 18px;
            margin-bottom: 15px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: #555;
        }
        input[type="text"],
        input[type="number"],
        select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
        }
        input[type="checkbox"] {
            margin-right: 8px;
            transform: scale(1.2);
        }
        .checkbox-label {
            display: flex;
            align-items: center;
            margin-top: 5px;
        }
        button {
            background: #2196F3;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            display: block;
            margin: 30px auto 0;
            min-width: 200px;
        }
        button:hover {
            background: #1976D2;
        }
        button:active {
            background: #0D47A1;
        }
        .message {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 5px;
            color: white;
            font-weight: 500;
            display: none;
        }
        .message.success {
            background: #4CAF50;
        }
        .message.error {
            background: #f44336;
        }
        .loading {
            text-align: center;
            padding: 50px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Lumi Assistant 配置</h1>
        <div id="loading" class="loading">加载配置中...</div>
        <form id="configForm" style="display: none;">
            <!-- 网络设置 -->
            <div class="section">
                <h2>🌐 网络设置</h2>
                <div class="form-group">
                    <label for="serverUrl">服务器地址</label>
                    <input type="text" id="serverUrl" name="serverUrl" placeholder="ws://192.168.1.100:8000">
                </div>
                <div class="form-group">
                    <label for="connectionTimeout">连接超时（毫秒）</label>
                    <input type="number" id="connectionTimeout" name="connectionTimeout" value="10000">
                </div>
            </div>

            <!-- Gotify设置 -->
            <div class="section">
                <h2>🔔 Gotify 通知设置</h2>
                <div class="form-group">
                    <label for="gotifyServerUrl">Gotify 服务器地址</label>
                    <input type="text" id="gotifyServerUrl" name="gotifyServerUrl" placeholder="http://192.168.1.100:8088">
                </div>
                <div class="form-group">
                    <label for="gotifyClientToken">Gotify 客户端令牌</label>
                    <input type="text" id="gotifyClientToken" name="gotifyClientToken" placeholder="YOUR_CLIENT_TOKEN">
                </div>
            </div>

            <!-- UI设置 -->
            <div class="section">
                <h2>🎨 界面设置</h2>
                <div class="form-group">
                    <label for="floatingChatSize">浮动聊天窗口大小</label>
                    <input type="number" id="floatingChatSize" name="floatingChatSize" value="80" min="60" max="120">
                </div>
                <div class="form-group">
                    <label for="fontScale">字体缩放比例</label>
                    <input type="number" id="fontScale" name="fontScale" value="1.0" min="0.8" max="1.5" step="0.1">
                </div>
                <div class="form-group">
                    <label for="animationDuration">动画时长（毫秒）</label>
                    <input type="number" id="animationDuration" name="animationDuration" value="300" min="0" max="1000">
                </div>
            </div>

            <button type="submit">保存配置</button>
        </form>
    </div>

    <div id="message" class="message"></div>

    <script>
        // 显示消息
        function showMessage(text, type) {
            const msg = document.getElementById('message');
            msg.textContent = text;
            msg.className = 'message ' + type;
            msg.style.display = 'block';
            setTimeout(() => {
                msg.style.display = 'none';
            }, 3000);
        }

        // 加载配置
        async function loadConfig() {
            try {
                const response = await fetch('/api/config');
                const config = await response.json();
                
                // 填充表单
                for (const [key, value] of Object.entries(config)) {
                    const input = document.getElementById(key);
                    if (input) {
                        if (input.type === 'checkbox') {
                            input.checked = value;
                        } else {
                            input.value = value;
                        }
                    }
                }
                
                document.getElementById('loading').style.display = 'none';
                document.getElementById('configForm').style.display = 'block';
            } catch (error) {
                showMessage('加载配置失败: ' + error.message, 'error');
            }
        }

        // 保存配置
        document.getElementById('configForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const formData = new FormData(e.target);
            const config = {};
            
            // 收集所有输入值
            for (const input of e.target.elements) {
                if (input.name) {
                    if (input.type === 'checkbox') {
                        config[input.name] = input.checked;
                    } else if (input.type === 'number') {
                        config[input.name] = parseFloat(input.value);
                    } else {
                        config[input.name] = input.value;
                    }
                }
            }
            
            try {
                const response = await fetch('/api/config', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(config)
                });
                
                if (response.ok) {
                    showMessage('配置已保存！', 'success');
                } else {
                    throw new Error('保存失败');
                }
            } catch (error) {
                showMessage('保存配置失败: ' + error.message, 'error');
            }
        });

        // 页面加载时获取配置
        loadConfig();
    </script>
</body>
</html>
''';
    
    return Response.ok(
      html,
      headers: {'Content-Type': 'text/html; charset=utf-8'},
    );
  }

  /// 处理获取配置请求
  Response _handleGetConfig(Request request) {
    final settings = AppSettings.instance;
    
    final config = {
      // 网络设置
      'serverUrl': settings.serverUrl,
      'connectionTimeout': settings.connectionTimeout,
      
      // Gotify设置
      'gotifyServerUrl': settings.gotifyServerUrl,
      'gotifyClientToken': settings.gotifyClientToken,
      
      // UI设置
      'floatingChatSize': settings.floatingChatSize,
      'fontScale': settings.fontScale,
      'animationDuration': settings.animationDuration,
      
      // 背景设置
      'wallpaperMode': settings.wallpaperMode.toString(),
    };
    
    return Response.ok(
      jsonEncode(config),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// 处理保存配置请求
  Future<Response> _handleSaveConfig(Request request) async {
    try {
      final body = await request.readAsString();
      final config = jsonDecode(body) as Map<String, dynamic>;
      
      AppLogger.getLogger('WebConfig').info('📝 收到配置更新请求: $config');
      
      final settings = AppSettings.instance;
      
      // 更新配置
      if (config.containsKey('serverUrl') && config['serverUrl'] != null) {
        await settings.updateServerUrl(config['serverUrl'] as String);
      }
      if (config.containsKey('connectionTimeout') && config['connectionTimeout'] != null) {
        final timeout = config['connectionTimeout'];
        if (timeout is int) {
          await settings.updateConnectionTimeout(timeout);
        } else if (timeout is String) {
          await settings.updateConnectionTimeout(int.parse(timeout));
        }
      }
      if (config.containsKey('gotifyServerUrl') && config['gotifyServerUrl'] != null) {
        await settings.updateGotifyServerUrl(config['gotifyServerUrl'] as String);
      }
      if (config.containsKey('gotifyClientToken') && config['gotifyClientToken'] != null) {
        await settings.updateGotifyClientToken(config['gotifyClientToken'] as String);
      }
      if (config.containsKey('floatingChatSize') && config['floatingChatSize'] != null) {
        final size = config['floatingChatSize'];
        if (size is double) {
          await settings.updateFloatingChatSize(size);
        } else if (size is int) {
          await settings.updateFloatingChatSize(size.toDouble());
        } else if (size is String) {
          await settings.updateFloatingChatSize(double.parse(size));
        }
      }
      if (config.containsKey('fontScale') && config['fontScale'] != null) {
        final scale = config['fontScale'];
        if (scale is double) {
          await settings.updateFontScale(scale);
        } else if (scale is String) {
          await settings.updateFontScale(double.parse(scale));
        }
      }
      if (config.containsKey('animationDuration') && config['animationDuration'] != null) {
        final duration = config['animationDuration'];
        if (duration is int) {
          await settings.updateAnimationDuration(duration);
        } else if (duration is String) {
          await settings.updateAnimationDuration(int.parse(duration));
        }
      }
      
      AppLogger.getLogger('WebConfig').info('✅ 配置更新成功');
      
      return Response.ok(
        jsonEncode({'success': true}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      AppLogger.getLogger('WebConfig').severe('❌ 保存配置失败', e, stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
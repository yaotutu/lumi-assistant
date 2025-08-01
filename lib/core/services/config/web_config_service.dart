import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../../config/app_settings.dart';
import '../../utils/app_logger.dart';

/// Web配置服务
/// 
/// 提供与应用内设置页面完全一致的Web配置界面
/// 默认启动，支持局域网访问配置
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

  /// 启动Web配置服务（默认启动）
  Future<String?> start() async {
    if (_isRunning) {
      return _serverUrl;
    }

    try {
      // 创建路由
      final router = Router();
      
      // 主页 - 配置界面
      router.get('/', _handleHomePage);
      
      // API端点 - 与AppSettings完全对应
      router.get('/api/settings', _handleGetAllSettings);
      router.post('/api/settings', _handleSaveAllSettings);
      router.post('/api/settings/reset', _handleResetSettings);
      
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

  /// 处理主页请求 - 完整的设置界面
  Response _handleHomePage(Request request) {
    final html = '''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lumi Assistant 配置中心</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            color: #333;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .header p {
            opacity: 0.9;
            font-size: 1.1em;
        }
        
        .content {
            padding: 40px;
        }
        
        .intro-section {
            text-align: center;
            margin-bottom: 40px;
            padding: 30px;
            background: rgba(255, 255, 255, 0.8);
            border-radius: 15px;
            border: 1px solid #e9ecef;
        }
        
        .intro-section h2 {
            color: #2c3e50;
            margin-bottom: 15px;
        }
        
        .intro-section p {
            color: #6c757d;
            font-size: 1.1em;
        }
        
        .settings-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .setting-section {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 25px;
            border: 1px solid #e9ecef;
            transition: all 0.3s ease;
        }
        
        .setting-section:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
        }
        
        .section-header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }
        
        .section-icon {
            font-size: 1.5em;
            margin-right: 12px;
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .section-title {
            font-size: 1.3em;
            font-weight: 600;
            color: #2c3e50;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #495057;
            font-size: 0.95em;
        }
        
        .form-input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            font-size: 1em;
            transition: all 0.3s ease;
            background: white;
        }
        
        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .form-checkbox {
            display: flex;
            align-items: center;
            margin-top: 10px;
        }
        
        .form-help {
            display: block;
            color: #6c757d;
            font-size: 0.85em;
            margin-top: 5px;
            font-style: italic;
        }
        
        .actions {
            text-align: center;
            padding-top: 30px;
            border-top: 2px solid #e9ecef;
        }
        
        .btn {
            display: inline-block;
            padding: 15px 30px;
            margin: 0 10px;
            border: none;
            border-radius: 10px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            min-width: 150px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }
        
        .status-message {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 10px;
            color: white;
            font-weight: 500;
            opacity: 0;
            transform: translateX(100%);
            transition: all 0.3s ease;
            z-index: 1000;
        }
        
        .status-message.show {
            opacity: 1;
            transform: translateX(0);
        }
        
        .status-success {
            background: #28a745;
        }
        
        .status-error {
            background: #dc3545;
        }
        
        /* 主题色彩 */
        .network-theme { background: linear-gradient(135deg, #56ab2f, #a8e6cf); }
        .gotify-theme { background: linear-gradient(135deg, #667eea, #764ba2); }
        .weather-theme { background: linear-gradient(135deg, #3498db, #5dade2); }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌟 Lumi Assistant</h1>
            <p>智能语音助手 - 配置中心</p>
        </div>
        
        <div class="content">
            <div class="intro-section">
                <h2>🌐 网络配置中心</h2>
                <p>专为闲置设备设计，无需手动输入繁琐的服务器地址和令牌</p>
            </div>
            
            <div class="settings-container">
                <!-- 网络连接设置 -->
                <div class="setting-section">
                    <div class="section-header">
                        <div class="section-icon network-theme">🌐</div>
                        <div class="section-title">网络连接设置</div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="serverUrl">服务器地址</label>
                        <input type="text" class="form-input" id="serverUrl" placeholder="ws://192.168.1.100:8000">
                        <small class="form-help">语音助手后端服务器的WebSocket地址</small>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="connectionTimeout">连接超时（秒）</label>
                        <input type="number" class="form-input" id="connectionTimeout" min="5" max="30" value="10">
                        <small class="form-help">网络连接的超时时间</small>
                    </div>
                </div>
                
                <!-- Gotify通知设置 -->
                <div class="setting-section">
                    <div class="section-header">
                        <div class="section-icon gotify-theme">🔔</div>
                        <div class="section-title">Gotify 通知设置</div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="gotifyServerUrl">Gotify 服务器地址</label>
                        <input type="text" class="form-input" id="gotifyServerUrl" placeholder="http://192.168.1.100:8088">
                        <small class="form-help">Gotify 推送服务的HTTP地址</small>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="gotifyClientToken">Gotify 客户端令牌</label>
                        <input type="text" class="form-input" id="gotifyClientToken" placeholder="输入您的Client Token">
                        <small class="form-help">用于接收通知的客户端令牌</small>
                    </div>
                </div>
            </div>
            
            <!-- 天气设置 -->
            <div class="setting-section">
                <div class="section-header">
                    <div class="section-icon weather-theme">🌤️</div>
                    <div class="section-title">天气服务设置</div>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="weatherEnabled">启用天气服务</label>
                    <select class="form-input" id="weatherEnabled">
                        <option value="true">启用</option>
                        <option value="false">禁用</option>
                    </select>
                    <small class="form-help">是否在主界面显示天气信息</small>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="weatherServiceType">天气服务类型</label>
                    <select class="form-input" id="weatherServiceType">
                        <option value="mock">模拟数据</option>
                        <option value="qweather">和风天气</option>
                        <option value="openweather">OpenWeather（即将支持）</option>
                    </select>
                    <small class="form-help">选择天气数据来源</small>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="weatherLocation">位置</label>
                    <input type="text" class="form-input" id="weatherLocation" placeholder="101010100 或 116.41,39.92">
                    <small class="form-help">
                        请使用城市ID（如：101010100）或经纬度坐标（如：116.41,39.92）<br>
                        <a href="https://github.com/qwd/LocationList" target="_blank" style="color: #667eea;">查询城市ID</a>
                    </small>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="weatherUpdateInterval">更新间隔（分钟）</label>
                    <input type="number" class="form-input" id="weatherUpdateInterval" min="10" max="120" value="30">
                    <small class="form-help">天气信息刷新频率</small>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="qweatherApiKey">和风天气 API Key</label>
                    <input type="text" class="form-input" id="qweatherApiKey" placeholder="输入您的API密钥">
                    <small class="form-help">前往 <a href="https://console.qweather.com/" target="_blank" style="color: #667eea;">console.qweather.com</a> 申请</small>
                </div>
            </div>
            
            <div class="actions">
                <button class="btn btn-primary" onclick="saveSettings()">💾 保存设置</button>
                <button class="btn btn-secondary" onclick="loadSettings()">🔄 重新加载</button>
                <button class="btn btn-danger" onclick="resetSettings()">🚨 重置全部</button>
            </div>
        </div>
    </div>
    
    <div id="statusMessage" class="status-message"></div>
    
    <script>
        // 初始化页面
        document.addEventListener('DOMContentLoaded', function() {
            loadSettings();
            initInputValidation();
        });
        
        // 初始化输入框验证
        function initInputValidation() {
            // 服务器地址验证
            const serverUrlInput = document.getElementById('serverUrl');
            serverUrlInput.addEventListener('blur', () => {
                const value = serverUrlInput.value;
                if (value && !value.startsWith('ws://') && !value.startsWith('wss://')) {
                    showMessage('服务器地址应以 ws:// 或 wss:// 开头', 'error');
                }
            });
            
            // Gotify服务器地址验证
            const gotifyUrlInput = document.getElementById('gotifyServerUrl');
            gotifyUrlInput.addEventListener('blur', () => {
                const value = gotifyUrlInput.value;
                if (value && !value.startsWith('http://') && !value.startsWith('https://')) {
                    showMessage('Gotify服务器地址应以 http:// 或 https:// 开头', 'error');
                }
            });
        }
        
        // 加载设置
        async function loadSettings() {
            try {
                const response = await fetch('/api/settings');
                const settings = await response.json();
                
                // 填充表单
                Object.keys(settings).forEach(key => {
                    const element = document.getElementById(key);
                    if (element) {
                        if (element.type === 'checkbox') {
                            element.checked = settings[key];
                        } else if (element.tagName === 'SELECT') {
                            // 处理select元素
                            element.value = settings[key]?.toString() || '';
                        } else {
                            element.value = settings[key] || '';
                        }
                    }
                });
                
                showMessage('设置加载成功', 'success');
            } catch (error) {
                showMessage('加载设置失败: ' + error.message, 'error');
            }
        }
        
        // 保存设置
        async function saveSettings() {
            try {
                const settings = {};
                const inputs = document.querySelectorAll('.form-input');
                
                inputs.forEach(input => {
                    if (input.type === 'number') {
                        settings[input.id] = parseInt(input.value);
                    } else if (input.tagName === 'SELECT') {
                        // 处理select元素
                        if (input.id === 'weatherEnabled') {
                            settings[input.id] = input.value === 'true';
                        } else {
                            settings[input.id] = input.value;
                        }
                    } else {
                        settings[input.id] = input.value;
                    }
                });
                
                const response = await fetch('/api/settings', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(settings)
                });
                
                if (response.ok) {
                    showMessage('设置保存成功', 'success');
                } else {
                    throw new Error('保存失败');
                }
            } catch (error) {
                showMessage('保存设置失败: ' + error.message, 'error');
            }
        }
        
        // 重置设置
        async function resetSettings() {
            if (confirm('确定要重置所有设置吗？此操作不可撤销。')) {
                try {
                    const response = await fetch('/api/settings/reset', {
                        method: 'POST'
                    });
                    
                    if (response.ok) {
                        showMessage('设置重置成功', 'success');
                        setTimeout(loadSettings, 1000);
                    } else {
                        throw new Error('重置失败');
                    }
                } catch (error) {
                    showMessage('重置设置失败: ' + error.message, 'error');
                }
            }
        }
        
        // 显示消息
        function showMessage(message, type) {
            const messageEl = document.getElementById('statusMessage');
            messageEl.textContent = message;
            messageEl.className = 'status-message status-' + type + ' show';
            
            setTimeout(() => {
                messageEl.classList.remove('show');
            }, 3000);
        }
    </script>
</body>
</html>
    ''';

    return Response.ok(
      html,
      headers: {'Content-Type': 'text/html; charset=utf-8'},
    );
  }

  /// 获取网络和通知相关设置
  Response _handleGetAllSettings(Request request) {
    final settings = AppSettings.instance;
    
    final allSettings = {
      // 网络设置
      'serverUrl': settings.serverUrl,
      'connectionTimeout': settings.connectionTimeout,
      
      // Gotify设置
      'gotifyServerUrl': settings.gotifyServerUrl,
      'gotifyClientToken': settings.gotifyClientToken,
      
      // 天气设置
      'weatherEnabled': settings.weatherEnabled,
      'weatherServiceType': settings.weatherServiceType,
      'weatherLocation': settings.weatherLocation,
      'weatherUpdateInterval': settings.weatherUpdateInterval,
      'qweatherApiKey': settings.qweatherApiKey,
    };
    
    return Response.ok(
      jsonEncode(allSettings),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// 保存网络和通知设置
  Future<Response> _handleSaveAllSettings(Request request) async {
    try {
      final body = await request.readAsString();
      final settings = jsonDecode(body) as Map<String, dynamic>;
      
      AppLogger.getLogger('WebConfig').info('📝 收到网络配置更新: ${settings.keys.toList()}');
      
      final appSettings = AppSettings.instance;
      
      // 网络设置
      if (settings.containsKey('serverUrl')) {
        await appSettings.updateServerUrl(settings['serverUrl'].toString());
      }
      if (settings.containsKey('connectionTimeout')) {
        await appSettings.updateConnectionTimeout(_parseInt(settings['connectionTimeout']));
      }
      
      // Gotify设置
      if (settings.containsKey('gotifyServerUrl')) {
        await appSettings.updateGotifyServerUrl(settings['gotifyServerUrl'].toString());
      }
      if (settings.containsKey('gotifyClientToken')) {
        await appSettings.updateGotifyClientToken(settings['gotifyClientToken'].toString());
      }
      
      // 天气设置
      if (settings.containsKey('weatherEnabled')) {
        await appSettings.updateWeatherEnabled(settings['weatherEnabled'] as bool);
      }
      if (settings.containsKey('weatherServiceType')) {
        await appSettings.updateWeatherServiceType(settings['weatherServiceType'].toString());
      }
      if (settings.containsKey('weatherLocation')) {
        await appSettings.updateWeatherLocation(settings['weatherLocation'].toString());
      }
      if (settings.containsKey('weatherUpdateInterval')) {
        await appSettings.updateWeatherUpdateInterval(_parseInt(settings['weatherUpdateInterval']));
      }
      if (settings.containsKey('qweatherApiKey')) {
        await appSettings.updateQweatherApiKey(settings['qweatherApiKey'].toString());
      }
      
      AppLogger.getLogger('WebConfig').info('✅ 设置更新完成');
      
      return Response.ok(
        jsonEncode({'success': true, 'message': '设置保存成功'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      AppLogger.getLogger('WebConfig').severe('❌ 保存设置失败', e, stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': '保存设置失败: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 重置所有设置
  Future<Response> _handleResetSettings(Request request) async {
    try {
      await AppSettings.instance.resetAllSettings();
      
      AppLogger.getLogger('WebConfig').info('🔄 所有设置已重置');
      
      return Response.ok(
        jsonEncode({'success': true, 'message': '设置重置成功'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      AppLogger.getLogger('WebConfig').severe('❌ 重置设置失败', e, stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': '重置设置失败: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // 辅助方法：解析数据类型
  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.parse(value);
    return 0;
  }
}
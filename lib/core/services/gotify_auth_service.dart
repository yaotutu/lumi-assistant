import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

/// Gotify 认证服务
/// 
/// 用于自动创建客户端并获取令牌
class GotifyAuthService {
  /// 创建新的客户端并获取令牌
  /// 
  /// 参数：
  /// - serverUrl: Gotify 服务器地址
  /// - username: 用户名
  /// - password: 密码
  /// - clientName: 客户端名称（默认：Lumi Assistant）
  /// 
  /// 返回：客户端令牌
  static Future<String?> createClientAndGetToken({
    required String serverUrl,
    required String username,
    required String password,
    String clientName = 'Lumi Assistant',
  }) async {
    try {
      AppLogger.getLogger('GotifyAuth').info('🔐 开始创建 Gotify 客户端');
      
      // 1. 首先获取用户认证令牌
      // 注意：较新版本的 Gotify 使用 /current/user/login
      var authResponse = await http.post(
        Uri.parse('$serverUrl/current/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': username,
          'pass': password,
        }),
      );
      
      // 如果新 API 路径失败，尝试旧版本路径
      if (authResponse.statusCode == 404) {
        AppLogger.getLogger('GotifyAuth').info('尝试旧版本 API 路径');
        authResponse = await http.post(
          Uri.parse('$serverUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': username,
            'pass': password,
          }),
        );
      }
      
      if (authResponse.statusCode != 200) {
        AppLogger.getLogger('GotifyAuth').severe(
          '❌ 登录失败: ${authResponse.statusCode} ${authResponse.body}'
        );
        return null;
      }
      
      final authData = jsonDecode(authResponse.body);
      final userToken = authData['token'];
      
      AppLogger.getLogger('GotifyAuth').info('✅ 登录成功');
      
      // 2. 使用用户令牌创建客户端
      final createResponse = await http.post(
        Uri.parse('$serverUrl/client'),
        headers: {
          'Content-Type': 'application/json',
          'X-Gotify-Key': userToken,
        },
        body: jsonEncode({
          'name': clientName,
        }),
      );
      
      if (createResponse.statusCode != 200) {
        // 如果创建失败，可能是客户端已存在，尝试获取现有客户端
        AppLogger.getLogger('GotifyAuth').warning('⚠️ 创建客户端失败，尝试获取现有客户端');
        
        final clientsResponse = await http.get(
          Uri.parse('$serverUrl/client'),
          headers: {'X-Gotify-Key': userToken},
        );
        
        if (clientsResponse.statusCode == 200) {
          final clients = jsonDecode(clientsResponse.body) as List;
          // 查找同名客户端
          final existingClient = clients.firstWhere(
            (client) => client['name'] == clientName,
            orElse: () => null,
          );
          
          if (existingClient != null) {
            AppLogger.getLogger('GotifyAuth').info('✅ 找到现有客户端');
            return existingClient['token'];
          }
        }
        
        AppLogger.getLogger('GotifyAuth').severe(
          '❌ 无法创建或获取客户端: ${createResponse.statusCode}'
        );
        return null;
      }
      
      final clientData = jsonDecode(createResponse.body);
      final clientToken = clientData['token'];
      
      AppLogger.getLogger('GotifyAuth').info('✅ 客户端创建成功');
      AppLogger.getLogger('GotifyAuth').info('📱 客户端令牌: $clientToken');
      
      return clientToken;
      
    } catch (e, stackTrace) {
      AppLogger.getLogger('GotifyAuth').severe(
        '❌ 创建客户端失败', e, stackTrace
      );
      return null;
    }
  }
  
}
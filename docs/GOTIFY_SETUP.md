# Gotify 设置说明

## 步骤 1：获取客户端令牌

1. 打开浏览器访问：http://YOUR_GOTIFY_SERVER
2. 登录（用户名：YOUR_USERNAME，密码：YOUR_PASSWORD）
3. 点击左侧菜单 "**Clients**"
4. 点击右上角 "**CREATE CLIENT**" 按钮
5. 输入客户端名称（例如：Lumi Assistant）
6. 点击 "**CREATE**"
7. 复制生成的 **Token**

## 步骤 2：配置应用

### 方法 A：通过设置页面（推荐）

1. 打开应用设置
2. 进入 "Gotify 通知配置"
3. 输入：
   - 服务器地址：`http://YOUR_GOTIFY_SERVER`
   - 客户端令牌：（粘贴步骤1获得的令牌）
4. 点击"测试连接"
5. 启用 Gotify 服务

### 方法 B：直接修改代码（快速测试）

编辑 `lib/core/services/gotify_service.dart`，在第 24 行后添加：

```dart
// 临时硬编码配置
static const String _tempToken = "YOUR_CLIENT_TOKEN_HERE";
```

然后修改第 134 行：
```dart
final url = '$wsUrl/stream?token=$_tempToken';
```

## 步骤 3：发送测试消息

使用您截图中的应用令牌发送测试：

```bash
# 使用"动态域名解析"应用
curl "http://YOUR_GOTIFY_SERVER/message?token=YOUR_APP_TOKEN" \
  -F "title=测试通知" \
  -F "message=Hello from Gotify!" \
  -F "priority=5"

# 或使用"test"应用
curl "http://YOUR_GOTIFY_SERVER/message?token=YOUR_TEST_TOKEN" \
  -F "title=测试通知" \
  -F "message=这是一条测试消息" \
  -F "priority=8"
```

## 注意事项

- **客户端令牌**（Client Token）：用于接收消息
- **应用令牌**（App Token）：用于发送消息
- Gotify 不支持通过 API 创建客户端，必须在 Web 界面操作
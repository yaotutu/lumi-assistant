# Gotify 快速测试指南

## 当前配置
- 服务器地址：http://43.139.248.238:8088
- 状态：已配置服务器地址，等待客户端令牌

## 获取客户端令牌步骤

1. 打开浏览器访问：http://43.139.248.238:8088
2. 使用以下凭据登录：
   - 用户名：yaotutu
   - 密码：redhat
3. 登录后，点击左侧菜单的 "**Clients**"
4. 如果没有客户端，点击 "**CREATE CLIENT**" 创建一个
   - Name: 输入 "Lumi Assistant" 或其他名称
   - 点击 "CREATE"
5. 复制显示的 **Token**（一长串字符）

## 配置令牌

1. 打开文件：`lib/core/services/gotify_service.dart`
2. 找到第 28 行：
   ```dart
   static const String _tempClientToken = 'YOUR_CLIENT_TOKEN'; // 请替换为您的客户端令牌
   ```
3. 将 `YOUR_CLIENT_TOKEN` 替换为您复制的令牌
4. 保存文件

## 测试

1. 运行应用：`flutter run -d 1W11833968`
2. 应用启动后，Gotify 服务会自动连接
3. 在 Gotify 服务器上发送测试消息：
   - 登录 Gotify 管理界面
   - 点击 "**APPS**"
   - 选择一个应用或创建新应用
   - 使用应用的 Token 发送测试消息

## 发送测试消息

使用 curl 命令发送测试消息（需要应用令牌，不是客户端令牌）：

```bash
curl "http://43.139.248.238:8088/message?token=YOUR_APP_TOKEN" \
  -F "title=测试通知" \
  -F "message=这是一条来自 Gotify 的测试消息" \
  -F "priority=5"
```

## 注意事项

- 客户端令牌（Client Token）用于接收消息
- 应用令牌（App Token）用于发送消息
- 两个令牌不同，不要混淆
- 通知会显示在应用左侧的通知气泡中
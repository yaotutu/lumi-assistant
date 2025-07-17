# MCP (Model Context Protocol) 协议深度分析与实现总结

## 协议概述

Model Context Protocol (MCP) 是由 Anthropic 推出的开放协议，旨在标准化应用程序向大语言模型（LLM）提供上下文的方式。正如官方所说，它就像是"AI应用程序的USB-C端口"。

### 核心信息
- **最新版本**: 2025-06-18
- **通信协议**: 基于 JSON-RPC 2.0
- **架构模式**: 客户端-服务器架构
- **官方网站**: https://modelcontextprotocol.io/

## 架构设计

### 组件关系
```
Host (LLM应用) 
  ↓
Client (1:1连接)
  ↓  
Server (MCP服务器)
  ↓
Data Sources/Tools
```

### 传输方式（仅两种官方标准）

#### 1. Stdio Transport
- **用途**: 本地进程间通信
- **机制**: 通过 stdin/stdout 交换 JSON-RPC 消息
- **适用场景**: 命令行工具、本地服务、Shell脚本集成

#### 2. Streamable HTTP Transport
- **用途**: 远程MCP服务器通信
- **机制**: HTTP POST + 可选的 Server-Sent Events (SSE)
- **特性**: 
  - 支持实时数据流
  - 状态化会话管理
  - 可恢复连接
  - 会话ID支持

## 核心功能

### 1. Resources（资源）
- **定义**: 服务器暴露给客户端的数据和内容
- **URI系统**: `protocol://host/path` 格式
- **类型**: 文件内容、数据库记录、API响应、系统数据等
- **API**:
  - `resources/list`: 列出可用资源
  - `resources/read`: 读取资源内容

### 2. Tools（工具）
- **定义**: LLM可以执行的功能函数
- **特性**: 模型控制的，允许AI自动调用（需人工批准）
- **参数**: 使用 JSON Schema 定义输入参数
- **API**:
  - `tools/list`: 列出可用工具
  - `tools/call`: 调用工具

### 3. Prompts（提示模板）
- **定义**: 可重用的提示模板和工作流
- **用途**: 创建模板化消息工作流
- **API**:
  - `prompts/list`: 列出可用提示模板
  - `prompts/get`: 获取提示模板

### 4. Sampling（采样）
- **定义**: 服务器发起的LLM交互
- **用途**: 实现代理行为和复杂工作流

## 协议细节

### 初始化流程
```json
// 客户端发送初始化请求
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-06-18",
    "capabilities": {
      "roots": { "listChanged": true },
      "sampling": {}
    },
    "clientInfo": {
      "name": "LumiAssistant",
      "version": "1.0.0"
    }
  }
}
```

### 消息类型
1. **请求 (Requests)**: 期望响应的消息
2. **响应 (Results)**: 成功的请求响应
3. **错误 (Errors)**: 失败的请求响应  
4. **通知 (Notifications)**: 单向消息，无需响应

### HTTP传输细节
- **Content-Type**: `application/json`
- **Accept**: `application/json, text/event-stream`
- **Session ID**: 通过 `Mcp-Session-Id` 头传递
- **SSE格式**: `event: message\ndata: {...}\n\n`

## 安全考虑

### 核心原则
- **用户同意**: 强调用户同意和控制
- **显式授权**: 数据访问需要明确授权
- **隐私保护**: 专注于用户隐私
- **工具安全**: 安全的工具执行
- **服务器可见性限制**: 限制服务器对提示的可见性

### 最佳实践
- 构建健壮的同意流程
- 记录安全影响
- 实现访问控制
- 遵循安全最佳实践

## 实现总结

### 我们的改进
1. **协议合规性**:
   - 移除非标准传输模式（websocket, sse, http）
   - 只保留官方的两种标准模式
   - 更新协议版本到 2025-06-18

2. **StreamableHttpMcpClient 增强**:
   - 完整的MCP初始化握手
   - Session ID 支持
   - 正确的HTTP头设置
   - SSE响应解析
   - Resources 和 Prompts 支持

3. **UnifiedMcpManager 扩展**:
   - 添加 Resources 管理功能
   - 改进错误处理和日志
   - 统一的资源访问接口

4. **接口完善**:
   - 扩展 McpClient 接口支持完整MCP功能
   - 添加 UnifiedMcpResource 数据模型
   - 改进类型安全性

### 关键代码示例

#### 初始化连接
```dart
final result = await _sendRequest('initialize', {
  'protocolVersion': '2025-06-18',
  'capabilities': {
    'roots': {'listChanged': true},
    'sampling': {}
  },
  'clientInfo': {
    'name': 'LumiAssistant',
    'version': '1.0.0'
  }
});
```

#### 资源访问
```dart
// 列出资源
final resources = await client.listResources();

// 读取资源
final content = await client.readResource('file:///path/to/resource');
```

#### 工具调用
```dart
final result = await client.callTool('tool_name', {
  'param1': 'value1',
  'param2': 'value2'
});
```

## 技术收获

1. **协议标准的重要性**: 严格遵循官方规范而不是自己创造"标准"
2. **文档驱动开发**: 深入研究官方文档比猜测更有效
3. **版本管理**: 使用最新的协议版本确保兼容性
4. **错误处理**: 实现健壮的错误处理机制
5. **安全第一**: 从设计阶段就考虑安全性

## 下一步计划

1. **完善 Stdio Transport**: 实现完整的 Stdio 客户端
2. **JSON Schema 验证**: 加强工具参数验证
3. **安全机制**: 实现完整的权限控制系统
4. **性能优化**: 连接池、缓存等优化
5. **监控和日志**: 完善的调试和监控机制

## 参考资源

- [MCP 官方网站](https://modelcontextprotocol.io/)
- [MCP 规范文档](https://modelcontextprotocol.io/specification)
- [MCP 架构文档](https://modelcontextprotocol.io/docs/concepts/architecture)
- [MCP 传输机制](https://modelcontextprotocol.io/docs/concepts/transports)
- [MCP SDK 文档](https://modelcontextprotocol.io/quickstart)

---

*最后更新: 2025-01-17*
*作者: Claude Code Assistant*
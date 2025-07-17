# MCP Multi-Transport Implementation

## 概述

本文档详细描述了在Lumi Assistant Flutter应用中实现的多传输模式MCP（Model Context Protocol）架构。该实现支持WebSocket、SSE（Server-Sent Events）、HTTP和Stdio四种传输模式，为设备控制提供了灵活的通信方式。

## 架构设计

### 核心组件

#### 1. MCP传输模式枚举 (McpTransportMode)
```dart
enum McpTransportMode {
  websocket,  // 全双工实时通信
  sse,        // 服务端推送
  http,       // 简单请求响应
  stdio,      // 本地进程通信
}
```

#### 2. MCP服务器配置 (McpServerConfig)
统一的配置类，支持所有传输模式：
- 基础信息：id、name、description
- 传输配置：transport、url、headers
- 运行配置：enabled、autoStart、priority
- 能力配置：tools、capabilities、category

#### 3. MCP客户端接口 (McpClient)
抽象接口定义了所有MCP客户端的统一行为：
```dart
abstract class McpClient {
  Future<void> connect();
  Future<void> disconnect();
  bool get isConnected;
  Future<List<dynamic>> listTools();
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments);
}
```

### 传输模式实现

#### 1. WebSocket传输模式 (WebSocketMcpClient)
**特点**：
- 全双工通信，实时性最佳
- 持久连接，低延迟
- 适合需要频繁交互的场景

**实现要点**：
- 基于Dart的WebSocket API
- 支持自定义headers（认证、设备标识等）
- 实现JSON-RPC 2.0协议
- 异步请求-响应管理

#### 2. SSE传输模式 (SseMcpClient)
**特点**：
- 服务端主动推送能力
- 单向流式数据传输
- 适合状态监控和通知场景

**实现要点**：
- 基于HTTP的长连接
- 事件流解析（data: 前缀）
- 结合HTTP POST发送请求
- 自动重连机制

#### 3. HTTP传输模式 (HttpMcpClient)
**特点**：
- 简单的请求-响应模式
- 无状态通信
- 适合基本的设备控制命令

**实现要点**：
- 标准HTTP POST请求
- JSON-RPC 2.0封装
- 连接池管理
- 错误重试机制

#### 4. Stdio传输模式 (计划中)
**特点**：
- 本地进程通信
- 高性能、低延迟
- 适合本地MCP服务器

**实现要点**：
- 进程启动和管理
- 标准输入/输出通信
- 生命周期管理

### 统一管理器 (UnifiedMcpManager)

#### 核心功能

1. **配置管理**：
   - 内置配置加载
   - 用户配置覆盖
   - 配置持久化

2. **服务器管理**：
   - 多服务器并行运行
   - 优先级路由
   - 自动故障转移

3. **工具调用**：
   - 统一的工具调用接口
   - 自动服务器选择
   - 错误处理和重试

#### 工具路由策略

```dart
Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
  // 1. 查找提供该工具的服务器
  final availableServers = _findServersForTool(toolName);
  
  // 2. 按优先级排序（内置服务器 > 外部服务器）
  availableServers.sort((a, b) => b.priority.compareTo(a.priority));
  
  // 3. 依次尝试调用，直到成功或全部失败
  for (final server in availableServers) {
    try {
      return await _callToolOnServer(server, toolName, arguments);
    } catch (e) {
      // 记录错误，尝试下一个服务器
      continue;
    }
  }
  
  throw Exception('所有服务器调用都失败了');
}
```

## 配置系统

### 配置文件格式

```json
{
  "mcpServers": {
    "websocket_server": {
      "type": "external",
      "transport": "websocket",
      "name": "WebSocket示例服务器",
      "url": "ws://localhost:8080/mcp",
      "headers": {
        "Authorization": "Bearer token",
        "Device-Id": "flutter-client"
      },
      "enabled": true,
      "autoStart": true,
      "tools": ["example_tool"],
      "priority": 50
    },
    "sse_server": {
      "type": "external",
      "transport": "sse",
      "name": "SSE示例服务器",
      "url": "http://localhost:8080/mcp/stream",
      "headers": {
        "Accept": "text/event-stream"
      },
      "enabled": true,
      "autoStart": false,
      "tools": ["notification_tool"],
      "priority": 40
    },
    "http_server": {
      "type": "external",
      "transport": "http",
      "name": "HTTP示例服务器",
      "url": "http://localhost:8080/mcp/api",
      "headers": {
        "Content-Type": "application/json"
      },
      "enabled": true,
      "autoStart": false,
      "tools": ["simple_tool"],
      "priority": 30
    }
  }
}
```

### 工厂方法

为了简化配置创建，提供了便捷的工厂方法：

```dart
// WebSocket服务器
final wsConfig = McpServerConfig.websocket(
  id: 'ws_server',
  name: 'WebSocket服务器',
  description: '实时通信服务器',
  url: 'ws://localhost:8080/mcp',
  headers: {'Authorization': 'Bearer token'},
  tools: ['tool1', 'tool2'],
);

// SSE服务器
final sseConfig = McpServerConfig.sse(
  id: 'sse_server',
  name: 'SSE服务器',
  description: '事件推送服务器',
  url: 'http://localhost:8080/mcp/stream',
  tools: ['notification_tool'],
);

// HTTP服务器
final httpConfig = McpServerConfig.http(
  id: 'http_server',
  name: 'HTTP服务器',
  description: 'REST API服务器',
  url: 'http://localhost:8080/mcp/api',
  tools: ['simple_tool'],
);
```

## 测试框架

### 单元测试

实现了全面的单元测试套件：

1. **配置测试**：
   - 工厂方法创建
   - 序列化/反序列化
   - 字段验证

2. **客户端测试**：
   - 客户端创建
   - 连接状态管理
   - 基本功能验证

3. **服务器测试**：
   - 嵌入式服务器初始化
   - 工具列表获取
   - 工具调用功能

4. **管理器测试**：
   - 初始化流程
   - 统计信息
   - 配置管理

### 集成测试

通过MCP测试页面提供可视化测试：

1. **传输模式测试**：
   - 配置创建测试
   - 客户端连接测试
   - 多模式兼容性测试

2. **功能测试**：
   - 工具列表获取
   - 设备控制功能
   - 错误处理

## 性能优化

### 连接管理

1. **连接池**：
   - HTTP客户端连接复用
   - 连接超时管理
   - 资源自动释放

2. **异步处理**：
   - 非阻塞工具调用
   - 并发请求处理
   - 超时机制

### 内存管理

1. **资源清理**：
   - 自动连接关闭
   - 定时器清理
   - 内存泄漏防护

2. **缓存策略**：
   - 工具定义缓存
   - 配置缓存
   - 智能失效机制

## 错误处理

### 分层错误处理

1. **传输层错误**：
   - 网络连接失败
   - 协议错误
   - 超时处理

2. **应用层错误**：
   - MCP协议错误
   - 工具调用失败
   - 参数验证错误

3. **系统层错误**：
   - 权限不足
   - 资源不可用
   - 配置错误

### 自动恢复机制

1. **连接重试**：
   - 指数退避算法
   - 最大重试次数
   - 故障转移

2. **服务器切换**：
   - 优先级路由
   - 健康检查
   - 动态负载均衡

## 扩展指南

### 添加新传输模式

1. **实现MCP客户端**：
   ```dart
   class NewTransportMcpClient implements McpClient {
     // 实现所有必需方法
   }
   ```

2. **更新配置系统**：
   - 添加新的传输模式枚举
   - 实现工厂方法
   - 更新序列化逻辑

3. **更新管理器**：
   - 添加客户端创建逻辑
   - 更新连接管理
   - 添加相关测试

### 添加新工具

1. **内置工具**：
   - 在EmbeddedMcpServer中实现
   - 添加JSON Schema
   - 实现工具逻辑

2. **外部工具**：
   - 配置外部服务器
   - 更新工具列表
   - 测试工具功能

## 部署建议

### 开发环境

1. **本地测试**：
   - 使用内置服务器
   - HTTP模式用于调试
   - 详细日志输出

2. **集成测试**：
   - 模拟外部服务器
   - 多传输模式测试
   - 性能基准测试

### 生产环境

1. **传输模式选择**：
   - 实时需求：WebSocket
   - 通知推送：SSE
   - 简单命令：HTTP
   - 本地服务：Stdio

2. **配置管理**：
   - 环境变量配置
   - 安全认证
   - 监控和日志

## 总结

本MCP多传输模式实现提供了：

1. **灵活性**：支持多种传输协议，适应不同使用场景
2. **可扩展性**：模块化设计，易于添加新传输模式
3. **可靠性**：完善的错误处理和自动恢复机制
4. **性能**：优化的连接管理和资源利用
5. **易用性**：统一的API和丰富的配置选项

该实现为Lumi Assistant提供了强大的设备控制能力，能够适应各种部署环境和使用需求。
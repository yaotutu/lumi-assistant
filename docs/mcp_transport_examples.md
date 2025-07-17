# MCP 多传输模式配置示例

## 支持的传输模式

Flutter客户端现在支持以下MCP传输模式：

### 1. WebSocket传输 (默认)
```dart
final wsConfig = McpServerConfig.websocket(
  id: 'python_server',
  name: 'Python后端服务器',
  description: 'Xiaozhi Python后端的MCP服务',
  url: 'ws://192.168.110.199:8000/mcp',
  headers: {
    'Authorization': 'Bearer your-token',
    'Device-Id': 'flutter-client'
  },
  enabled: true,
  autoStart: true,
  tools: ['device_control', 'system_info'],
  priority: 50,
);
```

### 2. Server-Sent Events (SSE)
```dart
final sseConfig = McpServerConfig.sse(
  id: 'home_assistant',
  name: 'Home Assistant',
  description: 'Home Assistant MCP服务器',
  url: 'http://192.168.1.100:8123/mcp/stream',
  headers: {
    'Authorization': 'Bearer ha-token',
    'Content-Type': 'text/plain'
  },
  enabled: true,
  autoStart: false,
  tools: ['light_control', 'climate_control'],
  priority: 30,
);
```

### 3. HTTP/REST传输
```dart
final httpConfig = McpServerConfig.http(
  id: 'rest_api',
  name: 'REST API服务',
  description: 'HTTP REST API MCP服务',
  url: 'http://localhost:3000/api/mcp',
  headers: {
    'Authorization': 'Bearer api-token',
    'Content-Type': 'application/json'
  },
  enabled: true,
  autoStart: false,
  tools: ['data_query', 'file_operations'],
  priority: 20,
);
```

### 4. Stdio传输 (本地进程)
```dart
final stdioConfig = McpServerConfig.stdio(
  id: 'local_fs',
  name: '本地文件系统',
  description: '本地文件系统MCP服务',
  command: 'npx',
  args: [
    '-y',
    '@modelcontextprotocol/server-filesystem',
    '/Users/username/Documents'
  ],
  workingDirectory: '/tmp',
  environment: {
    'NODE_ENV': 'production',
    'MCP_LOG_LEVEL': 'info'
  },
  enabled: false,
  autoStart: false,
  tools: ['file_read', 'file_write', 'directory_list'],
  priority: 10,
);
```

### 5. 嵌入式服务器 (最高优先级)
```dart
final embeddedConfig = McpServerConfig.embedded(
  id: 'embedded_device',
  name: '嵌入式设备控制',
  description: '内置的设备控制MCP服务器',
  enabled: true,
  autoStart: true,
  tools: [
    'set_brightness',
    'get_current_brightness',
    'adjust_volume',
    'get_current_volume',
    'get_system_info'
  ],
  priority: 100, // 最高优先级
);
```

## JSON配置文件示例

```json
{
  "mcpServers": {
    "embedded_device": {
      "type": "embedded",
      "transport": "websocket",
      "name": "嵌入式设备控制",
      "description": "内置的设备控制MCP服务器",
      "enabled": true,
      "autoStart": true,
      "tools": [
        "set_brightness",
        "get_current_brightness",
        "adjust_volume",
        "get_current_volume",
        "get_system_info"
      ],
      "priority": 100
    },
    "python_server": {
      "type": "external",
      "transport": "websocket",
      "name": "Python后端服务器",
      "description": "Xiaozhi Python后端的MCP服务",
      "url": "ws://192.168.110.199:8000/mcp",
      "headers": {
        "Authorization": "Bearer your-token",
        "Device-Id": "flutter-client"
      },
      "enabled": true,
      "autoStart": true,
      "tools": ["device_control", "system_info"],
      "priority": 50
    },
    "home_assistant": {
      "type": "external",
      "transport": "sse",
      "name": "Home Assistant",
      "description": "Home Assistant MCP服务器",
      "url": "http://192.168.1.100:8123/mcp/stream",
      "headers": {
        "Authorization": "Bearer ha-token"
      },
      "enabled": false,
      "autoStart": false,
      "tools": ["light_control", "climate_control"],
      "priority": 30
    },
    "local_fs": {
      "type": "external",
      "transport": "stdio",
      "name": "本地文件系统",
      "description": "本地文件系统MCP服务",
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/username/Documents"
      ],
      "workingDirectory": "/tmp",
      "environment": {
        "NODE_ENV": "production",
        "MCP_LOG_LEVEL": "info"
      },
      "enabled": false,
      "autoStart": false,
      "tools": ["file_read", "file_write", "directory_list"],
      "priority": 10
    }
  }
}
```

## 传输模式特性对比

| 传输模式 | 实时性 | 复杂度 | 适用场景 | 优先级建议 |
|---------|-------|--------|----------|-----------|
| **Embedded** | 极高 | 低 | 本地设备控制 | 100 (最高) |
| **WebSocket** | 高 | 中 | 实时交互 | 50 |
| **SSE** | 中 | 中 | 状态推送 | 30 |
| **HTTP** | 低 | 低 | 批量操作 | 20 |
| **Stdio** | 中 | 高 | 本地进程 | 10 |

## 使用建议

1. **嵌入式服务器**：用于最关键的本地设备控制，优先级最高
2. **WebSocket**：用于需要实时交互的远程服务
3. **SSE**：用于需要服务端推送的场景
4. **HTTP**：用于简单的API调用和批量操作
5. **Stdio**：用于本地MCP服务进程管理

## 错误处理

每种传输模式都有相应的错误处理机制：

- **连接失败**：自动重连（WebSocket、SSE）
- **超时处理**：可配置超时时间
- **优雅降级**：高优先级服务失败时切换到低优先级服务
- **状态监控**：实时监控每个MCP服务器的状态

## 性能优化

- **嵌入式服务器**：零网络延迟，<1ms响应时间
- **WebSocket**：持久连接，减少连接开销
- **HTTP**：支持连接复用和缓存
- **连接池**：复用连接，减少资源消耗
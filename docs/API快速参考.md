# 小智服务端 API 快速参考

## 📋 目录
- [HTTP REST API](#http-rest-api)
- [WebSocket API](#websocket-api)
- [错误码参考](#错误码参考)
- [数据格式参考](#数据格式参考)

---

## 🌐 HTTP REST API

### OTA升级接口

| 方法 | 路径 | 描述 | 认证 |
|------|------|------|------|
| GET | `/api/ota/` | 获取OTA状态 | ❌ |
| POST | `/api/ota/` | 检查固件更新 | device-id |
| GET | `/api/ota_bin/{filename}` | 下载固件文件 | ❌ |
| OPTIONS | `/api/ota/` | CORS预检 | ❌ |

**POST /api/ota/ 示例**
```bash
curl -X POST "http://localhost:8000/api/ota/" \
  -H "device-id: ESP32-001" \
  -H "Content-Type: application/json" \
  -d '{"application":{"version":"1.0.0"}}'
```

### 视觉分析接口

| 方法 | 路径 | 描述 | 认证 |
|------|------|------|------|
| GET | `/api/vision` | 获取服务状态 | ❌ |
| POST | `/api/vision` | 图片分析 | Bearer Token + device-id |
| OPTIONS | `/api/vision` | CORS预检 | ❌ |

**POST /api/vision 示例**
```bash
curl -X POST "http://localhost:8000/api/vision" \
  -H "Device-Id: your-device-id" \
  -H "Authorization: Bearer your-token" \
  -H "Client-Id: your-client-id" \
  -F "question=描述这张图片" \
  -F "file=@image.jpg"
```

### 配置管理接口

| 方法 | 路径 | 描述 | 认证 |
|------|------|------|------|
| GET | `/api/cfg` | 获取配置状态 | ❌ |
| POST | `/api/cfg` | 更新配置 | ❌ |
| OPTIONS | `/api/cfg` | CORS预检 | ❌ |

---

## 🔌 WebSocket API

### 连接信息
- **URL**: `ws://localhost:8000/`
- **协议**: WebSocket
- **消息格式**: JSON (文本) + 二进制 (音频)

### 客户端消息类型

| 类型 | 描述 | 必需字段 | 可选字段 |
|------|------|----------|----------|
| `hello` | 连接握手 | `type`, `version`, `audio_params` | - |
| `listen` | 语音控制 | `type`, `state` | `mode`, `text` |
| `chat` | 文本聊天 | `type`, `text` | - |
| `image` | 图像处理 | `type`, `image`, `text` | - |
| `iot` | IoT设备控制 | `type`, `device_id`, `action` | `data` |
| `vision` | 视觉处理 | `type`, `cmd` | `data` |
| `mcp` | MCP功能调用 | `type`, `action` | `function_name`, `parameters` |
| `abort` | 中止操作 | `type` | - |

### 服务端响应类型

| 类型 | 描述 | 字段 |
|------|------|------|
| `hello` | 握手响应 | `type`, `version`, `transport`, `session_id`, `audio_params` |
| `stt` | 语音识别结果 | `type`, `text`, `session_id`, `confidence`, `is_final` |
| `tts` | 语音合成状态 | `type`, `state`, `session_id`, `text`, `index`, `audio_codec` |
| `llm` | LLM回复 | `type`, `text`, `session_id`, `emotion`, `is_streaming`, `finish_reason` |
| `error` | 错误消息 | `type`, `code`, `message`, `session_id` |

### 快速示例

**建立连接**
```javascript
const ws = new WebSocket('ws://localhost:8000/');

// 连接成功后发送Hello
ws.onopen = () => {
    ws.send(JSON.stringify({
        type: 'hello',
        version: 1,
        audio_params: {
            format: 'pcm',
            sample_rate: 16000,
            channels: 1,
            frame_duration: 20
        }
    }));
};
```

**发送聊天消息**
```javascript
ws.send(JSON.stringify({
    type: 'chat',
    text: '你好，请介绍一下自己'
}));
```

**语音控制**
```javascript
// 开始语音识别
ws.send(JSON.stringify({
    type: 'listen',
    state: 'start',
    mode: 'manual'
}));

// 停止语音识别
ws.send(JSON.stringify({
    type: 'listen',
    state: 'stop'
}));
```

**图像分析**
```javascript
// 将文件转为base64
const reader = new FileReader();
reader.onload = () => {
    const base64 = reader.result.split(',')[1];
    ws.send(JSON.stringify({
        type: 'image',
        image: base64,
        text: '描述这张图片'
    }));
};
reader.readAsDataURL(imageFile);
```

---

## ❌ 错误码参考

### HTTP状态码

| 状态码 | 含义 | 常见原因 |
|--------|------|---------|
| 200 | 成功 | 请求正常处理 |
| 204 | 无内容 | OPTIONS请求成功 |
| 400 | 请求错误 | 参数缺失/格式错误 |
| 401 | 认证失败 | Token无效/设备ID不匹配 |
| 404 | 资源不存在 | 文件不存在/路径错误 |
| 413 | 载荷过大 | 文件超过5MB限制 |
| 500 | 服务器错误 | 内部处理异常 |
| 503 | 服务不可用 | 服务维护/资源耗尽 |

### 应用错误码

| 错误码 | 描述 | 解决方案 |
|--------|------|---------|
| `INVALID_TOKEN` | Token无效 | 重新获取Token |
| `DEVICE_ID_MISMATCH` | 设备ID不匹配 | 检查设备ID |
| `FILE_TOO_LARGE` | 文件过大 | 压缩图片或选择小文件 |
| `UNSUPPORTED_FORMAT` | 格式不支持 | 使用支持的图片格式 |
| `SERVICE_UNAVAILABLE` | 服务不可用 | 稍后重试 |

### WebSocket关闭码

| 关闭码 | 描述 |
|--------|------|
| 1000 | 正常关闭 |
| 1001 | 端点离开 |
| 1002 | 协议错误 |
| 1003 | 不支持的数据 |
| 1006 | 异常关闭 |
| 1011 | 服务器错误 |

---

## 📊 数据格式参考

### 音频参数

| 参数 | 值 | 描述 |
|------|---|------|
| `format` | `"pcm"` / `"opus"` | 音频格式 |
| `sample_rate` | `16000` / `24000` / `48000` | 采样率(Hz) |
| `channels` | `1` / `2` | 声道数 |
| `frame_duration` | `20` / `40` / `60` | 帧时长(ms) |

**推荐配置**
- 语音识别: PCM, 16kHz, 单声道, 20ms
- 语音合成: Opus, 24kHz, 单声道, 20ms

### 图像格式

| 格式 | 扩展名 | 描述 |
|------|--------|------|
| JPEG | `.jpg`, `.jpeg` | 有损压缩，适合照片 |
| PNG | `.png` | 无损压缩，支持透明 |
| GIF | `.gif` | 支持动画 |
| BMP | `.bmp` | 无压缩位图 |
| WEBP | `.webp` | 现代压缩格式 |

**限制**
- 最大文件大小: 5MB
- 建议分辨率: ≤1920x1080

### 请求头参数

| 参数名 | 位置 | 格式 | 示例 |
|--------|------|------|------|
| `device-id` | Header | 字符串 | `"ESP32-001"` |
| `Authorization` | Header | Bearer Token | `"Bearer abc123..."` |
| `Client-Id` | Header | 字符串 | `"web-client-001"` |
| `Content-Type` | Header | MIME类型 | `"application/json"` |

### 常用消息模板

**Hello消息**
```json
{
    "type": "hello",
    "version": 1,
    "audio_params": {
        "format": "pcm",
        "sample_rate": 16000,
        "channels": 1,
        "frame_duration": 20
    }
}
```

**聊天消息**
```json
{
    "type": "chat",
    "text": "你的问题内容"
}
```

**语音控制消息**
```json
{
    "type": "listen",
    "state": "start|stop|detect",
    "mode": "manual|auto"
}
```

**图像处理消息**
```json
{
    "type": "image",
    "image": "base64-encoded-data",
    "text": "你的问题"
}
```

**IoT控制消息**
```json
{
    "type": "iot",
    "device_id": "设备ID",
    "action": "动作类型",
    "data": {}
}
```

**MCP调用消息**
```json
{
    "type": "mcp",
    "action": "call_function",
    "function_name": "函数名",
    "parameters": {}
}
```

**中止消息**
```json
{
    "type": "abort"
}
```

---

## 🔧 配置参考

### 服务器配置

```yaml
# config.yaml
server:
  ip: "0.0.0.0"
  port: 8000
  token: "your-server-token"

web:
  enabled: true
  port: 8000
  websocket: "ws://localhost:8000/"

log:
  log_level: "info"
  log_format: "json"
```

### 客户端配置

```javascript
const config = {
    websocketUrl: 'ws://localhost:8000/',
    httpApiUrl: 'http://localhost:8000/api',
    reconnectAttempts: 5,
    reconnectDelay: 2000,
    audioConfig: {
        format: 'pcm',
        sampleRate: 16000,
        channels: 1,
        frameDuration: 20
    }
};
```

---

## 🚀 快速开始

### 1. 测试连接
```bash
# 测试HTTP API
curl "http://localhost:8000/api/ota/"

# 测试WebSocket (使用wscat)
npm install -g wscat
wscat -c ws://localhost:8000/
```

### 2. 基础WebSocket客户端
```javascript
const ws = new WebSocket('ws://localhost:8000/');

ws.onopen = () => {
    // 发送Hello消息
    ws.send(JSON.stringify({
        type: 'hello',
        version: 1,
        audio_params: {
            format: 'pcm',
            sample_rate: 16000,
            channels: 1,
            frame_duration: 20
        }
    }));
};

ws.onmessage = (event) => {
    if (event.data instanceof ArrayBuffer) {
        console.log('收到音频数据:', event.data.byteLength, 'bytes');
    } else {
        const message = JSON.parse(event.data);
        console.log('收到消息:', message);
    }
};

// 发送聊天消息
function sendChat(text) {
    ws.send(JSON.stringify({
        type: 'chat',
        text: text
    }));
}
```

### 3. 图片分析示例
```javascript
// 通过HTTP API
async function analyzeImage(file, question) {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('question', question);
    
    const response = await fetch('/api/vision', {
        method: 'POST',
        headers: {
            'Device-Id': 'your-device-id',
            'Authorization': 'Bearer your-token'
        },
        body: formData
    });
    
    return await response.json();
}
```

---

## 📝 注意事项

1. **认证**: Vision API需要Bearer Token和设备ID
2. **文件大小**: 图片最大5MB，建议压缩后上传
3. **音频格式**: 推荐使用PCM格式以获得最佳兼容性
4. **重连机制**: 实现指数退避重连策略
5. **错误处理**: 妥善处理网络中断和服务器错误
6. **资源清理**: 及时释放音频上下文和WebSocket连接

---

*最后更新: 2024-01-01*  
*版本: v1.0*
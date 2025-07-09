# 小智服务端 API 接口文档

## 目录
- [1. 服务概述](#1-服务概述)
- [2. 基础信息](#2-基础信息)
- [3. HTTP REST API](#3-http-rest-api)
  - [3.1 OTA升级接口](#31-ota升级接口)
  - [3.2 视觉分析接口](#32-视觉分析接口)
  - [3.3 配置管理接口](#33-配置管理接口)
- [4. WebSocket API](#4-websocket-api)
  - [4.1 连接建立](#41-连接建立)
  - [4.2 客户端消息类型](#42-客户端消息类型)
  - [4.3 服务端响应消息](#43-服务端响应消息)
- [5. 认证机制](#5-认证机制)
- [6. 错误处理](#6-错误处理)
- [7. 配置说明](#7-配置说明)
- [8. 客户端集成指南](#8-客户端集成指南)

---

## 1. 服务概述

小智服务端是一个多模态智能对话系统，提供以下核心功能：

### 1.1 主要功能
- **🔄 OTA升级服务**: 设备固件在线升级和版本管理
- **👁️ 视觉分析服务**: 图像识别、分析和理解
- **🗣️ 语音交互服务**: 实时语音识别(ASR)和语音合成(TTS)
- **🤖 智能对话服务**: 基于大语言模型的智能对话
- **⚙️ 配置管理服务**: 系统配置的获取和更新
- **🔗 MCP集成服务**: 多协议通信和功能扩展

### 1.2 技术特点
- **实时通信**: WebSocket支持实时双向通信
- **多模态支持**: 文本、语音、图像多种输入方式
- **模块化设计**: 可配置的ASR、TTS、LLM提供者
- **安全认证**: Token认证和设备ID验证
- **高性能**: 异步处理和连接池管理

---

## 2. 基础信息

### 2.1 服务地址
- **HTTP API Base URL**: `http://localhost:8000/api`
- **WebSocket URL**: `ws://localhost:8000/`
- **Swagger文档**: `http://localhost:8000/swagger/index.html`

### 2.2 默认端口
- **HTTP服务端口**: 8000
- **WebSocket服务端口**: 与HTTP共用

### 2.3 支持的协议
- **HTTP/1.1**: REST API通信
- **WebSocket**: 实时双向通信
- **Multipart**: 文件上传

---

## 3. HTTP REST API

### 3.1 OTA升级接口

OTA（Over-The-Air）升级接口用于设备固件的在线升级管理。

#### 3.1.1 获取OTA服务状态

获取OTA服务的运行状态和WebSocket连接地址。

```http
GET /api/ota/
```

**请求参数**: 无

**响应格式**: `text/plain`

**响应示例**:
```
OTA interface is running, websocket address: ws://localhost:8000/
```

**使用场景**: 
- 设备启动时检查OTA服务可用性
- 获取WebSocket连接地址用于实时通信

---

#### 3.1.2 检查固件更新

设备上报当前版本信息，服务端返回最新固件版本和下载地址。

```http
POST /api/ota/
Content-Type: application/json
device-id: your-device-id
```

**请求头参数**:
- `device-id` (必需): 设备唯一标识符
  - 格式: 字符串
  - 示例: `"ESP32-001"`, `"IoT-Device-123"`
  - 用途: 设备识别和日志记录

**请求体**:
```json
{
  "application": {
    "version": "1.0.0"  // 当前固件版本号
  }
}
```

**字段说明**:
- `application.version`: 当前固件版本
  - 格式: 语义化版本号 (如: "1.0.0", "2.1.3")
  - 默认值: "1.0.0"
  - 用途: 版本比较和升级判断

**成功响应** (HTTP 200):
```json
{
  "server_time": {
    "timestamp": 1688443200000,    // 服务器时间戳(毫秒)
    "timezone_offset": 480         // 时区偏移(分钟)
  },
  "firmware": {
    "version": "1.0.3",           // 最新固件版本
    "url": "/ota_bin/1.0.3.bin"   // 固件下载相对路径
  },
  "websocket": {
    "url": "wss://example.com/ota" // WebSocket连接地址
  }
}
```

**响应字段详解**:
- `server_time.timestamp`: 服务器当前时间戳
  - 单位: 毫秒
  - 用途: 时间同步和日志记录
- `server_time.timezone_offset`: 时区偏移
  - 单位: 分钟
  - 示例: 480 (UTC+8), -300 (UTC-5)
- `firmware.version`: 最新固件版本号
  - 格式: 语义化版本号
  - 用途: 版本比较和升级决策
- `firmware.url`: 固件下载地址
  - 格式: 相对路径
  - 用途: 固件文件下载
- `websocket.url`: WebSocket连接地址
  - 格式: 完整WebSocket URL
  - 用途: 实时通信连接

**错误响应** (HTTP 400):
```json
{
  "success": false,
  "message": "缺少 device-id"
}
```

**错误类型**:
- `"缺少 device-id"`: 请求头缺少device-id
- `"解析失败: xxx"`: JSON解析错误

---

#### 3.1.3 下载固件文件

根据固件文件名下载对应的固件二进制文件。

```http
GET /api/ota_bin/{filename}
```

**路径参数**:
- `filename`: 固件文件名
  - 格式: `{version}.bin`
  - 示例: `"1.0.3.bin"`, `"2.1.0.bin"`

**成功响应** (HTTP 200):
- **Content-Type**: `application/octet-stream`
- **Content-Disposition**: `attachment; filename={filename}`
- **响应体**: 二进制固件文件

**错误响应** (HTTP 404):
```json
{
  "success": false,
  "message": "file not found"
}
```

**使用流程**:
1. 调用检查更新接口获取最新固件URL
2. 使用返回的URL下载固件文件
3. 验证文件完整性后进行升级

---

#### 3.1.4 CORS预检请求

处理跨域请求的OPTIONS预检。

```http
OPTIONS /api/ota/
```

**响应**: HTTP 200 OK

**CORS头**:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type, device-id`

---

### 3.2 视觉分析接口

视觉分析接口提供图像识别、分析和理解功能，基于VLLLM（视觉大语言模型）。

#### 3.2.1 获取视觉服务状态

检查视觉分析服务的运行状态和可用模型数量。

```http
GET /api/vision
```

**请求参数**: 无

**响应格式**: `text/plain`

**响应示例**:
```
MCP Vision 接口运行正常，共有 1 个可用的视觉分析模型
```

**状态类型**:
- 正常: `"MCP Vision 接口运行正常，共有 N 个可用的视觉分析模型"`
- 异常: `"MCP Vision 接口运行不正常，没有可用的VLLLM provider"`

---

#### 3.2.2 图片分析

上传图片并进行智能分析，支持图像识别、描述、问答等功能。

```http
POST /api/vision
Content-Type: multipart/form-data
Device-Id: your-device-id
Authorization: Bearer your-token
Client-Id: your-client-id
```

**请求头参数**:
- `Device-Id` (必需): 设备唯一标识符
  - 格式: 字符串
  - 用途: 设备识别和权限验证
- `Authorization` (必需): Bearer Token认证
  - 格式: `Bearer {token}`
  - 用途: 身份验证和权限控制
- `Client-Id` (可选): 客户端标识符
  - 格式: 字符串
  - 用途: 客户端区分和日志记录

**请求体** (multipart/form-data):
- `question` (必需): 对图片的问题或分析要求
  - 格式: 字符串
  - 示例: `"描述这张图片"`, `"图片中有什么物体？"`
- `file` (必需): 图片文件
  - 格式: 二进制文件
  - 支持格式: JPEG, PNG, GIF, BMP, WEBP
  - 大小限制: 5MB

**成功响应** (HTTP 200):
```json
{
  "success": true,
  "result": "这是一张显示城市街道的图片。图片中可以看到高楼大厦、道路、汽车和行人。天空晴朗，阳光明媚。"
}
```

**错误响应**:
```json
{
  "success": false,
  "message": "无效的认证token或设备ID不匹配"
}
```

**错误类型**:
- `"无效的认证token或token已过期"`: 认证失败
- `"设备ID与token不匹配"`: 设备ID验证失败
- `"缺少问题字段"`: 缺少question参数
- `"缺少图片文件"`: 缺少file参数
- `"图片大小超过限制，最大允许5MB"`: 文件太大
- `"不支持的文件格式"`: 图片格式不支持
- `"没有可用的视觉分析模型"`: 服务不可用

**使用场景**:
- 图像内容识别和描述
- 图像中的文字提取(OCR)
- 图像问答和理解
- 图像分类和标注

---

#### 3.2.3 CORS预检请求

```http
OPTIONS /api/vision
```

**响应**: HTTP 200 OK

**CORS头**:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS`
- `Access-Control-Allow-Headers: client-id, content-type, device-id, authorization`

---

### 3.3 配置管理接口

配置管理接口用于系统配置的获取和更新。

#### 3.3.1 获取配置状态

```http
GET /api/cfg
```

**响应**:
```json
{
  "status": "ok",
  "message": "Cfg service is running"
}
```

#### 3.3.2 更新配置

```http
POST /api/cfg
Content-Type: application/json
```

**响应**:
```json
{
  "status": "ok",
  "message": "Cfg service is running"
}
```

#### 3.3.3 CORS预检请求

```http
OPTIONS /api/cfg
```

**响应**: HTTP 204 No Content

---

## 4. WebSocket API

WebSocket API提供实时双向通信，支持语音交互、智能对话和多媒体处理。

### 4.1 连接建立

#### 4.1.1 连接URL
```
ws://localhost:8000/
```

#### 4.1.2 连接流程
1. 客户端发起WebSocket连接
2. 连接成功后，客户端发送hello消息
3. 服务端响应hello消息，确认连接参数
4. 开始正常消息通信

#### 4.1.3 连接参数
- **协议**: WebSocket
- **消息格式**: JSON (文本消息) 或 二进制 (音频数据)
- **心跳**: 自动维持连接
- **重连**: 客户端负责重连逻辑

---

### 4.2 客户端消息类型

#### 4.2.1 Hello消息（连接握手）

建立连接后的第一条消息，用于协商音频参数和建立会话。

```json
{
  "type": "hello",
  "version": 1,
  "audio_params": {
    "format": "pcm",        // 音频格式
    "sample_rate": 16000,   // 采样率
    "channels": 1,          // 声道数
    "frame_duration": 20    // 帧时长(毫秒)
  }
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"hello"`
- `version`: 协议版本，当前为 `1`
- `audio_params`: 音频参数配置
  - `format`: 音频格式
    - 可选值: `"pcm"`, `"opus"`
    - 推荐: `"pcm"` (兼容性好), `"opus"` (压缩率高)
  - `sample_rate`: 采样率(Hz)
    - 可选值: `16000`, `24000`, `48000`
    - 推荐: `16000` (语音识别), `24000` (高质量语音)
  - `channels`: 声道数
    - 可选值: `1` (单声道), `2` (立体声)
    - 推荐: `1` (语音应用)
  - `frame_duration`: 音频帧时长(毫秒)
    - 可选值: `20`, `40`, `60`
    - 推荐: `20` (低延迟)

---

#### 4.2.2 语音控制消息

控制语音识别的开始、停止和检测状态。

```json
{
  "type": "listen",
  "state": "start",     // 控制状态
  "mode": "manual"      // 控制模式
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"listen"`
- `state`: 控制状态
  - `"start"`: 开始语音识别
    - 清空之前的识别结果
    - 准备接收音频数据
  - `"stop"`: 停止语音识别
    - 停止音频数据处理
    - 保留当前识别结果
  - `"detect"`: 检测模式
    - 可包含 `text` 字段进行文本处理
    - 用于手动触发处理
- `mode`: 控制模式
  - `"manual"`: 手动模式
    - 需要明确的开始/停止指令
    - 适合按键式语音输入
  - `"auto"`: 自动模式
    - 自动检测语音活动
    - 适合连续对话场景

**检测消息示例**:
```json
{
  "type": "listen",
  "state": "detect",
  "text": "你好，请介绍一下自己"
}
```

---

#### 4.2.3 聊天消息

纯文本的智能对话消息。

```json
{
  "type": "chat",
  "text": "你好，请介绍一下自己"
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"chat"`
- `text`: 聊天内容
  - 格式: 字符串
  - 长度限制: 建议不超过1000字符
  - 支持多语言: 中文、英文等

**使用场景**:
- 文本聊天对话
- 问答交互
- 指令执行

---

#### 4.2.4 图像处理消息

包含图像的多模态消息处理。

```json
{
  "type": "image",
  "image": "base64-encoded-image-data",
  "text": "描述这张图片"
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"image"`
- `image`: 图像数据
  - 格式: Base64编码的图像数据
  - 支持格式: JPEG, PNG, GIF, BMP, WEBP
  - 大小限制: 5MB
- `text`: 对图像的询问或指令
  - 格式: 字符串
  - 示例: `"描述这张图片"`, `"图中有什么物体？"`

**Base64编码示例**:
```javascript
// JavaScript中的图像编码
const fileInput = document.getElementById('imageFile');
const file = fileInput.files[0];
const reader = new FileReader();
reader.onload = function(e) {
  const base64Data = e.target.result.split(',')[1]; // 移除data:image/jpeg;base64,前缀
  // 发送WebSocket消息
};
reader.readAsDataURL(file);
```

---

#### 4.2.5 IOT设备消息

IOT设备控制和状态消息。

```json
{
  "type": "iot",
  "device_id": "smart-light-001",
  "action": "turn_on",
  "data": {
    "brightness": 80,
    "color": "#FF0000"
  }
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"iot"`
- `device_id`: 设备标识符
  - 格式: 字符串
  - 示例: `"smart-light-001"`, `"sensor-temp-02"`
- `action`: 动作类型
  - 常见值: `"turn_on"`, `"turn_off"`, `"status"`, `"set_config"`
- `data`: 设备相关数据
  - 格式: JSON对象
  - 内容根据设备类型和动作而定

**设备类型示例**:
- 智能灯泡: 亮度、颜色、开关状态
- 温度传感器: 温度值、湿度值
- 摄像头: 拍照指令、录像控制

---

#### 4.2.6 视觉处理消息

视觉相关的处理指令。

```json
{
  "type": "vision",
  "cmd": "read_img",
  "data": {
    "image_path": "/path/to/image.jpg",
    "question": "识别图片中的文字"
  }
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"vision"`
- `cmd`: 视觉处理命令
  - `"read_img"`: 图像识别和分析
  - `"gen_pic"`: 图像生成
  - `"gen_video"`: 视频生成
- `data`: 命令相关数据
  - 格式: JSON对象
  - 内容根据命令类型而定

---

#### 4.2.7 MCP消息

MCP（Multi-Protocol Communication）功能调用消息。

```json
{
  "type": "mcp",
  "action": "call_function",
  "function_name": "get_weather",
  "parameters": {
    "city": "北京",
    "date": "2024-01-01"
  }
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"mcp"`
- `action`: MCP动作类型
  - `"call_function"`: 调用函数
  - `"list_functions"`: 列出可用函数
  - `"get_status"`: 获取状态
- `function_name`: 要调用的函数名
- `parameters`: 函数参数
  - 格式: JSON对象
  - 内容根据函数定义而定

**常见MCP函数**:
- `get_weather`: 获取天气信息
- `search_web`: 网络搜索
- `send_email`: 发送邮件
- `control_device`: 设备控制

---

#### 4.2.8 中止消息

中止当前正在进行的对话或处理。

```json
{
  "type": "abort"
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"abort"`

**使用场景**:
- 取消正在进行的语音合成
- 中断长时间的处理任务
- 重置对话状态

---

#### 4.2.9 音频数据消息

音频数据通过WebSocket的二进制消息传输。

**消息类型**: 二进制消息 (messageType = 2)

**数据格式**:
- **PCM格式**: 未压缩的原始音频数据
  - 采样率: 16kHz/24kHz/48kHz
  - 位深度: 16-bit
  - 声道: 单声道/立体声
- **Opus格式**: 压缩的音频数据
  - 帧大小: 20ms/40ms/60ms
  - 比特率: 自适应

**发送示例** (JavaScript):
```javascript
// 发送PCM音频数据
const audioData = new Int16Array(320); // 20ms@16kHz的PCM数据
websocket.send(audioData.buffer);

// 发送Opus音频数据
const opusFrame = new Uint8Array(opusEncodedData);
websocket.send(opusFrame.buffer);
```

---

### 4.3 服务端响应消息

#### 4.3.1 Hello响应消息

响应客户端的hello消息，确认连接参数。

```json
{
  "type": "hello",
  "version": 1,
  "transport": "websocket",
  "session_id": "session-uuid-12345",
  "audio_params": {
    "format": "opus",
    "sample_rate": 24000,
    "channels": 1,
    "frame_duration": 20
  }
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"hello"`
- `version`: 协议版本
- `transport`: 传输协议，固定为 `"websocket"`
- `session_id`: 会话唯一标识符
  - 格式: UUID字符串
  - 用途: 会话管理和日志关联
- `audio_params`: 服务端音频参数
  - 格式与客户端相同
  - 可能与客户端请求的参数不同

---

#### 4.3.2 语音识别结果消息

语音识别(STT)的结果消息。

```json
{
  "type": "stt",
  "text": "你好，请介绍一下自己",
  "session_id": "session-uuid-12345",
  "confidence": 0.95,
  "is_final": true
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"stt"`
- `text`: 识别出的文本内容
  - 格式: 字符串
  - 编码: UTF-8
- `session_id`: 会话标识符
- `confidence`: 识别置信度 (可选)
  - 范围: 0.0 - 1.0
  - 值越高表示识别越准确
- `is_final`: 是否为最终结果 (可选)
  - `true`: 最终识别结果
  - `false`: 中间识别结果

---

#### 4.3.3 语音合成状态消息

语音合成(TTS)的状态通知消息。

```json
{
  "type": "tts",
  "state": "sentence_start",
  "session_id": "session-uuid-12345",
  "text": "你好，我是小智AI助手",
  "index": 1,
  "audio_codec": "opus"
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"tts"`
- `state`: TTS状态
  - `"sentence_start"`: 句子开始合成
  - `"sentence_end"`: 句子合成完成
  - `"stop"`: 所有合成完成
- `session_id`: 会话标识符
- `text`: 当前合成的文本
- `index`: 句子索引
  - 用于标识多句回复中的位置
  - 从1开始计数
- `audio_codec`: 音频编码格式
  - 常见值: `"opus"`, `"pcm"`

**状态流程**:
1. `sentence_start` → 开始合成第一句
2. (发送音频数据)
3. `sentence_end` → 第一句完成
4. `sentence_start` → 开始合成第二句
5. (发送音频数据)
6. `sentence_end` → 第二句完成
7. `stop` → 所有句子完成

---

#### 4.3.4 LLM响应消息

大语言模型的回复消息。

```json
{
  "type": "llm",
  "text": "你好！我是小智AI助手，很高兴为您服务。",
  "emotion": "happy",
  "session_id": "session-uuid-12345",
  "is_streaming": false,
  "finish_reason": "stop"
}
```

**字段说明**:
- `type`: 消息类型，固定为 `"llm"`
- `text`: LLM回复内容
  - 格式: 字符串
  - 编码: UTF-8
- `emotion`: 情感标识 (可选)
  - 可选值: `"happy"`, `"sad"`, `"angry"`, `"neutral"`, `"excited"`, `"calm"`
  - 用途: 情感TTS合成、表情控制
- `session_id`: 会话标识符
- `is_streaming`: 是否为流式响应 (可选)
  - `true`: 流式响应，会有多条消息
  - `false`: 完整响应
- `finish_reason`: 完成原因 (可选)
  - `"stop"`: 正常完成
  - `"length"`: 达到最大长度
  - `"abort"`: 用户中止

---

#### 4.3.5 音频数据响应

服务端发送的音频数据。

**消息类型**: 二进制消息 (messageType = 2)

**数据格式**:
- **Opus格式**: 压缩的音频帧
  - 帧大小: 20ms
  - 采样率: 24kHz
  - 声道: 单声道

**接收示例** (JavaScript):
```javascript
websocket.onmessage = function(event) {
  if (event.data instanceof ArrayBuffer) {
    // 音频数据
    const audioData = new Uint8Array(event.data);
    playAudio(audioData);
  } else {
    // JSON消息
    const message = JSON.parse(event.data);
    handleMessage(message);
  }
};
```

---

## 5. 认证机制

### 5.1 Token认证

#### 5.1.1 Token格式
```
Authorization: Bearer {token}
```

#### 5.1.2 Token生成
Token由服务端生成，包含以下信息：
- 设备ID
- 过期时间
- 权限信息
- 签名

#### 5.1.3 Token验证流程
1. 客户端在请求头中包含Token
2. 服务端解析Token并验证签名
3. 检查Token是否过期
4. 验证设备ID是否匹配
5. 检查权限是否足够

#### 5.1.4 Token刷新
- Token有效期: 24小时
- 刷新时机: 过期前30分钟
- 刷新方式: 重新请求Token

### 5.2 设备ID验证

#### 5.2.1 设备ID格式
- 格式: 字符串
- 长度: 8-64字符
- 字符集: 字母、数字、连字符、下划线
- 示例: `"ESP32-001"`, `"IoT_Device_123"`

#### 5.2.2 设备ID用途
- 设备唯一标识
- 权限控制
- 日志记录
- 会话管理

---

## 6. 错误处理

### 6.1 HTTP错误码

#### 6.1.1 成功响应
- **200 OK**: 请求成功
- **204 No Content**: 请求成功，无返回内容

#### 6.1.2 客户端错误
- **400 Bad Request**: 请求参数错误
  - 缺少必需参数
  - 参数格式错误
  - 数据验证失败
- **401 Unauthorized**: 认证失败
  - Token无效或过期
  - 设备ID不匹配
  - 权限不足
- **404 Not Found**: 资源不存在
  - 文件不存在
  - 接口不存在
- **413 Payload Too Large**: 请求体过大
  - 文件大小超过限制
  - 请求数据过大

#### 6.1.3 服务端错误
- **500 Internal Server Error**: 服务器内部错误
  - 服务异常
  - 数据库错误
  - 第三方服务错误
- **503 Service Unavailable**: 服务不可用
  - 服务正在维护
  - 资源耗尽

### 6.2 错误响应格式

#### 6.2.1 标准错误格式
```json
{
  "success": false,
  "message": "具体错误信息",
  "code": "ERROR_CODE",
  "details": {
    "field": "error_detail"
  }
}
```

#### 6.2.2 常见错误码
- `INVALID_TOKEN`: Token无效
- `DEVICE_ID_MISMATCH`: 设备ID不匹配
- `FILE_TOO_LARGE`: 文件过大
- `UNSUPPORTED_FORMAT`: 不支持的格式
- `SERVICE_UNAVAILABLE`: 服务不可用

### 6.3 WebSocket错误处理

#### 6.3.1 连接错误
- **1000**: 正常关闭
- **1001**: 端点离开
- **1002**: 协议错误
- **1003**: 不支持的数据类型
- **1006**: 异常关闭
- **1011**: 服务器错误

#### 6.3.2 错误消息格式
```json
{
  "type": "error",
  "code": "ERROR_CODE",
  "message": "错误描述",
  "session_id": "session-uuid"
}
```

---

## 7. 配置说明

### 7.1 音频配置

#### 7.1.1 支持的音频格式
- **PCM**: 未压缩原始音频
  - 优点: 兼容性好，处理简单
  - 缺点: 数据量大
  - 适用: 本地处理，低延迟要求
- **Opus**: 高质量音频编码
  - 优点: 压缩率高，质量好
  - 缺点: 需要编解码器支持
  - 适用: 网络传输，节省带宽

#### 7.1.2 采样率配置
- **16kHz**: 标准语音识别
  - 用途: 语音识别(ASR)
  - 特点: 较小的数据量
- **24kHz**: 高质量语音
  - 用途: 语音合成(TTS)输出
  - 特点: 更好的音质
- **48kHz**: 高保真音频
  - 用途: 音乐播放
  - 特点: 高质量，大数据量

#### 7.1.3 声道配置
- **单声道 (1)**: 
  - 用途: 语音应用
  - 特点: 数据量小
- **立体声 (2)**:
  - 用途: 音乐播放
  - 特点: 立体声效果

### 7.2 图像配置

#### 7.2.1 支持的图像格式
- **JPEG (.jpg, .jpeg)**:
  - 特点: 有损压缩，文件小
  - 适用: 照片、自然图像
- **PNG (.png)**:
  - 特点: 无损压缩，支持透明
  - 适用: 图标、截图
- **GIF (.gif)**:
  - 特点: 支持动画
  - 适用: 简单动画
- **BMP (.bmp)**:
  - 特点: 无压缩，文件大
  - 适用: 系统截图
- **WEBP (.webp)**:
  - 特点: 现代格式，压缩率高
  - 适用: 网页图像

#### 7.2.2 图像大小限制
- **最大文件大小**: 5MB
- **建议分辨率**: 1920x1080以下
- **最小分辨率**: 64x64

### 7.3 网络配置

#### 7.3.1 连接超时
- **连接超时**: 30秒
- **读取超时**: 60秒
- **写入超时**: 30秒

#### 7.3.2 重连策略
- **最大重连次数**: 5次
- **重连间隔**: 2秒, 4秒, 8秒, 16秒, 32秒
- **重连条件**: 网络错误, 服务器重启

---

## 8. 客户端集成指南

### 8.1 快速开始

#### 8.1.1 基本流程
1. 建立WebSocket连接
2. 发送Hello消息进行握手
3. 根据业务需求发送相应消息
4. 处理服务端响应
5. 优雅关闭连接

#### 8.1.2 示例代码 (JavaScript)
```javascript
// 1. 建立WebSocket连接
const ws = new WebSocket('ws://localhost:8000/');

// 2. 连接成功后发送Hello消息
ws.onopen = function() {
    const helloMessage = {
        type: 'hello',
        version: 1,
        audio_params: {
            format: 'pcm',
            sample_rate: 16000,
            channels: 1,
            frame_duration: 20
        }
    };
    ws.send(JSON.stringify(helloMessage));
};

// 3. 处理服务端消息
ws.onmessage = function(event) {
    if (event.data instanceof ArrayBuffer) {
        // 音频数据
        handleAudioData(event.data);
    } else {
        // JSON消息
        const message = JSON.parse(event.data);
        handleMessage(message);
    }
};

// 4. 发送聊天消息
function sendChatMessage(text) {
    const message = {
        type: 'chat',
        text: text
    };
    ws.send(JSON.stringify(message));
}
```

### 8.2 最佳实践

#### 8.2.1 连接管理
- 实现自动重连机制
- 监控连接状态
- 处理网络中断

#### 8.2.2 消息处理
- 验证消息格式
- 处理异常情况
- 记录错误日志

#### 8.2.3 性能优化
- 复用WebSocket连接
- 控制消息发送频率
- 优化音频数据传输

### 8.3 错误处理

#### 8.3.1 连接错误
```javascript
ws.onerror = function(error) {
    console.error('WebSocket error:', error);
    // 实现重连逻辑
};

ws.onclose = function(event) {
    console.log('WebSocket closed:', event.code, event.reason);
    // 根据关闭码决定是否重连
};
```

#### 8.3.2 消息错误
```javascript
function handleMessage(message) {
    try {
        switch(message.type) {
            case 'error':
                handleError(message);
                break;
            case 'hello':
                handleHello(message);
                break;
            // ... 其他消息类型
        }
    } catch (error) {
        console.error('Message handling error:', error);
    }
}
```

### 8.4 安全考虑

#### 8.4.1 数据验证
- 验证所有输入数据
- 检查消息格式和类型
- 防止恶意数据注入

#### 8.4.2 认证授权
- 正确使用Token认证
- 定期刷新Token
- 保护敏感信息

---

## 附录

### A. 消息类型总览

| 消息类型 | 方向 | 描述 |
|---------|------|------|
| hello | 双向 | 连接握手和参数协商 |
| listen | 客户端→服务端 | 语音控制消息 |
| chat | 客户端→服务端 | 文本聊天消息 |
| image | 客户端→服务端 | 图像处理消息 |
| iot | 客户端→服务端 | IoT设备控制消息 |
| vision | 客户端→服务端 | 视觉处理消息 |
| mcp | 客户端→服务端 | MCP功能调用消息 |
| abort | 客户端→服务端 | 中止当前操作 |
| stt | 服务端→客户端 | 语音识别结果 |
| tts | 服务端→客户端 | 语音合成状态 |
| llm | 服务端→客户端 | LLM响应消息 |
| error | 服务端→客户端 | 错误消息 |

### B. HTTP状态码总览

| 状态码 | 描述 | 常见原因 |
|--------|------|---------|
| 200 | OK | 请求成功 |
| 204 | No Content | 请求成功，无返回内容 |
| 400 | Bad Request | 参数错误、格式错误 |
| 401 | Unauthorized | 认证失败、Token无效 |
| 404 | Not Found | 资源不存在 |
| 413 | Payload Too Large | 文件过大 |
| 500 | Internal Server Error | 服务器内部错误 |
| 503 | Service Unavailable | 服务不可用 |

### C. 音频参数配置表

| 参数 | PCM | Opus |
|------|-----|------|
| 格式 | 未压缩 | 压缩 |
| 采样率 | 16kHz/24kHz/48kHz | 16kHz/24kHz/48kHz |
| 位深度 | 16-bit | 自适应 |
| 帧大小 | 20ms/40ms/60ms | 20ms/40ms/60ms |
| 数据量 | 大 | 小 |
| 处理复杂度 | 低 | 中 |
| 适用场景 | 本地处理 | 网络传输 |

---

*本文档版本: v1.0*  
*最后更新: 2024-01-01*  
*维护者: 小智开发团队*
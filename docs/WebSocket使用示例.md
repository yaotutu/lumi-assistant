# 小智服务端 WebSocket API 使用示例

## 目录
- [1. 基础连接示例](#1-基础连接示例)
- [2. 语音交互示例](#2-语音交互示例)
- [3. 图像处理示例](#3-图像处理示例)
- [4. 错误处理示例](#4-错误处理示例)
- [5. 完整集成示例](#5-完整集成示例)

---

## 1. 基础连接示例

### 1.1 JavaScript 基础连接

```javascript
class XiaoZhiWebSocketClient {
    constructor(url = 'ws://192.168.110.199:8000/') {
        // 注意：这是开发环境的IP地址，生产环境需要调整为实际的服务器地址
        this.url = url;
        this.ws = null;
        this.sessionId = null;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 5;
        this.reconnectInterval = 2000;
        
        // 回调函数
        this.onConnected = null;
        this.onDisconnected = null;
        this.onMessage = null;
        this.onError = null;
    }
    
    // 连接到服务器
    connect() {
        try {
            this.ws = new WebSocket(this.url);
            this.setupEventHandlers();
        } catch (error) {
            console.error('连接失败:', error);
            this.handleReconnect();
        }
    }
    
    // 设置事件处理器
    setupEventHandlers() {
        this.ws.onopen = (event) => {
            console.log('WebSocket连接已建立');
            this.reconnectAttempts = 0;
            this.sendHelloMessage();
        };
        
        this.ws.onmessage = (event) => {
            this.handleMessage(event);
        };
        
        this.ws.onclose = (event) => {
            console.log('WebSocket连接已关闭:', event.code, event.reason);
            this.sessionId = null;
            if (this.onDisconnected) {
                this.onDisconnected(event);
            }
            this.handleReconnect();
        };
        
        this.ws.onerror = (error) => {
            console.error('WebSocket错误:', error);
            if (this.onError) {
                this.onError(error);
            }
        };
    }
    
    // 发送Hello消息
    sendHelloMessage() {
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
        this.send(helloMessage);
    }
    
    // 处理接收到的消息
    handleMessage(event) {
        if (event.data instanceof ArrayBuffer) {
            // 处理音频数据
            this.handleAudioData(event.data);
        } else {
            // 处理JSON消息
            try {
                const message = JSON.parse(event.data);
                this.handleJsonMessage(message);
            } catch (error) {
                console.error('解析JSON消息失败:', error);
            }
        }
    }
    
    // 处理JSON消息
    handleJsonMessage(message) {
        switch (message.type) {
            case 'hello':
                this.sessionId = message.session_id;
                console.log('收到Hello响应，会话ID:', this.sessionId);
                if (this.onConnected) {
                    this.onConnected(message);
                }
                break;
            case 'stt':
                console.log('语音识别结果:', message.text);
                break;
            case 'tts':
                console.log('TTS状态:', message.state, message.text);
                break;
            case 'llm':
                console.log('LLM回复:', message.text);
                if (message.emotion) {
                    console.log('情感:', message.emotion);
                }
                break;
            case 'error':
                console.error('服务器错误:', message.message);
                break;
            default:
                console.log('未知消息类型:', message.type);
        }
        
        if (this.onMessage) {
            this.onMessage(message);
        }
    }
    
    // 处理音频数据
    handleAudioData(audioData) {
        console.log('收到音频数据，大小:', audioData.byteLength);
        // 这里可以添加音频播放逻辑
    }
    
    // 发送消息
    send(message) {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            if (typeof message === 'object') {
                this.ws.send(JSON.stringify(message));
            } else {
                this.ws.send(message);
            }
        } else {
            console.error('WebSocket连接未就绪');
        }
    }
    
    // 重连处理
    handleReconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            console.log(`${this.reconnectInterval}ms后尝试第${this.reconnectAttempts}次重连`);
            setTimeout(() => {
                this.connect();
            }, this.reconnectInterval);
            this.reconnectInterval = Math.min(this.reconnectInterval * 2, 30000);
        } else {
            console.error('达到最大重连次数，停止重连');
        }
    }
    
    // 断开连接
    disconnect() {
        if (this.ws) {
            this.ws.close();
        }
    }
}

// 使用示例
const client = new XiaoZhiWebSocketClient();

client.onConnected = (message) => {
    console.log('连接成功，服务器参数:', message.audio_params);
};

client.onMessage = (message) => {
    console.log('收到消息:', message);
};

client.connect();
```

### 1.2 Python 基础连接

```python
import asyncio
import websockets
import json
import logging

class XiaoZhiWebSocketClient:
    def __init__(self, url="ws://192.168.110.199:8000/"):
        # 注意：这是开发环境的IP地址，生产环境需要调整为实际的服务器地址
        self.url = url
        self.websocket = None
        self.session_id = None
        self.running = False
        
        # 设置日志
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
    
    async def connect(self):
        """连接到WebSocket服务器"""
        try:
            self.websocket = await websockets.connect(self.url)
            self.running = True
            self.logger.info("WebSocket连接已建立")
            
            # 发送Hello消息
            await self.send_hello_message()
            
            # 开始监听消息
            await self.listen_messages()
            
        except Exception as e:
            self.logger.error(f"连接失败: {e}")
    
    async def send_hello_message(self):
        """发送Hello消息"""
        hello_message = {
            "type": "hello",
            "version": 1,
            "audio_params": {
                "format": "pcm",
                "sample_rate": 16000,
                "channels": 1,
                "frame_duration": 20
            }
        }
        await self.send_message(hello_message)
    
    async def send_message(self, message):
        """发送消息"""
        if self.websocket:
            if isinstance(message, dict):
                await self.websocket.send(json.dumps(message, ensure_ascii=False))
            else:
                await self.websocket.send(message)
    
    async def listen_messages(self):
        """监听消息"""
        try:
            async for message in self.websocket:
                await self.handle_message(message)
        except websockets.exceptions.ConnectionClosed:
            self.logger.info("WebSocket连接已关闭")
        except Exception as e:
            self.logger.error(f"监听消息时出错: {e}")
        finally:
            self.running = False
    
    async def handle_message(self, message):
        """处理接收到的消息"""
        if isinstance(message, bytes):
            # 处理音频数据
            self.handle_audio_data(message)
        else:
            # 处理JSON消息
            try:
                data = json.loads(message)
                await self.handle_json_message(data)
            except json.JSONDecodeError as e:
                self.logger.error(f"解析JSON失败: {e}")
    
    async def handle_json_message(self, message):
        """处理JSON消息"""
        msg_type = message.get("type")
        
        if msg_type == "hello":
            self.session_id = message.get("session_id")
            self.logger.info(f"收到Hello响应，会话ID: {self.session_id}")
            
        elif msg_type == "stt":
            self.logger.info(f"语音识别结果: {message.get('text')}")
            
        elif msg_type == "tts":
            state = message.get("state")
            text = message.get("text", "")
            self.logger.info(f"TTS状态: {state} - {text}")
            
        elif msg_type == "llm":
            text = message.get("text")
            emotion = message.get("emotion")
            self.logger.info(f"LLM回复: {text}")
            if emotion:
                self.logger.info(f"情感: {emotion}")
                
        elif msg_type == "error":
            self.logger.error(f"服务器错误: {message.get('message')}")
            
        else:
            self.logger.info(f"未知消息类型: {msg_type}")
    
    def handle_audio_data(self, audio_data):
        """处理音频数据"""
        self.logger.info(f"收到音频数据，大小: {len(audio_data)} bytes")
        # 这里可以添加音频播放逻辑
    
    async def send_chat_message(self, text):
        """发送聊天消息"""
        message = {
            "type": "chat",
            "text": text
        }
        await self.send_message(message)
    
    async def disconnect(self):
        """断开连接"""
        self.running = False
        if self.websocket:
            await self.websocket.close()

# 使用示例
async def main():
    client = XiaoZhiWebSocketClient()
    
    # 连接并发送消息
    await client.connect()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## 2. 语音交互示例

### 2.1 语音识别控制

```javascript
class VoiceController {
    constructor(websocketClient) {
        this.client = websocketClient;
        this.isListening = false;
        this.audioContext = null;
        this.microphone = null;
        this.processor = null;
    }
    
    // 初始化音频上下文
    async initAudio() {
        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)({
                sampleRate: 16000
            });
            
            const stream = await navigator.mediaDevices.getUserMedia({
                audio: {
                    sampleRate: 16000,
                    channelCount: 1,
                    echoCancellation: true,
                    noiseSuppression: true
                }
            });
            
            this.microphone = this.audioContext.createMediaStreamSource(stream);
            this.processor = this.audioContext.createScriptProcessor(1024, 1, 1);
            
            this.processor.onaudioprocess = (event) => {
                if (this.isListening) {
                    const inputData = event.inputBuffer.getChannelData(0);
                    const pcmData = this.floatTo16BitPCM(inputData);
                    this.client.ws.send(pcmData.buffer);
                }
            };
            
            this.microphone.connect(this.processor);
            this.processor.connect(this.audioContext.destination);
            
        } catch (error) {
            console.error('初始化音频失败:', error);
        }
    }
    
    // 转换音频格式
    floatTo16BitPCM(float32Array) {
        const buffer = new ArrayBuffer(float32Array.length * 2);
        const view = new DataView(buffer);
        let offset = 0;
        
        for (let i = 0; i < float32Array.length; i++, offset += 2) {
            let s = Math.max(-1, Math.min(1, float32Array[i]));
            view.setInt16(offset, s < 0 ? s * 0x8000 : s * 0x7FFF, true);
        }
        
        return new Int16Array(buffer);
    }
    
    // 开始语音识别
    startListening() {
        if (!this.isListening) {
            this.isListening = true;
            const message = {
                type: 'listen',
                state: 'start',
                mode: 'manual'
            };
            this.client.send(message);
            console.log('开始语音识别');
        }
    }
    
    // 停止语音识别
    stopListening() {
        if (this.isListening) {
            this.isListening = false;
            const message = {
                type: 'listen',
                state: 'stop',
                mode: 'manual'
            };
            this.client.send(message);
            console.log('停止语音识别');
        }
    }
    
    // 发送文本检测
    detectText(text) {
        const message = {
            type: 'listen',
            state: 'detect',
            text: text
        };
        this.client.send(message);
    }
}

// 使用示例
const client = new XiaoZhiWebSocketClient();
const voiceController = new VoiceController(client);

client.onConnected = async () => {
    await voiceController.initAudio();
    console.log('音频系统已初始化');
};

// 按钮控制
document.getElementById('startBtn').onclick = () => {
    voiceController.startListening();
};

document.getElementById('stopBtn').onclick = () => {
    voiceController.stopListening();
};
```

### 2.2 音频播放处理

```javascript
class AudioPlayer {
    constructor() {
        this.audioContext = null;
        this.audioQueue = [];
        this.isPlaying = false;
        this.currentSource = null;
    }
    
    // 初始化音频上下文
    async init() {
        this.audioContext = new (window.AudioContext || window.webkitAudioContext)({
            sampleRate: 24000
        });
    }
    
    // 添加音频数据到播放队列
    addAudioData(audioData) {
        this.audioQueue.push(audioData);
        if (!this.isPlaying) {
            this.playNext();
        }
    }
    
    // 播放下一个音频片段
    async playNext() {
        if (this.audioQueue.length === 0) {
            this.isPlaying = false;
            return;
        }
        
        this.isPlaying = true;
        const audioData = this.audioQueue.shift();
        
        try {
            // 解码Opus音频数据（需要使用Opus解码库）
            const pcmData = await this.decodeOpusData(audioData);
            
            // 创建音频缓冲区
            const audioBuffer = this.audioContext.createBuffer(1, pcmData.length, 24000);
            audioBuffer.getChannelData(0).set(pcmData);
            
            // 播放音频
            this.currentSource = this.audioContext.createBufferSource();
            this.currentSource.buffer = audioBuffer;
            this.currentSource.connect(this.audioContext.destination);
            
            this.currentSource.onended = () => {
                this.playNext();
            };
            
            this.currentSource.start();
            
        } catch (error) {
            console.error('播放音频失败:', error);
            this.playNext();
        }
    }
    
    // 解码Opus数据（示例，需要实际的Opus解码库）
    async decodeOpusData(opusData) {
        // 这里需要使用实际的Opus解码库，如opus-decoder
        // 返回PCM数据
        return new Float32Array(opusData.byteLength / 2);
    }
    
    // 停止播放
    stop() {
        if (this.currentSource) {
            this.currentSource.stop();
            this.currentSource = null;
        }
        this.audioQueue = [];
        this.isPlaying = false;
    }
}

// 使用示例
const audioPlayer = new AudioPlayer();

client.onConnected = async () => {
    await audioPlayer.init();
};

client.handleAudioData = (audioData) => {
    audioPlayer.addAudioData(audioData);
};
```

---

## 3. 图像处理示例

### 3.1 图像上传和分析

```javascript
class ImageProcessor {
    constructor(websocketClient) {
        this.client = websocketClient;
    }
    
    // 通过WebSocket发送图像
    async sendImageForAnalysis(imageFile, question) {
        try {
            // 转换为Base64
            const base64Data = await this.fileToBase64(imageFile);
            
            const message = {
                type: 'image',
                image: base64Data,
                text: question
            };
            
            this.client.send(message);
            
        } catch (error) {
            console.error('发送图像失败:', error);
        }
    }
    
    // 文件转Base64
    fileToBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                // 移除data:image/...;base64,前缀
                const base64 = reader.result.split(',')[1];
                resolve(base64);
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }
    
    // 通过HTTP API发送图像（推荐方式）
    async sendImageViaHTTP(imageFile, question, deviceId, token) {
        try {
            const formData = new FormData();
            formData.append('file', imageFile);
            formData.append('question', question);
            
            const response = await fetch('/api/vision', {
                method: 'POST',
                headers: {
                    'Device-Id': deviceId,
                    'Authorization': `Bearer ${token}`,
                    'Client-Id': 'web-client-001'
                },
                body: formData
            });
            
            const result = await response.json();
            
            if (result.success) {
                console.log('图像分析结果:', result.result);
                return result.result;
            } else {
                console.error('图像分析失败:', result.message);
                throw new Error(result.message);
            }
            
        } catch (error) {
            console.error('HTTP图像分析失败:', error);
            throw error;
        }
    }
}

// 使用示例
const imageProcessor = new ImageProcessor(client);

// HTML文件选择器
const fileInput = document.getElementById('imageInput');
const questionInput = document.getElementById('questionInput');
const analyzeBtn = document.getElementById('analyzeBtn');

analyzeBtn.onclick = async () => {
    const file = fileInput.files[0];
    const question = questionInput.value;
    
    if (!file) {
        alert('请选择图像文件');
        return;
    }
    
    if (!question) {
        alert('请输入问题');
        return;
    }
    
    try {
        // 方式1: 通过WebSocket
        await imageProcessor.sendImageForAnalysis(file, question);
        
        // 方式2: 通过HTTP API（推荐）
        // const result = await imageProcessor.sendImageViaHTTP(
        //     file, question, 'your-device-id', 'your-token'
        // );
        
    } catch (error) {
        alert('图像分析失败: ' + error.message);
    }
};
```

### 3.2 摄像头实时分析

```javascript
class CameraProcessor {
    constructor(websocketClient) {
        this.client = websocketClient;
        this.video = null;
        this.canvas = null;
        this.context = null;
        this.stream = null;
        this.isCapturing = false;
    }
    
    // 初始化摄像头
    async initCamera() {
        try {
            this.video = document.createElement('video');
            this.canvas = document.createElement('canvas');
            this.context = this.canvas.getContext('2d');
            
            this.stream = await navigator.mediaDevices.getUserMedia({
                video: {
                    width: { ideal: 1280 },
                    height: { ideal: 720 },
                    facingMode: 'user'
                }
            });
            
            this.video.srcObject = this.stream;
            this.video.autoplay = true;
            
            await new Promise(resolve => {
                this.video.onloadedmetadata = resolve;
            });
            
            this.canvas.width = this.video.videoWidth;
            this.canvas.height = this.video.videoHeight;
            
            console.log('摄像头初始化成功');
            
        } catch (error) {
            console.error('摄像头初始化失败:', error);
            throw error;
        }
    }
    
    // 捕获当前画面
    captureFrame() {
        if (!this.video || !this.canvas) {
            throw new Error('摄像头未初始化');
        }
        
        this.context.drawImage(this.video, 0, 0);
        return new Promise(resolve => {
            this.canvas.toBlob(resolve, 'image/jpeg', 0.8);
        });
    }
    
    // 开始自动分析
    async startAutoAnalysis(question, interval = 5000) {
        if (this.isCapturing) {
            console.log('已在进行自动分析');
            return;
        }
        
        this.isCapturing = true;
        
        const analyze = async () => {
            if (!this.isCapturing) return;
            
            try {
                const imageBlob = await this.captureFrame();
                const base64Data = await this.blobToBase64(imageBlob);
                
                const message = {
                    type: 'image',
                    image: base64Data,
                    text: question
                };
                
                this.client.send(message);
                
            } catch (error) {
                console.error('自动分析失败:', error);
            }
            
            if (this.isCapturing) {
                setTimeout(analyze, interval);
            }
        };
        
        analyze();
    }
    
    // 停止自动分析
    stopAutoAnalysis() {
        this.isCapturing = false;
    }
    
    // Blob转Base64
    blobToBase64(blob) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                resolve(base64);
            };
            reader.onerror = reject;
            reader.readAsDataURL(blob);
        });
    }
    
    // 清理资源
    cleanup() {
        this.stopAutoAnalysis();
        
        if (this.stream) {
            this.stream.getTracks().forEach(track => track.stop());
        }
    }
}

// 使用示例
const cameraProcessor = new CameraProcessor(client);

document.getElementById('startCameraBtn').onclick = async () => {
    try {
        await cameraProcessor.initCamera();
        await cameraProcessor.startAutoAnalysis('描述你看到的内容', 3000);
        console.log('摄像头自动分析已开始');
    } catch (error) {
        alert('摄像头启动失败: ' + error.message);
    }
};

document.getElementById('stopCameraBtn').onclick = () => {
    cameraProcessor.cleanup();
    console.log('摄像头已停止');
};
```

---

## 4. 错误处理示例

### 4.1 完整的错误处理机制

```javascript
class ErrorHandler {
    constructor() {
        this.errorCallbacks = new Map();
        this.retryStrategies = new Map();
    }
    
    // 注册错误处理回调
    registerErrorHandler(errorType, callback) {
        if (!this.errorCallbacks.has(errorType)) {
            this.errorCallbacks.set(errorType, []);
        }
        this.errorCallbacks.get(errorType).push(callback);
    }
    
    // 注册重试策略
    registerRetryStrategy(operation, strategy) {
        this.retryStrategies.set(operation, strategy);
    }
    
    // 处理错误
    async handleError(errorType, error, context = {}) {
        console.error(`错误类型: ${errorType}`, error);
        
        // 执行注册的错误处理回调
        const callbacks = this.errorCallbacks.get(errorType) || [];
        for (const callback of callbacks) {
            try {
                await callback(error, context);
            } catch (callbackError) {
                console.error('错误处理回调执行失败:', callbackError);
            }
        }
        
        // 执行重试策略
        const retryStrategy = this.retryStrategies.get(context.operation);
        if (retryStrategy) {
            return await this.executeRetry(retryStrategy, context);
        }
    }
    
    // 执行重试
    async executeRetry(strategy, context) {
        for (let attempt = 1; attempt <= strategy.maxAttempts; attempt++) {
            try {
                console.log(`重试第${attempt}次: ${context.operation}`);
                await new Promise(resolve => setTimeout(resolve, strategy.delay * attempt));
                
                if (context.retryFunction) {
                    const result = await context.retryFunction();
                    console.log(`重试成功: ${context.operation}`);
                    return result;
                }
                
            } catch (retryError) {
                console.error(`重试第${attempt}次失败:`, retryError);
                if (attempt === strategy.maxAttempts) {
                    throw new Error(`重试${strategy.maxAttempts}次后仍然失败`);
                }
            }
        }
    }
}

// 增强的WebSocket客户端
class EnhancedXiaoZhiClient extends XiaoZhiWebSocketClient {
    constructor(url) {
        super(url);
        this.errorHandler = new ErrorHandler();
        this.setupErrorHandlers();
        this.setupRetryStrategies();
    }
    
    setupErrorHandlers() {
        // 连接错误处理
        this.errorHandler.registerErrorHandler('connection', async (error, context) => {
            console.log('处理连接错误:', error.message);
            // 可以显示用户友好的错误信息
            this.showUserMessage('连接失败，正在尝试重连...');
        });
        
        // 认证错误处理
        this.errorHandler.registerErrorHandler('auth', async (error, context) => {
            console.log('处理认证错误:', error.message);
            // 可能需要重新获取token
            this.showUserMessage('认证失败，请重新登录');
        });
        
        // 消息发送错误处理
        this.errorHandler.registerErrorHandler('message', async (error, context) => {
            console.log('处理消息错误:', error.message);
            this.showUserMessage('消息发送失败，请稍后重试');
        });
        
        // 音频错误处理
        this.errorHandler.registerErrorHandler('audio', async (error, context) => {
            console.log('处理音频错误:', error.message);
            this.showUserMessage('音频处理失败，请检查麦克风权限');
        });
    }
    
    setupRetryStrategies() {
        // 连接重试策略
        this.errorHandler.registerRetryStrategy('connect', {
            maxAttempts: 5,
            delay: 2000
        });
        
        // 消息发送重试策略
        this.errorHandler.registerRetryStrategy('sendMessage', {
            maxAttempts: 3,
            delay: 1000
        });
        
        // HTTP请求重试策略
        this.errorHandler.registerRetryStrategy('httpRequest', {
            maxAttempts: 3,
            delay: 1500
        });
    }
    
    // 增强的发送消息方法
    async sendMessageWithRetry(message) {
        try {
            await this.send(message);
        } catch (error) {
            await this.errorHandler.handleError('message', error, {
                operation: 'sendMessage',
                retryFunction: () => this.send(message)
            });
        }
    }
    
    // 增强的连接方法
    async connectWithRetry() {
        try {
            await this.connect();
        } catch (error) {
            await this.errorHandler.handleError('connection', error, {
                operation: 'connect',
                retryFunction: () => this.connect()
            });
        }
    }
    
    // 显示用户消息
    showUserMessage(message, type = 'info') {
        // 这里可以集成UI组件显示消息
        console.log(`[${type.toUpperCase()}] ${message}`);
        
        // 示例：显示Toast消息
        if (typeof window !== 'undefined' && window.showToast) {
            window.showToast(message, type);
        }
    }
    
    // 处理WebSocket错误
    handleWebSocketError(error) {
        let errorType = 'connection';
        
        if (error.message && error.message.includes('auth')) {
            errorType = 'auth';
        } else if (error.code === 1006) {
            errorType = 'connection';
        }
        
        this.errorHandler.handleError(errorType, error);
    }
}
```

### 4.2 网络状态监控

```javascript
class NetworkMonitor {
    constructor(client) {
        this.client = client;
        this.isOnline = navigator.onLine;
        this.setupEventListeners();
    }
    
    setupEventListeners() {
        window.addEventListener('online', () => {
            console.log('网络已连接');
            this.isOnline = true;
            this.handleNetworkReconnect();
        });
        
        window.addEventListener('offline', () => {
            console.log('网络已断开');
            this.isOnline = false;
            this.handleNetworkDisconnect();
        });
        
        // 定期检查连接状态
        setInterval(() => {
            this.checkConnectionHealth();
        }, 30000);
    }
    
    handleNetworkReconnect() {
        if (this.client.ws && this.client.ws.readyState !== WebSocket.OPEN) {
            console.log('网络恢复，尝试重连WebSocket');
            this.client.connect();
        }
    }
    
    handleNetworkDisconnect() {
        this.client.showUserMessage('网络连接已断开', 'warning');
    }
    
    async checkConnectionHealth() {
        if (!this.isOnline) return;
        
        try {
            // 发送ping消息检查连接
            if (this.client.ws && this.client.ws.readyState === WebSocket.OPEN) {
                const pingMessage = {
                    type: 'ping',
                    timestamp: Date.now()
                };
                this.client.send(pingMessage);
            }
        } catch (error) {
            console.error('连接健康检查失败:', error);
        }
    }
}

// 使用示例
const client = new EnhancedXiaoZhiClient();
const networkMonitor = new NetworkMonitor(client);

client.connectWithRetry();
```

---

## 5. 完整集成示例

### 5.1 完整的聊天机器人示例

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>小智AI助手</title>
    <style>
        .chat-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 10px;
        }
        
        .chat-messages {
            height: 400px;
            overflow-y: auto;
            border: 1px solid #eee;
            padding: 10px;
            margin-bottom: 20px;
        }
        
        .message {
            margin-bottom: 10px;
            padding: 10px;
            border-radius: 5px;
        }
        
        .user-message {
            background-color: #007bff;
            color: white;
            text-align: right;
        }
        
        .ai-message {
            background-color: #f8f9fa;
            color: #333;
        }
        
        .controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .controls input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        
        .controls button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .status {
            margin-top: 10px;
            padding: 10px;
            border-radius: 5px;
            display: none;
        }
        
        .status.info { background-color: #d1ecf1; color: #0c5460; }
        .status.warning { background-color: #fff3cd; color: #856404; }
        .status.error { background-color: #f8d7da; color: #721c24; }
        .status.success { background-color: #d4edda; color: #155724; }
    </style>
</head>
<body>
    <div class="chat-container">
        <h2>小智AI助手</h2>
        
        <div class="chat-messages" id="chatMessages"></div>
        
        <div class="controls">
            <input type="text" id="messageInput" placeholder="输入消息..." 
                   onkeypress="handleKeyPress(event)">
            <button onclick="sendMessage()" id="sendBtn">发送</button>
            <button onclick="toggleVoice()" id="voiceBtn">🎤 语音</button>
            <input type="file" id="imageInput" accept="image/*" style="display: none;">
            <button onclick="selectImage()">📷 图片</button>
        </div>
        
        <div class="status" id="statusDiv"></div>
    </div>

    <script>
        // 全局变量
        let client = null;
        let voiceController = null;
        let audioPlayer = null;
        let isVoiceMode = false;
        
        // 初始化应用
        async function initApp() {
            try {
                // 创建客户端
                client = new EnhancedXiaoZhiClient();
                
                // 设置回调
                client.onConnected = handleConnected;
                client.onMessage = handleMessage;
                client.onDisconnected = handleDisconnected;
                client.onError = handleError;
                
                // 连接服务器
                await client.connectWithRetry();
                
                showStatus('正在连接服务器...', 'info');
                
            } catch (error) {
                showStatus('初始化失败: ' + error.message, 'error');
            }
        }
        
        // 连接成功处理
        async function handleConnected(message) {
            showStatus('已连接到服务器', 'success');
            
            // 初始化语音控制器
            voiceController = new VoiceController(client);
            await voiceController.initAudio();
            
            // 初始化音频播放器
            audioPlayer = new AudioPlayer();
            await audioPlayer.init();
            
            // 设置音频数据处理
            client.handleAudioData = (audioData) => {
                audioPlayer.addAudioData(audioData);
            };
            
            hideStatus();
        }
        
        // 消息处理
        function handleMessage(message) {
            switch (message.type) {
                case 'stt':
                    if (message.text) {
                        addMessage('user', `[语音] ${message.text}`);
                    }
                    break;
                    
                case 'llm':
                    if (message.text) {
                        addMessage('ai', message.text);
                    }
                    break;
                    
                case 'tts':
                    if (message.state === 'sentence_start') {
                        showStatus(`正在播放: ${message.text}`, 'info');
                    } else if (message.state === 'stop') {
                        hideStatus();
                    }
                    break;
                    
                case 'error':
                    showStatus('服务器错误: ' + message.message, 'error');
                    break;
            }
        }
        
        // 连接断开处理
        function handleDisconnected(event) {
            showStatus('连接已断开，正在重连...', 'warning');
        }
        
        // 错误处理
        function handleError(error) {
            showStatus('发生错误: ' + error.message, 'error');
        }
        
        // 发送消息
        async function sendMessage() {
            const input = document.getElementById('messageInput');
            const text = input.value.trim();
            
            if (!text) return;
            
            try {
                addMessage('user', text);
                
                const message = {
                    type: 'chat',
                    text: text
                };
                
                await client.sendMessageWithRetry(message);
                input.value = '';
                
            } catch (error) {
                showStatus('发送失败: ' + error.message, 'error');
            }
        }
        
        // 切换语音模式
        function toggleVoice() {
            if (!voiceController) {
                showStatus('语音系统未初始化', 'warning');
                return;
            }
            
            const btn = document.getElementById('voiceBtn');
            
            if (isVoiceMode) {
                voiceController.stopListening();
                btn.textContent = '🎤 语音';
                btn.style.backgroundColor = '';
                isVoiceMode = false;
                hideStatus();
            } else {
                voiceController.startListening();
                btn.textContent = '⏹️ 停止';
                btn.style.backgroundColor = '#ff4444';
                isVoiceMode = true;
                showStatus('正在监听语音...', 'info');
            }
        }
        
        // 选择图片
        function selectImage() {
            document.getElementById('imageInput').click();
        }
        
        // 处理图片选择
        document.getElementById('imageInput').onchange = async function(event) {
            const file = event.target.files[0];
            if (!file) return;
            
            try {
                const question = prompt('请输入对图片的问题:', '描述这张图片');
                if (!question) return;
                
                addMessage('user', `[图片] ${question}`);
                showStatus('正在分析图片...', 'info');
                
                // 使用HTTP API发送图片
                const imageProcessor = new ImageProcessor(client);
                const result = await imageProcessor.sendImageViaHTTP(
                    file, 
                    question, 
                    'web-client-001', 
                    'your-token' // 这里需要实际的token
                );
                
                addMessage('ai', result);
                hideStatus();
                
            } catch (error) {
                showStatus('图片分析失败: ' + error.message, 'error');
            }
        };
        
        // 键盘事件处理
        function handleKeyPress(event) {
            if (event.key === 'Enter') {
                sendMessage();
            }
        }
        
        // 添加消息到聊天界面
        function addMessage(sender, text) {
            const messagesDiv = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${sender}-message`;
            messageDiv.textContent = text;
            messagesDiv.appendChild(messageDiv);
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }
        
        // 显示状态
        function showStatus(message, type) {
            const statusDiv = document.getElementById('statusDiv');
            statusDiv.textContent = message;
            statusDiv.className = `status ${type}`;
            statusDiv.style.display = 'block';
        }
        
        // 隐藏状态
        function hideStatus() {
            const statusDiv = document.getElementById('statusDiv');
            statusDiv.style.display = 'none';
        }
        
        // 页面加载时初始化
        window.onload = initApp;
        
        // 页面关闭时清理
        window.onbeforeunload = function() {
            if (client) {
                client.disconnect();
            }
            if (voiceController) {
                voiceController.audioContext?.close();
            }
        };
    </script>
</body>
</html>
```

### 5.2 React组件示例

```jsx
import React, { useState, useEffect, useRef } from 'react';
import { EnhancedXiaoZhiClient, VoiceController, AudioPlayer } from './xiaozhi-client';

const XiaoZhiChat = () => {
    const [messages, setMessages] = useState([]);
    const [inputText, setInputText] = useState('');
    const [isConnected, setIsConnected] = useState(false);
    const [isVoiceMode, setIsVoiceMode] = useState(false);
    const [status, setStatus] = useState({ message: '', type: '' });
    
    const clientRef = useRef(null);
    const voiceControllerRef = useRef(null);
    const audioPlayerRef = useRef(null);
    
    useEffect(() => {
        initializeClient();
        return cleanup;
    }, []);
    
    const initializeClient = async () => {
        try {
            const client = new EnhancedXiaoZhiClient();
            clientRef.current = client;
            
            client.onConnected = handleConnected;
            client.onMessage = handleMessage;
            client.onDisconnected = () => setIsConnected(false);
            client.onError = (error) => {
                setStatus({ message: `错误: ${error.message}`, type: 'error' });
            };
            
            await client.connectWithRetry();
            setStatus({ message: '正在连接...', type: 'info' });
            
        } catch (error) {
            setStatus({ message: `初始化失败: ${error.message}`, type: 'error' });
        }
    };
    
    const handleConnected = async (message) => {
        setIsConnected(true);
        setStatus({ message: '已连接', type: 'success' });
        
        // 初始化语音和音频
        const voiceController = new VoiceController(clientRef.current);
        const audioPlayer = new AudioPlayer();
        
        await voiceController.initAudio();
        await audioPlayer.init();
        
        voiceControllerRef.current = voiceController;
        audioPlayerRef.current = audioPlayer;
        
        clientRef.current.handleAudioData = (audioData) => {
            audioPlayer.addAudioData(audioData);
        };
        
        setTimeout(() => setStatus({ message: '', type: '' }), 2000);
    };
    
    const handleMessage = (message) => {
        switch (message.type) {
            case 'stt':
                if (message.text) {
                    addMessage('user', `[语音] ${message.text}`);
                }
                break;
            case 'llm':
                if (message.text) {
                    addMessage('ai', message.text);
                }
                break;
            case 'tts':
                if (message.state === 'sentence_start') {
                    setStatus({ message: `播放: ${message.text}`, type: 'info' });
                } else if (message.state === 'stop') {
                    setStatus({ message: '', type: '' });
                }
                break;
        }
    };
    
    const addMessage = (sender, text) => {
        setMessages(prev => [...prev, { sender, text, timestamp: Date.now() }]);
    };
    
    const sendMessage = async () => {
        if (!inputText.trim() || !isConnected) return;
        
        try {
            addMessage('user', inputText);
            
            await clientRef.current.sendMessageWithRetry({
                type: 'chat',
                text: inputText
            });
            
            setInputText('');
        } catch (error) {
            setStatus({ message: `发送失败: ${error.message}`, type: 'error' });
        }
    };
    
    const toggleVoice = () => {
        if (!voiceControllerRef.current) return;
        
        if (isVoiceMode) {
            voiceControllerRef.current.stopListening();
            setIsVoiceMode(false);
            setStatus({ message: '', type: '' });
        } else {
            voiceControllerRef.current.startListening();
            setIsVoiceMode(true);
            setStatus({ message: '正在监听...', type: 'info' });
        }
    };
    
    const cleanup = () => {
        if (clientRef.current) {
            clientRef.current.disconnect();
        }
        if (voiceControllerRef.current && voiceControllerRef.current.audioContext) {
            voiceControllerRef.current.audioContext.close();
        }
    };
    
    return (
        <div className="xiaozhi-chat">
            <div className="chat-header">
                <h2>小智AI助手</h2>
                <div className={`connection-status ${isConnected ? 'connected' : 'disconnected'}`}>
                    {isConnected ? '已连接' : '未连接'}
                </div>
            </div>
            
            <div className="chat-messages">
                {messages.map((msg, index) => (
                    <div key={index} className={`message ${msg.sender}-message`}>
                        {msg.text}
                    </div>
                ))}
            </div>
            
            <div className="chat-controls">
                <input
                    type="text"
                    value={inputText}
                    onChange={(e) => setInputText(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
                    placeholder="输入消息..."
                    disabled={!isConnected}
                />
                <button onClick={sendMessage} disabled={!isConnected}>
                    发送
                </button>
                <button 
                    onClick={toggleVoice} 
                    disabled={!isConnected}
                    className={isVoiceMode ? 'voice-active' : ''}
                >
                    {isVoiceMode ? '⏹️' : '🎤'}
                </button>
            </div>
            
            {status.message && (
                <div className={`status ${status.type}`}>
                    {status.message}
                </div>
            )}
        </div>
    );
};

export default XiaoZhiChat;
```

---

这些示例提供了完整的WebSocket客户端实现，包括：

1. **基础连接管理**: 连接建立、重连机制、错误处理
2. **语音交互**: 录音、发送音频、播放TTS音频
3. **图像处理**: 图像上传、分析、摄像头集成
4. **错误处理**: 完整的错误处理和重试机制
5. **实际应用**: HTML页面和React组件示例

您可以根据具体需求选择合适的示例作为起点，进行定制开发。
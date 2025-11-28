package com.lumi.assistant.network

import android.os.Handler
import android.os.Looper
import android.util.Log
import okhttp3.*
import okio.ByteString
import org.json.JSONObject
import java.util.UUID
import java.util.concurrent.TimeUnit

private const val TAG = "WebSocketManager"

class WebSocketManager {
    private var webSocket: WebSocket? = null
    private val client = OkHttpClient.Builder()
        .readTimeout(0, TimeUnit.MILLISECONDS)
        .build()

    private var sessionId: String? = null
    private val deviceId = UUID.randomUUID().toString().replace("-", "").take(12)
    private val deviceMac = generateMac()

    // 自动重连相关
    private var currentWsUrl: String? = null
    private var shouldReconnect = true
    private var reconnectAttempts = 0
    private val maxReconnectAttempts = 10
    private val reconnectHandler = Handler(Looper.getMainLooper())
    private val reconnectRunnable = Runnable { attemptReconnect() }

    // 回调
    var onConnectionStateChange: ((Boolean) -> Unit)? = null
    var onTextMessage: ((JSONObject) -> Unit)? = null
    var onBinaryMessage: ((ByteArray) -> Unit)? = null
    var onSttResult: ((String) -> Unit)? = null
    var onLlmResponse: ((String) -> Unit)? = null
    var onTtsStateChange: ((Boolean) -> Unit)? = null
    var onEmotionChange: ((String) -> Unit)? = null
    var onTtsSentence: ((String) -> Unit)? = null

    fun connect(wsUrl: String) {
        // 保存URL用于重连
        currentWsUrl = wsUrl
        shouldReconnect = true
        reconnectAttempts = 0

        // 取消之前的重连尝试
        reconnectHandler.removeCallbacks(reconnectRunnable)

        doConnect()
    }

    private fun doConnect() {
        val wsUrl = currentWsUrl ?: return
        val fullUrl = "$wsUrl?device-id=$deviceId"
        Log.d(TAG, "Connecting to: $fullUrl (attempt ${reconnectAttempts + 1})")

        val request = Request.Builder()
            .url(fullUrl)
            .build()

        webSocket = client.newWebSocket(request, object : WebSocketListener() {
            override fun onOpen(webSocket: WebSocket, response: Response) {
                Log.i(TAG, "WebSocket connected successfully")
                reconnectAttempts = 0 // 重置重连计数
                onConnectionStateChange?.invoke(true)
                sendHelloMessage()
            }

            override fun onMessage(webSocket: WebSocket, text: String) {
                Log.d(TAG, "Received text: $text")
                handleTextMessage(text)
            }

            override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
                Log.d(TAG, "Received binary: ${bytes.size} bytes")
                onBinaryMessage?.invoke(bytes.toByteArray())
            }

            override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
                Log.w(TAG, "WebSocket closing: $code - $reason")
                webSocket.close(1000, null)
                onConnectionStateChange?.invoke(false)
                // 非正常关闭时尝试重连
                if (code != 1000) {
                    scheduleReconnect()
                }
            }

            override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
                Log.w(TAG, "WebSocket closed: $code - $reason")
                onConnectionStateChange?.invoke(false)
                // 非正常关闭时尝试重连
                if (code != 1000 && shouldReconnect) {
                    scheduleReconnect()
                }
            }

            override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                Log.e(TAG, "WebSocket failure: ${t.message}", t)
                onConnectionStateChange?.invoke(false)
                // 连接失败时尝试重连
                if (shouldReconnect) {
                    scheduleReconnect()
                }
            }
        })
    }

    private fun scheduleReconnect() {
        if (!shouldReconnect || reconnectAttempts >= maxReconnectAttempts) {
            if (reconnectAttempts >= maxReconnectAttempts) {
                Log.e(TAG, "Max reconnect attempts reached, giving up")
            }
            return
        }

        reconnectAttempts++
        val delayMs = minOf(1000L * reconnectAttempts, 30000L) // 最多延迟30秒
        Log.i(TAG, "Scheduling reconnect in ${delayMs}ms (attempt $reconnectAttempts/$maxReconnectAttempts)")

        reconnectHandler.postDelayed(reconnectRunnable, delayMs)
    }

    private fun attemptReconnect() {
        Log.i(TAG, "Attempting to reconnect...")
        doConnect()
    }

    fun disconnect() {
        Log.i(TAG, "User initiated disconnect")
        shouldReconnect = false // 禁止自动重连
        reconnectHandler.removeCallbacks(reconnectRunnable) // 取消待执行的重连
        webSocket?.close(1000, "User disconnect")
        webSocket = null
        sessionId = null
        currentWsUrl = null
    }

    fun isConnected(): Boolean = webSocket != null

    private fun sendHelloMessage() {
        val hello = JSONObject().apply {
            put("type", "hello")
            put("device_id", deviceId)
            put("device_name", "Lumi Assistant")
            put("device_mac", deviceMac)
            put("token", "")
        }
        webSocket?.send(hello.toString())
    }

    fun sendListenStart() {
        val msg = JSONObject().apply {
            put("type", "listen")
            put("mode", "manual")
            put("state", "start")
        }
        webSocket?.send(msg.toString())
    }

    fun sendListenStop() {
        val msg = JSONObject().apply {
            put("type", "listen")
            put("mode", "manual")
            put("state", "stop")
        }
        webSocket?.send(msg.toString())
    }

    fun sendTextMessage(text: String) {
        val msg = JSONObject().apply {
            put("type", "listen")
            put("mode", "manual")
            put("state", "detect")
            put("text", text)
        }
        webSocket?.send(msg.toString())
    }

    fun sendAbort() {
        sessionId?.let { sid ->
            val msg = JSONObject().apply {
                put("session_id", sid)
                put("type", "abort")
                put("reason", "wake_word_detected")
            }
            webSocket?.send(msg.toString())
        }
    }

    fun sendAudioData(data: ByteArray) {
        webSocket?.send(ByteString.of(*data))
    }

    fun sendAudioEnd() {
        webSocket?.send(ByteString.of(*ByteArray(0)))
    }

    private fun handleTextMessage(text: String) {
        val json = JSONObject(text)
        onTextMessage?.invoke(json)

        when (json.optString("type")) {
            "hello" -> {
                sessionId = json.optString("session_id")
            }
            "stt" -> {
                onSttResult?.invoke(json.optString("text"))
            }
            "llm" -> {
                val llmText = json.optString("text")
                onLlmResponse?.invoke(llmText)
                // 提取表情
                val emoji = extractEmoji(llmText)
                if (emoji.isNotEmpty()) {
                    onEmotionChange?.invoke(emoji)
                }
            }
            "tts" -> {
                when (json.optString("state")) {
                    "start" -> onTtsStateChange?.invoke(true)
                    "stop" -> onTtsStateChange?.invoke(false)
                    "sentence_start" -> {
                        val text = json.optString("text")
                        if (text.isNotEmpty()) {
                            onTtsSentence?.invoke(text)
                        }
                    }
                }
            }
        }
    }

    private fun extractEmoji(text: String): String {
        val emojiPattern = Regex("[\\p{So}\\p{Cn}]")
        return emojiPattern.find(text)?.value ?: ""
    }

    private fun generateMac(): String {
        return (1..6).map {
            String.format("%02X", (0..255).random())
        }.joinToString(":")
    }
}

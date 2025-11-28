package com.lumi.assistant.viewmodel

import android.media.ToneGenerator
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lumi.assistant.audio.AudioPlayer
import com.lumi.assistant.audio.AudioRecorder
import com.lumi.assistant.config.AppSettings
import com.lumi.assistant.model.Message
import com.lumi.assistant.network.WebSocketManager
import com.lumi.assistant.repository.SettingsRepository
import com.lumi.assistant.wakeup.WakeupConfig
import com.lumi.assistant.wakeup.WakeupListener
import com.lumi.assistant.wakeup.WakeupManager
import android.content.Context
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject
import kotlin.math.abs

private const val TAG = "VoiceAssistantVM"

/**
 * 语音助手状态机
 */
enum class AssistantState {
    IDLE,       // 待机状态：等待唤醒词
    RECORDING,  // 录音状态：用户说话中，VAD工作中
    PLAYING     // 播放状态：AI回复中
}

data class VoiceAssistantState(
    val isConnected: Boolean = false,
    val isRecording: Boolean = false,
    val isSpeaking: Boolean = false,
    val recordingSeconds: Float = 0f,
    val emotion: String = "😶",
    val messages: List<Message> = emptyList(),
    val wsUrl: String = "ws://192.168.100.100:8000/xiaozhi/v1/",
    val isWakeupListening: Boolean = false,
    val isWakeupTriggered: Boolean = false,
    val wakeupStatus: String = "未初始化",
    val waveformBars: List<Float> = List(12) { 0f },
    val currentState: AssistantState = AssistantState.IDLE
)

@HiltViewModel
class VoiceAssistantViewModel @Inject constructor(
    @ApplicationContext private val context: Context,
    private val settingsRepository: SettingsRepository,
    private val webSocketManager: WebSocketManager,
    private val audioPlayer: AudioPlayer,
    private val wakeupManager: WakeupManager
) : ViewModel() {
    private val _state = MutableStateFlow(VoiceAssistantState())
    val state: StateFlow<VoiceAssistantState> = _state.asStateFlow()

    // 当前应用配置（从DataStore读取）
    private var currentSettings = AppSettings()

    private lateinit var audioRecorder: AudioRecorder
    private val mainHandler = Handler(Looper.getMainLooper())

    // 音频提示音
    private var toneGenerator: ToneGenerator? = null

    // VAD相关
    private var lastSoundTime = 0L
    private var isSilent = true
    private val vadHandler = Handler(Looper.getMainLooper())
    private var vadCheckRunnable: Runnable? = null

    // 音频缓冲队列（录音期间暂存AI音频）
    private val audioBuffer = mutableListOf<ByteArray>()

    // 波形数据
    private val volumeHistory = mutableListOf<Float>()

    init {
        setupWebSocketCallbacks()
        setupAudioRecorder()
        setupToneGenerator()

        // 监听配置变化
        viewModelScope.launch {
            settingsRepository.settingsFlow.collect { settings ->
                val previousKeyword = currentSettings.wakeup.keyword
                val previousWsUrl = currentSettings.server.wsUrl
                currentSettings = settings
                Log.i(TAG, "⚙️ 配置已更新: VAD静音=${settings.vad.silenceThreshold}ms, VAD音量=${settings.vad.volumeThreshold}, 服务器=${settings.server.wsUrl}, 唤醒词=${settings.wakeup.keyword}")

                // 更新 WebSocket URL
                _state.update { it.copy(wsUrl = settings.server.wsUrl) }

                // 如果服务器地址变化，断开旧连接并重连新地址
                if (settings.server.wsUrl != previousWsUrl && previousWsUrl.isNotEmpty()) {
                    Log.i(TAG, "🔄 服务器地址已变化: '$previousWsUrl' -> '${settings.server.wsUrl}'")
                    mainHandler.post {
                        // 断开旧连接
                        if (_state.value.isConnected) {
                            Log.i(TAG, "断开旧服务器连接...")
                            webSocketManager.disconnect()
                        }
                        // 延迟500ms后重连新地址
                        mainHandler.postDelayed({
                            Log.i(TAG, "连接新服务器: ${settings.server.wsUrl}")
                            connect()
                        }, 500)
                    }
                }

                // 如果唤醒词变化，更新唤醒管理器
                if (settings.wakeup.keyword != previousKeyword) {
                    Log.i(TAG, "🔄 唤醒词已变化: '$previousKeyword' -> '${settings.wakeup.keyword}'")
                    wakeupManager.updateKeyword(settings.wakeup.keyword)

                    // 如果当前正在监听唤醒，需要重新启动
                    if (_state.value.isWakeupListening) {
                        Log.i(TAG, "🔄 重新启动唤醒监听以应用新唤醒词")
                        mainHandler.post {
                            stopWakeupListening()
                            mainHandler.postDelayed({
                                startWakeupListening()
                            }, 500)
                        }
                    }
                }
            }
        }

        // 延迟自动连接WebSocket (等待唤醒SDK初始化和配置加载)
        mainHandler.postDelayed({
            if (!_state.value.isConnected) {
                Log.i(TAG, "Auto-connecting to WebSocket...")
                connect()
            }
        }, 3000) // 3秒后自动连接
    }

    private fun setupWebSocketCallbacks() {
        webSocketManager.onConnectionStateChange = { connected ->
            Log.d(TAG, "Connection state changed: $connected")
            mainHandler.post {
                _state.update { it.copy(isConnected = connected) }
                if (connected) {
                    audioPlayer.start()
                } else {
                    audioPlayer.stop()
                    _state.update { it.copy(isSpeaking = false) }
                }
            }
        }

        webSocketManager.onBinaryMessage = { data ->
            mainHandler.post {
                when (_state.value.currentState) {
                    AssistantState.RECORDING -> {
                        // 录音状态：暂存AI音频，不播放
                        audioBuffer.add(data)
                        Log.d(TAG, "📦 [RECORDING] 收到AI音频，暂存到缓冲区 (共${audioBuffer.size}块)")
                    }
                    AssistantState.PLAYING, AssistantState.IDLE -> {
                        // 播放状态或待机状态：直接播放
                        audioPlayer.enqueue(data)
                        Log.d(TAG, "▶️ [${_state.value.currentState}] 收到AI音频，直接播放")
                    }
                }
            }
        }

        webSocketManager.onSttResult = { text ->
            if (text.isNotEmpty()) {
                mainHandler.post {
                    addMessage(Message(content = text, isFromUser = true))
                }
            }
        }

        webSocketManager.onLlmResponse = { text ->
            if (text.isNotEmpty()) {
                mainHandler.post {
                    addMessage(Message(content = text, isFromUser = false))
                }
            }
        }

        webSocketManager.onTtsStateChange = { speaking ->
            mainHandler.post {
                _state.update { it.copy(isSpeaking = speaking) }
                if (!speaking) {
                    audioPlayer.clear()

                    // 如果当前是PLAYING状态，播放完成后返回IDLE
                    if (_state.value.currentState == AssistantState.PLAYING) {
                        Log.i(TAG, "✅ [PLAYING → IDLE] AI播放完成，重新开启唤醒监听")

                        // 🔑 状态转换: PLAYING → IDLE
                        _state.update {
                            it.copy(
                                currentState = AssistantState.IDLE,
                                wakeupStatus = "等待唤醒",
                                isWakeupTriggered = false
                            )
                        }

                        // 延迟500ms后重新开启唤醒监听（避免AI声音尾音触发唤醒）
                        mainHandler.postDelayed({
                            startWakeupListening()
                        }, 500)
                    }
                }
            }
        }

        webSocketManager.onEmotionChange = { emoji ->
            mainHandler.post {
                _state.update { it.copy(emotion = emoji) }
            }
        }

        webSocketManager.onTtsSentence = { text ->
            if (text.isNotEmpty()) {
                mainHandler.post {
                    addMessage(Message(content = text, isFromUser = false))
                }
            }
        }
    }

    private fun setupAudioRecorder() {
        audioRecorder = AudioRecorder(
            onAudioData = { data ->
                webSocketManager.sendAudioData(data)
            },
            onRecordingTime = { seconds ->
                _state.update { it.copy(recordingSeconds = seconds) }
            },
            onVolumeUpdate = { volume ->
                updateWaveform(volume)
            }
        )
    }

    /**
     * 更新波形数据
     * 只在RECORDING状态时更新波形和VAD检测
     */
    private fun updateWaveform(volume: Int) {
        // 🔑 关键：只在RECORDING状态时才更新波形和VAD
        if (_state.value.currentState != AssistantState.RECORDING) {
            return
        }

        // VAD 检测逻辑（使用配置中的音量阈值）
        // 环境噪音通常在 100-500 之间，说话音量通常在 800 以上
        if (volume > currentSettings.vad.volumeThreshold) {
            // 检测到用户声音
            lastSoundTime = System.currentTimeMillis()
            isSilent = false
            Log.d(TAG, "🔊 VAD检测: 音量=$volume (阈值=${currentSettings.vad.volumeThreshold}) -> 更新lastSoundTime")
        } else {
            val silenceDuration = System.currentTimeMillis() - lastSoundTime
            Log.d(TAG, "🔇 VAD检测: 音量=$volume (阈值=${currentSettings.vad.volumeThreshold}) -> 已静音${silenceDuration}ms")
        }

        // 将音量归一化到 0-1 范围，使用更灵敏的缩放
        // 实际测试发现正常说话音量约 1000-5000，大声可达 10000+
        val normalizedVolume = when {
            volume < 100 -> 0f  // 过滤背景噪音
            volume < 3000 -> (volume / 3000f) * 0.5f  // 小声：0-0.5
            else -> 0.5f + ((volume - 3000f) / 12000f).coerceAtMost(0.5f)  // 正常/大声：0.5-1.0
        }

        // 使用平方根增强对比度，让变化更明显
        val enhancedVolume = kotlin.math.sqrt(normalizedVolume)

        // 添加到历史记录
        volumeHistory.add(enhancedVolume)

        // 保持最多12个数据点
        if (volumeHistory.size > 12) {
            volumeHistory.removeAt(0)
        }

        // 更新状态（如果不足12个，用0填充）
        val bars = volumeHistory.toList() + List(12 - volumeHistory.size) { 0f }

        _state.update { it.copy(waveformBars = bars) }
    }

    /**
     * 清空波形数据
     */
    private fun clearWaveform() {
        volumeHistory.clear()
        _state.update { it.copy(waveformBars = List(12) { 0f }) }
    }

    fun connect() {
        val url = _state.value.wsUrl
        Log.d(TAG, "Connecting to: $url")
        if (url.isNotEmpty()) {
            webSocketManager.connect(url)
        }
    }

    fun disconnect() {
        stopRecording()
        webSocketManager.disconnect()
    }

    fun updateWsUrl(url: String) {
        _state.update { it.copy(wsUrl = url) }
    }

    fun startRecording() {
        if (_state.value.isConnected && !_state.value.isRecording) {
            // 如果正在播放，先中断
            if (_state.value.isSpeaking) {
                webSocketManager.sendAbort()
                audioPlayer.clear()
                _state.update { it.copy(isSpeaking = false) }
            }

            if (audioRecorder.start(context)) {
                webSocketManager.sendListenStart()
                _state.update { it.copy(isRecording = true, recordingSeconds = 0f) }

                // 手动录音也需要启动VAD
                lastSoundTime = System.currentTimeMillis()
                isSilent = false
                startVadCheck()
                Log.i(TAG, "🎤 手动录音已启动，VAD已开启")
            }
        }
    }

    fun stopRecording() {
        if (_state.value.isRecording) {
            // 停止VAD检查
            vadCheckRunnable?.let {
                vadHandler.removeCallbacks(it)
                Log.i(TAG, "⏰ VAD检查已停止（手动停止）")
            }

            audioRecorder.stop()
            webSocketManager.sendAudioEnd()
            webSocketManager.sendListenStop()
            clearWaveform()
            _state.update { it.copy(isRecording = false, recordingSeconds = 0f) }

            Log.i(TAG, "🎤 手动停止录音")
        }
    }

    fun sendTextMessage(text: String) {
        if (_state.value.isConnected && text.isNotEmpty()) {
            webSocketManager.sendTextMessage(text)
            addMessage(Message(content = text, isFromUser = true))
        }
    }

    private fun addMessage(message: Message) {
        _state.update { it.copy(messages = it.messages + message) }
    }

    fun clearMessages() {
        _state.update { it.copy(messages = emptyList()) }
    }

    // ===== 唤醒相关方法 =====

    /**
     * 初始化唤醒SDK
     */
    fun initWakeup() {
        Log.i(TAG, "initWakeup() called")
        _state.update { it.copy(wakeupStatus = "初始化中...") }
        Log.i(TAG, "Calling wakeupManager.initSDK()...")
        wakeupManager.initSDK(
            onSuccess = {
                Log.i(TAG, "Wakeup SDK initialized successfully")
                mainHandler.post {
                    _state.update { it.copy(wakeupStatus = "已初始化") }
                    // 自动启动唤醒监听
                    startWakeupListening()
                }
            },
            onError = { error ->
                Log.e(TAG, "Wakeup SDK init failed: $error")
                mainHandler.post {
                    _state.update { it.copy(wakeupStatus = "初始化失败: $error") }
                }
            }
        )
        Log.i(TAG, "wakeupManager.initSDK() call returned")
    }

    /**
     * 启动唤醒监听
     */
    private fun startWakeupListening() {
        if (_state.value.isWakeupListening) {
            Log.w(TAG, "Wakeup already listening")
            return
        }

        val listener = object : WakeupListener {
            override fun onWakeupSuccess(keyword: String, score: Int) {
                Log.i(TAG, "Wakeup success: keyword=$keyword, score=$score")
                mainHandler.post {
                    handleWakeupSuccess()
                }
            }

            override fun onPreWakeup() {
                Log.d(TAG, "Pre-wakeup triggered")
            }

            override fun onWakeupError(errorCode: Int, errorMsg: String) {
                Log.e(TAG, "Wakeup error: code=$errorCode, msg=$errorMsg")
                mainHandler.post {
                    _state.update { it.copy(wakeupStatus = "唤醒错误: $errorMsg") }
                }
            }

            override fun onAudioData(audioData: ByteArray) {
                // 唤醒触发后,用于VAD检测
                if (_state.value.isWakeupTriggered && _state.value.isRecording) {
                    checkVad(audioData)
                }
            }
        }

        wakeupManager.startWakeup(listener)
        _state.update {
            it.copy(
                isWakeupListening = true,
                wakeupStatus = "正在监听 '${currentSettings.wakeup.keyword}'"
            )
        }
        Log.i(TAG, "Wakeup listening started: ${currentSettings.wakeup.keyword}")
    }

    /**
     * 停止唤醒监听
     */
    private fun stopWakeupListening() {
        if (!_state.value.isWakeupListening) {
            Log.w(TAG, "Wakeup not listening")
            return
        }

        wakeupManager.stopWakeup()
        _state.update {
            it.copy(
                isWakeupListening = false,
                wakeupStatus = "监听已停止"
            )
        }
        Log.i(TAG, "Wakeup listening stopped")
    }

    /**
     * 处理唤醒成功
     */
    private fun handleWakeupSuccess() {
        // 更新状态
        _state.update {
            it.copy(
                isWakeupTriggered = true,
                wakeupStatus = "唤醒成功!正在录音...",
                emotion = "👂"
            )
        }

        // 停止唤醒监听,开始录音
        wakeupManager.stopWakeup()
        _state.update { it.copy(isWakeupListening = false) }

        // 如果已连接WebSocket,立即开始录音（无延迟，波形即为视觉反馈）
        if (_state.value.isConnected) {
            startRecordingAfterWakeup()
        } else {
            _state.update { it.copy(wakeupStatus = "请先连接WebSocket") }
            resetWakeup()
        }
    }

    /**
     * 唤醒后开始录音
     */
    private fun startRecordingAfterWakeup() {
        if (_state.value.isConnected && !_state.value.isRecording) {
            // 如果正在播放,先中断
            if (_state.value.isSpeaking) {
                webSocketManager.sendAbort()
                audioPlayer.clear()
                _state.update { it.copy(isSpeaking = false) }
            }

            // 清空音频缓冲区
            audioBuffer.clear()
            Log.i(TAG, "🗑️ 清空音频缓冲区")

            if (audioRecorder.start(context)) {
                webSocketManager.sendListenStart()

                // 🔑 状态转换: IDLE → RECORDING
                _state.update {
                    it.copy(
                        isRecording = true,
                        recordingSeconds = 0f,
                        currentState = AssistantState.RECORDING
                    )
                }

                // 初始化VAD
                lastSoundTime = System.currentTimeMillis()
                isSilent = false
                startVadCheck()

                Log.i(TAG, "🎤 [IDLE → RECORDING] 唤醒后开始录音")
            }
        }
    }

    /**
     * 播放提示音(简单的beep声)
     */
    private fun playBeep() {
        try {
            toneGenerator?.startTone(ToneGenerator.TONE_PROP_BEEP, 150)
        } catch (e: Exception) {
            Log.e(TAG, "Play beep failed", e)
        }
    }

    /**
     * 设置提示音生成器
     */
    private fun setupToneGenerator() {
        try {
            toneGenerator = ToneGenerator(AudioManager.STREAM_MUSIC, 80)
        } catch (e: Exception) {
            Log.e(TAG, "ToneGenerator init failed", e)
        }
    }

    /**
     * VAD检测 - 检测静音
     */
    private fun checkVad(audioData: ByteArray) {
        val volume = calculateVolume(audioData)

        if (volume > currentSettings.vad.volumeThreshold) {
            // 有声音
            lastSoundTime = System.currentTimeMillis()
            if (isSilent) {
                Log.d(TAG, "VAD: 检测到声音恢复, 音量=$volume (阈值=${currentSettings.vad.volumeThreshold})")
            }
            isSilent = false
        } else {
            // 静音
            val silenceDuration = System.currentTimeMillis() - lastSoundTime
            if (silenceDuration > currentSettings.vad.silenceThreshold && !isSilent) {
                isSilent = true
                Log.i(TAG, "VAD: 检测到${silenceDuration}ms静音，停止录音（阈值=${currentSettings.vad.silenceThreshold}ms）")
                mainHandler.post {
                    stopRecordingAfterVad()
                }
            } else if (silenceDuration > 1000 && silenceDuration % 1000 < 100) {
                // 每秒输出一次静音进度
                Log.d(TAG, "VAD: 静音持续${silenceDuration}ms, 音量=$volume (阈值=${currentSettings.vad.volumeThreshold})")
            }
        }
    }

    /**
     * 计算音量
     */
    private fun calculateVolume(audioData: ByteArray): Int {
        var sum = 0L
        for (i in audioData.indices step 2) {
            if (i + 1 < audioData.size) {
                val sample = (audioData[i].toInt() and 0xFF) or
                            ((audioData[i + 1].toInt() and 0xFF) shl 8)
                sum += abs(sample.toShort().toInt())
            }
        }
        return if (audioData.isNotEmpty()) (sum / (audioData.size / 2)).toInt() else 0
    }

    /**
     * 启动VAD定期检查
     */
    private fun startVadCheck() {
        Log.i(TAG, "⏰ VAD检查已启动")
        vadCheckRunnable = object : Runnable {
            override fun run() {
                val isRec = _state.value.isRecording
                Log.d(TAG, "⏰ VAD Timer检查: isRecording=$isRec")

                if (isRec) {
                    val silenceDuration = System.currentTimeMillis() - lastSoundTime
                    Log.d(TAG, "⏰ VAD Timer: 静音时长=${silenceDuration}ms, 阈值=${currentSettings.vad.silenceThreshold}ms")

                    if (silenceDuration > currentSettings.vad.silenceThreshold && !isSilent) {
                        isSilent = true
                        Log.i(TAG, "⏰ VAD Timer: 检测到${silenceDuration}ms静音，停止录音")
                        stopRecordingAfterVad()
                    } else {
                        vadHandler.postDelayed(this, 500) // 每500ms检查一次
                    }
                } else {
                    Log.w(TAG, "⏰ VAD Timer: 录音已停止，停止检查")
                }
            }
        }
        vadHandler.postDelayed(vadCheckRunnable!!, 500)
    }

    /**
     * VAD检测到静音后停止录音，播放缓冲的AI音频
     */
    private fun stopRecordingAfterVad() {
        vadCheckRunnable?.let {
            vadHandler.removeCallbacks(it)
            Log.i(TAG, "⏰ VAD检查已停止（VAD自动停止）")
        }

        if (_state.value.isRecording && _state.value.currentState == AssistantState.RECORDING) {
            // 停止录音
            audioRecorder.stop()
            webSocketManager.sendAudioEnd()
            webSocketManager.sendListenStop()
            clearWaveform()

            Log.i(TAG, "⏰ VAD检测到3秒静音，停止录音")

            // 检查是否有缓冲的AI音频
            if (audioBuffer.isNotEmpty()) {
                Log.i(TAG, "▶️ [RECORDING → PLAYING] 播放缓冲的${audioBuffer.size}块AI音频")

                // 🔑 状态转换: RECORDING → PLAYING
                _state.update {
                    it.copy(
                        isRecording = false,
                        recordingSeconds = 0f,
                        currentState = AssistantState.PLAYING,
                        isSpeaking = true,
                        wakeupStatus = "AI回复中..."
                    )
                }

                // 播放所有缓冲的音频
                audioBuffer.forEach { data ->
                    audioPlayer.enqueue(data)
                }
                audioBuffer.clear()
                Log.i(TAG, "🗑️ 清空音频缓冲区")
            } else {
                // 没有AI音频，直接返回IDLE状态
                Log.i(TAG, "⚠️ 没有缓冲的AI音频，直接返回IDLE")
                _state.update {
                    it.copy(
                        isRecording = false,
                        recordingSeconds = 0f,
                        currentState = AssistantState.IDLE,
                        wakeupStatus = "等待唤醒"
                    )
                }
                // 重新开启唤醒监听
                startWakeupListening()
            }
        }
    }

    /**
     * 重置唤醒状态
     */
    private fun resetWakeup() {
        _state.update {
            it.copy(
                isWakeupTriggered = false,
                emotion = "😶"
            )
        }
        // 重新开始监听唤醒词
        startWakeupListening()
    }

    override fun onCleared() {
        super.onCleared()
        disconnect()
        wakeupManager.release()
        toneGenerator?.release()
        toneGenerator = null
        vadCheckRunnable?.let { vadHandler.removeCallbacks(it) }
    }
}

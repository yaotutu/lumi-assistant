package com.lumi.assistant.wakeup

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import com.iflytek.aikit.core.AiAudio
import com.iflytek.aikit.core.AiHandle
import com.iflytek.aikit.core.AiHelper
import com.iflytek.aikit.core.AiListener
import com.iflytek.aikit.core.AiRequest
import com.iflytek.aikit.core.AiResponse
import com.iflytek.aikit.core.AiStatus
import com.iflytek.aikit.core.BaseLibrary
import com.iflytek.aikit.core.CoreListener
import com.iflytek.aikit.core.ErrType
import java.io.BufferedWriter
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStreamWriter
import java.util.concurrent.atomic.AtomicBoolean

/**
 * 语音唤醒管理器
 * 负责初始化SDK、启动/停止唤醒监听、处理唤醒回调
 */
class WakeupManager(private val context: Context) {

    companion object {
        private const val TAG = "WakeupManager"
        private const val MSG_START = 0x0001
        private const val MSG_WRITE = 0x0002
        private const val MSG_END = 0x0003
    }

    private var audioRecord: AudioRecord? = null
    private val isRecording = AtomicBoolean(false)
    private val isInitialized = AtomicBoolean(false)
    private var aiHandle: AiHandle? = null
    private var wakeupListener: WakeupListener? = null
    private var handler: Handler? = null
    private var recordThread: Thread? = null

    // 当前使用的唤醒词
    private var currentKeyword: String = WakeupConfig.WAKEUP_KEYWORD

    /**
     * 初始化AIKit SDK
     */
    fun initSDK(onSuccess: () -> Unit, onError: (String) -> Unit) {
        if (isInitialized.get()) {
            Log.w(TAG, "SDK already initialized")
            onSuccess()
            return
        }

        try {
            // 创建工作目录
            val workDir = WakeupConfig.getWorkDir(context)
            val logDir = workDir + "aikit/"
            File(logDir).mkdirs()

            // 从 assets 复制 IVW 模型文件到应用私有目录
            copyAssetsToWorkDir()

            // 设置SDK日志
            AiHelper.getInst().setLogInfo(
                com.iflytek.aikit.core.LogLvl.VERBOSE,
                1,
                logDir + "aeeLog.txt"
            )

            Log.i(TAG, "SDK log configured: $logDir")

            // 注册授权监听
            AiHelper.getInst().registerListener(object : CoreListener {
                override fun onAuthStateChange(type: ErrType?, code: Int) {
                    Log.i(TAG, "Auth state changed: type=$type, code=$code")
                    if (code == 0) {
                        isInitialized.set(true)
                        registerWakeupListener()
                        onSuccess()
                    } else {
                        Log.e(TAG, "SDK authorization failed: code=$code, type=$type")
                        onError("SDK授权失败: code=$code, type=$type")
                    }
                }
            })

            // 初始化SDK参数
            val params = BaseLibrary.Params.builder()
                .appId(WakeupConfig.APP_ID)
                .apiKey(WakeupConfig.API_KEY)
                .apiSecret(WakeupConfig.API_SECRET)
                .workDir(workDir)
                .build()

            // 在子线程中初始化SDK
            Thread {
                try {
                    Log.i(TAG, "Starting SDK initialization in background thread...")
                    AiHelper.getInst().initEntry(context, params)
                    Log.i(TAG, "SDK initEntry called successfully")
                } catch (e: Exception) {
                    Log.e(TAG, "SDK initEntry exception", e)
                    onError("SDK初始化异常: ${e.message}")
                }
            }.start()

            Log.i(TAG, "SDK init thread started, workDir=$workDir")
        } catch (e: Exception) {
            Log.e(TAG, "SDK init setup failed", e)
            onError("SDK初始化设置异常: ${e.message}")
        }
    }

    /**
     * 注册唤醒监听器
     */
    private fun registerWakeupListener() {
        val listener = object : AiListener {
            override fun onResult(
                handleID: Int,
                outputData: List<AiResponse>?,
                usrContext: Any?
            ) {
                outputData?.forEach { response ->
                    val key = response.key
                    val valueBytes = response.value
                    val value = String(valueBytes ?: ByteArray(0))

                    Log.d(TAG, "Wakeup result: key=$key, value=$value")

                    when (key) {
                        "func_wake_up" -> {
                            // 唤醒成功
                            val score = extractScore(value)
                            wakeupListener?.onWakeupSuccess(currentKeyword, score)
                        }
                        "func_pre_wakeup" -> {
                            // 预唤醒
                            wakeupListener?.onPreWakeup()
                        }
                    }
                }
            }

            override fun onEvent(handleID: Int, eventType: Int, list: List<AiResponse>?, usrContext: Any?) {
                Log.d(TAG, "Wakeup event: type=$eventType")
            }

            override fun onError(handleID: Int, err: Int, msg: String?, usrContext: Any?) {
                Log.e(TAG, "Wakeup error: err=$err, msg=$msg")
                wakeupListener?.onWakeupError(err, msg ?: "Unknown error")
            }
        }

        AiHelper.getInst().registerListener(WakeupConfig.ABILITY_ID, listener)
        Log.i(TAG, "Wakeup listener registered")
    }

    /**
     * 提取唤醒分数
     */
    private fun extractScore(value: String): Int {
        return try {
            value.toIntOrNull() ?: 0
        } catch (e: Exception) {
            0
        }
    }

    /**
     * 启动唤醒监听
     */
    fun startWakeup(listener: WakeupListener) {
        if (!isInitialized.get()) {
            Log.e(TAG, "SDK not initialized")
            listener.onWakeupError(-1, "SDK未初始化")
            return
        }

        if (isRecording.get()) {
            Log.w(TAG, "Already listening")
            return
        }

        this.wakeupListener = listener

        // 创建工作线程和Handler
        recordThread = Thread {
            Looper.prepare()
            handler = object : Handler(Looper.myLooper()!!) {
                override fun handleMessage(msg: Message) {
                    when (msg.what) {
                        MSG_START -> handleStart()
                        MSG_WRITE -> handleWrite()
                        MSG_END -> handleEnd()
                    }
                }
            }
            Looper.loop()
        }
        recordThread?.start()

        // 等待Handler初始化
        Thread.sleep(100)

        // 发送启动消息
        handler?.sendEmptyMessage(MSG_START)
    }

    /**
     * 处理启动消息
     */
    private fun handleStart() {
        try {
            // 准备唤醒词文件
            prepareKeywordFile()

            // 加载唤醒词资源
            val customBuilder = AiRequest.builder()
            customBuilder.customText(
                "key_word",
                WakeupConfig.getKeywordFilePath(context),
                0
            )
            AiHelper.getInst().loadData(WakeupConfig.ABILITY_ID, customBuilder.build())

            // 指定数据集
            val indexes = intArrayOf(0)
            AiHelper.getInst().specifyDataSet(WakeupConfig.ABILITY_ID, "key_word", indexes)

            // 启动唤醒引擎
            val paramBuilder = AiRequest.builder()
            paramBuilder.param("wdec_param_nCmThreshold", WakeupConfig.CM_THRESHOLD)
            paramBuilder.param("gramLoad", true)

            aiHandle = AiHelper.getInst().start(
                WakeupConfig.ABILITY_ID,
                paramBuilder.build(),
                null
            )

            if (aiHandle == null || aiHandle!!.code != 0) {
                Log.e(TAG, "Failed to start wakeup engine: code=${aiHandle?.code}")
                wakeupListener?.onWakeupError(aiHandle?.code ?: -1, "唤醒引擎启动失败")
                return
            }

            Log.i(TAG, "Wakeup engine started successfully")

            // 开始录音
            startRecording()

        } catch (e: Exception) {
            Log.e(TAG, "Start wakeup failed", e)
            wakeupListener?.onWakeupError(-1, "启动唤醒失败: ${e.message}")
        }
    }

    /**
     * 准备唤醒词文件
     */
    private fun prepareKeywordFile() {
        val resDir = WakeupConfig.getIvwResDir(context)
        File(resDir).mkdirs()

        val keywordFile = File(WakeupConfig.getKeywordFilePath(context))
        BufferedWriter(OutputStreamWriter(FileOutputStream(keywordFile))).use { writer ->
            writer.write(currentKeyword)
        }

        Log.i(TAG, "Keyword file prepared: ${keywordFile.absolutePath}, keyword='$currentKeyword'")
    }

    /**
     * 更新唤醒词
     * 需要停止当前唤醒，更新关键词文件，然后可以重新启动
     */
    fun updateKeyword(newKeyword: String) {
        if (newKeyword.isBlank()) {
            Log.w(TAG, "Cannot update to blank keyword")
            return
        }

        if (currentKeyword == newKeyword) {
            Log.i(TAG, "Keyword unchanged: $newKeyword")
            return
        }

        Log.i(TAG, "Updating keyword from '$currentKeyword' to '$newKeyword'")

        // 如果正在录音，先停止
        val wasRecording = isRecording.get()
        if (wasRecording) {
            stopWakeup()
        }

        // 更新唤醒词
        currentKeyword = newKeyword

        // 重新准备关键词文件
        if (isInitialized.get()) {
            prepareKeywordFile()
            Log.i(TAG, "Keyword updated successfully, ready to restart wakeup")
        }
    }

    /**
     * 开始录音
     */
    private fun startRecording() {
        val bufferSize = AudioRecord.getMinBufferSize(
            WakeupConfig.SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            WakeupConfig.SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize.coerceAtLeast(WakeupConfig.BUFFER_SIZE)
        )

        audioRecord?.startRecording()
        isRecording.set(true)

        Log.i(TAG, "Recording started")

        // 开始写入音频数据
        handler?.sendEmptyMessage(MSG_WRITE)
    }

    /**
     * 处理音频数据写入
     */
    private fun handleWrite() {
        if (!isRecording.get()) return

        Thread {
            val buffer = ByteArray(WakeupConfig.BUFFER_SIZE)

            while (isRecording.get()) {
                val readSize = audioRecord?.read(buffer, 0, buffer.size) ?: 0

                if (readSize > 0) {
                    // 发送给唤醒引擎
                    writeAudioToEngine(buffer, readSize)

                    // 回调音频数据(用于VAD检测)
                    wakeupListener?.onAudioData(buffer.copyOf(readSize))
                }
            }
        }.start()
    }

    /**
     * 写入音频到引擎
     */
    private fun writeAudioToEngine(buffer: ByteArray, size: Int) {
        try {
            val aiAudio = AiAudio.get("wav")
                .data(buffer.copyOf(size))
                .status(AiStatus.CONTINUE)
                .valid()

            val dataBuilder = AiRequest.builder().payload(aiAudio)
            AiHelper.getInst().write(dataBuilder.build(), aiHandle)
        } catch (e: Exception) {
            Log.e(TAG, "Write audio failed", e)
        }
    }

    /**
     * 停止唤醒监听
     */
    fun stopWakeup() {
        if (!isRecording.get()) return

        Log.i(TAG, "Stopping wakeup...")

        isRecording.set(false)

        // 停止录音
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null

        // 结束引擎会话
        handler?.sendEmptyMessage(MSG_END)
    }

    /**
     * 处理结束消息
     */
    private fun handleEnd() {
        try {
            aiHandle?.let {
                AiHelper.getInst().end(it)
                Log.i(TAG, "Wakeup session ended")
            }
            aiHandle = null
        } catch (e: Exception) {
            Log.e(TAG, "End wakeup failed", e)
        }
    }

    /**
     * 释放资源(应用退出时调用)
     */
    fun release() {
        stopWakeup()

        // 退出Looper
        handler?.looper?.quit()
        recordThread?.interrupt()

        // 注意: engineUninit仅在完全不再使用时调用,否则会导致崩溃
        // AiHelper.getInst().engineUninit(WakeupConfig.ABILITY_ID)

        wakeupListener = null
        isInitialized.set(false)

        Log.i(TAG, "WakeupManager released")
    }

    /**
     * 从 assets 复制 IVW 模型文件到应用私有目录
     */
    private fun copyAssetsToWorkDir() {
        try {
            val ivwResDir = WakeupConfig.getIvwResDir(context)
            val targetDir = File(ivwResDir)

            // 如果模型文件已存在，跳过复制
            if (targetDir.exists() && targetDir.listFiles()?.any { it.name.startsWith("IVW_") } == true) {
                Log.i(TAG, "IVW model files already exist, skip copying")
                return
            }

            targetDir.mkdirs()

            val assetManager = context.assets
            val assetFiles = assetManager.list("ivw") ?: emptyArray()

            Log.i(TAG, "Copying ${assetFiles.size} files from assets/ivw to $ivwResDir")

            for (filename in assetFiles) {
                val targetFile = File(targetDir, filename)

                assetManager.open("ivw/$filename").use { inputStream ->
                    FileOutputStream(targetFile).use { outputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }

                Log.d(TAG, "Copied: $filename (${targetFile.length()} bytes)")
            }

            Log.i(TAG, "Successfully copied all IVW model files from assets")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to copy assets to work dir", e)
            throw e
        }
    }
}

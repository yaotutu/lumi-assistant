package com.lumi.assistant.audio

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import androidx.core.content.ContextCompat
import com.theeasiestway.opus.Constants
import com.theeasiestway.opus.Opus
import kotlinx.coroutines.*

private const val TAG = "AudioRecorder"

class AudioRecorder(
    private val onAudioData: (ByteArray) -> Unit,
    private val onRecordingTime: (Float) -> Unit,
    private val onVolumeUpdate: ((Int) -> Unit)? = null
) {
    companion object {
        private const val SAMPLE_RATE = 16000
        private const val CHANNELS = 1
        // 60ms @ 16kHz = 960 samples
        private const val FRAME_SIZE = 960
    }

    private var audioRecord: AudioRecord? = null
    private var opusEncoder: Opus? = null
    private var recordingJob: Job? = null
    private var isRecording = false
    private var startTime = 0L

    fun start(context: android.content.Context): Boolean {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            Log.e(TAG, "录音权限未授予")
            return false
        }

        // 初始化 Opus 编码器
        if (!initOpusEncoder()) {
            Log.e(TAG, "Opus 编码器初始化失败")
            return false
        }

        val bufferSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        ).coerceAtLeast(FRAME_SIZE * 2)

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize
        )

        if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
            Log.e(TAG, "AudioRecord 初始化失败")
            return false
        }

        isRecording = true
        startTime = System.currentTimeMillis()
        audioRecord?.startRecording()
        Log.d(TAG, "开始录音: sampleRate=$SAMPLE_RATE, frameSize=$FRAME_SIZE")

        recordingJob = CoroutineScope(Dispatchers.IO).launch {
            val buffer = ShortArray(FRAME_SIZE)

            while (isRecording) {
                val read = audioRecord?.read(buffer, 0, FRAME_SIZE) ?: 0
                if (read > 0) {
                    // 使用 JNI Opus 编码器编码 PCM → Opus
                    encodeOpus(buffer, read)
                }

                val elapsed = (System.currentTimeMillis() - startTime) / 1000f
                withContext(Dispatchers.Main) {
                    onRecordingTime(elapsed)
                }
            }
        }

        return true
    }

    fun stop() {
        Log.d(TAG, "停止录音")
        isRecording = false
        recordingJob?.cancel()
        recordingJob = null

        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null

        try {
            opusEncoder?.encoderRelease()
        } catch (e: Exception) {
            Log.e(TAG, "释放 Opus 编码器失败", e)
        }
        opusEncoder = null
    }

    private fun initOpusEncoder(): Boolean {
        return try {
            opusEncoder = Opus()

            // 初始化编码器: 16kHz, 单声道
            val result = opusEncoder?.encoderInit(
                Constants.SampleRate._16000(),
                Constants.Channels.mono(),
                Constants.Application.audio()
            )

            if (result != null && result >= 0) {
                // 设置比特率（可选，自动模式）
                opusEncoder?.encoderSetBitrate(Constants.Bitrate.auto())

                Log.d(TAG, "Opus 编码器初始化成功: sampleRate=$SAMPLE_RATE, channels=mono, result=$result")
                true
            } else {
                Log.e(TAG, "Opus 编码器初始化失败: result=$result")
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Opus 编码器初始化异常", e)
            false
        }
    }

    private fun encodeOpus(pcmBuffer: ShortArray, size: Int) {
        val encoder = opusEncoder ?: return

        try {
            // 计算音量（RMS）
            val volume = calculateVolume(pcmBuffer, size)
            CoroutineScope(Dispatchers.Main).launch {
                onVolumeUpdate?.invoke(volume)
            }

            // 将 ShortArray 转换为 ByteArray (Little-Endian)
            val pcmBytes = ByteArray(size * 2)
            for (i in 0 until size) {
                val sample = pcmBuffer[i].toInt()
                pcmBytes[i * 2] = (sample and 0xFF).toByte()           // 低字节
                pcmBytes[i * 2 + 1] = ((sample shr 8) and 0xFF).toByte() // 高字节
            }

            // 使用 JNI Opus 编码: ByteArray PCM → ByteArray Opus
            val opusData = encoder.encode(pcmBytes, Constants.FrameSize._960())

            if (opusData != null && opusData.isNotEmpty()) {
                onAudioData(opusData)
                Log.d(TAG, "编码成功: ${pcmBytes.size}B PCM -> ${opusData.size}B Opus")
            } else {
                Log.w(TAG, "编码返回空数据")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Opus 编码失败", e)
        }
    }

    /**
     * 计算音频音量（RMS）
     */
    private fun calculateVolume(buffer: ShortArray, size: Int): Int {
        var sum = 0L
        for (i in 0 until size) {
            sum += kotlin.math.abs(buffer[i].toInt())
        }
        val volume = if (size > 0) (sum / size).toInt() else 0
        // 只在音量变化较大时输出日志，避免刷屏
        if (volume > 500) {
            Log.d(TAG, "检测到声音: 音量=$volume")
        }
        return volume
    }

    fun isRecording(): Boolean = isRecording
}

package com.lumi.assistant.audio

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.util.Log
import com.theeasiestway.opus.Constants
import com.theeasiestway.opus.Opus
import kotlinx.coroutines.*
import java.util.concurrent.LinkedBlockingQueue

private const val TAG = "AudioPlayer"

class AudioPlayer {
    companion object {
        private const val SAMPLE_RATE = 16000
        private const val CHANNELS = 1
        // 60ms frame at 16kHz = 960 samples
        private const val FRAME_SIZE = 960
    }

    private var audioTrack: AudioTrack? = null
    private var opus: Opus? = null
    private val audioQueue = LinkedBlockingQueue<ByteArray>()
    private var playbackJob: Job? = null

    @Volatile
    private var isPlaying = false

    fun start() {
        if (isPlaying) {
            Log.d(TAG, "Already playing, skip start")
            return
        }

        Log.d(TAG, "Starting AudioPlayer")

        // 初始化 AudioTrack
        initAudioTrack()

        // 初始化 Opus 解码器
        if (!initOpusDecoder()) {
            Log.e(TAG, "Failed to initialize Opus decoder")
            return
        }

        isPlaying = true
        audioTrack?.play()
        Log.d(TAG, "AudioTrack started, state: ${audioTrack?.playState}")

        // 启动播放协程
        playbackJob = CoroutineScope(Dispatchers.IO).launch {
            Log.d(TAG, "Playback coroutine started")

            while (isPlaying) {
                try {
                    val data = audioQueue.poll()
                    if (data != null && data.isNotEmpty()) {
                        decodeAndPlay(data)
                    } else {
                        delay(5)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error in playback loop", e)
                }
            }

            Log.d(TAG, "Playback coroutine ended")
        }
    }

    fun enqueue(opusData: ByteArray) {
        if (opusData.isNotEmpty()) {
            val added = audioQueue.offer(opusData)
            Log.d(TAG, "Enqueued ${opusData.size} bytes, success=$added, queueSize=${audioQueue.size}")
        }
    }

    fun stop() {
        Log.d(TAG, "Stopping AudioPlayer")
        isPlaying = false
        playbackJob?.cancel()
        playbackJob = null

        try {
            opus?.decoderRelease()
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing Opus decoder", e)
        }
        opus = null

        try {
            audioTrack?.stop()
            audioTrack?.release()
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping AudioTrack", e)
        }
        audioTrack = null

        audioQueue.clear()
        Log.d(TAG, "AudioPlayer stopped")
    }

    fun clear() {
        audioQueue.clear()
    }

    private fun initOpusDecoder(): Boolean {
        return try {
            opus = Opus()

            // 初始化解码器: 16kHz, 单声道
            val result = opus?.decoderInit(Constants.SampleRate._16000(), Constants.Channels.mono())

            // Opus 成功返回 0，失败返回负数
            if (result != null && result >= 0) {
                Log.d(TAG, "Opus decoder initialized: sampleRate=$SAMPLE_RATE, channels=mono, frameSize=$FRAME_SIZE, result=$result")
                true
            } else {
                Log.e(TAG, "Opus decoder init failed with result: $result")
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to init Opus decoder", e)
            false
        }
    }

    private fun initAudioTrack() {
        val bufferSize = AudioTrack.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        ).coerceAtLeast(4096)

        audioTrack = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setSampleRate(SAMPLE_RATE)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .build()
            )
            .setBufferSizeInBytes(bufferSize)
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()

        Log.d(TAG, "AudioTrack initialized: sampleRate=$SAMPLE_RATE, bufferSize=$bufferSize")
    }

    private fun decodeAndPlay(opusData: ByteArray) {
        val decoder = opus ?: return

        try {
            // 使用 JNI Opus 解码：输入 ByteArray，输出 ByteArray（PCM 格式）
            // 60ms @ 16kHz = 960 samples
            val pcmBytes = decoder.decode(opusData, Constants.FrameSize._960())

            if (pcmBytes != null && pcmBytes.isNotEmpty()) {
                // 写入 AudioTrack
                val written = audioTrack?.write(pcmBytes, 0, pcmBytes.size) ?: -1
                Log.d(TAG, "Decoded ${opusData.size}B Opus -> ${pcmBytes.size}B PCM, written: $written")

                if (written < 0) {
                    Log.e(TAG, "AudioTrack write error: $written")
                }
            } else {
                Log.w(TAG, "Decoder returned null or empty for ${opusData.size} bytes")
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error decoding Opus", e)
        }
    }

    fun isPlaying(): Boolean = isPlaying
}

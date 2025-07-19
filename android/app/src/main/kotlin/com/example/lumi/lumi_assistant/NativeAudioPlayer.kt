package com.example.lumi.lumi_assistant

import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.Message
import android.util.Log

enum class PlayState {
    STOPPED,
    PLAYING,
    PAUSED
}

enum class PCMType {
    PCM8,
    PCM16,
    PCM32
}

/**
 * 原生音频播放器 - 基于flutter_pcm_player实现
 * 
 * 核心特性：
 * 1. 使用AudioTrack进行PCM音频播放
 * 2. HandlerThread异步处理音频数据写入
 * 3. 支持流式播放，连续feed数据
 * 4. 完整的状态管理和错误处理
 */
class NativeAudioPlayer {
    companion object {
        private const val TAG = "NativeAudioPlayer"
        private const val CMD_WRITE = 1
        private const val CMD_WRITE32 = 2
    }

    private var audioTrack: AudioTrack? = null
    private var bufferSize = 0
    
    private var handlerThread: HandlerThread? = null
    private var audioHandler: AudioHandler? = null
    
    // 音频参数
    private var nChannels = 1
    private var sampleRate = 16000
    private var pcmType = PCMType.PCM16

    init {
        // 创建专用线程处理音频数据
        handlerThread = HandlerThread("NativeAudioPlayer").apply {
            start()
        }
        audioHandler = AudioHandler(handlerThread!!.looper)
        Log.d(TAG, "NativeAudioPlayer 初始化完成")
    }

    /**
     * 初始化音频播放器
     * @param nChannels 声道数 (1=单声道, 2=立体声)
     * @param sampleRate 采样率 (通常16000)
     * @param pcmType PCM格式 (0=PCM8, 1=PCM16, 2=PCM32)
     */
    fun init(nChannels: Int, sampleRate: Int, pcmType: Int) {
        this.nChannels = nChannels
        this.sampleRate = sampleRate
        this.pcmType = PCMType.values()[pcmType]
        
        // 确定音频格式
        val format = when (this.pcmType) {
            PCMType.PCM8 -> AudioFormat.ENCODING_PCM_8BIT
            PCMType.PCM16 -> AudioFormat.ENCODING_PCM_16BIT
            PCMType.PCM32 -> AudioFormat.ENCODING_PCM_FLOAT
        }
        
        // 确定声道配置
        val channelConfig = if (nChannels == 1) {
            AudioFormat.CHANNEL_OUT_MONO
        } else {
            AudioFormat.CHANNEL_OUT_STEREO
        }
        
        // 计算缓冲区大小
        bufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, format)
        
        // 创建AudioTrack
        audioTrack = AudioTrack(
            AudioManager.STREAM_MUSIC,
            sampleRate,
            channelConfig,
            format,
            bufferSize,
            AudioTrack.MODE_STREAM
        )
        
        Log.d(TAG, "AudioTrack初始化: channels=$nChannels, sampleRate=$sampleRate, " +
                "type=${this.pcmType}, bufferSize=$bufferSize")
    }

    /**
     * 开始播放
     */
    fun play() {
        audioTrack?.let { track ->
            if (track.state == AudioTrack.STATE_INITIALIZED) {
                track.play()
                Log.d(TAG, "AudioTrack 开始播放")
            } else {
                Log.e(TAG, "AudioTrack 未正确初始化，无法播放")
            }
        } ?: Log.e(TAG, "AudioTrack 为空，无法播放")
    }

    /**
     * 停止播放
     */
    fun stop() {
        audioTrack?.let { track ->
            if (track.playState != AudioTrack.PLAYSTATE_STOPPED) {
                track.stop()
                Log.d(TAG, "AudioTrack 停止播放")
            }
        }
    }

    /**
     * 暂停播放
     */
    fun pause() {
        audioTrack?.let { track ->
            if (track.playState == AudioTrack.PLAYSTATE_PLAYING) {
                track.pause()
                Log.d(TAG, "AudioTrack 暂停播放")
            }
        }
    }

    /**
     * 写入音频数据（异步）
     * @param data PCM音频字节数组
     */
    fun write(data: ByteArray) {
        val message = Message.obtain().apply {
            what = CMD_WRITE
            obj = data
        }
        audioHandler?.sendMessage(message)
    }

    /**
     * 写入32位浮点音频数据（异步）
     * @param data PCM音频浮点数组
     */
    fun write(data: FloatArray) {
        val message = Message.obtain().apply {
            what = CMD_WRITE32
            obj = data
        }
        audioHandler?.sendMessage(message)
    }

    /**
     * 设置音量
     * @param volume 音量值 (0.0 - 1.0)
     */
    fun setVolume(volume: Double) {
        audioTrack?.let { track ->
            val gain = volume.toFloat().coerceIn(0.0f, 1.0f)
            track.setStereoVolume(gain, gain)
            Log.d(TAG, "设置音量: $gain")
        }
    }

    /**
     * 获取播放状态
     */
    fun getPlayState(): Int {
        return audioTrack?.let { track ->
            when (track.playState) {
                AudioTrack.PLAYSTATE_PAUSED -> PlayState.PAUSED.ordinal
                AudioTrack.PLAYSTATE_PLAYING -> PlayState.PLAYING.ordinal
                else -> PlayState.STOPPED.ordinal
            }
        } ?: PlayState.STOPPED.ordinal
    }

    /**
     * 释放资源
     */
    fun release() {
        audioTrack?.let { track ->
            if (track.state == AudioTrack.STATE_INITIALIZED) {
                track.stop()
                track.release()
            }
        }
        audioTrack = null
        
        handlerThread?.quitSafely()
        handlerThread = null
        audioHandler = null
        
        Log.d(TAG, "NativeAudioPlayer 资源已释放")
    }

    /**
     * 音频处理Handler - 在专用线程中处理音频数据写入
     */
    private inner class AudioHandler(looper: Looper) : Handler(looper) {
        override fun handleMessage(msg: Message) {
            when (msg.what) {
                CMD_WRITE -> {
                    val data = msg.obj as ByteArray
                    writeAudioData(data)
                }
                CMD_WRITE32 -> {
                    val data = msg.obj as FloatArray
                    writeAudioData32(data)
                }
                else -> {
                    Log.e(TAG, "不支持的命令: ${msg.what}")
                }
            }
        }

        /**
         * 写入字节数组音频数据
         */
        private fun writeAudioData(data: ByteArray) {
            audioTrack?.let { track ->
                if (track.playState == AudioTrack.PLAYSTATE_PLAYING) {
                    var pos = 0
                    while (pos < data.size) {
                        val len = if (pos + bufferSize > data.size) {
                            data.size - pos
                        } else {
                            bufferSize
                        }
                        
                        val bytesWritten = track.write(data, pos, len)
                        if (bytesWritten < 0) {
                            Log.e(TAG, "AudioTrack写入失败: $bytesWritten")
                            break
                        }
                        pos += len
                    }
                } else {
                    Log.w(TAG, "AudioTrack未在播放状态，跳过数据写入")
                }
            }
        }

        /**
         * 写入32位浮点音频数据
         */
        private fun writeAudioData32(data: FloatArray) {
            audioTrack?.let { track ->
                if (track.playState == AudioTrack.PLAYSTATE_PLAYING) {
                    var pos = 0
                    val frameSize = bufferSize / 4 // 32位 = 4字节
                    
                    while (pos < data.size) {
                        val len = if (pos + frameSize > data.size) {
                            data.size - pos
                        } else {
                            frameSize
                        }
                        
                        val framesWritten = track.write(data, pos, len, AudioTrack.WRITE_BLOCKING)
                        if (framesWritten < 0) {
                            Log.e(TAG, "AudioTrack写入32位数据失败: $framesWritten")
                            break
                        }
                        pos += len
                    }
                } else {
                    Log.w(TAG, "AudioTrack未在播放状态，跳过32位数据写入")
                }
            }
        }
    }
}
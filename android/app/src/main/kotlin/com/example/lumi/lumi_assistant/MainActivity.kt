package com.example.lumi.lumi_assistant

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val AUDIO_CHANNEL = "lumi_assistant/native_audio"
    private lateinit var nativeAudioPlayer: NativeAudioPlayer

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 初始化原生音频播放器
        nativeAudioPlayer = NativeAudioPlayer()
        
        // 设置MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val nChannels = call.argument<Int>("nChannels") ?: 1
                    val sampleRate = call.argument<Int>("sampleRate") ?: 16000
                    val pcmType = call.argument<Int>("pcmType") ?: 1 // PCM16 = 1
                    nativeAudioPlayer.init(nChannels, sampleRate, pcmType)
                    result.success(null)
                }
                "release" -> {
                    nativeAudioPlayer.release()
                    result.success(null)
                }
                "play" -> {
                    nativeAudioPlayer.play()
                    result.success(nativeAudioPlayer.getPlayState())
                }
                "stop" -> {
                    nativeAudioPlayer.stop()
                    result.success(nativeAudioPlayer.getPlayState())
                }
                "pause" -> {
                    nativeAudioPlayer.pause()
                    result.success(nativeAudioPlayer.getPlayState())
                }
                "resume" -> {
                    nativeAudioPlayer.play()
                    result.success(nativeAudioPlayer.getPlayState())
                }
                "feed" -> {
                    val data = call.argument<ByteArray>("data")
                    if (data != null) {
                        nativeAudioPlayer.write(data)
                        result.success(nativeAudioPlayer.getPlayState())
                    } else {
                        result.error("INVALID_ARGUMENT", "Data is null", null)
                    }
                }
                "setVolume" -> {
                    val volume = call.argument<Double>("volume") ?: 1.0
                    nativeAudioPlayer.setVolume(volume)
                    result.success(nativeAudioPlayer.getPlayState())
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        if (::nativeAudioPlayer.isInitialized) {
            nativeAudioPlayer.release()
        }
        super.onDestroy()
    }
}

package com.lumi.assistant.config

/**
 * 应用配置数据模型
 * 使用 DataStore 持久化存储
 */
data class AppSettings(
    /** 应用模式 - 聊天模式或车机模式 */
    val appMode: AppMode = AppMode.CHAT,
    val vad: VadSettings = VadSettings(),
    val server: ServerSettings = ServerSettings(),
    val wakeup: WakeupSettings = WakeupSettings()
)

/**
 * VAD (Voice Activity Detection) 配置
 */
data class VadSettings(
    /** 静音阈值(毫秒) - 超过此时间无声音则认为说话结束 */
    val silenceThreshold: Long = 2000L,

    /** 音量阈值 - 低于此值认为是静音 */
    val volumeThreshold: Int = 900
)

/**
 * 服务器配置
 */
data class ServerSettings(
    /** WebSocket 服务器地址 */
    val wsUrl: String = "ws://192.168.100.100:8000/xiaozhi/v1/"
)

/**
 * 唤醒词配置
 */
data class WakeupSettings(
    /** 唤醒关键词 */
    val keyword: String = "你好天天"
)

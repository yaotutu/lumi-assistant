package com.lumi.assistant.wakeup

/**
 * 讯飞AIKit唤醒配置
 */
object WakeupConfig {
    // SDK凭证配置 (来自demo测试凭证)
    const val APP_ID = "16709949"
    const val API_KEY = "45fdb01f03085acb618c6275378ef172"
    const val API_SECRET = "YTMxZDdhZjJiODRlY2FkYjNkZDEzZmZl"

    // 唤醒能力ID
    const val ABILITY_ID = "e867a88f2"

    // 唤醒词
    const val WAKEUP_KEYWORD = "你好天天"

    // 音频参数配置
    const val SAMPLE_RATE = 16000 // 采样率 16kHz
    const val CHANNEL_COUNT = 1   // 单声道
    const val BUFFER_SIZE = 1280  // 录音缓冲区大小(字节)

    // VAD配置已迁移到 DataStore (config/AppSettings.kt)
    // 可通过设置页面动态配置：静音阈值、音量阈值

    // 唤醒参数配置
    const val CM_THRESHOLD = "0 0:800" // 置信度阈值参数

    /**
     * 获取工作目录路径(使用应用私有外部存储目录)
     */
    fun getWorkDir(context: android.content.Context): String {
        return context.getExternalFilesDir(null)?.absolutePath + "/iflytek/"
    }

    /**
     * 获取唤醒资源目录
     */
    fun getIvwResDir(context: android.content.Context): String {
        return getWorkDir(context) + "ivw/"
    }

    /**
     * 获取唤醒词文件路径
     */
    fun getKeywordFilePath(context: android.content.Context): String {
        return getIvwResDir(context) + "keyword.txt"
    }
}

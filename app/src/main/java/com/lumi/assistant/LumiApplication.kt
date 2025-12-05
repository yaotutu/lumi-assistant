package com.lumi.assistant

import android.app.Application
import android.util.Log
import com.lumi.assistant.config.AppMode
import dagger.hilt.android.HiltAndroidApp

/**
 * Lumi Assistant 应用入口
 * @HiltAndroidApp 触发 Hilt 代码生成，包括应用的基类作为依赖容器
 */
@HiltAndroidApp
class LumiApplication : Application() {
    companion object {
        private const val TAG = "LumiApplication"
        /**
         * 当前应用模式（从 DataStore 读取，在 MainActivity 中设置）
         */
        var currentMode: AppMode = AppMode.CHAT
    }

    override fun onCreate() {
        Log.d(TAG, "LumiApplication onCreate started")
        super.onCreate()
        Log.d(TAG, "LumiApplication onCreate completed")
    }
}

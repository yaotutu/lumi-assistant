package com.lumi.assistant

import android.app.Application
import android.util.Log
import dagger.hilt.android.HiltAndroidApp

/**
 * Lumi Assistant 应用入口
 * @HiltAndroidApp 触发 Hilt 代码生成，包括应用的基类作为依赖容器
 */
@HiltAndroidApp
class LumiApplication : Application() {
    companion object {
        private const val TAG = "LumiApplication"
    }

    override fun onCreate() {
        Log.d(TAG, "LumiApplication onCreate started")
        super.onCreate()
        Log.d(TAG, "LumiApplication onCreate completed")
    }
}

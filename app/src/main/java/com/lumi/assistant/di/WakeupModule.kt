package com.lumi.assistant.di

import android.content.Context
import com.lumi.assistant.wakeup.WakeupManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * 语音唤醒依赖注入模块
 */
@Module
@InstallIn(SingletonComponent::class)
object WakeupModule {

    /**
     * 提供 WakeupManager 单例
     */
    @Provides
    @Singleton
    fun provideWakeupManager(
        @ApplicationContext context: Context
    ): WakeupManager {
        return WakeupManager(context)
    }
}

package com.lumi.assistant.di

import android.content.Context
import com.lumi.assistant.audio.AudioPlayer
import com.lumi.assistant.network.WebSocketManager
import com.lumi.assistant.repository.SettingsRepository
import com.lumi.assistant.repository.WeatherRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * 应用级依赖注入模块
 * 提供整个应用生命周期内的单例对象
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    /**
     * 提供 AudioPlayer 单例
     */
    @Provides
    @Singleton
    fun provideAudioPlayer(): AudioPlayer {
        return AudioPlayer()
    }

    /**
     * 提供 WebSocketManager 单例
     */
    @Provides
    @Singleton
    fun provideWebSocketManager(): WebSocketManager {
        return WebSocketManager()
    }

    /**
     * 提供 SettingsRepository 单例
     */
    @Provides
    @Singleton
    fun provideSettingsRepository(
        @ApplicationContext context: Context
    ): SettingsRepository {
        return SettingsRepository(context)
    }

    /**
     * 提供 WeatherRepository 单例
     */
    @Provides
    @Singleton
    fun provideWeatherRepository(
        @ApplicationContext context: Context
    ): WeatherRepository {
        return WeatherRepository(context)
    }
}

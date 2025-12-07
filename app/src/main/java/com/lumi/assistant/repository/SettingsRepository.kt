package com.lumi.assistant.repository

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.lumi.assistant.config.AppMode
import com.lumi.assistant.config.AppSettings
import com.lumi.assistant.config.ServerSettings
import com.lumi.assistant.config.VadSettings
import com.lumi.assistant.config.WakeupSettings
import com.lumi.assistant.config.WeatherSettings
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

/**
 * 设置数据仓库
 * 使用 DataStore 持久化应用配置
 */
class SettingsRepository(private val context: Context) {

    companion object {
        // DataStore 实例
        private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "app_settings")

        // PreferencesKeys 定义
        private val APP_MODE = stringPreferencesKey("app_mode")
        private val VAD_SILENCE_THRESHOLD = longPreferencesKey("vad_silence_threshold")
        private val VAD_VOLUME_THRESHOLD = intPreferencesKey("vad_volume_threshold")
        private val SERVER_WS_URL = stringPreferencesKey("server_ws_url")
        private val WAKEUP_KEYWORD = stringPreferencesKey("wakeup_keyword")
        private val WEATHER_ENABLED = booleanPreferencesKey("weather_enabled")
        private val WEATHER_CREDENTIALS_ID = stringPreferencesKey("weather_credentials_id")
        private val WEATHER_API_KEY = stringPreferencesKey("weather_api_key")
        private val WEATHER_REFRESH_INTERVAL = intPreferencesKey("weather_refresh_interval")
    }

    /**
     * 配置流 - 监听配置变化
     */
    val settingsFlow: Flow<AppSettings> = context.dataStore.data.map { preferences ->
        AppSettings(
            appMode = try {
                AppMode.valueOf(preferences[APP_MODE] ?: AppMode.CHAT.name)
            } catch (e: IllegalArgumentException) {
                AppMode.CHAT
            },
            vad = VadSettings(
                silenceThreshold = preferences[VAD_SILENCE_THRESHOLD] ?: 2000L,
                volumeThreshold = preferences[VAD_VOLUME_THRESHOLD] ?: 900
            ),
            server = ServerSettings(
                wsUrl = preferences[SERVER_WS_URL] ?: "ws://192.168.100.100:8000/xiaozhi/v1/"
            ),
            wakeup = WakeupSettings(
                keyword = preferences[WAKEUP_KEYWORD] ?: "你好天天"
            ),
            weather = WeatherSettings(
                enabled = preferences[WEATHER_ENABLED] ?: true,
                credentialsId = preferences[WEATHER_CREDENTIALS_ID] ?: "T7PT8KRCB4",
                apiKey = preferences[WEATHER_API_KEY] ?: "eb6cdd44048d446e9a94b29793caaefc",
                refreshIntervalMinutes = preferences[WEATHER_REFRESH_INTERVAL] ?: 30
            )
        )
    }

    /**
     * 更新 VAD 配置
     */
    suspend fun updateVadSettings(silenceThreshold: Long, volumeThreshold: Int) {
        context.dataStore.edit { preferences ->
            preferences[VAD_SILENCE_THRESHOLD] = silenceThreshold
            preferences[VAD_VOLUME_THRESHOLD] = volumeThreshold
        }
    }

    /**
     * 更新服务器地址
     */
    suspend fun updateServerUrl(url: String) {
        context.dataStore.edit { preferences ->
            preferences[SERVER_WS_URL] = url
        }
    }

    /**
     * 更新唤醒词
     */
    suspend fun updateWakeupKeyword(keyword: String) {
        context.dataStore.edit { preferences ->
            preferences[WAKEUP_KEYWORD] = keyword
        }
    }

    /**
     * 更新应用模式
     */
    suspend fun updateAppMode(mode: AppMode) {
        context.dataStore.edit { preferences ->
            preferences[APP_MODE] = mode.name
        }
    }

    /**
     * 更新天气启用状态
     */
    suspend fun updateWeatherEnabled(enabled: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[WEATHER_ENABLED] = enabled
        }
    }

    /**
     * 更新天气凭据ID
     */
    suspend fun updateWeatherCredentialsId(credentialsId: String) {
        context.dataStore.edit { preferences ->
            preferences[WEATHER_CREDENTIALS_ID] = credentialsId
        }
    }

    /**
     * 更新天气 API Key
     */
    suspend fun updateWeatherApiKey(apiKey: String) {
        context.dataStore.edit { preferences ->
            preferences[WEATHER_API_KEY] = apiKey
        }
    }

    /**
     * 更新天气刷新间隔
     */
    suspend fun updateWeatherRefreshInterval(intervalMinutes: Int) {
        context.dataStore.edit { preferences ->
            preferences[WEATHER_REFRESH_INTERVAL] = intervalMinutes
        }
    }
}

package com.lumi.assistant.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lumi.assistant.model.WeatherState
import com.lumi.assistant.repository.SettingsRepository
import com.lumi.assistant.repository.WeatherRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * 天气 ViewModel
 * 管理天气数据的获取、缓存和自动刷新
 */
@HiltViewModel
class WeatherViewModel @Inject constructor(
    private val weatherRepository: WeatherRepository,
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    companion object {
        private const val TAG = "WeatherViewModel"
    }

    // 天气状态
    private val _weatherState = MutableStateFlow<WeatherState>(WeatherState.Idle)
    val weatherState: StateFlow<WeatherState> = _weatherState.asStateFlow()

    // 是否正在自动刷新
    private var isAutoRefreshing = false

    init {
        // 监听设置变化
        viewModelScope.launch {
            settingsRepository.settingsFlow.collect { settings ->
                Log.d(TAG, "Settings changed - Weather enabled: ${settings.weather.enabled}, Credentials ID: ${if (settings.weather.credentialsId.isNotBlank()) "present" else "blank"}, API Key: ${if (settings.weather.apiKey.isNotBlank()) "present" else "blank"}")

                if (settings.weather.enabled) {
                    // 天气功能已启用，开始自动刷新
                    if (!isAutoRefreshing) {
                        Log.d(TAG, "Starting auto refresh with interval: ${settings.weather.refreshIntervalMinutes} minutes")
                        startAutoRefresh(settings.weather.credentialsId, settings.weather.apiKey, settings.weather.refreshIntervalMinutes)
                    } else {
                        Log.d(TAG, "Auto refresh already running")
                    }
                } else {
                    // 天气功能已禁用，停止刷新
                    Log.d(TAG, "Weather disabled, stopping auto refresh")
                    stopAutoRefresh()
                }
            }
        }
    }

    /**
     * 手动刷新天气
     */
    fun refreshWeather(credentialsId: String, apiKey: String) {
        Log.d(TAG, "refreshWeather called with credentialsId: $credentialsId, API Key: ${apiKey.take(8)}...")
        viewModelScope.launch {
            try {
                Log.d(TAG, "Starting weather refresh...")
                _weatherState.value = WeatherState.Loading

                Log.d(TAG, "Calling weather repository getCurrentWeather...")
                val weather = weatherRepository.getCurrentWeather(credentialsId, apiKey, forceRefresh = true)
                _weatherState.value = WeatherState.Success(weather)
                Log.d(TAG, "Weather refreshed successfully - ${weather.temperature} ${weather.description}")
            } catch (e: SecurityException) {
                Log.e(TAG, "Permission denied during weather refresh", e)
                val cachedWeather = weatherRepository.getCachedWeather()
                _weatherState.value = WeatherState.Error(
                    message = "需要位置权限才能获取天气信息",
                    cachedWeather = cachedWeather
                )
            } catch (e: IllegalArgumentException) {
                Log.e(TAG, "Invalid credentials/API key during weather refresh", e)
                _weatherState.value = WeatherState.Error(message = e.message ?: "凭据ID或API Key 无效")
            } catch (e: Exception) {
                Log.e(TAG, "Error during weather refresh", e)
                val cachedWeather = weatherRepository.getCachedWeather()
                val errorMessage = when {
                    e.message?.contains("API error") == true -> e.message!!
                    e.message?.contains("Network") == true -> "网络连接失败，请检查网络"
                    e.message?.contains("位置") == true -> e.message!!
                    else -> "获取天气失败: ${e.message}"
                }
                _weatherState.value = WeatherState.Error(
                    message = errorMessage,
                    cachedWeather = cachedWeather
                )
            }
        }
    }

    /**
     * 启动自动刷新
     */
    private fun startAutoRefresh(credentialsId: String, apiKey: String, intervalMinutes: Int) {
        if (isAutoRefreshing) return

        isAutoRefreshing = true
        Log.d(TAG, "Starting auto refresh with interval: $intervalMinutes minutes")

        viewModelScope.launch {
            while (isAutoRefreshing) {
                // 首次立即刷新
                refreshWeather(credentialsId, apiKey)

                // 等待刷新间隔
                delay(intervalMinutes * 60 * 1000L)
            }
        }
    }

    /**
     * 停止自动刷新
     */
    private fun stopAutoRefresh() {
        isAutoRefreshing = false
        _weatherState.value = WeatherState.Idle
        Log.d(TAG, "Auto refresh stopped")
    }

    /**
     * 检查是否有位置权限
     */
    fun hasLocationPermission(): Boolean {
        return weatherRepository.hasLocationPermission()
    }

    /**
     * 清除缓存
     */
    fun clearCache() {
        weatherRepository.clearCache()
        _weatherState.value = WeatherState.Idle
        Log.d(TAG, "Cache cleared")
    }
}

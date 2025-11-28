package com.lumi.assistant.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lumi.assistant.config.AppMode
import com.lumi.assistant.config.AppSettings
import com.lumi.assistant.repository.SettingsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * 设置页面 ViewModel
 * 使用 Hilt 进行依赖注入
 */
@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val repository: SettingsRepository
) : ViewModel() {

    /**
     * 配置状态流
     */
    val settings: StateFlow<AppSettings> = repository.settingsFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = AppSettings()
        )

    /**
     * 更新 VAD 静音阈值
     */
    fun updateVadSilenceThreshold(value: Long) {
        viewModelScope.launch {
            repository.updateVadSettings(
                silenceThreshold = value,
                volumeThreshold = settings.value.vad.volumeThreshold
            )
        }
    }

    /**
     * 更新 VAD 音量阈值
     */
    fun updateVadVolumeThreshold(value: Int) {
        viewModelScope.launch {
            repository.updateVadSettings(
                silenceThreshold = settings.value.vad.silenceThreshold,
                volumeThreshold = value
            )
        }
    }

    /**
     * 更新服务器地址
     */
    fun updateServerUrl(url: String) {
        viewModelScope.launch {
            repository.updateServerUrl(url)
        }
    }

    /**
     * 更新唤醒词
     */
    fun updateWakeupKeyword(keyword: String) {
        viewModelScope.launch {
            repository.updateWakeupKeyword(keyword)
        }
    }

    /**
     * 更新应用模式
     */
    fun updateAppMode(mode: AppMode) {
        viewModelScope.launch {
            repository.updateAppMode(mode)
        }
    }
}

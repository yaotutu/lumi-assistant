package com.lumi.assistant.standby.pages

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import com.lumi.assistant.standby.*
import com.lumi.assistant.ui.content.IdleModeContent
import com.lumi.assistant.viewmodel.WeatherViewModel

/**
 * 时钟待机页
 * 显示：大时间 + 日期 + 天气
 * 配置：状态栏 + 语音助手 + 语音栏（默认配置）
 */
class ClockPage : StandbyPage {

    override val pageId = "clock"
    override val pageName = "时钟"

    // 配置：使用默认配置（状态栏 + 语音助手 + 语音栏）
    override val slotConfiguration = SlotConfiguration.Default

    @Composable
    override fun Content(modifier: Modifier) {
        // 注入天气 ViewModel
        val weatherViewModel: WeatherViewModel = hiltViewModel()
        val weatherState by weatherViewModel.weatherState.collectAsState()

        // 显示时间/日期/天气（复用原 StandbyScreen 的 IdleModeContent）
        IdleModeContent(
            weatherState = weatherState,
            modifier = modifier
        )
    }
}

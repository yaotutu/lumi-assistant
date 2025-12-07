package com.lumi.assistant.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.lumi.assistant.ui.StandbyScreen
import com.lumi.assistant.ui.SettingsScreen
import com.lumi.assistant.viewmodel.SettingsViewModel
import com.lumi.assistant.viewmodel.VoiceAssistantViewModel

/**
 * 应用导航图
 */
@Composable
fun LumiNavGraph(
    navController: NavHostController,
    viewModel: VoiceAssistantViewModel,
    modifier: Modifier = Modifier
) {
    val state by viewModel.state.collectAsState()
    val settingsViewModel: SettingsViewModel = hiltViewModel()
    val settings by settingsViewModel.settings.collectAsState()

    NavHost(
        navController = navController,
        startDestination = Routes.STANDBY,
        modifier = modifier
    ) {
        // 主页面（待机模式）
        composable(Routes.STANDBY) {
            StandbyScreen(
                emotion = state.emotion,
                isConnected = state.isConnected,
                wakeupKeyword = settings.wakeup.keyword,
                assistantState = state.currentState,
                isRecording = state.isRecording,
                waveformBars = state.waveformBars,
                messages = state.messages,
                isWakeupListening = state.isWakeupListening,
                isWakeupTriggered = state.isWakeupTriggered,
                wakeupStatus = state.wakeupStatus,
                isSpeaking = state.isSpeaking,
                recordingSeconds = state.recordingSeconds,
                onNavigateToSettings = {
                    navController.navigate(Routes.SETTINGS)
                }
            )
        }

        // 设置页面
        composable(Routes.SETTINGS) {
            SettingsScreen(
                settings = settings,
                onNavigateBack = {
                    navController.popBackStack()
                },
                onUpdateVadSilenceThreshold = settingsViewModel::updateVadSilenceThreshold,
                onUpdateVadVolumeThreshold = settingsViewModel::updateVadVolumeThreshold,
                onUpdateServerUrl = settingsViewModel::updateServerUrl,
                onUpdateWakeupKeyword = settingsViewModel::updateWakeupKeyword,
                onUpdateWeatherEnabled = settingsViewModel::updateWeatherEnabled,
                onUpdateWeatherApiKey = settingsViewModel::updateWeatherApiKey,
                onUpdateWeatherCredentialsId = settingsViewModel::updateWeatherCredentialsId
            )
        }
    }
}

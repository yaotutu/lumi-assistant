package com.lumi.assistant.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.lumi.assistant.config.AppMode
import com.lumi.assistant.ui.StandbyScreen
import com.lumi.assistant.ui.VoiceAssistantScreen
import com.lumi.assistant.ui.SettingsScreen
import com.lumi.assistant.viewmodel.SettingsViewModel
import com.lumi.assistant.viewmodel.VoiceAssistantViewModel

/**
 * 应用导航图
 * 支持聊天模式和待机模式切换
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

    // 根据 appMode 决定起始路由
    val startRoute = when (settings.appMode) {
        AppMode.CHAT -> Routes.ASSISTANT
        AppMode.CAR -> Routes.STANDBY
    }

    // 监听 appMode 变化，自动切换页面
    LaunchedEffect(settings.appMode) {
        val currentRoute = navController.currentBackStackEntry?.destination?.route
        val targetRoute = when (settings.appMode) {
            AppMode.CHAT -> Routes.ASSISTANT
            AppMode.CAR -> Routes.STANDBY
        }

        // 如果当前不在设置页面，且目标路由与当前路由不同，则导航到目标路由
        if (currentRoute != Routes.SETTINGS && currentRoute != targetRoute) {
            navController.navigate(targetRoute) {
                popUpTo(navController.graph.startDestinationId) {
                    inclusive = true
                }
                launchSingleTop = true
            }
        }
    }

    NavHost(
        navController = navController,
        startDestination = startRoute,
        modifier = modifier
    ) {
        // 聊天模式页面
        composable(Routes.ASSISTANT) {
            VoiceAssistantScreen(
                state = state,
                onConnect = viewModel::connect,
                onDisconnect = viewModel::disconnect,
                onWsUrlChange = viewModel::updateWsUrl,
                onStartRecording = viewModel::startRecording,
                onStopRecording = viewModel::stopRecording,
                onSendText = viewModel::sendTextMessage,
                onNavigateToSettings = {
                    navController.navigate(Routes.SETTINGS)
                }
            )
        }

        // 待机模式页面
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
                onUpdateAppMode = settingsViewModel::updateAppMode,
                onUpdateWeatherEnabled = settingsViewModel::updateWeatherEnabled,
                onUpdateWeatherApiKey = settingsViewModel::updateWeatherApiKey,
                onUpdateWeatherCredentialsId = settingsViewModel::updateWeatherCredentialsId
            )
        }
    }
}

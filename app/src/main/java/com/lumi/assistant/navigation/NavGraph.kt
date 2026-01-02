package com.lumi.assistant.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.lumi.assistant.standby.StandbyContainer
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
        // 主页面（待机模式）- 使用新的组件插槽系统
        composable(Routes.STANDBY) {
            StandbyContainer(
                state = state,
                wakeupKeyword = settings.wakeup.keyword,
                onNavigateToSettings = {
                    navController.navigate(Routes.SETTINGS)
                }
            )
        }

        // 设置页面
        composable(Routes.SETTINGS) {
            SettingsScreen(
                settings = settings,
                healthCheck = state.healthCheck,
                onNavigateBack = {
                    navController.popBackStack()
                },
                onUpdateVadSilenceThreshold = settingsViewModel::updateVadSilenceThreshold,
                onUpdateVadVolumeThreshold = settingsViewModel::updateVadVolumeThreshold,
                onUpdateServerUrl = settingsViewModel::updateServerUrl,
                onUpdateWakeupKeyword = settingsViewModel::updateWakeupKeyword,
                onUpdateWeatherEnabled = settingsViewModel::updateWeatherEnabled,
                onUpdateWeatherApiKey = settingsViewModel::updateWeatherApiKey,
                onUpdateWeatherCredentialsId = settingsViewModel::updateWeatherCredentialsId,
                onPerformHealthCheck = viewModel::performHealthCheck
            )
        }
    }
}

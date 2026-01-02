package com.lumi.assistant.standby

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.lumi.assistant.standby.pages.ClockPage
import com.lumi.assistant.viewmodel.VoiceAssistantState
import com.lumi.assistant.viewmodel.AssistantState

/**
 * 待机桌面容器
 * 管理：组件插槽层 + 待机页面导航
 */
@Composable
fun StandbyContainer(
    state: VoiceAssistantState,
    wakeupKeyword: String,
    onNavigateToSettings: () -> Unit,
    modifier: Modifier = Modifier,
    navController: NavHostController = rememberNavController()
) {
    // 当前页面的插槽配置
    var currentSlotConfig by remember { mutableStateOf(SlotConfiguration.Default) }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        // 内容层：待机页面导航
        // 语音助手激活时（RECORDING/PLAYING）背景模糊，避免与对话框内容重叠
        NavHost(
            navController = navController,
            startDestination = "clock",  // 默认显示时钟页
            modifier = Modifier
                .fillMaxSize()
                .blur(
                    radius = if (state.currentState != AssistantState.IDLE) 24.dp else 0.dp
                )
        ) {
            // 时钟页（第一版实现）
            composable("clock") {
                val page = ClockPage()

                // 更新插槽配置
                LaunchedEffect(Unit) {
                    currentSlotConfig = page.slotConfiguration
                }

                // 渲染页面内容
                page.Content()
            }

            // 未来可添加更多待机页面...
            // composable("calendar") { CalendarPage().Content() }
            // composable("photo_frame") { PhotoFramePage().Content() }
        }

        // 插槽层：浮动组件（覆盖在内容之上）
        ComponentSlotLayer(
            slotConfiguration = currentSlotConfig,
            assistantState = state,
            wakeupKeyword = wakeupKeyword,
            onNavigateToSettings = onNavigateToSettings
        )
    }
}

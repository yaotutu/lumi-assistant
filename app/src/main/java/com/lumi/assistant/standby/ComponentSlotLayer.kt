package com.lumi.assistant.standby

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.lumi.assistant.standby.components.StatusBarComponent
import com.lumi.assistant.standby.components.VoiceBarComponent
import com.lumi.assistant.standby.components.VoiceAssistantComponent
import com.lumi.assistant.viewmodel.AssistantState
import com.lumi.assistant.viewmodel.VoiceAssistantState

/**
 * 组件插槽层
 * 根据 SlotConfiguration 渲染浮动组件
 */
@Composable
fun ComponentSlotLayer(
    slotConfiguration: SlotConfiguration,
    assistantState: VoiceAssistantState,
    wakeupKeyword: String,
    onNavigateToSettings: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(modifier = modifier.fillMaxSize()) {
        // 模糊遮罩背景（语音唤醒时显示，盖住底层页面）
        AnimatedVisibility(
            visible = assistantState.currentState != AssistantState.IDLE,
            enter = fadeIn(),
            exit = fadeOut()
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.85f))
            )
        }
        // 顶部插槽
        RenderSlot(
            slotConfig = slotConfiguration.topSlot,
            alignment = Alignment.TopCenter,
            assistantState = assistantState,
            wakeupKeyword = wakeupKeyword,
            onNavigateToSettings = onNavigateToSettings,
            modifier = Modifier.windowInsetsPadding(
                WindowInsets.systemBars.only(WindowInsetsSides.Top)
            )
        )

        // 底部插槽
        RenderSlot(
            slotConfig = slotConfiguration.bottomSlot,
            alignment = Alignment.BottomCenter,
            assistantState = assistantState,
            wakeupKeyword = wakeupKeyword,
            onNavigateToSettings = onNavigateToSettings,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .windowInsetsPadding(
                    WindowInsets.systemBars.only(WindowInsetsSides.Bottom)
                )
                .padding(bottom = 32.dp)
        )

        // 中心插槽（语音助手）
        RenderSlot(
            slotConfig = slotConfiguration.centerSlot,
            alignment = Alignment.Center,
            assistantState = assistantState,
            wakeupKeyword = wakeupKeyword,
            onNavigateToSettings = onNavigateToSettings,
            modifier = Modifier
        )

        // 左侧插槽（未来）
        // RenderSlot(slotConfiguration.startSlot, Alignment.CenterStart, ...)

        // 右侧插槽（未来）
        // RenderSlot(slotConfiguration.endSlot, Alignment.CenterEnd, ...)
    }
}

/**
 * 渲染单个插槽
 */
@Composable
private fun BoxScope.RenderSlot(
    slotConfig: SlotConfig,
    alignment: Alignment,
    assistantState: VoiceAssistantState,
    wakeupKeyword: String,
    onNavigateToSettings: () -> Unit,
    modifier: Modifier = Modifier
) {
    when (slotConfig) {
        is SlotConfig.Component -> {
            AnimatedVisibility(
                visible = true,  // 组件配置存在即显示
                modifier = Modifier.align(alignment),
                enter = fadeIn() + slideInVertically { if (alignment == Alignment.TopCenter) -it else it },
                exit = fadeOut() + slideOutVertically { if (alignment == Alignment.TopCenter) -it else it }
            ) {
                // 根据组件类型渲染对应组件
                when (slotConfig.componentType) {
                    ComponentType.STATUS_BAR -> {
                        StatusBarComponent(
                            internetConnected = assistantState.healthCheck.internetConnected,
                            serverConnected = assistantState.healthCheck.serverReachable,
                            onNavigateToSettings = onNavigateToSettings,
                            modifier = modifier.alpha(slotConfig.alpha)
                        )
                    }
                    ComponentType.VOICE_BAR -> {
                        VoiceBarComponent(
                            assistantState = assistantState.currentState,
                            isRecording = assistantState.isRecording,
                            waveformBars = assistantState.waveformBars,
                            messages = assistantState.messages,
                            wakeupKeyword = wakeupKeyword,
                            modifier = modifier.alpha(slotConfig.alpha)
                        )
                    }
                    ComponentType.VOICE_ASSISTANT -> {
                        VoiceAssistantComponent(
                            emotion = assistantState.emotion,
                            assistantState = assistantState.currentState,
                            isConnected = assistantState.isConnected,
                            isRecording = assistantState.isRecording,
                            isWakeupListening = assistantState.isWakeupListening,
                            isWakeupTriggered = assistantState.isWakeupTriggered,
                            wakeupStatus = assistantState.wakeupStatus,
                            isSpeaking = assistantState.isSpeaking,
                            recordingSeconds = assistantState.recordingSeconds,
                            modifier = modifier.alpha(slotConfig.alpha)
                        )
                    }
                    ComponentType.NOTIFICATION -> {
                        // 未来实现
                    }
                    ComponentType.QUICK_ACTIONS -> {
                        // 未来实现
                    }
                }
            }
        }
        SlotConfig.Empty -> {
            // 空插槽，不渲染任何内容
        }
    }
}

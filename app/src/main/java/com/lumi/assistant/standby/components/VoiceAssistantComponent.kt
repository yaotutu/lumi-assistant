package com.lumi.assistant.standby.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import android.content.res.Configuration
import com.lumi.assistant.viewmodel.AssistantState
import com.lumi.assistant.ui.utils.getDetailedStatus

/**
 * 语音助手交互组件
 * 显示：表情 + 状态信息（根据 assistantState 动态变化）
 *
 * 设计要点：
 * - IDLE 状态：可以不显示，或显示小图标
 * - RECORDING/PLAYING 状态：显示表情 + 详细状态
 * - 支持浮动在不同位置（center, top, bottom 等）
 */
@Composable
fun VoiceAssistantComponent(
    emotion: String,
    assistantState: AssistantState,
    isConnected: Boolean,
    isRecording: Boolean,
    isWakeupListening: Boolean,
    isWakeupTriggered: Boolean,
    wakeupStatus: String,
    isSpeaking: Boolean,
    recordingSeconds: Float,
    modifier: Modifier = Modifier
) {
    // 呼吸动画
    val infiniteTransition = rememberInfiniteTransition(label = "breathing")
    val scale by infiniteTransition.animateFloat(
        initialValue = 1.0f,
        targetValue = 1.1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 2000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "breathing_scale"
    )

    val configuration = LocalConfiguration.current
    val isLandscape = configuration.orientation == Configuration.ORIENTATION_LANDSCAPE

    // 横屏时缩小尺寸
    val emojiSize = if (isLandscape) 100.sp else 140.sp
    val titleSize = if (isLandscape) 24.sp else 32.sp
    val statusSize = if (isLandscape) 11.sp else 13.sp
    val spacing = if (isLandscape) 16.dp else 24.dp

    // 根据状态决定是否显示
    if (assistantState == AssistantState.IDLE) {
        // 待机状态：不显示或显示小图标（可配置）
        // 这里可以选择返回空，或者显示一个小的浮动图标
        return
    }

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(spacing)
    ) {
        // 表情图标（带呼吸动画）
        Text(
            text = emotion,
            fontSize = emojiSize,
            modifier = Modifier.scale(scale)
        )

        // 欢迎标题
        Text(
            text = "嘿,我是天天",
            fontSize = titleSize,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )

        // 详细状态信息
        Text(
            text = getDetailedStatus(
                isConnected = isConnected,
                assistantState = assistantState,
                isRecording = isRecording,
                isWakeupListening = isWakeupListening,
                isWakeupTriggered = isWakeupTriggered,
                wakeupStatus = wakeupStatus,
                isSpeaking = isSpeaking,
                recordingSeconds = recordingSeconds
            ),
            fontSize = statusSize,
            color = Color.White.copy(alpha = 0.7f),
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 32.dp)
        )
    }
}

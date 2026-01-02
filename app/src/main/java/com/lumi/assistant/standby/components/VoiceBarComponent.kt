package com.lumi.assistant.standby.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.lumi.assistant.model.Message
import com.lumi.assistant.ui.components.WaveformVisualization
import com.lumi.assistant.viewmodel.AssistantState

/**
 * 语音栏组件
 * 显示：唤醒提示 / 波纹动画 / 对话内容
 */
@Composable
fun VoiceBarComponent(
    assistantState: AssistantState,
    isRecording: Boolean,
    waveformBars: List<Float>,
    messages: List<Message>,
    wakeupKeyword: String,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier.height(80.dp),
        shape = RoundedCornerShape(16.dp),
        color = Color.White.copy(alpha = 0.1f)
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            when {
                isRecording -> {
                    WaveformVisualization(
                        waveformBars = waveformBars,
                        modifier = Modifier.fillMaxSize()
                    )
                }
                messages.isNotEmpty() -> {
                    val lastMessage = messages.lastOrNull()
                    lastMessage?.let { message ->
                        Text(
                            text = message.content,
                            fontSize = 16.sp,
                            color = Color.White,
                            textAlign = TextAlign.Center,
                            maxLines = 2,
                            modifier = Modifier.padding(horizontal = 16.dp)
                        )
                    }
                }
                else -> {
                    Text(
                        text = "请说'$wakeupKeyword'唤醒我",
                        fontSize = 14.sp,
                        color = Color.White.copy(alpha = 0.7f)
                    )
                }
            }
        }
    }
}

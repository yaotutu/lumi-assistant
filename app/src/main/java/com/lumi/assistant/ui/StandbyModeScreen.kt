package com.lumi.assistant.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.lumi.assistant.model.Message
import com.lumi.assistant.ui.components.FullScreenAudioWaveform
import com.lumi.assistant.viewmodel.VoiceAssistantState

@Composable
fun StandbyModeScreen(
    state: VoiceAssistantState,
    onConnect: () -> Unit,
    onDisconnect: () -> Unit,
    onWsUrlChange: (String) -> Unit,
    onStartRecording: () -> Unit,
    onStopRecording: () -> Unit,
    onSendText: (String) -> Unit,
    onNavigateToSettings: () -> Unit,
    modifier: Modifier = Modifier
) {
    var textInput by remember { mutableStateOf("") }
    var showSettings by remember { mutableStateOf(false) }
    val listState = rememberLazyListState()

    // 自动滚动到底部
    LaunchedEffect(state.messages.size) {
        if (state.messages.isNotEmpty()) {
            listState.animateScrollToItem(state.messages.size - 1)
        }
    }

    Box(
        modifier = modifier.fillMaxSize()
    ) {
        // 主界面内容
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
        ) {
            // 顶部状态卡片
            TopStatusCard(
                state = state,
                onExpandSettings = { showSettings = !showSettings },
                onNavigateToSettings = onNavigateToSettings
            )

            // 设置区域（可折叠）
            AnimatedVisibility(visible = showSettings) {
                SettingsSection(
                    wsUrl = state.wsUrl,
                    isConnected = state.isConnected,
                    onWsUrlChange = onWsUrlChange,
                    onConnect = onConnect,
                    onDisconnect = onDisconnect
                )
            }

            // 消息列表
            LazyColumn(
                state = listState,
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                contentPadding = PaddingValues(vertical = 16.dp)
            ) {
                if (state.messages.isEmpty()) {
                    item {
                        EmptyMessagePlaceholder()
                    }
                } else {
                    items(state.messages) { message ->
                        MessageItem(message)
                    }
                }
            }

            // 底部输入区域
            BottomInputArea(
                textInput = textInput,
                onTextChange = { textInput = it },
                isConnected = state.isConnected,
                isRecording = state.isRecording,
                recordingSeconds = state.recordingSeconds,
                onSendText = {
                    if (textInput.isNotEmpty()) {
                        onSendText(textInput)
                        textInput = ""
                    }
                },
                onStartRecording = onStartRecording,
                onStopRecording = onStopRecording
            )
        }

        // 全屏波形覆盖层（仅在录音时显示）
        AnimatedVisibility(
            visible = state.isRecording,
            modifier = Modifier.fillMaxSize()
        ) {
            FullScreenAudioWaveform(
                waveformBars = state.waveformBars
            )
        }
    }
}

@Composable
private fun TopStatusCard(
    state: VoiceAssistantState,
    onExpandSettings: () -> Unit,
    onNavigateToSettings: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = Color.Transparent,
        shadowElevation = 4.dp
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    brush = Brush.verticalGradient(
                        colors = when {
                            state.isWakeupTriggered -> listOf(
                                MaterialTheme.colorScheme.tertiaryContainer,
                                MaterialTheme.colorScheme.tertiaryContainer.copy(alpha = 0.7f)
                            )
                            state.isWakeupListening -> listOf(
                                MaterialTheme.colorScheme.primaryContainer,
                                MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.7f)
                            )
                            state.isConnected -> listOf(
                                MaterialTheme.colorScheme.surfaceVariant,
                                MaterialTheme.colorScheme.surface
                            )
                            else -> listOf(
                                MaterialTheme.colorScheme.errorContainer.copy(alpha = 0.3f),
                                MaterialTheme.colorScheme.surface
                            )
                        }
                    )
                )
                .clickable { onExpandSettings() }
                .padding(20.dp)
        ) {
            // 设置按钮（右上角）
            IconButton(
                onClick = onNavigateToSettings,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .size(40.dp)
            ) {
                Icon(
                    imageVector = Icons.Filled.Settings,
                    contentDescription = "设置",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // 左右布局：表情 | 状态信息
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // 左侧：表情图标
                Text(
                    text = state.emotion,
                    fontSize = 56.sp
                )

                // 右侧：状态信息
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    // 主要状态文字
                    Text(
                        text = when {
                            state.isWakeupTriggered -> "正在录音..."
                            state.isWakeupListening -> "等待唤醒"
                            state.isConnected -> "已就绪"
                            else -> "未连接"
                        },
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )

                    // 详细状态信息
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        // 连接状态指示灯
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .background(
                                    color = if (state.isConnected) Color(0xFF4CAF50) else Color(0xFFF44336),
                                    shape = CircleShape
                                )
                        )
                        Text(
                            text = when {
                                state.isSpeaking -> "AI回复中"
                                state.isRecording -> String.format("%.1fs", state.recordingSeconds)
                                state.isWakeupListening -> state.wakeupStatus
                                else -> state.wakeupStatus
                            },
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                // 展开/收起设置提示
                Icon(
                    imageVector = Icons.Filled.KeyboardArrowDown,
                    contentDescription = "展开设置",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

@Composable
private fun SettingsSection(
    wsUrl: String,
    isConnected: Boolean,
    onWsUrlChange: (String) -> Unit,
    onConnect: () -> Unit,
    onDisconnect: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = MaterialTheme.colorScheme.surfaceVariant,
        tonalElevation = 2.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Text(
                text = "服务器设置",
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 12.dp)
            )

            OutlinedTextField(
                value = wsUrl,
                onValueChange = onWsUrlChange,
                label = { Text("WebSocket 地址") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                enabled = !isConnected,
                shape = RoundedCornerShape(12.dp)
            )

            Spacer(modifier = Modifier.height(12.dp))

            Button(
                onClick = { if (isConnected) onDisconnect() else onConnect() },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (isConnected)
                        MaterialTheme.colorScheme.error
                    else
                        MaterialTheme.colorScheme.primary
                ),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text(
                    text = if (isConnected) "断开连接" else "连接服务器",
                    fontSize = 16.sp
                )
            }
        }
    }
}

@Composable
private fun EmptyMessagePlaceholder() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 60.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "💬",
            fontSize = 48.sp,
            modifier = Modifier.padding(bottom = 16.dp)
        )
        Text(
            text = "还没有对话",
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "说'你好天天'开始对话",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
        )
    }
}

@Composable
private fun MessageItem(message: Message) {
    val isUser = message.isFromUser

    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (isUser) Arrangement.End else Arrangement.Start
    ) {
        Surface(
            shape = RoundedCornerShape(
                topStart = 20.dp,
                topEnd = 20.dp,
                bottomStart = if (isUser) 20.dp else 4.dp,
                bottomEnd = if (isUser) 4.dp else 20.dp
            ),
            color = if (isUser)
                MaterialTheme.colorScheme.primary
            else
                MaterialTheme.colorScheme.secondaryContainer,
            shadowElevation = 2.dp,
            modifier = Modifier.widthIn(max = 280.dp)
        ) {
            Text(
                text = message.content,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                color = if (isUser)
                    MaterialTheme.colorScheme.onPrimary
                else
                    MaterialTheme.colorScheme.onSecondaryContainer,
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Start
            )
        }
    }
}

@Composable
private fun BottomInputArea(
    textInput: String,
    onTextChange: (String) -> Unit,
    isConnected: Boolean,
    isRecording: Boolean,
    recordingSeconds: Float,
    onSendText: () -> Unit,
    onStartRecording: () -> Unit,
    onStopRecording: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shadowElevation = 8.dp,
        tonalElevation = 3.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // 文本输入框
            OutlinedTextField(
                value = textInput,
                onValueChange = onTextChange,
                modifier = Modifier.weight(1f),
                placeholder = { Text("输入消息...") },
                enabled = isConnected && !isRecording,
                shape = RoundedCornerShape(24.dp),
                maxLines = 4
            )

            // 语音/发送按钮
            if (textInput.isEmpty()) {
                // 语音按钮
                FilledIconButton(
                    onClick = {
                        if (isRecording) onStopRecording() else onStartRecording()
                    },
                    modifier = Modifier
                        .size(56.dp),
                    enabled = isConnected,
                    colors = IconButtonDefaults.filledIconButtonColors(
                        containerColor = if (isRecording)
                            MaterialTheme.colorScheme.error
                        else
                            MaterialTheme.colorScheme.primary
                    ),
                    shape = CircleShape
                ) {
                    if (isRecording) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(
                                imageVector = Icons.Filled.Stop,
                                contentDescription = "停止录音",
                                tint = MaterialTheme.colorScheme.onError
                            )
                        }
                    } else {
                        Icon(
                            imageVector = Icons.Filled.Mic,
                            contentDescription = "开始录音",
                            tint = MaterialTheme.colorScheme.onPrimary
                        )
                    }
                }
            } else {
                // 发送按钮
                FilledIconButton(
                    onClick = onSendText,
                    modifier = Modifier.size(56.dp),
                    enabled = isConnected && textInput.isNotEmpty(),
                    colors = IconButtonDefaults.filledIconButtonColors(
                        containerColor = MaterialTheme.colorScheme.primary
                    ),
                    shape = CircleShape
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.Send,
                        contentDescription = "发送",
                        tint = MaterialTheme.colorScheme.onPrimary
                    )
                }
            }
        }
    }

    // 录音时显示时长
    if (isRecording) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.errorContainer)
                .padding(vertical = 8.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "录音中 ${String.format("%.1f", recordingSeconds)}s",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onErrorContainer,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

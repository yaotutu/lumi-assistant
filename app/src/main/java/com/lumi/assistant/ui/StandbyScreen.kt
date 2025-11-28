package com.lumi.assistant.ui

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.Cloud
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import android.content.res.Configuration
import com.lumi.assistant.model.Message
import com.lumi.assistant.viewmodel.AssistantState
import java.text.SimpleDateFormat
import java.util.*
import kotlinx.coroutines.delay

/**
 * 待机模式全屏界面
 *
 * 设计要点：
 * - 纯黑背景（省电，适合OLED）
 * - 顶部：时间 + 网络状态 + 设置按钮
 * - 中央：表情图标（带呼吸动画）+ 欢迎文案
 * - 底部：对话横条（显示提示文字/波纹动画/对话内容）
 */
@Composable
fun StandbyScreen(
    emotion: String,
    isConnected: Boolean,
    wakeupKeyword: String,
    assistantState: AssistantState,
    isRecording: Boolean,
    waveformBars: List<Float>,
    messages: List<Message>,
    isWakeupListening: Boolean,
    isWakeupTriggered: Boolean,
    wakeupStatus: String,
    isSpeaking: Boolean,
    recordingSeconds: Float,
    onNavigateToSettings: () -> Unit,
    modifier: Modifier = Modifier
) {
    // 当前时间（每秒更新）
    var currentTime by remember { mutableStateOf(getCurrentTime()) }

    LaunchedEffect(Unit) {
        while (true) {
            currentTime = getCurrentTime()
            delay(1000) // 每秒更新一次
        }
    }

    // 呼吸动画：1.0x → 1.1x → 1.0x，循环播放
    val infiniteTransition = rememberInfiniteTransition(label = "breathing")
    val scale by infiniteTransition.animateFloat(
        initialValue = 1.0f,
        targetValue = 1.1f,
        animationSpec = infiniteRepeatable(
            animation = tween(
                durationMillis = 2000,
                easing = FastOutSlowInEasing
            ),
            repeatMode = RepeatMode.Reverse
        ),
        label = "breathing_scale"
    )

    // 获取屏幕方向
    val configuration = LocalConfiguration.current
    val isLandscape = configuration.orientation == Configuration.ORIENTATION_LANDSCAPE

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(Color.Black) // 纯黑背景
    ) {
        // 顶部：时间 + 网络状态 + 设置按钮 (使用 WindowInsets 适配状态栏区域)
        StandbyTopBar(
            time = currentTime,
            isConnected = isConnected,
            onNavigateToSettings = onNavigateToSettings,
            modifier = Modifier
                .align(Alignment.TopCenter)
                .windowInsetsPadding(WindowInsets.systemBars.only(WindowInsetsSides.Top))
        )

        // 中央：根据状态显示不同内容
        // 横屏时内容向上偏移，避免与底部横条重叠
        val centerModifier = if (isLandscape) {
            Modifier
                .align(Alignment.Center)
                .offset(y = (-40).dp)
        } else {
            Modifier.align(Alignment.Center)
        }

        if (assistantState == AssistantState.IDLE) {
            // 待机模式：显示时间/日期/天气
            IdleModeContent(
                currentTime = currentTime,
                modifier = centerModifier
            )
        } else {
            // 对话模式：显示表情 + 文案
            DialogModeContent(
                emotion = emotion,
                scale = scale,
                isConnected = isConnected,
                assistantState = assistantState,
                isRecording = isRecording,
                isWakeupListening = isWakeupListening,
                isWakeupTriggered = isWakeupTriggered,
                wakeupStatus = wakeupStatus,
                isSpeaking = isSpeaking,
                recordingSeconds = recordingSeconds,
                modifier = centerModifier
            )
        }

        // 底部：对话横条 (使用 WindowInsets 适配手势区域)
        // 横屏时缩小宽度并降低位置
        val bottomBarModifier = if (isLandscape) {
            Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth(0.7f)  // 横屏时宽度为70%
                .windowInsetsPadding(WindowInsets.systemBars.only(WindowInsetsSides.Bottom))
                .padding(bottom = 16.dp)  // 横屏时降低底部距离
        } else {
            Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .windowInsetsPadding(WindowInsets.systemBars.only(WindowInsetsSides.Bottom))
                .padding(bottom = 32.dp)
        }

        BottomDialogBar(
            assistantState = assistantState,
            isRecording = isRecording,
            waveformBars = waveformBars,
            messages = messages,
            wakeupKeyword = wakeupKeyword,
            modifier = bottomBarModifier
        )
    }
}

/**
 * 待机模式内容：时间 + 日期 + 天气
 * 支持横屏和竖屏布局
 */
@Composable
private fun IdleModeContent(
    currentTime: String,
    modifier: Modifier = Modifier
) {
    // 获取屏幕方向
    val configuration = LocalConfiguration.current
    val isLandscape = configuration.orientation == Configuration.ORIENTATION_LANDSCAPE

    // 获取日期信息
    val calendar = Calendar.getInstance()
    val dateFormat = SimpleDateFormat("MM月dd日 EEEE", Locale.CHINESE)
    val currentDate = dateFormat.format(calendar.time)

    // 假的天气数据
    val weatherTemp = "24°C"
    val weatherDesc = "晴转多云"
    val weatherIcon = "☀️"

    if (isLandscape) {
        // 横屏布局：左右分布
        Row(
            modifier = modifier.fillMaxWidth(0.8f),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 左侧：时间
            Text(
                text = currentTime,
                fontSize = 120.sp,
                fontWeight = FontWeight.Light,
                color = Color.White,
                letterSpacing = 6.sp
            )

            // 右侧：日期 + 天气
            Column(
                horizontalAlignment = Alignment.Start,
                verticalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                // 日期
                Text(
                    text = currentDate,
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White.copy(alpha = 0.9f)
                )

                // 天气信息
                Row(
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = weatherIcon,
                        fontSize = 48.sp
                    )
                    Column(
                        horizontalAlignment = Alignment.Start
                    ) {
                        Text(
                            text = weatherTemp,
                            fontSize = 32.sp,
                            fontWeight = FontWeight.Medium,
                            color = Color.White
                        )
                        Text(
                            text = weatherDesc,
                            fontSize = 18.sp,
                            color = Color.White.copy(alpha = 0.7f)
                        )
                    }
                }
            }
        }
    } else {
        // 竖屏布局：上下分布
        Column(
            modifier = modifier,
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(40.dp)
        ) {
            // 大时间显示（增大字体）
            Text(
                text = currentTime,
                fontSize = 140.sp,
                fontWeight = FontWeight.Light,
                color = Color.White,
                letterSpacing = 6.sp
            )

            // 日期（增大字体）
            Text(
                text = currentDate,
                fontSize = 28.sp,
                fontWeight = FontWeight.Medium,
                color = Color.White.copy(alpha = 0.9f)
            )

            // 天气信息（增大字体和图标）
            Row(
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = weatherIcon,
                    fontSize = 48.sp
                )
                Column(
                    horizontalAlignment = Alignment.Start
                ) {
                    Text(
                        text = weatherTemp,
                        fontSize = 36.sp,
                        fontWeight = FontWeight.Medium,
                        color = Color.White
                    )
                    Text(
                        text = weatherDesc,
                        fontSize = 20.sp,
                        color = Color.White.copy(alpha = 0.7f)
                    )
                }
            }
        }
    }
}

/**
 * 对话模式内容：表情 + 标题 + 状态
 * 支持横屏和竖屏布局
 */
@Composable
private fun DialogModeContent(
    emotion: String,
    scale: Float,
    isConnected: Boolean,
    assistantState: AssistantState,
    isRecording: Boolean,
    isWakeupListening: Boolean,
    isWakeupTriggered: Boolean,
    wakeupStatus: String,
    isSpeaking: Boolean,
    recordingSeconds: Float,
    modifier: Modifier = Modifier
) {
    // 获取屏幕方向
    val configuration = LocalConfiguration.current
    val isLandscape = configuration.orientation == Configuration.ORIENTATION_LANDSCAPE

    // 横屏时缩小尺寸
    val emojiSize = if (isLandscape) 100.sp else 140.sp
    val titleSize = if (isLandscape) 24.sp else 32.sp
    val statusSize = if (isLandscape) 11.sp else 13.sp
    val spacing = if (isLandscape) 16.dp else 24.dp

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

/**
 * 底部对话横条
 *
 * 三种显示状态:
 * 1. IDLE - 显示唤醒提示文字
 * 2. RECORDING - 显示音频波纹动画
 * 3. PLAYING - 显示对话内容
 */
@Composable
private fun BottomDialogBar(
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
                // 录音状态：显示波纹动画
                isRecording -> {
                    WaveformVisualization(
                        waveformBars = waveformBars,
                        modifier = Modifier.fillMaxSize()
                    )
                }
                // 有对话内容：显示最后一条消息
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
                // 默认状态：显示唤醒提示
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

/**
 * 波纹可视化组件（横向显示）
 */
@Composable
private fun WaveformVisualization(
    waveformBars: List<Float>,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.padding(horizontal = 32.dp),
        horizontalArrangement = Arrangement.spacedBy(6.dp, Alignment.CenterHorizontally),
        verticalAlignment = Alignment.CenterVertically
    ) {
        waveformBars.forEach { amplitude ->
            Box(
                modifier = Modifier
                    .width(4.dp)
                    .height(((amplitude * 40).coerceAtLeast(4f)).dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(
                        brush = Brush.verticalGradient(
                            colors = listOf(
                                Color(0xFF4CAF50),
                                Color(0xFF81C784)
                            )
                        )
                    )
            )
        }
    }
}

/**
 * 顶部状态栏：时间 + 网络状态 + 设置按钮
 */
@Composable
private fun StandbyTopBar(
    time: String,
    isConnected: Boolean,
    onNavigateToSettings: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 20.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        // 左侧：当前时间
        Text(
            text = time,
            fontSize = 18.sp,
            fontWeight = FontWeight.Medium,
            color = Color.White
        )

        // 右侧：网络状态 + 设置按钮
        Row(
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 网络连接状态云朵图标
            Icon(
                imageVector = if (isConnected) Icons.Filled.Cloud else Icons.Outlined.Cloud,
                contentDescription = if (isConnected) "已连接" else "未连接",
                tint = if (isConnected) Color(0xFF4CAF50) else Color.Gray,
                modifier = Modifier.size(20.dp)
            )

            // 设置按钮
            IconButton(
                onClick = onNavigateToSettings,
                modifier = Modifier.size(32.dp)
            ) {
                Icon(
                    imageVector = Icons.Filled.Settings,
                    contentDescription = "设置",
                    tint = Color.White.copy(alpha = 0.7f),
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}

/**
 * 获取当前时间（格式：HH:mm）
 */
private fun getCurrentTime(): String {
    val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
    return formatter.format(Date())
}

/**
 * 生成详细的状态描述信息
 */
@Composable
private fun getDetailedStatus(
    isConnected: Boolean,
    assistantState: AssistantState,
    isRecording: Boolean,
    isWakeupListening: Boolean,
    isWakeupTriggered: Boolean,
    wakeupStatus: String,
    isSpeaking: Boolean,
    recordingSeconds: Float
): String {
    return buildString {
        // 网络连接状态
        append(if (isConnected) "✓ 已连接" else "✗ 未连接")
        append(" | ")

        // 唤醒状态
        when {
            wakeupStatus.contains("失败") || wakeupStatus.contains("错误") -> {
                append("唤醒: $wakeupStatus")
            }
            isWakeupTriggered -> {
                append("🔔 已唤醒")
            }
            isWakeupListening -> {
                append("👂 监听唤醒词中")
            }
            else -> {
                append("唤醒: $wakeupStatus")
            }
        }
        append(" | ")

        // 当前状态
        when (assistantState) {
            AssistantState.IDLE -> {
                append("待机中")
            }
            AssistantState.RECORDING -> {
                append("🎤 录音中 (${String.format("%.1f", recordingSeconds)}s)")
                if (!isRecording) {
                    append(" [VAD检测到停止]")
                }
            }
            AssistantState.PLAYING -> {
                if (isSpeaking) {
                    append("🔊 播放AI回复中")
                } else {
                    append("处理中...")
                }
            }
        }
    }
}

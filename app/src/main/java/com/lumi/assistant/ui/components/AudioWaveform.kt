package com.lumi.assistant.ui.components

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * 全屏音频波形可视化组件
 * 从中心向两边扩散的波形效果，带半透明背景
 *
 * @param waveformBars 柱子的高度值列表，范围 0-1
 * @param modifier 修饰符
 */
@Composable
fun FullScreenAudioWaveform(
    waveformBars: List<Float>,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.3f)),
        contentAlignment = Alignment.Center
    ) {
        // 从中间向两边扩散的波形
        Row(
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 左侧镜像（倒序）
            repeat(12) { index ->
                val barValue = waveformBars.getOrElse(11 - index) { 0f }
                WaveformBar(
                    barValue = barValue,
                    maxHeight = 250.dp,
                    barWidth = 6.dp
                )
            }

            // 右侧正序
            repeat(12) { index ->
                val barValue = waveformBars.getOrElse(index) { 0f }
                WaveformBar(
                    barValue = barValue,
                    maxHeight = 250.dp,
                    barWidth = 6.dp
                )
            }
        }
    }
}

/**
 * 单个波形柱子
 */
@Composable
private fun WaveformBar(
    barValue: Float,
    maxHeight: Dp,
    barWidth: Dp
) {
    // 计算柱子高度（最小高度1dp，静音时几乎不可见）
    val targetHeight = (maxHeight * barValue.coerceIn(0f, 1f)).coerceAtLeast(1.dp)

    // 使用更快的动画（50ms）提高响应性
    val animatedHeight by animateDpAsState(
        targetValue = targetHeight,
        animationSpec = tween(durationMillis = 50),
        label = "bar_height"
    )

    // 渲染柱子
    Box(
        modifier = Modifier
            .width(barWidth)
            .height(animatedHeight)
            .clip(RoundedCornerShape(3.dp))
            .background(Color.White.copy(alpha = 0.9f))
    )
}

/**
 * 小型音频波形组件（用于顶部状态卡）
 * 显示12个竖直柱子，根据音量高低实时动画
 *
 * @param waveformBars 12个柱子的高度值，范围 0-1
 * @param modifier 修饰符
 * @param maxHeight 柱子最大高度
 * @param barWidth 柱子宽度
 * @param barSpacing 柱子间距
 */
@Composable
fun AudioWaveform(
    waveformBars: List<Float>,
    modifier: Modifier = Modifier,
    maxHeight: Dp = 40.dp,
    barWidth: Dp = 4.dp,
    barSpacing: Dp = 2.dp
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(barSpacing),
        verticalAlignment = Alignment.Bottom
    ) {
        repeat(12) { index ->
            val barValue = waveformBars.getOrElse(index) { 0f }
            val targetHeight = maxHeight * barValue.coerceIn(0f, 1f)
            val minHeight = 2.dp
            val actualHeight = if (targetHeight < minHeight) minHeight else targetHeight

            val animatedHeight by animateDpAsState(
                targetValue = actualHeight,
                animationSpec = tween(durationMillis = 100),
                label = "bar_height_$index"
            )

            Box(
                modifier = Modifier
                    .width(barWidth)
                    .height(animatedHeight)
                    .clip(RoundedCornerShape(2.dp))
                    .background(MaterialTheme.colorScheme.primary)
            )
        }
    }
}

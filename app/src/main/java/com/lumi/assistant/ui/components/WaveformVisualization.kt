package com.lumi.assistant.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

/**
 * 波纹可视化组件（横向显示）
 * 显示音频波形的实时可视化
 */
@Composable
fun WaveformVisualization(
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

package com.lumi.assistant.ui.content

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import android.content.res.Configuration
import com.lumi.assistant.model.WeatherState
import com.lumi.assistant.ui.components.WeatherDisplay
import com.lumi.assistant.ui.utils.getCurrentDate
import com.lumi.assistant.ui.utils.getCurrentTime
import kotlinx.coroutines.delay

/**
 * 待机模式内容：时间 + 日期 + 天气
 * 支持横屏和竖屏布局
 */
@Composable
fun IdleModeContent(
    weatherState: WeatherState,
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

    // 获取屏幕方向
    val configuration = LocalConfiguration.current
    val isLandscape = configuration.orientation == Configuration.ORIENTATION_LANDSCAPE

    // 获取日期信息
    val currentDate = getCurrentDate()

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
                WeatherDisplay(
                    weatherState = weatherState,
                    textColor = Color.White,
                    iconSize = 48,
                    temperatureFontSize = 32.sp,
                    descriptionFontSize = 18.sp
                )
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
            WeatherDisplay(
                weatherState = weatherState,
                textColor = Color.White,
                iconSize = 48,
                temperatureFontSize = 36.sp,
                descriptionFontSize = 20.sp
            )
        }
    }
}

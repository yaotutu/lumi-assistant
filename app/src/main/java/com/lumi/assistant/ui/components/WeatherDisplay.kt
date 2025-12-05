package com.lumi.assistant.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.lumi.assistant.model.Weather
import com.lumi.assistant.model.WeatherState
import com.lumi.assistant.utils.WeatherIconUtils

/**
 * 天气显示组件
 */
@Composable
fun WeatherDisplay(
    weatherState: WeatherState,
    modifier: Modifier = Modifier,
    textColor: Color = Color.White,
    iconSize: Int = 48,
    temperatureFontSize: TextUnit = 36.sp,
    descriptionFontSize: TextUnit = 20.sp
) {
    when (weatherState) {
        is WeatherState.Idle -> {
            // 空闲状态，不显示
        }

        is WeatherState.Loading -> {
            // 加载中
            Row(
                modifier = modifier,
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                CircularProgressIndicator(
                    modifier = Modifier.size(iconSize.dp),
                    color = textColor.copy(alpha = 0.7f)
                )
                Text(
                    text = "加载中...",
                    color = textColor.copy(alpha = 0.7f),
                    fontSize = descriptionFontSize
                )
            }
        }

        is WeatherState.Success -> {
            // 成功获取天气
            WeatherContent(
                weather = weatherState.weather,
                modifier = modifier,
                textColor = textColor,
                iconSize = iconSize,
                temperatureFontSize = temperatureFontSize,
                descriptionFontSize = descriptionFontSize
            )
        }

        is WeatherState.Error -> {
            // 错误状态
            if (weatherState.cachedWeather != null) {
                // 显示缓存数据 + 错误提示
                Column(
                    modifier = modifier,
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    WeatherContent(
                        weather = weatherState.cachedWeather,
                        textColor = textColor.copy(alpha = 0.7f),
                        iconSize = iconSize,
                        temperatureFontSize = temperatureFontSize,
                        descriptionFontSize = descriptionFontSize
                    )
                    Text(
                        text = "(数据可能过期)",
                        color = textColor.copy(alpha = 0.5f),
                        fontSize = (descriptionFontSize.value * 0.8).sp
                    )
                }
            } else {
                // 仅显示错误信息
                Text(
                    text = "天气: ${weatherState.message}",
                    color = textColor.copy(alpha = 0.7f),
                    fontSize = descriptionFontSize,
                    modifier = modifier
                )
            }
        }
    }
}

/**
 * 天气内容显示
 */
@Composable
private fun WeatherContent(
    weather: Weather,
    modifier: Modifier = Modifier,
    textColor: Color = Color.White,
    iconSize: Int = 48,
    temperatureFontSize: TextUnit = 36.sp,
    descriptionFontSize: TextUnit = 20.sp
) {
    val context = LocalContext.current
    val iconResourceName = weather.getIconResourceName()
    val iconResourceId = WeatherIconUtils.getWeatherIconResource(context, iconResourceName)

    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // 天气图标（优先使用 Vector Drawable，失败时使用 Emoji）
        if (iconResourceId != 0) {
            Icon(
                painter = painterResource(id = iconResourceId),
                contentDescription = weather.description,
                modifier = Modifier.size(iconSize.dp),
                tint = textColor
            )
        } else {
            // 回退到 Emoji
            Text(
                text = weather.getWeatherEmoji(),
                fontSize = iconSize.sp,
                modifier = Modifier.size(iconSize.dp),
                color = textColor
            )
        }

        // 温度和天气描述
        Column(
            horizontalAlignment = Alignment.Start
        ) {
            Text(
                text = weather.temperature,
                color = textColor,
                fontSize = temperatureFontSize,
                fontWeight = FontWeight.Medium
            )
            Text(
                text = weather.description,
                color = textColor.copy(alpha = 0.9f),
                fontSize = descriptionFontSize
            )
        }
    }
}

/**
 * 简化版天气显示（仅图标 + 温度）
 */
@Suppress("unused")
@Composable
fun CompactWeatherDisplay(
    weatherState: WeatherState,
    modifier: Modifier = Modifier,
    textColor: Color = Color.White
) {
    when (weatherState) {
        is WeatherState.Success -> {
            val weather = weatherState.weather
            val context = LocalContext.current
            val iconResourceName = weather.getIconResourceName()
            val iconResourceId = WeatherIconUtils.getWeatherIconResource(context, iconResourceName)

            Row(
                modifier = modifier,
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // 天气图标（优先使用 Vector Drawable，失败时使用 Emoji）
                if (iconResourceId != 0) {
                    Icon(
                        painter = painterResource(id = iconResourceId),
                        contentDescription = weather.description,
                        modifier = Modifier.size(32.dp),
                        tint = textColor
                    )
                } else {
                    // 回退到 Emoji
                    Text(
                        text = weather.getWeatherEmoji(),
                        fontSize = 32.sp,
                        modifier = Modifier.size(32.dp),
                        color = textColor
                    )
                }

                Text(
                    text = weather.temperature,
                    color = textColor,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Medium
                )
            }
        }

        is WeatherState.Loading -> {
            CircularProgressIndicator(
                modifier = Modifier.size(32.dp),
                color = textColor.copy(alpha = 0.7f)
            )
        }

        else -> {
            // 其他状态不显示
        }
    }
}

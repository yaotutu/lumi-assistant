package com.lumi.assistant.standby.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.Cloud
import androidx.compose.material.icons.outlined.Dns
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.lumi.assistant.ui.utils.getCurrentTime
import kotlinx.coroutines.delay

/**
 * 状态栏组件
 * 显示：时间、互联网状态、语音助手服务器状态、设置按钮
 *
 * 设计原则：与业务层解耦，仅接收状态数据
 */
@Composable
fun StatusBarComponent(
    internetConnected: Boolean,
    serverConnected: Boolean,
    onNavigateToSettings: () -> Unit,
    modifier: Modifier = Modifier
) {
    // 实时时间
    var currentTime by remember { mutableStateOf(getCurrentTime()) }

    LaunchedEffect(Unit) {
        while (true) {
            currentTime = getCurrentTime()
            delay(1000)
        }
    }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 20.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        // 左侧：当前时间
        Text(
            text = currentTime,
            fontSize = 18.sp,
            fontWeight = FontWeight.Medium,
            color = Color.White
        )

        // 右侧：互联网状态 + 服务器状态 + 设置按钮
        Row(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 互联网连接状态图标（地球图标）
            Icon(
                imageVector = if (internetConnected) Icons.Filled.Cloud else Icons.Outlined.Cloud,
                contentDescription = if (internetConnected) "互联网已连接" else "互联网未连接",
                tint = if (internetConnected) Color(0xFF4CAF50) else Color.Gray,
                modifier = Modifier.size(20.dp)
            )

            // 语音助手服务器状态图标（服务器图标）
            Icon(
                imageVector = if (serverConnected) Icons.Filled.Dns else Icons.Outlined.Dns,
                contentDescription = if (serverConnected) "服务器已连接" else "服务器未连接",
                tint = if (serverConnected) Color(0xFF4CAF50) else Color.Gray,
                modifier = Modifier.size(20.dp)
            )

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

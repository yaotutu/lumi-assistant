package com.lumi.assistant.ui

import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.lumi.assistant.MainActivity
import com.lumi.assistant.config.AppMode
import com.lumi.assistant.config.AppSettings

/**
 * 设置页面
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    settings: AppSettings,
    onNavigateBack: () -> Unit,
    onUpdateVadSilenceThreshold: (Long) -> Unit,
    onUpdateVadVolumeThreshold: (Int) -> Unit,
    onUpdateServerUrl: (String) -> Unit,
    onUpdateWakeupKeyword: (String) -> Unit,
    onUpdateAppMode: (AppMode) -> Unit,
    onUpdateWeatherEnabled: (Boolean) -> Unit,
    onUpdateWeatherApiKey: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val activity = context as? ComponentActivity
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("设置") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "返回"
                        )
                    }
                }
            )
        }
    ) { innerPadding ->
        Column(
            modifier = modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // VAD 配置部分
            SettingsSection(title = "语音活动检测 (VAD)") {
                // 静音阈值
                SliderSetting(
                    label = "静音阈值",
                    value = settings.vad.silenceThreshold.toFloat(),
                    valueRange = 500f..5000f,
                    steps = 8,
                    unit = "ms",
                    onValueChange = { onUpdateVadSilenceThreshold(it.toLong()) }
                )

                // 音量阈值
                SliderSetting(
                    label = "音量阈值",
                    value = settings.vad.volumeThreshold.toFloat(),
                    valueRange = 100f..2000f,
                    steps = 18,
                    unit = "",
                    onValueChange = { onUpdateVadVolumeThreshold(it.toInt()) }
                )
            }

            // 服务器配置部分
            SettingsSection(title = "服务器配置") {
                var serverUrl by remember(settings.server.wsUrl) {
                    mutableStateOf(settings.server.wsUrl)
                }

                OutlinedTextField(
                    value = serverUrl,
                    onValueChange = { serverUrl = it },
                    label = { Text("WebSocket 地址") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )

                if (serverUrl != settings.server.wsUrl) {
                    Button(
                        onClick = { onUpdateServerUrl(serverUrl) },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("保存服务器地址")
                    }
                }
            }

            // 唤醒词配置部分
            SettingsSection(title = "唤醒词配置") {
                var keyword by remember(settings.wakeup.keyword) {
                    mutableStateOf(settings.wakeup.keyword)
                }

                OutlinedTextField(
                    value = keyword,
                    onValueChange = { keyword = it },
                    label = { Text("唤醒词") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )

                if (keyword != settings.wakeup.keyword) {
                    Button(
                        onClick = { onUpdateWakeupKeyword(keyword) },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("保存唤醒词")
                    }
                }
            }

            // 天气设置部分
            SettingsSection(title = "天气设置") {
                // 启用开关
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "启用天气功能",
                            style = MaterialTheme.typography.bodyLarge
                        )
                        Text(
                            text = "在待机界面显示实时天气信息",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    Switch(
                        checked = settings.weather.enabled,
                        onCheckedChange = onUpdateWeatherEnabled
                    )
                }

                // API Key 输入
                if (settings.weather.enabled) {
                    var apiKey by remember(settings.weather.apiKey) {
                        mutableStateOf(settings.weather.apiKey)
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    OutlinedTextField(
                        value = apiKey,
                        onValueChange = { apiKey = it },
                        label = { Text("和风天气 API Key") },
                        placeholder = { Text("请输入您的 API Key") },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true,
                        supportingText = {
                            Text("在 dev.qweather.com 注册获取免费 API Key")
                        }
                    )

                    if (apiKey != settings.weather.apiKey) {
                        Button(
                            onClick = { onUpdateWeatherApiKey(apiKey) },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text("保存 API Key")
                        }
                    }

                    // 提示信息
                    if (settings.weather.apiKey.isBlank()) {
                        Text(
                            text = "⚠️ 请先配置 API Key 才能使用天气功能",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.error,
                            modifier = Modifier.padding(top = 8.dp)
                        )
                    }
                }
            }

            // 应用模式切换
            SettingsSection(title = "应用模式") {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = if (settings.appMode == AppMode.CHAT) "聊天模式" else "待机模式",
                            style = MaterialTheme.typography.bodyLarge
                        )
                        Text(
                            text = if (settings.appMode == AppMode.CHAT)
                                "传统聊天界面，消息列表展示"
                            else
                                "待机交互模式，音频文字同步播放",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    Switch(
                        checked = settings.appMode == AppMode.CAR,
                        onCheckedChange = { isCarMode ->
                            val newMode = if (isCarMode) AppMode.CAR else AppMode.CHAT

                            // 保存设置
                            onUpdateAppMode(newMode)

                            // 提示用户
                            activity?.let {
                                Toast.makeText(
                                    context,
                                    "模式已切换，应用即将重启",
                                    Toast.LENGTH_SHORT
                                ).show()

                                // 延迟500ms自动重启
                                Handler(Looper.getMainLooper()).postDelayed({
                                    it.finishAffinity()
                                    it.startActivity(Intent(it, MainActivity::class.java))
                                    Runtime.getRuntime().exit(0)
                                }, 500)
                            }
                        }
                    )
                }

                Text(
                    text = "⚠️ 切换模式将自动重启应用",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.error,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
        }
    }
}

/**
 * 设置区块组件
 */
@Composable
private fun SettingsSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )
            content()
        }
    }
}

/**
 * 滑块设置组件
 */
@Composable
private fun SliderSetting(
    label: String,
    value: Float,
    valueRange: ClosedFloatingPointRange<Float>,
    steps: Int,
    unit: String,
    onValueChange: (Float) -> Unit
) {
    var sliderValue by remember(value) { mutableFloatStateOf(value) }

    Column {
        Text(
            text = "$label: ${sliderValue.toInt()}$unit",
            style = MaterialTheme.typography.bodyMedium
        )
        Slider(
            value = sliderValue,
            onValueChange = { sliderValue = it },
            onValueChangeFinished = { onValueChange(sliderValue) },
            valueRange = valueRange,
            steps = steps
        )
    }
}

package com.lumi.assistant.ui.utils

import com.lumi.assistant.viewmodel.AssistantState
import java.text.SimpleDateFormat
import java.util.*

/**
 * 获取当前时间（格式：HH:mm）
 */
fun getCurrentTime(): String {
    val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
    return formatter.format(Date())
}

/**
 * 获取当前日期（格式：MM月dd日 EEEE）
 */
fun getCurrentDate(): String {
    val calendar = Calendar.getInstance()
    val dateFormat = SimpleDateFormat("MM月dd日 EEEE", Locale.CHINESE)
    return dateFormat.format(calendar.time)
}

/**
 * 生成详细的状态描述信息
 */
fun getDetailedStatus(
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

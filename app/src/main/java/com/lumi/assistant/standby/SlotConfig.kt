package com.lumi.assistant.standby

import androidx.compose.ui.Alignment

/**
 * 单个插槽的配置
 */
sealed class SlotConfig {
    /**
     * 显示组件
     * @param componentType 组件类型
     * @param alignment 对齐方式（默认居中）
     * @param alpha 透明度（0.0 - 1.0）
     */
    data class Component(
        val componentType: ComponentType,
        val alignment: Alignment = Alignment.Center,
        val alpha: Float = 0.95f
    ) : SlotConfig()

    /**
     * 空插槽（不显示任何内容）
     */
    data object Empty : SlotConfig()
}

/**
 * 组件类型枚举
 */
enum class ComponentType {
    STATUS_BAR,       // 状态栏
    VOICE_BAR,        // 语音横条
    VOICE_ASSISTANT,  // 语音助手（核心组件）
    NOTIFICATION,     // 通知（未来）
    QUICK_ACTIONS     // 快捷操作（未来）
}

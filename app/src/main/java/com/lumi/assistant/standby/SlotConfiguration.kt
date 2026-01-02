package com.lumi.assistant.standby

/**
 * 完整的插槽配置（所有插槽）
 */
data class SlotConfiguration(
    val topSlot: SlotConfig = SlotConfig.Empty,
    val bottomSlot: SlotConfig = SlotConfig.Empty,
    val startSlot: SlotConfig = SlotConfig.Empty,
    val endSlot: SlotConfig = SlotConfig.Empty,
    val centerSlot: SlotConfig = SlotConfig.Empty
) {
    companion object {
        /**
         * 默认配置：显示状态栏 + 语音助手 + 语音栏
         */
        val Default = SlotConfiguration(
            topSlot = SlotConfig.Component(ComponentType.STATUS_BAR),
            centerSlot = SlotConfig.Component(ComponentType.VOICE_ASSISTANT),
            bottomSlot = SlotConfig.Component(ComponentType.VOICE_BAR)
        )

        /**
         * 极简配置：仅显示状态栏 + 语音助手
         */
        val Minimal = SlotConfiguration(
            topSlot = SlotConfig.Component(ComponentType.STATUS_BAR),
            centerSlot = SlotConfig.Component(ComponentType.VOICE_ASSISTANT)
        )

        /**
         * 全屏配置：不显示任何浮动组件
         */
        val Fullscreen = SlotConfiguration()
    }
}

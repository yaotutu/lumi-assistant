package com.lumi.assistant.standby

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

/**
 * 待机页面接口
 * 所有待机页面必须实现此接口
 */
interface StandbyPage {
    /**
     * 页面唯一标识
     */
    val pageId: String

    /**
     * 页面显示名称
     */
    val pageName: String

    /**
     * 插槽配置
     * 声明该页面需要哪些浮动组件
     */
    val slotConfiguration: SlotConfiguration

    /**
     * 页面内容（Composable 函数）
     * 在 StandbyContainer 中会调用此方法渲染内容
     */
    @Composable
    fun Content(modifier: Modifier = Modifier)
}

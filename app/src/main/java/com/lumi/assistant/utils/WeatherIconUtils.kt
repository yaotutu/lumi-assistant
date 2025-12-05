package com.lumi.assistant.utils

import android.content.Context

/**
 * 天气图标工具类
 */
object WeatherIconUtils {

    /**
     * 根据资源名称获取资源 ID
     * 如果找不到对应的资源，返回默认图标
     */
    fun getWeatherIconResource(context: Context, resourceName: String): Int {
        val resourceId = context.resources.getIdentifier(
            resourceName,
            "drawable",
            "com.lumi.assistant"
        )

        return if (resourceId != 0) {
            resourceId
        } else {
            // 如果找不到对应的图标，返回0表示使用默认的雾图标
            0
        }
    }

    /**
     * 获取所有支持的和风天气图标代码
     */
    fun getSupportedIconCodes(): List<String> {
        return listOf(
            // 晴天
            "100", "150",
            // 多云
            "101", "102", "103", "104", "151",
            // 雨天
            "300", "301", "302", "303", "304", "305", "306", "307", "308", "309",
            "310", "311", "312", "313", "314", "315", "316", "317", "318", "399",
            // 雪天
            "400", "401", "402", "403", "404", "405", "406", "407", "408", "409", "410",
            "456", "457", "489", "490",
            // 雾天
            "500", "501", "502", "509", "510", "514", "515",
            // 沙尘
            "503", "504", "507", "508", "511", "512", "513",
            // 风
            "506"
        )
    }
}
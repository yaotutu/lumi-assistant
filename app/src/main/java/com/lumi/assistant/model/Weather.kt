package com.lumi.assistant.model

import android.util.Log

/**
 * 天气数据模型
 */
data class Weather(
    /** 温度（摄氏度） */
    val temperature: String,

    /** 天气状态文字描述（如：晴、多云、阴、雨等） */
    val description: String,

    /** 天气图标代码（和风天气图标代码，如：100表示晴天） */
    val iconCode: String,

    /** 体感温度（摄氏度） */
    val feelsLike: String? = null,

    /** 湿度（百分比） */
    val humidity: String? = null,

    /** 风向 */
    val windDirection: String? = null,

    /** 风速（km/h） */
    val windSpeed: String? = null,

    /** 数据更新时间（时间戳） */
    val updateTime: Long = System.currentTimeMillis()
) {
    /**
     * 获取天气图标资源名称（使用和风天气官方图标）
     */
    fun getIconResourceName(): String {
        val resourceName = when (iconCode) {
            // 白天天气图标
            "100" -> "weather_sunny"           // 晴
            "101" -> "weather_cloudy"          // 多云
            "102" -> "weather_overcast"        // 阴
            "103" -> "weather_shade"           // 晴间多云
            "104" -> "weather_partly_cloudy"   // 多云
            "150" -> "weather_clear_night"     // 晴夜
            "151" -> "weather_cloudy_night"    // 多云夜间

            // 雨天图标
            "300" -> "weather_shower_rain"     // 阵雨
            "301" -> "weather_thunder_shower"  // 强阵雨
            "302" -> "weather_heavy_rain"      // 雷阵雨
            "303" -> "weather_heavy_rain"      // 雷阵雨
            "304" -> "weather_hail"            // 雷阵雨伴有冰雹
            "305" -> "weather_light_rain"      // 小雨
            "306" -> "weather_moderate_rain"   // 中雨
            "307" -> "weather_heavy_rain"      // 大雨
            "308" -> "weather_extreme_rain"    // 极端降雨
            "309" -> "weather_drizzle_rain"    // 毛毛雨
            "310" -> "weather_storm_rain"      // 暴雨
            "311" -> "weather_heavy_storm"     // 大暴雨
            "312" -> "weather_severe_storm"    // 特大暴雨
            "313" -> "weather_freezing_rain"   // 冻雨
            "314" -> "weather_light_to_heavy_rain" // 小到中雨
            "315" -> "weather_moderate_to_heavy_rain" // 中到大雨
            "316" -> "weather_heavy_to_storm_rain" // 大到暴雨
            "317" -> "weather_storm_to_heavy_storm" // 暴雨到大暴雨
            "318" -> "weather_heavy_to_severe_storm" // 大暴雨到特大暴雨
            "399" -> "weather_rain"           // 雨

            // 雪天图标
            "400" -> "weather_light_snow"      // 小雪
            "401" -> "weather_moderate_snow"   // 中雪
            "402" -> "weather_heavy_snow"      // 大雪
            "403" -> "weather_snow_storm"      // 暴雪
            "404" -> "weather_sleet"          // 雨夹雪
            "405" -> "weather_rain_snow"      // 小雨夹雪
            "406" -> "weather_moderate_rain_snow" // 中雨夹雪
            "407" -> "weather_heavy_rain_snow"   // 大雨夹雪
            "408" -> "weather_sleet_storm"    // 雨夹雪暴
            "409" -> "weather_light_snow_storm" // 小雪伴雷
            "410" -> "weather_moderate_snow_storm" // 中雪伴雷
            "456" -> "weather_light_rain_snow"   // 小雨雪
            "457" -> "weather_moderate_rain_snow" // 中雨雪
            "489" -> "weather_light_snow_storm"   // 小雪伴雷
            "490" -> "weather_moderate_snow_storm" // 中雪伴雷

            // 雾天图标
            "500" -> "weather_fog"            // 薄雾
            "501" -> "weather_haze"           // 雾
            "502" -> "weather_smoky_fog"      // 霾
            "509" -> "weather_fog"            // 雾
            "510" -> "weather_fog"            // 雾
            "514" -> "weather_fog"            // 雾
            "515" -> "weather_fog"            // 雾

            // 沙尘天气图标
            "503" -> "weather_sand"           // 浮尘
            "504" -> "weather_sand_storm"     // 扬沙
            "507" -> "weather_dust"           // 沙尘暴
            "508" -> "weather_heavy_sand_storm" // 强沙尘暴
            "511" -> "weather_dust"           // 沙尘暴
            "512" -> "weather_heavy_sand_storm" // 强沙尘暴
            "513" -> "weather_heavy_sand_storm" // 强沙尘暴

            // 风和特殊天气
            "506" -> "weather_windy"          // 大风
            "507" -> "weather_sand_storm"     // 沙尘暴

            // 默认图标
            else -> "weather_unknown"
        }
        Log.d("Weather", "Icon code: $iconCode -> Resource: $resourceName")
        return resourceName
    }

    /**
     * 获取天气图标（使用 Emoji 作为备用）
     */
    fun getWeatherEmoji(): String {
        return when (iconCode) {
            // 晴天
            "100" -> "☀️"
            "150" -> "🌤️"
            // 多云
            "101", "104" -> "☁️"
            // 阴天
            "102", "103" -> "☁️"
            // 小雨
            "305", "308", "309", "350", "351" -> "🌦️"
            // 中雨
            "306", "307", "310", "311", "312", "313" -> "🌧️"
            // 大雨和雷阵雨
            "302", "303", "304" -> "⛈️"
            "314", "315", "316", "317", "318" -> "⛈️"
            // 雪
            "399", "400", "401", "402", "403", "404", "405", "406", "407", "408", "409", "410", "456", "457", "489", "490" -> "❄️"
            // 雾
            "500", "501", "502", "509", "510", "514", "515" -> "🌫️"
            // 沙尘
            "503", "504", "507", "508", "511", "512", "513" -> "🌪️"
            // 风
            "506" -> "💨"
            // 其他
            else -> "🌈"
        }
    }

    /**
     * 判断数据是否过期（默认30分钟）
     */
    fun isExpired(cacheTimeMillis: Long = 30 * 60 * 1000): Boolean {
        return System.currentTimeMillis() - updateTime > cacheTimeMillis
    }
}

/**
 * 天气数据加载状态
 */
sealed class WeatherState {
    /** 空闲状态 */
    object Idle : WeatherState()

    /** 加载中 */
    object Loading : WeatherState()

    /** 加载成功 */
    data class Success(val weather: Weather) : WeatherState()

    /** 加载失败 */
    data class Error(val message: String, val cachedWeather: Weather? = null) : WeatherState()
}

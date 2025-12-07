package com.lumi.assistant.network

import android.util.Log
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.lumi.assistant.model.Weather
import okhttp3.Callback
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.Call
import java.io.IOException
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

/**
 * 和风天气 API 服务
 */
class QWeatherApi(
    private val credentialsId: String,
    private val apiKey: String,
    private val httpClient: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build()
) {
    companion object {
        private const val TAG = "QWeatherApi"
        private const val BASE_URL = "https://devapi.qweather.com/v7"
    }

    private val gson = Gson()

    /**
     * 获取实时天气
     * @param location 位置信息，支持：
     *   - 经纬度格式：116.41,39.92
     *   - 城市ID：101010100
     * @return Weather 对象，失败时抛出异常
     */
    suspend fun getCurrentWeather(location: String): Weather {
        val url = "$BASE_URL/weather/now?location=$location&key=$apiKey"
        Log.d(TAG, "Fetching weather for location: $location")
        Log.d(TAG, "Using credentialsId: $credentialsId")
        Log.d(TAG, "Request URL: $BASE_URL/weather/now?location=$location&key=${apiKey.take(8)}...")

        val request = Request.Builder()
            .url(url)
            .get()
            .build()

        try {
            Log.d(TAG, "Executing async HTTP request...")

            // 使用 suspendCoroutine 将异步调用转换为协程
            return suspendCoroutine { continuation ->
                httpClient.newCall(request).enqueue(object : Callback {
                    override fun onFailure(call: Call, e: IOException) {
                        Log.e(TAG, "Network request failed", e)
                        continuation.resumeWithException(e)
                    }

                    override fun onResponse(call: Call, response: Response) {
                        try {
                            val responseBody = response.body?.string()

                            Log.d(TAG, "HTTP Response - Code: ${response.code}, Message: ${response.message}, Body: ${responseBody?.take(200)}...")

                            if (!response.isSuccessful) {
                                Log.e(TAG, "API request failed - Code: ${response.code}, Message: ${response.message}")
                                continuation.resumeWithException(IOException("API request failed with code: ${response.code}"))
                                return
                            }

                            if (responseBody == null) {
                                Log.e(TAG, "Response body is null")
                                continuation.resumeWithException(IOException("Response body is null"))
                                return
                            }

                            Log.d(TAG, "Full API Response: $responseBody")

                            val apiResponse = gson.fromJson(responseBody, QWeatherResponse::class.java)
                            Log.d(TAG, "Parsed API response - Code: ${apiResponse.code}, UpdateTime: ${apiResponse.updateTime}")

                            if (apiResponse.code != "200") {
                                Log.e(TAG, "API error - Code: ${apiResponse.code}, Message: ${getErrorMessage(apiResponse.code)}")
                                continuation.resumeWithException(IOException("API error: ${getErrorMessage(apiResponse.code)}"))
                                return
                            }

                            if (apiResponse.now == null) {
                                Log.e(TAG, "Weather data (now) is null in API response")
                                continuation.resumeWithException(IOException("Weather data is null"))
                                return
                            }

                            Log.d(TAG, "Weather data parsed - Temp: ${apiResponse.now.temp}, Text: ${apiResponse.now.text}, Icon: ${apiResponse.now.icon}")

                            val weather = Weather(
                                temperature = "${apiResponse.now.temp}°C",
                                description = apiResponse.now.text,
                                iconCode = apiResponse.now.icon,
                                feelsLike = apiResponse.now.feelsLike?.let { "${it}°C" },
                                humidity = apiResponse.now.humidity?.let { "${it}%" },
                                windDirection = apiResponse.now.windDir,
                                windSpeed = apiResponse.now.windSpeed?.let { "${it} km/h" },
                                updateTime = System.currentTimeMillis()
                            )

                            continuation.resume(weather)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error parsing weather API response", e)
                            continuation.resumeWithException(IOException("Error parsing weather data: ${e.message}"))
                        }
                    }
                })
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error during weather API call", e)
            throw IOException("Error parsing weather data: ${e.message}")
        }
    }

    /**
     * 获取错误信息描述
     */
    private fun getErrorMessage(code: String): String {
        return when (code) {
            "204" -> "请求成功，但当前地区暂无数据"
            "400" -> "请求错误，可能是参数错误或缺少必需参数"
            "401" -> "认证失败，API Key 错误或已过期"
            "402" -> "超过访问次数限制，请升级套餐"
            "403" -> "无访问权限"
            "404" -> "查询的数据不存在"
            "429" -> "请求过于频繁，超过限制"
            "500" -> "服务器错误"
            else -> "未知错误: $code"
        }
    }
}

/**
 * 和风天气 API 响应模型
 */
private data class QWeatherResponse(
    @SerializedName("code")
    val code: String,

    @SerializedName("updateTime")
    val updateTime: String? = null,

    @SerializedName("fxLink")
    val fxLink: String? = null,

    @SerializedName("now")
    val now: QWeatherNow? = null
)

/**
 * 实时天气数据
 */
private data class QWeatherNow(
    @SerializedName("obsTime")
    val obsTime: String,

    @SerializedName("temp")
    val temp: String,

    @SerializedName("feelsLike")
    val feelsLike: String? = null,

    @SerializedName("icon")
    val icon: String,

    @SerializedName("text")
    val text: String,

    @SerializedName("wind360")
    val wind360: String? = null,

    @SerializedName("windDir")
    val windDir: String? = null,

    @SerializedName("windScale")
    val windScale: String? = null,

    @SerializedName("windSpeed")
    val windSpeed: String? = null,

    @SerializedName("humidity")
    val humidity: String? = null,

    @SerializedName("precip")
    val precip: String? = null,

    @SerializedName("pressure")
    val pressure: String? = null,

    @SerializedName("vis")
    val vis: String? = null,

    @SerializedName("cloud")
    val cloud: String? = null,

    @SerializedName("dew")
    val dew: String? = null
)

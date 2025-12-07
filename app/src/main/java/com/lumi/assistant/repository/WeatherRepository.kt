package com.lumi.assistant.repository

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.os.Bundle
import android.util.Log
import androidx.core.content.ContextCompat
import com.lumi.assistant.model.Weather
import com.lumi.assistant.network.QWeatherApi
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.concurrent.atomic.AtomicBoolean
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

/**
 * 天气数据仓库
 * 负责获取天气数据、缓存管理和位置服务
 */
@Singleton
class WeatherRepository @Inject constructor(
    @field:ApplicationContext private val context: Context
) {
    companion object {
        private const val TAG = "WeatherRepository"
        private const val CACHE_DURATION_MS = 30 * 60 * 1000L // 30分钟缓存
    }

    private val locationManager: LocationManager =
        context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

    // 内存缓存
    private var cachedWeather: Weather? = null
    private var cacheTimestamp: Long = 0

    /**
     * 获取当前位置的天气
     * @param credentialsId 和风天气凭据ID
     * @param apiKey 和风天气 API Key
     * @param forceRefresh 是否强制刷新（忽略缓存）
     * @return Weather 对象，失败时抛出异常
     */
    suspend fun getCurrentWeather(credentialsId: String, apiKey: String, forceRefresh: Boolean = false): Weather {
        Log.d(TAG, "getCurrentWeather called with forceRefresh: $forceRefresh")

        // 检查缓存
        if (!forceRefresh && isCacheValid()) {
            Log.d(TAG, "Returning cached weather data: ${cachedWeather?.temperature}")
            return cachedWeather!!
        }

        // 检查凭据ID和API Key
        if (credentialsId.isBlank()) {
            Log.e(TAG, "Credentials ID is blank")
            throw IllegalArgumentException("凭据ID未配置，请在设置中输入和风天气凭据ID")
        }
        if (apiKey.isBlank()) {
            Log.e(TAG, "API Key is blank")
            throw IllegalArgumentException("API Key 未配置，请在设置中输入和风天气 API Key")
        }

        Log.d(TAG, "Using credentialsId: $credentialsId")
        Log.d(TAG, "Using API Key: ${apiKey.take(8)}...")

        try {
            // 获取位置
            Log.d(TAG, "Getting current location...")
            val location = getCurrentLocation()
            val locationString = "${location.longitude},${location.latitude}"
            Log.d(TAG, "Successfully got location: $locationString (lat: ${location.latitude}, lng: ${location.longitude})")

            // 调用 API
            Log.d(TAG, "Calling weather API with location: $locationString")
            val api = QWeatherApi(credentialsId, apiKey)
            val weather = api.getCurrentWeather(locationString)

            // 更新缓存
            cachedWeather = weather
            cacheTimestamp = System.currentTimeMillis()

            Log.d(TAG, "Weather updated successfully: ${weather.temperature}, ${weather.description}")
            return weather
        } catch (e: Exception) {
            Log.e(TAG, "Error getting weather", e)
            throw e
        }
    }

    /**
     * 获取当前位置（经纬度）
     * @return Location 对象
     * @throws SecurityException 如果没有位置权限
     * @throws IllegalStateException 如果无法获取位置
     */
    private suspend fun getCurrentLocation(): Location {
        Log.d(TAG, "getCurrentLocation called")

        // 检查权限
        if (!hasLocationPermission()) {
            Log.e(TAG, "Location permission not granted")
            throw SecurityException("没有位置权限，请在设置中授予位置权限")
        }

        Log.d(TAG, "Location permission granted, requesting location...")

        try {
            // 首先尝试获取最后已知位置
            val lastKnownLocation = getLastKnownLocation()
            if (lastKnownLocation != null) {
                Log.d(TAG, "Using last known location: lat=${lastKnownLocation.latitude}, lng=${lastKnownLocation.longitude}")
                return lastKnownLocation
            }

            // 如果没有最后位置，请求当前位置
            Log.d(TAG, "No last known location, requesting current location...")
            return requestCurrentLocation()
        } catch (e: SecurityException) {
            Log.e(TAG, "Location permission denied", e)
            throw SecurityException("没有位置权限")
        } catch (e: Exception) {
            Log.e(TAG, "Error getting location", e)
            throw IllegalStateException("获取位置失败: ${e.message}")
        }
    }

    /**
     * 获取最后已知位置
     */
    private fun getLastKnownLocation(): Location? {
        val providers = listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER)

        for (provider in providers) {
            try {
                if (locationManager.isProviderEnabled(provider)) {
                    val location = locationManager.getLastKnownLocation(provider)
                    if (location != null) {
                        val age = System.currentTimeMillis() - location.time
                        // 如果位置数据不超过5分钟，认为是有效的
                        if (age < 5 * 60 * 1000) {
                            Log.d(TAG, "Found valid last known location from $provider: lat=${location.latitude}, lng=${location.longitude}")
                            return location
                        }
                    }
                }
            } catch (e: SecurityException) {
                Log.w(TAG, "No permission for provider $provider", e)
            } catch (e: Exception) {
                Log.w(TAG, "Error getting last known location from $provider", e)
            }
        }

        Log.d(TAG, "No valid last known location found")
        return null
    }

    /**
     * 请求当前位置
     */
    private suspend fun requestCurrentLocation(): Location = suspendCoroutine { continuation ->
        Log.d(TAG, "Requesting current location via LocationManager...")

        // 检查位置服务是否开启
        val isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
        val isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)

        Log.d(TAG, "GPS enabled: $isGpsEnabled, Network enabled: $isNetworkEnabled")

        if (!isGpsEnabled && !isNetworkEnabled) {
            continuation.resumeWithException(IllegalStateException("请开启GPS或网络定位服务"))
            return@suspendCoroutine
        }

        // 使用原子布尔值防止重复恢复 continuation
        val isCompleted = AtomicBoolean(false)

        // 创建位置监听器
        val locationListener = object : android.location.LocationListener {
            override fun onLocationChanged(location: Location) {
                Log.d(TAG, "Location received: lat=${location.latitude}, lng=${location.longitude}, provider=${location.provider}")
                if (isCompleted.compareAndSet(false, true)) {
                    Log.d(TAG, "Location completion: lat=${location.latitude}, lng=${location.longitude}")
                    locationManager.removeUpdates(this)
                    continuation.resume(location)
                }
            }

            @Deprecated("Deprecated in Java")
            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {
                Log.d(TAG, "Provider status changed: $provider, status: $status")
            }

            override fun onProviderEnabled(provider: String) {
                Log.d(TAG, "Provider enabled: $provider")
            }

            override fun onProviderDisabled(provider: String) {
                Log.d(TAG, "Provider disabled: $provider")
            }
        }

        // 创建错误完成函数
        fun completeWithError(message: String) {
            if (isCompleted.compareAndSet(false, true)) {
                Log.d(TAG, "Location error: $message")
                locationManager.removeUpdates(locationListener)
                continuation.resumeWithException(IllegalStateException(message))
            }
        }

        try {
            // 首先尝试网络定位（更快）
            if (isNetworkEnabled) {
                Log.d(TAG, "Requesting network location updates...")
                locationManager.requestLocationUpdates(
                    LocationManager.NETWORK_PROVIDER,
                    10000L, // 10秒
                    100f,   // 100米
                    locationListener
                )
            }

            // 同时请求GPS定位（更精确）
            if (isGpsEnabled) {
                Log.d(TAG, "Requesting GPS location updates...")
                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    10000L, // 10秒
                    100f,   // 100米
                    locationListener
                )
            }

            // 设置超时，30秒后如果没有收到位置，抛出异常
            GlobalScope.launch {
                delay(30000L)
                completeWithError("位置获取超时，请确保在开阔区域")
            }

        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception when requesting location updates", e)
            completeWithError("没有位置权限")
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting location updates", e)
            completeWithError("位置请求失败: ${e.message}")
        }
    }

    /**
     * 检查是否有位置权限
     */
    fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * 检查缓存是否有效
     */
    private fun isCacheValid(): Boolean {
        if (cachedWeather == null) return false
        val cacheAge = System.currentTimeMillis() - cacheTimestamp
        return cacheAge < CACHE_DURATION_MS
    }

    /**
     * 获取缓存的天气数据（如果存在）
     */
    fun getCachedWeather(): Weather? {
        return if (isCacheValid()) cachedWeather else null
    }

    /**
     * 清除缓存
     */
    fun clearCache() {
        cachedWeather = null
        cacheTimestamp = 0
        Log.d(TAG, "Cache cleared")
    }
}

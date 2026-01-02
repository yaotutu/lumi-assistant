package com.lumi.assistant.network

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.InetSocketAddress
import java.net.Socket
import java.net.URL
import javax.inject.Inject
import javax.inject.Singleton

private const val TAG = "NetworkHealthChecker"

/**
 * 健康检测结果
 */
data class HealthCheckResult(
    val internetConnected: Boolean = false,      // 互联网连接状态
    val serverReachable: Boolean = false,        // 服务器可达状态
    val lastCheckTime: Long = 0,                 // 最后检测时间
    val internetLatency: Int = -1,               // 互联网延迟(ms)
    val serverLatency: Int = -1,                 // 服务器延迟(ms)
    val errorMessage: String? = null             // 错误信息
)

/**
 * 网络健康检测器
 *
 * 功能：
 * 1. 检测互联网连接（ping 114.114.114.114）
 * 2. 检测语音助手服务器可达性
 */
@Singleton
class NetworkHealthChecker @Inject constructor() {

    /**
     * 执行完整的健康检测
     * @param serverWsUrl WebSocket 服务器地址（如 ws://192.168.100.100:8000/xiaozhi/v1/）
     */
    suspend fun performHealthCheck(serverWsUrl: String): HealthCheckResult = withContext(Dispatchers.IO) {
        Log.i(TAG, "🏥 开始健康检测...")
        Log.i(TAG, "📋 服务器配置: $serverWsUrl")

        // 1. 检测互联网连接（尝试连接百度 DNS）
        val internetCheck = checkTcpConnection("114.114.114.114", 53)
        Log.i(TAG, "🌐 互联网检测: ${if (internetCheck.success) "成功 (${internetCheck.latency}ms)" else "失败 - ${internetCheck.error}"}")

        // 2. 检测服务器可达性
        val serverHost = extractHost(serverWsUrl)
        val serverPort = extractPort(serverWsUrl)

        Log.i(TAG, "🔍 解析服务器: host=$serverHost, port=$serverPort")

        val serverCheck = if (serverHost != null && serverPort != null) {
            checkTcpConnection(serverHost, serverPort)
        } else {
            PingResult(success = false, latency = -1, error = "无效的服务器地址: $serverWsUrl")
        }
        Log.i(TAG, "🖥️ 服务器检测($serverHost:$serverPort): ${if (serverCheck.success) "成功 (${serverCheck.latency}ms)" else "失败 - ${serverCheck.error}"}")

        // 3. 返回检测结果
        HealthCheckResult(
            internetConnected = internetCheck.success,
            serverReachable = serverCheck.success,
            lastCheckTime = System.currentTimeMillis(),
            internetLatency = internetCheck.latency,
            serverLatency = serverCheck.latency,
            errorMessage = when {
                !internetCheck.success -> "网络连接失败：${internetCheck.error}"
                !serverCheck.success -> "服务器不可达：${serverCheck.error}"
                else -> null
            }
        )
    }

    /**
     * 使用 TCP Socket 连接测试网络可达性（更可靠）
     * @param host 主机 IP 或域名
     * @param port 端口号
     * @param timeout 超时时间（毫秒）
     * @return 连接测试结果
     */
    private suspend fun checkTcpConnection(
        host: String,
        port: Int,
        timeout: Int = 3000
    ): PingResult = withContext(Dispatchers.IO) {
        var socket: Socket? = null
        try {
            val startTime = System.currentTimeMillis()

            socket = Socket()
            socket.connect(InetSocketAddress(host, port), timeout)

            val endTime = System.currentTimeMillis()
            val latency = (endTime - startTime).toInt()

            Log.d(TAG, "✓ $host:$port 可达，延迟: ${latency}ms")
            PingResult(success = true, latency = latency)

        } catch (e: java.net.SocketTimeoutException) {
            Log.w(TAG, "✗ $host:$port 连接超时")
            PingResult(success = false, latency = -1, error = "连接超时")
        } catch (e: java.net.ConnectException) {
            Log.w(TAG, "✗ $host:$port 连接被拒绝: ${e.message}")
            PingResult(success = false, latency = -1, error = "连接被拒绝")
        } catch (e: java.net.UnknownHostException) {
            Log.e(TAG, "✗ $host DNS解析失败: ${e.message}")
            PingResult(success = false, latency = -1, error = "DNS解析失败")
        } catch (e: Exception) {
            Log.e(TAG, "✗ $host:$port 检测异常: ${e.message}", e)
            PingResult(success = false, latency = -1, error = e.message ?: "网络异常")
        } finally {
            try {
                socket?.close()
            } catch (e: Exception) {
                // 忽略关闭异常
            }
        }
    }

    /**
     * 从 WebSocket URL 中提取主机名
     * 例如：ws://192.168.100.100:8000/xiaozhi/v1/ -> 192.168.100.100
     */
    private fun extractHost(wsUrl: String): String? {
        return try {
            // 将 ws:// 或 wss:// 替换为 http:// 或 https://，方便 URL 解析
            val httpUrl = wsUrl.replace("ws://", "http://").replace("wss://", "https://")
            val url = URL(httpUrl)
            url.host
        } catch (e: Exception) {
            Log.e(TAG, "无法解析服务器地址: $wsUrl", e)
            null
        }
    }

    /**
     * 从 WebSocket URL 中提取端口号
     * 例如：ws://192.168.100.100:8000/xiaozhi/v1/ -> 8000
     */
    private fun extractPort(wsUrl: String): Int? {
        return try {
            // 将 ws:// 或 wss:// 替换为 http:// 或 https://，方便 URL 解析
            val httpUrl = wsUrl.replace("ws://", "http://").replace("wss://", "https://")
            val url = URL(httpUrl)
            // 如果 URL 中明确指定了端口，返回该端口；否则返回 null
            if (url.port != -1) {
                url.port
            } else {
                // 如果没有指定端口，根据协议返回默认端口
                when {
                    wsUrl.startsWith("wss://") -> 443
                    wsUrl.startsWith("ws://") -> 80
                    else -> null
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "无法解析端口: $wsUrl", e)
            null
        }
    }

    /**
     * Ping 结果
     */
    private data class PingResult(
        val success: Boolean,
        val latency: Int,        // 延迟（毫秒）
        val error: String? = null
    )
}

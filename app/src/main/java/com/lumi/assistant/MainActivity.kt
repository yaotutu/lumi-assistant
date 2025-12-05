package com.lumi.assistant

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.core.content.ContextCompat
import androidx.core.view.WindowCompat
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.compose.rememberNavController
import com.lumi.assistant.navigation.LumiNavGraph
import com.lumi.assistant.ui.theme.LumiassistantTheme
import com.lumi.assistant.viewmodel.VoiceAssistantViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    companion object {
        private const val TAG = "MainActivity"
    }

    private var allPermissionsGranted = false

    private val requestMultiplePermissionsLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        Log.d(TAG, "Permission request result: $permissions")
        allPermissionsGranted = permissions.values.all { it }

        if (allPermissionsGranted) {
            Log.i(TAG, "All permissions granted successfully")
            Toast.makeText(this, "权限已授予", Toast.LENGTH_SHORT).show()
        } else {
            val deniedPermissions = permissions.filter { !it.value }.keys
            val grantedPermissions = permissions.filter { it.value }.keys
            Log.w(TAG, "Some permissions denied - Denied: $deniedPermissions, Granted: $grantedPermissions")

            // 根据拒绝的权限类型提供不同的提示
            val message = when {
                deniedPermissions.any { it.contains("LOCATION") } ->
                    "需要位置权限才能获取天气信息；录音和电话状态权限用于语音唤醒功能"
                else ->
                    "需要录音和电话状态权限才能使用语音唤醒功能"
            }

            Toast.makeText(this, message, Toast.LENGTH_LONG).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "MainActivity onCreate started")
        super.onCreate(savedInstanceState)

        // 保持屏幕常亮
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        // 启用边到边显示 (Edge-to-Edge)
        enableEdgeToEdge()
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // 启用沉浸式全屏模式 (使用兼容性API)
        WindowCompat.getInsetsController(window, window.decorView)?.apply {
            // 隐藏系统状态栏和导航栏
            hide(androidx.core.view.WindowInsetsCompat.Type.statusBars())
            hide(androidx.core.view.WindowInsetsCompat.Type.navigationBars())
            // 允许用户从边缘滑动呼出系统栏
            systemBarsBehavior = androidx.core.view.WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }

        setContent {
            LumiassistantTheme {
                val navController = rememberNavController()
                val viewModel: VoiceAssistantViewModel = hiltViewModel()
                val state by viewModel.state.collectAsState()

                // 权限授予后初始化唤醒SDK
                LaunchedEffect(allPermissionsGranted, state.wakeupStatus) {
                    if (allPermissionsGranted && state.wakeupStatus == "未初始化") {
                        Log.i(TAG, "Initializing wakeup SDK...")
                        viewModel.initWakeup()
                    }
                }

                // 不使用 Scaffold 的 padding,让内容完全填充屏幕
                Scaffold(modifier = Modifier.fillMaxSize()) { _ ->
                    LumiNavGraph(
                        navController = navController,
                        viewModel = viewModel,
                        modifier = Modifier.fillMaxSize()
                    )
                }
            }
        }

        // 请求必要权限
        Log.d(TAG, "About to request permissions")
        requestPermissions()
        Log.d(TAG, "MainActivity onCreate completed")
    }

    /**
     * 请求必要权限(录音权限 + 电话状态权限 + 位置权限)
     */
    private fun requestPermissions() {
        val requiredPermissions = arrayOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        )

        Log.d(TAG, "Checking permissions...")
        requiredPermissions.forEach { permission ->
            val granted = ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
            Log.d(TAG, "Permission $permission: ${if (granted) "GRANTED" else "DENIED"}")
        }

        val permissionsToRequest = requiredPermissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (permissionsToRequest.isNotEmpty()) {
            Log.i(TAG, "Requesting missing permissions: $permissionsToRequest")
            requestMultiplePermissionsLauncher.launch(permissionsToRequest.toTypedArray())
        } else {
            Log.i(TAG, "All permissions already granted")
            allPermissionsGranted = true
        }
    }
}

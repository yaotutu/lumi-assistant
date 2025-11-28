plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.hilt.android)
    alias(libs.plugins.kotlin.kapt)
}

android {
    namespace = "com.lumi.assistant"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.lumi.assistant"
        minSdk = 24
        targetSdk = 35
        versionCode = System.getenv("VERSION_CODE")?.toIntOrNull() ?: 1
        versionName = System.getenv("VERSION_NAME") ?: "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // Native 库架构配置
        // AIKit.aar 仅支持 ARM 架构，因此只打包 ARM 版本
        ndk {
            // arm64-v8a: 2019年后的主流手机 (64位)
            // armeabi-v7a: 2019年前的老旧手机 (32位)
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
    }

    signingConfigs {
        create("release") {
            // 从环境变量读取签名配置（用于 CI/CD）
            storeFile = System.getenv("RELEASE_KEYSTORE_PATH")?.let { file(it) }
            storePassword = System.getenv("RELEASE_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("RELEASE_KEY_ALIAS")
            keyPassword = System.getenv("RELEASE_KEY_PASSWORD")
        }
    }

    // APK 分割配置 - 为不同架构生成独立 APK
    splits {
        abi {
            isEnable = true
            reset()
            include("arm64-v8a", "armeabi-v7a")
            isUniversalApk = true  // 同时生成一个包含所有架构的通用 APK
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 仅在签名配置完整时启用签名
            if (System.getenv("RELEASE_KEYSTORE_PATH") != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
    buildFeatures {
        compose = true
    }
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.material.icons.extended)

    // WebSocket
    implementation(libs.okhttp)

    // ViewModel for Compose
    implementation(libs.androidx.lifecycle.viewmodel.compose)

    // DataStore for preferences
    implementation(libs.androidx.datastore.preferences)

    // Hilt - Dependency Injection
    implementation(libs.hilt.android)
    kapt(libs.hilt.compiler)
    implementation(libs.androidx.hilt.navigation.compose)

    // Navigation Compose
    implementation(libs.androidx.navigation.compose)

    // Opus Codec for audio decoding - JNI wrapper (local AAR)
    implementation(files("libs/opus.aar"))

    // iFlytek AIKit for voice wakeup - local AAR
    implementation(files("libs/AIKit.aar"))

    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.ui.test.junit4)
    debugImplementation(libs.androidx.ui.tooling)
    debugImplementation(libs.androidx.ui.test.manifest)
}
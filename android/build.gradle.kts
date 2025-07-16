allprojects {
    repositories {
        // 使用国内镜像源，优先级更高
        maven { 
            url = uri("https://maven.aliyun.com/repository/google") 
            isAllowInsecureProtocol = false
        }
        maven { 
            url = uri("https://maven.aliyun.com/repository/public") 
            isAllowInsecureProtocol = false
        }
        maven { 
            url = uri("https://maven.aliyun.com/repository/central") 
            isAllowInsecureProtocol = false
        }
        maven { 
            url = uri("https://maven.aliyun.com/repository/gradle-plugin") 
            isAllowInsecureProtocol = false
        }
        maven { 
            url = uri("https://jitpack.io") 
            isAllowInsecureProtocol = false
        }
        
        // 原始仓库作为备用
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

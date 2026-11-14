import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Release 签名（TODO K7 · 决策 D118）────────────────────────────────────────
// key.properties 与 *.jks 都被 android/.gitignore 忽略，绝不入库。
// 缺失时**回退 debug 签名**，让 `flutter run --release` 在本地仍然可用；
// 代价是产物不可上架，因此这里必须把话说得足够响，避免「以为签了」。
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
} else {
    logger.warn(
        "================================================================\n" +
            "  android/key.properties 不存在 —— release 将使用 DEBUG KEY 签名。\n" +
            "  这个产物【不可上架】，仅供本地 flutter run --release 使用。\n" +
            "  生成发布密钥： powershell -File scripts/gen_keystore.ps1\n" +
            "================================================================"
    )
}

android {
    namespace = "com.lingdesign.careerly"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // 决策 D118：发布后永久不可改。见 docs/05_progress/TODO.md §3.2。
        applicationId = "com.lingdesign.careerly"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

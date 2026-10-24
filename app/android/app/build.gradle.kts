import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// `key.properties` is gitignored, so it is absent in a fresh clone. The read is
// guarded so debug builds configure without it; a release build without it fails
// at task-graph time instead of silently signing with the debug key, which Play
// rejects at upload (same rule as Amethyst). `doctor --fix` writes a template
// from key.properties.example. See docs/release-workflow.md.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}
val hasReleaseKeystore =
    listOf("keyAlias", "keyPassword", "storeFile", "storePassword").all {
        !keystoreProperties.getProperty(it).isNullOrBlank()
    }

if (!hasReleaseKeystore) {
    gradle.taskGraph.whenReady {
        val releaseTask = allTasks.firstOrNull {
            it.project.path == ":app" &&
                it.name.contains("Release") &&
                (it.name.startsWith("assemble") || it.name.startsWith("bundle"))
        }
        if (releaseTask != null) {
            throw GradleException(
                "android/key.properties is missing or incomplete, so ':app:" +
                    "${releaseTask.name}' would sign with the debug key. Run " +
                    "`doctor --fix` for a template, fill it in, or build a debug variant.",
            )
        }
    }
}

android {
    namespace = "com.jinisolutions.capdebour"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // The Play identity, permanent from its first upload (owner ruling 2026-10-25).
        applicationId = "com.jinisolutions.capdebour"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
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
            // The debug fallback only lets configuration succeed without a keystore;
            // the task-graph check above stops any release task before it runs.
            signingConfig = signingConfigs.getByName(if (hasReleaseKeystore) "release" else "debug")
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

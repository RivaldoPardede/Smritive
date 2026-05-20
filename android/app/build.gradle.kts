plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smritive"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.smritive"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ── Build Variants ───────────────────────────────────────────────────────
    // Defines two product flavors: free and paid.
    // Usage:
    //   flutter run --flavor free  --dart-define=FLAVOR=free
    //   flutter run --flavor paid  --dart-define=FLAVOR=paid
    //
    // The `dimension` field is required when using productFlavors in Gradle.
    flavorDimensions += "tier"

    productFlavors {
        create("free") {
            dimension = "tier"
            applicationIdSuffix = ".free"
            versionNameSuffix = "-free"
            // app_name + launcher icons supplied by android/app/src/free/res/
        }
        create("paid") {
            dimension = "tier"
            // No suffix for the paid (full) variant — this is the canonical app.
            // app_name + launcher icons supplied by android/app/src/paid/res/
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Exclude LiteRT to avoid duplicate classes with TensorFlow Lite
configurations.all {
    exclude(group = "com.google.ai.edge.litert", module = "litert-api")
    exclude(group = "com.google.ai.edge.litert", module = "litert-gpu")
    exclude(group = "com.google.ai.edge.litert", module = "litert")
}

android {
    namespace = "ar.com.digipad"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        viewBinding = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ar.com.digipad"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
        minSdk = flutter.minSdkVersion // flutter.minSdkVersion = 24; overridden to 23 in afterEvaluate below
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    aaptOptions {
        noCompress ("tflite")
        noCompress ("lite")
    }

}

flutter {
    source = "../.."
}

// flutter.minSdkVersion = 24 (hardcoded in FlutterExtension.kt).
// AGP injects defaultConfig.minSdk into the merged manifest, overriding the manifest value.
// finalizeDsl fires JUST before AGP locks the DSL — this is the last safe moment to override.
// Required for Lenovo YT3 X50F (Android 6.0.1, API 23).
androidComponents {
    finalizeDsl { ext ->
        ext.defaultConfig.minSdk = 23
    }
}

dependencies {
    // TensorFlow Lite dependencies for YOLOv8 Detector
    implementation("org.tensorflow:tensorflow-lite:2.14.0")
    implementation("org.tensorflow:tensorflow-lite-support:0.4.4")
    implementation("org.tensorflow:tensorflow-lite-gpu:2.14.0")
    
    // CameraX dependencies for YOLOv8Activity
    val cameraxVersion = "1.3.1"
    implementation("androidx.camera:camera-camera2:${cameraxVersion}")
    implementation("androidx.camera:camera-lifecycle:${cameraxVersion}")
    implementation("androidx.camera:camera-view:${cameraxVersion}")
    
    // AndroidX dependencies
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    
    // Guava for ListenableFuture (required by CameraX)
    implementation("com.google.guava:guava:31.1-android")
    
    // Fix for CallbackToFutureAdapter not found
    implementation("androidx.concurrent:concurrent-futures:1.1.0")

    implementation ("androidx.exifinterface:exifinterface:1.3.7")
    
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}

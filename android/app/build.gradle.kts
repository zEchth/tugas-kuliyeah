plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.task_tracking"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // compileOptions {
    //     sourceCompatibility = JavaVersion.VERSION_11
    //     targetCompatibility = JavaVersion.VERSION_11
    // }

    // ubah
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // ubah
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.task_tracking"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
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

}

// tambah ini
dependencies {
   coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

   // Import the Firebase BoM
   implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
   implementation("com.google.firebase:firebase-messaging")
   
   // TODO: Add the dependencies for Firebase products you want to use
   // When using the BoM, don't specify versions in Firebase dependencies
   implementation("com.google.firebase:firebase-analytics")


  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}

kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}


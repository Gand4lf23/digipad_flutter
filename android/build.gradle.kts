buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.3")
    classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.0")
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
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

    configurations.all {
        resolutionStrategy {
            force("androidx.concurrent:concurrent-futures:1.1.0")
        }
    }

    plugins.withId("com.android.library") {
        dependencies {
            add("implementation", "androidx.concurrent:concurrent-futures:1.1.0")
        }
    }

    plugins.withId("com.android.application") {
        dependencies {
            add("implementation", "androidx.concurrent:concurrent-futures:1.1.0")
        }
    }

}

// gradle.afterProject fires for each project AFTER it's fully evaluated (including libraries).
// This ensures minSdk=23 wins over "minSdkVersion flutter.minSdkVersion" (= 24 hardcoded in
// FlutterExtension.kt). Required for Lenovo YT3 X50F (Android 6.0.1, API 23).
gradle.afterProject {
    if (this == rootProject) return@afterProject
    val android = extensions.findByName("android") ?: return@afterProject
    try {
        val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
        val methods = defaultConfig.javaClass.methods
        val setMinSdk = methods.find { it.name == "setMinSdk" && it.parameterCount == 1 }
            ?: methods.find { it.name == "setMinSdkVersion" && it.parameterCount == 1 }
        setMinSdk?.invoke(defaultConfig, 23)
    } catch (e: Exception) {
        // Non-fatal
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

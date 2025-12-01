buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.3")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.25")
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

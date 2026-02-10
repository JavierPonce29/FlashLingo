// Importamos las extensiones de Android
import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
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

// --- SOLUCIÓN ROBUSTA PARA ISAR ---
subprojects {
    if (project.name == "isar_flutter_libs") {
        // Definimos la acción de corrección
        val applyNamespace = {
            project.extensions.configure<LibraryExtension> {
                namespace = "dev.isar.isar_flutter_libs"
            }
        }

        // VERIFICACIÓN DE ESTADO:
        // Si el proyecto ya terminó de evaluarse, aplicamos el cambio directamente.
        // Si no, esperamos a que termine con afterEvaluate.
        if (project.state.executed) {
            applyNamespace()
        } else {
            project.afterEvaluate { applyNamespace() }
        }
    }
}
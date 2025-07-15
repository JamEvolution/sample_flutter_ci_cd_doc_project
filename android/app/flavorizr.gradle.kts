import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.example.sample.dev"
            resValue(type = "string", name = "app_name", value = "Dev-Sample-App")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.example.sample.prod"
            resValue(type = "string", name = "app_name", value = "Prod-Sample-App")
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.example.sample.staging"
            resValue(type = "string", name = "app_name", value = "Staging-Sample-App")
        }
    }
}
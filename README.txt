1). Open the Android project and go to the MapView module, then select MapViewPlugin.kt inside the java folder (This should be the file path: /.pub-cache/hosted/pub.dartlang.org/map_view-0.0.14/android/src/main/kotlin/com/apptreesoftware/mapview/MapViewPlugin.kt)
2). If you are using Android Studio you will already see red warnings. Go to line 168 where you'll find `                val cameraDict = mapOptions["cameraPosition"] as Map<String, Any>`

3). Change it to this `val cameraDict = mapOptions!!["cameraPosition"] as Map<String, Any>`

change Dependencies

    dependencies {
        classpath 'com.android.tools.build:gradle:3.1.0'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.2.50'

1.) SET gradle.properties
android.enableJetifier=true
android.useAndroidX=true
org.gradle.jvmargs=-Xmx1536M

2.)Replace project.evaluationDependsOn(':app')
WITH project.configurations.all {
    resolutionStrategy.eachDependency { details ->
    if (details.requested.group == 'com.android.support'
            && !details.requested.name.contains('multidex') ) {
                details.useVersion "26.1.0"
        }
    }
    }
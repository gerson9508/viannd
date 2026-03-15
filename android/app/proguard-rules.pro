# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keepclassmembers class com.dexterous.** { *; }
-keep class androidx.core.app.** { *; }
-keep class androidx.core.content.** { *; }

# Timezone
-keep class org.joda.** { *; }
-keep class net.time4j.** { *; }
-dontwarn net.time4j.**
-dontwarn org.joda.**

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Serialization / JSON
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod
-keepclassmembers class ** {
    @android.webkit.JavascriptInterface <methods>;
}

# Gson
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# General Android
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.**
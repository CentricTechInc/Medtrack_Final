# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep all Agora SDK classes
-keep class io.agora.**{*;}
-dontwarn io.agora.**

# Keep permission handler classes
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core library
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Common Android rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Remove debug logs
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
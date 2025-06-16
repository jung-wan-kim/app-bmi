# BMI Tracker ProGuard 설정
# 앱 크기 최적화 및 난독화를 위한 설정

# Flutter 관련 설정
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase 관련 설정
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }
-dontwarn io.supabase.**

# HTTP 클라이언트 관련
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# JSON 직렬화 관련
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# 모델 클래스 보호 (JSON 직렬화 때문에)
-keep class com.example.app_bmi.models.** { *; }

# Riverpod 관련
-keep class com.riverpod.** { *; }

# 리플렉션 사용 클래스 보호
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# 네이티브 메서드 보호
-keepclasseswithmembernames class * {
    native <methods>;
}

# 열거형 보호
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 일반적인 최적화 설정
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

# 로그 제거 (릴리즈 빌드에서)
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# 디버그 정보 유지 (크래시 리포트용)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
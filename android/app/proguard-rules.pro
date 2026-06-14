# ── Razorpay ─────────────────────────────────────────────────────────────────
# Keep the SDK and the payment callbacks it invokes via reflection. Required
# only when code shrinking (R8/ProGuard) is enabled — see build.gradle.kts.
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** { *; }
-optimizations !method/inlining/*
-keepclasseswithmembers class * {
  public void onPayment*(...);
}
# Razorpay pulls in the Google Pay / ProGuard annotation classes.
-keep class proguard.annotation.** { *; }
-dontwarn proguard.annotation.**

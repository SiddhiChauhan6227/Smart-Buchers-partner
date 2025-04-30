# Razorpay SDK - Keep everything in the package
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Fix for missing annotations used in Razorpay
#-keep @interface proguard.annotation.Keep
#-keep @interface proguard.annotation.KeepClassMembers
#-dontwarn proguard.annotation.Keep
#-dontwarn proguard.annotation.KeepClassMembers

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Widget למסך הבית (home_widget)
-keep class es.antonborri.home_widget.** { *; }
-keep class com.eliavital.wedding_countdown.** { *; }

# Play Core (רכיבים נדחים של Flutter) — לא בשימוש, מונע אזהרות R8
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

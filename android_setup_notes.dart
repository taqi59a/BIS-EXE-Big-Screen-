// This file configures the Android-specific build settings.
// Run `flutter create .` in the project root to generate the full android/ folder,
// then apply these configurations to the generated files:

// ── android/app/src/main/AndroidManifest.xml ──
// Add these permissions INSIDE <manifest> before <application>:
//
//   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
//   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
//   <uses-permission android:name="android.permission.WAKE_LOCK"/>
//   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
//
// Inside <activity> tag add:
//
//   android:screenOrientation="landscape"
//   android:keepScreenOn="true"
//   android:showWhenLocked="true"
//   android:turnScreenOn="true"
//   android:configChanges="orientation|screenSize"
//
// ── android/app/build.gradle ──
// Set:
//   minSdkVersion 21
//   targetSdkVersion 34
//   compileSdkVersion 34
//
// ── Notes ──
// • After running `flutter create .`, place .mp3 files into:
//   /sdcard/BISL_Display/music/
// • Place school logo as: assets/images/logo.png
// • Place background ambient tracks in: assets/music/

# NeverMindSpark — Store Submission Checklist

Everything below is Android-first (the app runs on Android today). iOS folder
exists but is not yet configured for stores.

## 1. Replace test AdMob credentials (REQUIRED)

All IDs in the code right now are Google's official **test** IDs. Store builds
will NOT serve real ads (and may be rejected) until you swap them for your own.

- `android/app/src/main/AndroidManifest.xml` → `com.google.android.gms.ads.APPLICATION_ID`
  (currently `ca-app-pub-3940256099942544~3347511713`)
- `lib/services/ads_service.dart` → `AdConfig.bannerUnitId` / `AdConfig.rewardedUnitId`

Create a real app in the AdMob console (`apps.admob.com`), then:
1. Register the Android App ID (`com.nevermindspark.app.nevermindspark`).
2. Create Banner (adaptive) and Rewarded ad units.
3. Put the App ID in the manifest and the two unit IDs in `AdConfig`.

## 2. iOS (only when you target iOS)

- `ios/Runner/Info.plist`: add `GADApplicationIdentifier` with the AdMob App ID.
- `flutter_local_notifications` needs nothing special on iOS beyond the runtime
  permission request, which the app already handles.

## 3. Release signing (Android)

`android/app/build.gradle.kts` currently signs **release** builds with the debug
key. Before Play Store submission:

```kotlin
signingConfigs {
    create("release") {
        storeFile = file("path/to/your-upload-keystore.jks")
        storePassword = "..."
        keyAlias = "..."
        keyPassword = "..."
    }
}
buildTypes {
    release { signingConfig = signingConfigs.getByName("release") }
}
```

Then build the artifact:
`flutter build appbundle` → `build/app/outputs/bundle/release/app-release.aab`

## 4. App identity & store listing

- Display name on Android is already `NeverMindSpark` (manifest label). On iOS it's
  the default project name; update `ios/Runner/Info.plist` CFBundleDisplayName.
- App version/name live in `pubspec.yaml` (`1.0.0+1`).
- Play Console listing needs: app icon (`flutter_launcher_icons` or custom),
  feature graphic, 4–8 screenshots, short + full description, category,
  content rating questionnaire, privacy policy URL.

## 5. Data safety / privacy (ads)

You distribute ads, so in Google Play's *Data safety* form:
- Collection: third-party ad SDKs collect device ID + ad ID, request records.
- Sharing: yes, with the ad provider (Google).
- Link to a privacy policy that states ad SDK usage.
- Same applies to App Store privacy labels (Apple Advertising identifier).

## 6. Notifications permission

- `android.permission.POST_NOTIFICATIONS` is already declared. Runtime flow:
  Onboarding/Settings toggle requests it. If the user denies, the reminder simply
  won't fire — the app handles this gracefully.
- For the Play rating questionnaire, notifications usage is "user-facing features
  (optional daily reminder)".

## 7. Final verification before upload

```sh
flutter analyze                       # must be: No issues found!
flutter test                          # must be: All tests passed!
flutter build appbundle --release     # after signing config
```

Manual smoke test on a real device across the full flow:
onboarding → 5-question run → results (+ reward) → stats/badges → settings →
daily notification fires.

## Build-environment notes (this machine)

This network blocks `dl.google.com` and `pub.dev`. The repo is configured to cope:

- `pubspec.lock`/mirror: pub uses the Flutter-io.cn mirror (PVC-cache under
  `~/.pub-cache/hosted/pub.flutter-io.cn`).
- `android/settings.gradle.kts` + `android/build.gradle.kts` use the Tencent Nexus
  mirror instead of `google()`.
- `android/app/build.gradle.kts` pins `ndkVersion = "27.1.12297006"` (Flutter's
  preferred 28.x isn't downloadable here).
- The pub-cache copies of several plugin `android/build.gradle` files were patched
  in place to use the mirror (flutter_local_notifications, flutter_timezone,
  google_mobile_ads, jni, jni_flutter, webview_flutter_android). These patches are
  local and won't survive a cache flush.
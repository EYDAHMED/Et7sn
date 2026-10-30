# Et7sn - Fitness, Nutrition & Prayer app (Flutter + Firebase)

Bilingual (Arabic / English, full RTL), username + password accounts (no e-mail),
calorie & macro engine with a meal "Skip" button, GPS prayer times with a live
countdown, weekly weight leaderboard, and a super admin dashboard.

## Folder structure

```
lib/
  main.dart                      app entry, providers, localization, themes
  l10n/                          app_localizations.dart, app_en.dart, app_ar.dart
  models/                        user_profile, meal, nutrition, prayer, leaderboard_entry, weight_entry
  services/                      auth, firestore, nutrition (BMR/TDEE/macros), meal_planner, prayer, location
  providers/                     session, settings, diet, prayer (state)
  data/                          ingredient_catalog, meal_library (local, affordable foods; EN + AR)
  screens/                       auth_gate, auth/login, onboarding, home_shell, diet, prayer,
                                 leaderboard, profile, edit_profile, admin/
  widgets/                       shared UI pieces
  theme/                         app_colors, app_theme (light + dark, olive green)
firestore.rules  firestore.indexes.json  firebase.json
android_overrides/AndroidManifest.xml    setup_android.py
```

## 1. Create the Firebase project (5 min)

1. https://console.firebase.google.com -> **Add project** (name it Et7sn).
2. **Build > Authentication > Get started > Sign-in method > Email/Password > Enable.**
   (The app builds a private internal address from the username, so users never see an e-mail.)
3. **Build > Firestore Database > Create database** (production mode, pick a nearby region).
4. **Firestore > Rules** tab: paste the contents of `firestore.rules` and **Publish**.
5. **Project settings > Your apps > Add app > Android.** Package name: `com.et7sn.et7sn`.
   Download **google-services.json**.

## 2. Build the Android project

Install Flutter (https://docs.flutter.dev/get-started/install) and run `flutter doctor`.

```bash
cd et7sn
flutter create --org com.et7sn --project-name et7sn --platforms android .
python3 setup_android.py                 # manifest, Firebase plugin, minSdk 23
cp /path/to/google-services.json android/app/google-services.json
flutter pub get
flutter run                              # optional: test on a phone / emulator
```

## 3. Make yourself the Super Admin

1. Open the app, **create your account**, and finish the profile screen.
2. Firebase console > Authentication > Users: copy your **User UID**.
3. Firestore > **Start collection** `admins` > Document ID = your UID > add any field
   (for example `role` = `super`) > Save.
4. Reopen the app: an **Admin** tab appears with every user, their profile data,
   weight updates and weekly progress, live.

## 4. Build the APK and share it on WhatsApp

```bash
flutter build apk --release --split-per-abi
```

The files are in `build/app/outputs/flutter-apk/`. Send **`app-arm64-v8a-release.apk`**
(works on almost every modern phone; use `app-armeabi-v7a-release.apk` for very old phones).
Or build one universal file with `flutter build apk --release`.

Share on WhatsApp: attach it as a **Document** (paperclip > Document), not as media.
Friends open it and tap **Install**; Android asks once to "allow installs from this source".
WhatsApp sometimes refuses `.apk` files directly. If so, rename it to `Et7sn.apk.zip` and tell
them to rename it back, or upload to Google Drive and share the link.

The release build is signed with Flutter's debug key, which is fine for sharing directly.
Always install new versions over the old one from the same build machine so it updates cleanly.

## Notes

- There is no password reset (no e-mail on file). If someone forgets their password, delete
  their user in Firebase Authentication and let them register again.
- Weeks start on Saturday. Users update their weight once a week from the Leaderboard or Profile tab.
- Prayer times are calculated on the device from GPS (the `adhan` library), so they work offline
  after the first location fix. Calculation method can be changed in Profile > Settings.

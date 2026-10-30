#!/usr/bin/env python3
"""Prepares the Android side of Et7sn after `flutter create`.

Run from the project root:   python3 setup_android.py

It (1) installs the Et7sn AndroidManifest (internet + GPS permissions, app name),
(2) adds the Google Services (Firebase) Gradle plugin, (3) sets minSdk to 23 and
(4) removes the default sample test. Running it twice is safe.
"""
import pathlib
import re
import shutil
import sys

root = pathlib.Path(__file__).resolve().parent
android = root / "android"
if not android.is_dir():
    sys.exit("android/ folder not found. Run: flutter create --org com.et7sn "
             "--project-name et7sn --platforms android .")

# 1. Manifest
shutil.copy(root / "android_overrides" / "AndroidManifest.xml",
            android / "app" / "src" / "main" / "AndroidManifest.xml")
print("OK  AndroidManifest.xml installed")

# 2. Google Services plugin: settings.gradle.kts
settings = android / "settings.gradle.kts"
app_gradle = android / "app" / "build.gradle.kts"
if not settings.exists() or not app_gradle.exists():
    sys.exit("Expected Kotlin Gradle files (settings.gradle.kts / app/build.gradle.kts). "
             "Use a recent Flutter version (3.35 or newer).")

text = settings.read_text()
if "com.google.gms.google-services" not in text:
    pattern = re.compile(r'(\n[ \t]*id\("com\.android\.application"\)[^\n]*)')
    if not pattern.search(text):
        sys.exit("Could not find the com.android.application plugin line in settings.gradle.kts")
    text = pattern.sub(
        r'\1\n    id("com.google.gms.google-services") version "4.4.2" apply false',
        text, count=1)
    settings.write_text(text)
print("OK  settings.gradle.kts patched")

# 3. app/build.gradle.kts
text = app_gradle.read_text()
if "com.google.gms.google-services" not in text:
    pattern = re.compile(r'(\n[ \t]*id\("dev\.flutter\.flutter-gradle-plugin"\))')
    if not pattern.search(text):
        sys.exit("Could not find the Flutter Gradle plugin line in app/build.gradle.kts")
    text = pattern.sub(r'\1\n    id("com.google.gms.google-services")', text, count=1)
text = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 23', text)
app_gradle.write_text(text)
print("OK  app/build.gradle.kts patched (Firebase plugin, minSdk 23)")

# 4. Remove the default sample test (it references a widget that does not exist here)
sample = root / "test" / "widget_test.dart"
if sample.exists():
    sample.unlink()
    print("OK  removed sample test")

if not (android / "app" / "google-services.json").exists():
    print("\nWARNING: android/app/google-services.json is missing.\n"
          "Download it from Firebase console > Project settings > Your apps (Android)\n"
          "and put it in android/app/ before building.")

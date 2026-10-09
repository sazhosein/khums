<div dir="rtl">

# ساخت فایل APK برای «خمس‌یار»

پوشه `android/` پروژه کامل است و آماده build. این سند سه راه برای گرفتن
APK توضیح می‌دهد.

---

## راه ۱ — خودکار در گیت‌هاب (بدون نیاز به هیچ نصبی)

فایل workflow آماده است اما برای فعال‌سازی، توکن باید اسکوپ **`workflow`**
داشته باشد (گیت‌هاب اجازه نمی‌دهد توکن بدون این اسکوپ فایل CI را تغییر دهد).

### گام ۱: توکن با اسکوپ workflow بسازید
1. به https://github.com/settings/tokens بروید
2. توکن فعلی را حذف (revoke) کنید
3. **Generate new token (classic)** بزنید
4. اسکوپ‌ها را تیک بزنید: **`repo`** و **`workflow`**
5. توکن را کپی کنید

### گام ۲: فایل workflow را فعال کنید
فایل `ci/build-apk.yml.template` را در مخزن به مسیر زیر منتقل کنید:
```
.github/workflows/build-apk.yml
```
این کار را می‌توانید از رابط وب گیت‌هاب انجام دهید:
1. در مخزن → **Add file** → **Create new file**
2. نام فایل: `.github/workflows/build-apk.yml`
3. محتوای `ci/build-apk.yml.template` را کپی و پیست کنید
4. **Commit changes**

> یا اگر توکن با اسکوپ `workflow` دارید، دستور زیر کار را انجام می‌دهد:
> ```bash
> git mv ci/build-apk.yml.template .github/workflows/build-apk.yml
> git commit -m "ci: enable APK build workflow"
> git push
> ```

### گام ۳: منتظر بمانید و APK را بردارید
- به تب **Actions** مخزن بروید — workflow «Build APK» خودکار اجرا می‌شود
- پس از ~۵ دقیقه، به تب **Releases** بروید
- فایل‌های APK آنجا هستند:
  - `khumsyar-universal.apk` — نصب روی هر گوشی (پیشنهادی)
  - `khumsyar-arm64.apk` — گوشی‌های مدرن
  - `khumsyar-arm32.apk` — گوشی‌های قدیمی‌تر
  - `khumsyar-x86_64.apk` — شبیه‌سازها

> همچنین در تب Actions → run → **Artifacts** هم قابل دانلود است.

---

## راه ۲ — ساخت روی کامپیوتر خودتان

نیازمندی‌ها: Flutter SDK 3.24+، Android Studio (با Android SDK 35)، JDK 17

### روش سریع (اسکریپت)
```powershell
cd flutter_app
.\build_apk.ps1
```

### روش دستی
```bash
cd flutter_app
flutter pub get
flutter build apk --release
```
خروجی: `flutter_app/build/app/outputs/flutter-apk/app-release.apk`

برای نسخه‌های جداگانه بر اساس معماری:
```bash
flutter build apk --release --split-per-abi
```

---

## راه ۳ — ساخت با امضای رسمی (برای Google Play)

APK ساخته‌شده با کلید debug امضا می‌شود و برای **تست و توزیع غیررسمی**
مناسب است. برای انتشار در Google Play:

### گام ۱: ساخت keystore
```bash
keytool -genkey -v -keystore khumsyar-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias khumsyar
```

### گام ۲: فایل `android/key.properties`
```properties
storePassword=<رمز شما>
keyPassword=<رمز کلید>
keyAlias=khumsyar
storeFile=../khumsyar-release.jks
```

### گام ۳: فعال‌سازی امضا در `android/app/build.gradle`
بخش `buildTypes.release` را به این تغییر دهید:
```gradle
release {
    signingConfig signingConfigs.release
    minifyEnabled true
    shrinkResources true
}
```
و در `android { }` اضافه کنید:
```gradle
signingConfigs {
    release {
        def keyProps = new Properties()
        keyProps.load(new FileInputStream(rootProject.file("key.properties")))
        storeFile file(keyProps["storeFile"])
        storePassword keyProps["storePassword"]
        keyAlias keyProps["keyAlias"]
        keyPassword keyProps["keyPassword"]
    }
}
```

> ⚠️ فایل‌های `key.properties` و `*.jks` در `.gitignore` هستند و
> هرگز کامیت نمی‌شوند.

### گام ۴: ساخت App Bundle (فرمت موردنیاز Play)
```bash
flutter build appbundle --release
```

---

## مشخصات تنظیم‌شده در پروژه

| مورد | مقدار |
|------|-------|
| applicationId | `app.khumsyar.khums_yar` |
| minSdk | 23 (Android 6.0) |
| targetSdk / compileSdk | 35 |
| Java / Kotlin JVM | 17 |
| Gradle | 8.9 |
| Android Gradle Plugin | 8.7.0 |
| Kotlin | 1.9.24 |
| دسترسی‌های خاص | POST_NOTIFICATIONS، SCHEDULE_EXACT_ALARM، RECEIVE_BOOT_COMPLETED |
| Deep link | `khumsyar://payment/...` برای بازگشت از درگاه |

---

## عیب‌یابی

| خطا | راه‌حل |
|------|--------|
| `flutter.sdk not set` | فایل `android/local.properties` بسازید: `flutter.sdk=<مسیر Flutter>` |
| `SDK location not found` | `sdk.dir=<مسیر Android SDK>` در `local.properties` |
| خطای NDK | `flutter doctor --android-licenses` و نصب NDK 27.0.12077973 |
| `minSdk` بالاتر لازم است | در `build.gradle` مقدار `minSdk` را افزایش دهید |
| APK نصب نمی‌شود | نسخه debug و release نمی‌توانند همزمان نصب شوند (`applicationIdSuffix`) |

</div>

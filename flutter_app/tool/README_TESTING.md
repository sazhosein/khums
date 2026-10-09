<div dir="rtl">

# راهنمای تست موتور محاسبه (بدون Flutter)

پوشه `tool/` شامل ابزارهایی برای اجرای منطق محاسبه اپ در محیطی است که
`Flutter SDK` نصب نیست. این ابزارها **بخشی از توزیع اپ نیستند**.

## فایل‌ها

| فایل | کاربرد |
|------|--------|
| `verify_calculator.dart` | تست مستقل منطق محاسبه (۱۳ تست) — بدون هیچ وابستگی |
| `run_real_calculator.dart` | اجرای موتور محاسبه **واقعی** اپ (نیازمند محیط تحلیل) |
| `run_real_calculator_file.dart` | مانند بالا، ولی خروجی UTF-8 در فایل می‌نویسد |

## اجرای تست مستقل (ساده‌ترین راه)

نیاز به هیچ تنظیم اضافه‌ای ندارد:

```bash
cd flutter_app
dart run tool/verify_calculator.dart
```

خروجی: `موفق: 13   ناموفق: 0`

## اجرای کد واقعی اپ (models + khums_calculator)

فایل‌های مدل به `package:flutter/foundation.dart` وابسته‌اند (برای
انوتیشن `@immutable`). برای اجرای آفلاین، یک محیط تحلیل موقت می‌سازیم
که `package:flutter` را به یک stub حداقلی نگاشت می‌کند:

### گام ۱ — ساخت محیط موقت
```bash
mkdir /tmp/khums_verify && cd /tmp/khums_verify
mkdir -p lib stub/flutter .dart_tool
cp -r <path-to>/flutter_app/lib/models lib/
cp -r <path-to>/flutter_app/lib/services lib/
cp -r <path-to>/flutter_app/lib/data lib/
```

### گام ۲ — stub حداقلی
`stub/flutter/foundation.dart`:
```dart
library flutter.foundation;

class _Immutable {
  const _Immutable();
}

const Object immutable = _Immutable();
```

### گام ۳ — pubspec و package_config
`pubspec.yaml`:
```yaml
name: khums_verify
publish_to: none
environment:
  sdk: ">=3.3.0 <4.0.0"
```

`.dart_tool/package_config.json` (باید **بدون BOM** و UTF-8 باشد):
```json
{
  "configVersion": 2,
  "packages": [
    { "name": "flutter", "rootUri": "../stub/flutter", "packageUri": ".", "languageVersion": "3.0" },
    { "name": "khums_verify", "rootUri": "../", "packageUri": "lib/", "languageVersion": "3.0" }
  ]
}
```

### گام ۴ — اجرا
```bash
# تحلیل (باید "No issues found!" بدهد)
dart analyze lib/models/khums_input.dart lib/services/khums_calculator.dart

# اجرا — مسیرهای import را از '../lib/' به '' تغییر دهید
dart run lib/run_real.dart
```

## نکات مهم

- **کدپیج ترمینال:** برای نمایش صحیح فارسی در ویندوز،
  `chcp 65001` را اجرا کنید یا خروجی را در فایل بنویسید.
- این روش فقط برای **منطق خالص Dart** است. صفحات UI و ویجت‌ها نیازمند
  `Flutter SDK` واقعی هستند:
  ```bash
  flutter pub get && flutter analyze && flutter test
  ```

</div>

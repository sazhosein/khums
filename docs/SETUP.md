<div dir="rtl">

# راهنمای نصب و راه‌اندازی «خمس‌یار»

این سند مراحل کامل راه‌اندازی اپ Flutter و بک‌اند Node.js/PostgreSQL را
توضیح می‌دهد.

---

## ۱. پیش‌نیازها

| ابزار | نسخه پیشنهادی |
|-------|----------------|
| Flutter SDK | 3.3 یا بالاتر |
| Dart | همراه Flutter |
| Node.js | 20 LTS یا بالاتر |
| PostgreSQL | 15 یا بالاتر |
| Git | آخرین نسخه |

بررسی نصب:
```bash
flutter doctor
node --version
psql --version
```

---

## ۲. راه‌اندازی بک‌اند

### ۲.۱ ساخت دیتابیس
```bash
psql -U postgres
```
```sql
CREATE DATABASE khumsyar;
CREATE USER khums_user WITH ENCRYPTED PASSWORD 'strong_password';
GRANT ALL PRIVILEGES ON DATABASE khumsyar TO khums_user;
\q
```

### ۲.۲ نصب وابستگی‌ها
```bash
cd backend
npm install
```

### ۲.۳ تنظیم متغیرهای محیطی
```bash
cp .env.example .env
```
سپس `.env` را ویرایش کنید:
```env
DATABASE_URL=postgres://khums_user:strong_password@localhost:5432/khumsyar
JWT_SECRET=<یک رشته تصادفی طولانی>
SMS_PROVIDER=console
ZARINPAL_MERCHANT_ID=<شناسه مرچنت شما>
```

> در حالت `SMS_PROVIDER=console` کد OTP در ترمینال چاپ می‌شود (مناسب توسعه).

### ۲.۴ اجرای مهاجرت و داده اولیه
```bash
npm run migrate
npm run seed
```

### ۲.۵ اجرای سرور
```bash
npm run dev
```
خروجی موفق:
```
✅ خمس‌یار backend running on http://localhost:3000
```
تست: `curl http://localhost:3000/health`

---

## ۳. راه‌اندازی اپ Flutter

### ۳.۱ دریافت وابستگی‌ها
```bash
cd flutter_app
flutter pub get
```

### ۳.۲ تنظیم آدرس بک‌اند
در `lib/services/api_client.dart` و `lib/services/payment_service.dart`
مقدار `baseUrl` را به آدرس سرور خود تغییر دهید:
```dart
ApiClient(baseUrl: 'http://10.0.2.2:3000')  // اندروید امولاتور
// یا
ApiClient(baseUrl: 'http://localhost:3000') // iOS simulator
```

### ۳.۳ فونت وزیرمتن
فایل‌های فونت را در مسیر زیر قرار دهید:
```
flutter_app/assets/fonts/
├── Vazirmatn-Regular.ttf
├── Vazirmatn-Medium.ttf
└── Vazirmatn-Bold.ttf
```
> دانلود: https://github.com/rastikerdar/vazirmatn/releases

در صورت نبود فایل فونت، پروژه از `google_fonts` استفاده می‌کند (نیازمند اینترنت).

### ۳.۴ اجرا
```bash
flutter run
```
برای ساخت نسخه نهایی:
```bash
flutter build apk --release      # اندروید
flutter build ios --release      # iOS
```

---

## ۴. دیتابیس — نمای کلی جداول

| جدول | کاربرد |
|------|--------|
| `users` | کاربران و تنظیماتشان |
| `otp_codes` | کدهای یک‌بارمصرف |
| `marjas` | مراجع و قواعد فقهی (نسخه‌بندی‌شده) |
| `faqs` | سوالات متداول |
| `calculations` | سوابق محاسبه (اختیاری) |
| `payments` | پرداخت‌ها |
| `charity_records` | کمک‌های خیریه از سهم امام |

---

## ۵. API — خلاصه اندپوینت‌ها

| متد | مسیر | توضیح |
|-----|------|-------|
| GET | `/health` | سلامت سرویس |
| POST | `/v1/auth/otp/request` | درخواست کد پیامکی |
| POST | `/v1/auth/otp/verify` | تأیید کد و دریافت توکن |
| GET | `/v1/marjas` | لیست مراجع و قواعد |
| GET | `/v1/marjas/:id` | جزئیات مرجع |
| GET | `/v1/marjas/meta/version` | نسخه قواعد |
| GET | `/v1/faqs?marjaId=&locale=` | سوالات متداول |
| POST | `/v1/payments/request` | ایجاد پرداخت |
| POST | `/v1/payments/verify` | تأیید پرداخت |
| GET | `/v1/payments/callback` | بازگشت از درگاه |
| GET | `/v1/payments` | تاریخچه پرداخت |

### نمونه درخواست OTP
```bash
curl -X POST http://localhost:3000/v1/auth/otp/request \
  -H "Content-Type: application/json" \
  -d '{"phone":"09123456789"}'
```
پاسخ: `{"ok":true,"expiresIn":120}` — کد در ترمینال سرور چاپ می‌شود.

### نمونه تأیید
```bash
curl -X POST http://localhost:3000/v1/auth/otp/verify \
  -H "Content-Type: application/json" \
  -d '{"phone":"09123456789","code":"12345"}'
```
پاسخ: `{"token":"...","user":{...}}`

---

## ۶. به‌روزرسانی قواعد فقهی

1. قواعد جدید را در `backend/src/db/seeds/01_marjas.js` اصلاح کنید و
   `rules_version` را یک واحد افزایش دهید.
2. `npm run seed` را اجرا کنید.
3. اپ با فراخوانی `/v1/marjas/meta/version` متوجه نسخه جدید می‌شود و
   قواعد را از `/v1/marjas` به‌روزرسانی می‌کند.

> ⚠️ قبل از افزایش نسخه، تأیید دفتر مرجع را دریافت کنید و
> `verified_by_office = true` را ثبت نمایید.

---

## ۷. پیکربندی درگاه پرداخت

### زرین‌پال
- `ZARINPAL_MERCHANT_ID` را از پنل زرین‌پال بگیرید.

### آیدی‌پی
- `IDPAY_API_KEY` را در پنل آیدی‌پی بسازید.
- در حالت توسعه، `X-SANDBOX: 1` فعال است.

### سامان
- `SAMAN_TERMINAL_ID` و `SAMAN_TERMINAL_PASSWORD` را تنظیم کنید.

> در تولید، `PAYMENT_CALLBACK_URL` باید به‌صورت `https://` باشد و در
> پنل درگاه ثبت شده باشد.

---

## ۸. تست

### بک‌اند
```bash
cd backend
node --check src/server.js       # بررسی سینتکس
node --test                       # تست‌ها (در صورت وجود)
```

### اپ Flutter
```bash
cd flutter_app
flutter analyze
flutter test
```

---

## ۹. عیب‌یابی

| مشکل | راه‌حل |
|------|--------|
| `flutter: command not found` | Flutter را به PATH اضافه کنید |
| خطای اتصال دیتابیس | مقدار `DATABASE_URL` و اجرای PostgreSQL را بررسی کنید |
| OTP نمی‌رسد | `SMS_PROVIDER=console` و لاگ ترمینال را ببینید |
| خطای CORS | `CORS_ORIGIN` را در `.env` تنظیم کنید |
| درگاه خطا می‌دهد | صحت `MERCHANT_ID` و آدرس callback را بررسی کنید |

---

## ۱۰. انتشار

1. **تأیید دفاتر مراجع** برای قواعد فقهی (الزامی).
2. به‌روزرسانی `version` در `flutter_app/pubspec.yaml`.
3. ساخت امضا و نسخه release:
   ```bash
   flutter build appbundle --release   # Google Play
   flutter build ipa --release         # App Store
   ```
4. استقرار بک‌اند روی سرور با HTTPS و `NODE_ENV=production`.
5. ثبت `PAYMENT_CALLBACK_URL` در پنل درگاه‌ها.

</div>

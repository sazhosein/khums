import 'package:flutter/material.dart';

/// پشتیبانی چندزبانه: فارسی (پیش‌فرض)، عربی، انگلیسی
/// ساختار کلید-مقدار ساده و قابل توسعه برای زبان‌های دیگر.
class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  static LocalizationsDelegate<AppStrings> delegate =
      const _AppStringsDelegate();

  bool get isRtl => locale.languageCode == 'fa' || locale.languageCode == 'ar';

  String _t(String fa, String ar, String en) {
    switch (locale.languageCode) {
      case 'ar':
        return ar;
      case 'en':
        return en;
      default:
        return fa;
    }
  }

  // ── عمومی ──
  String get appName => _t('خمس‌یار', 'خمسياري', 'Khums Yar');
  String get next => _t('بعدی', 'التالي', 'Next');
  String get back => _t('بازگشت', 'رجوع', 'Back');
  String get save => _t('ذخیره', 'حفظ', 'Save');
  String get cancel => _t('لغو', 'إلغاء', 'Cancel');
  String get toman => _t('تومان', 'دينار', 'Toman');
  String get percent => _t('درصد', 'نسبة', 'percent');

  // ── انتخاب مرجع ──
  String get chooseMarja => _t(
        'مرجع تقلید خود را انتخاب کنید',
        'اختر مرجعك',
        'Select your Marja',
      );
  String get chooseMarjaSub => _t(
        'محاسبه بر اساس قواعد فقهی مرجع انتخابی انجام می‌شود.',
        'يتم الحساب وفق قواعد مرجعك.',
        'Calculation follows your Marja’s rules.',
      );
  String get addOtherMarja => _t(
        'افزودن سایر مراجع',
        'إضافة مرجع آخر',
        'Add another Marja',
      );

  // ── محاسبه ──
  String get khumsCalculation => _t('محاسبه خمس', 'حساب الخمس', 'Khums Calculation');
  String get incomeSection => _t('درآمد سالانه', 'الدخل السنوي', 'Annual Income');
  String get totalIncome => _t('کل درآمد', 'إجمالي الدخل', 'Total Income');
  String get expensesSection => _t('مخارج سالانه', 'المصروفات السنوية', 'Annual Expenses');
  String get food => _t('خوراک', 'الطعام', 'Food');
  String get clothing => _t('پوشاک', 'الملابس', 'Clothing');
  String get housing => _t('مسکن', 'السكن', 'Housing');
  String get medical => _t('درمان', 'العلاج', 'Medical');
  String get education => _t('آموزش', 'التعليم', 'Education');
  String get debts => _t('بدهی‌ها', 'الديون', 'Debts');
  String get other => _t('سایر', 'أخرى', 'Other');
  String get trousseau => _t('جهیزیه', 'الجهاز', 'Trousseau');
  String get assetsSection => _t('سرمایه و اموال', 'رأس المال والأموال', 'Capital & Assets');
  String get businessCapital => _t('سرمایه تجاری', 'رأس المال التجاري', 'Business Capital');
  String get cashSavings => _t('پس‌انداز نقدی', 'المدخرات النقدية', 'Cash Savings');
  String get gold => _t('طلا و جواهر', 'الذهب', 'Gold');
  String get coins => _t('سکه', 'العملات الذهبية', 'Coins');
  String get currency => _t('ارز', 'العملة', 'Currency');
  String get stocks => _t('سهام', 'الأسهم', 'Stocks');
  String get emergencySavings =>
      _t('پس‌انداز پیشامدها', 'مدخرات الطوارئ', 'Emergency Savings');
  String get futureSavings =>
      _t('پس‌انداز ضروری آینده', 'مدخرات الحاجات المستقبلية', 'Future Savings');
  String get exemptSection => _t('اموال معاف', 'الأموال المعفاة', 'Exempt Assets');
  String get inheritance => _t('ارث', 'الإرث', 'Inheritance');
  String get dowry => _t('مهریه', 'المهر', 'Dowry');
  String get bloodMoney => _t('دیه', 'الدية', 'Blood Money');
  String get otherExempt => _t('سایر معاف', 'معفى آخر', 'Other Exempt');
  String get calculate => _t('محاسبه خمس', 'احسب الخمس', 'Calculate Khums');

  // ── نتیجه ──
  String get resultTitle => _t('نتیجه محاسبه', 'نتيجة الحساب', 'Calculation Result');
  String get surplus => _t('مازاد بر مؤونه', 'الفائض عن المؤونة', 'Surplus over expenses');
  String get khumsDue => _t('خمس واجب', 'الخمس المستحق', 'Khums Due');
  String get imamShare => _t('سهم امام', 'سهم الإمام', 'Imam’s Share');
  String get sayyidShare => _t('سهم سادات', 'سهم السادة', 'Sayyids’ Share');
  String get details => _t('جزئیات محاسبه', 'تفاصيل الحساب', 'Calculation Details');
  String get notes => _t('یادداشت‌های فقهی', 'ملاحظات فقهية', 'Fiqh Notes');
  String get warnings => _t('هشدارهای شرعی', 'تنبيهات شرعية', 'Religious Notes');
  String get disclaimer => _t(
        'نتیجه محاسبه جنبه کمک‌آموزشی دارد. برای اطمینان، با دفتر مرجع خود مشورت کنید.',
        'النتيجة تعليمية فقط. للتأكد استشر مكتب مرجعك.',
        'This result is educational only. Consult your Marja’s office for certainty.',
      );
  String get payNow => _t('پرداخت', 'ادفع الآن', 'Pay Now');

  // ── پرداخت ──
  String get payment => _t('پرداخت خمس', 'دفع الخمس', 'Khums Payment');
  String get gateway => _t('درگاه پرداخت', 'بوابة الدفع', 'Payment Gateway');
  String get paymentHistory => _t('تاریخچه پرداخت', 'سجل الدفعات', 'Payment History');
  String get noPayments => _t('پرداختی ثبت نشده است.', 'لا توجد دفعات.', 'No payments yet.');

  // ── مشاوره ──
  String get consultation => _t('مشاوره', 'الاستشارة', 'Consultation');
  String get liveChat => _t('چت آنلاین با مشاور', 'دردشة مباشرة', 'Live Chat');
  String get callOffice => _t('تماس با دفتر مرجع', 'اتصل بمكتب المرجع', 'Call Marja Office');
  String get faq => _t('سوالات متداول', 'الأسئلة الشائعة', 'FAQ');

  // ── سال خمسی ──
  String get khumsYear => _t('سال خمسی', 'السنة الخمسية', 'Khums Year');
  String get khumsYearStart =>
      _t('مبدأ سال خمسی', 'بداية السنة الخمسية', 'Khums Year Start');
  String get setupKhumsYear =>
      _t('تعیین سال خمسی', 'تحديد السنة الخمسية', 'Set Khums Year');
  String get remindMe =>
      _t('یادآور سال خمسی', 'تذكير السنة الخمسية', 'Khums Year Reminder');
  String get daysRemaining => _t('روز باقی‌مانده', 'يوم متبقٍ', 'days remaining');

  // ── تنظیمات ──
  String get settings => _t('تنظیمات', 'الإعدادات', 'Settings');
  String get language => _t('زبان', 'اللغة', 'Language');
  String get darkMode => _t('حالت تاریک', 'الوضع الليلي', 'Dark Mode');
  String get manualOverride =>
      _t('تنظیم دستی', 'ضبط يدوي', 'Manual Override');

  // ── خانه ──
  String get home => _t('خانه', 'الرئيسية', 'Home');
  String get charity => _t('صدقه و خیرات', 'الصدقة والخيرات', 'Charity');
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['fa', 'ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

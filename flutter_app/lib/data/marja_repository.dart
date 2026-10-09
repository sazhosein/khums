import '../models/marja.dart';

/// مخزن مراجع و قواعد فقهی
///
/// ⚠️ هشدار مهم:
/// مقادیر این فایل «جنبه کمک‌آموزشی» دارند و باید پیش از انتشار،
/// توسط دفاتر مراجع محترم تأیید (یا اصلاح) شوند.
/// در نسخه تولیدی، این داده‌ها از API سرور بارگذاری و به‌روزرسانی می‌شوند.
class MarjaRepository {
  const MarjaRepository();

  /// لیست پیش‌فرض مراجع (شامل موارد قابل افزودن)
  List<Marja> get defaultMarjas => const [
        Marja(
          id: 'khamenei',
          name: 'آیت‌الله خامنه‌ای',
          nameAr: 'آية الله الخامنئي',
          nameEn: 'Ayatollah Khamenei',
          officePhone: '+982133200000',
          websiteUrl: 'https://www.leader.ir',
          offices: ['تهران', 'قم', 'مشهد', 'اصفهان', 'شیراز'],
          rules: MarjaRules(
            paymentPolicy: KhumsPaymentPolicy.toMarjaOffice,
            emergencySavingsExempt: true,
            sayyidShareDirectPayment: false,
            imamShareRequiresPermission: true,
            capitalBoughtFromUnkhumsedIncome: true,
            note: 'خمس باید به دفتر یا وکیل مرجع پرداخت شود. '
                'پس‌انداز برای پیشامدها (با شرایط) معاف است.',
          ),
        ),
        Marja(
          id: 'sistani',
          name: 'آیت‌الله سیستانی',
          nameAr: 'آية الله السيستاني',
          nameEn: 'Ayatollah Sistani',
          officePhone: '+964313000000',
          websiteUrl: 'https://www.sistani.org',
          offices: ['نجف', 'قم', 'مشهد', 'تهران'],
          rules: MarjaRules(
            paymentPolicy: KhumsPaymentPolicy.sayyidDirectImamPermission,
            emergencySavingsExempt: false,
            sayyidShareDirectPayment: true,
            imamShareRequiresPermission: true,
            capitalBoughtFromUnkhumsedIncome: true,
            note: 'سهم سادات را می‌توان مستقیم پرداخت کرد؛ '
                'سهم امام نیاز به اجازه دارد.',
          ),
        ),
        Marja(
          id: 'makarem',
          name: 'آیت‌الله مکارم شیرازی',
          nameAr: 'آية الله مكارم الشيرازي',
          nameEn: 'Ayatollah Makarem Shirazi',
          officePhone: '+982513000000',
          websiteUrl: 'https://www.makarem.ir',
          offices: ['قم', 'شیراز', 'مشهد'],
          rules: MarjaRules(
            paymentPolicy: KhumsPaymentPolicy.freePayment,
            trousseauExempt: true,
            gradualTrousseauExempt: true,
            emergencySavingsExempt: false,
            imamShareRequiresPermission: true,
            capitalBoughtFromUnkhumsedIncome: true,
            note: 'در شهرهای متعارف، تهیه تدریجی جهیزیه معاف است.',
          ),
        ),
        Marja(
          id: 'shobeiri',
          name: 'آیت‌الله شبیری زنجانی',
          nameAr: 'آية الله الشبیری الزنجاني',
          nameEn: 'Ayatollah Shobeiri Zanjani',
          officePhone: '+982512000000',
          websiteUrl: 'https://www.zanjani.ir',
          offices: ['قم', 'زنجان'],
          rules: MarjaRules(
            paymentPolicy: KhumsPaymentPolicy.freePayment,
            futureNecessitiesSavingsExempt: true,
            emergencySavingsExempt: false,
            imamShareRequiresPermission: true,
            capitalBoughtFromUnkhumsedIncome: true,
            note: 'پس‌انداز برای هزینه‌های ضروری آینده معاف است.',
          ),
        ),
        Marja(
          id: 'noori',
          name: 'آیت‌الله نوری همدانی',
          nameAr: 'آية الله النوري الهمداني',
          nameEn: 'Ayatollah Noori Hamedani',
          officePhone: '+982511000000',
          websiteUrl: 'https://www.noorihamedani.ir',
          offices: ['قم', 'همدان'],
          rules: MarjaRules(
            paymentPolicy: KhumsPaymentPolicy.freePayment,
            emergencySavingsExempt: false,
            imamShareRequiresPermission: true,
            capitalBoughtFromUnkhumsedIncome: true,
            note: 'برای پرداخت خمس با دفتر مرجع مشورت کنید.',
          ),
        ),
      ];

  /// افزودن مرجع جدید توسط کاربر (سایر مراجع)
  Marja createCustomMarja({
    required String name,
    String? phone,
    String? website,
  }) {
    return Marja(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      nameAr: '',
      nameEn: name,
      officePhone: phone,
      websiteUrl: website,
      rules: const MarjaRules(
        paymentPolicy: KhumsPaymentPolicy.freePayment,
        imamShareRequiresPermission: true,
        note: 'قواعد این مرجع به‌صورت پیش‌فرض تنظیم شده است. '
            'برای دقت بیشتر، مرجع خود را در تنظیمات دستی وارد کنید.',
      ),
    );
  }
}

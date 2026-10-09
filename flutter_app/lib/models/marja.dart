import 'package:flutter/foundation.dart';

/// مرجع تقلید (Source of Emulation / Marja)
@immutable
class Marja {
  final String id;
  final String name;
  final String nameAr;
  final String nameEn;
  final String? avatarAsset;
  final String? websiteUrl;
  final String? officePhone;
  final List<String> offices; // دفاتر در شهرهای مختلف

  /// قواعد فقهی مختص این مرجع
  final MarjaRules rules;

  const Marja({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.nameEn,
    this.avatarAsset,
    this.websiteUrl,
    this.officePhone,
    this.offices = const [],
    required this.rules,
  });

  factory Marja.fromJson(Map<String, dynamic> json) {
    return Marja(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      avatarAsset: json['avatarAsset'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      officePhone: json['officePhone'] as String?,
      offices: (json['offices'] as List?)?.cast<String>() ?? const [],
      rules: MarjaRules.fromJson(
        json['rules'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'avatarAsset': avatarAsset,
        'websiteUrl': websiteUrl,
        'officePhone': officePhone,
        'offices': offices,
        'rules': rules.toJson(),
      };
}

/// قواعد فقهی قابل تنظیم برای هر مرجع
///
/// ⚠️ این قواعد از سرور به‌روزرسانی می‌شوند و باید پیش از انتشار
/// توسط دفاتر مراجع تأیید شوند. مقادیر پیش‌فرض جنبه کمک‌آموزشی دارند.
@immutable
class MarjaRules {
  /// روش پرداخت خمس
  final KhumsPaymentPolicy paymentPolicy;

  /// آیا پس‌انداز برای پیشامدها معاف است؟
  final bool emergencySavingsExempt;

  /// آیا پس‌انداز برای هزینه‌های ضروری آینده معاف است؟
  final bool futureNecessitiesSavingsExempt;

  /// آیا هزینه‌های جهیزیه معاف است؟
  final bool trousseauExempt;

  /// آیا تهیه تدریجی جهیزیه در شهرهای متعارف معاف است؟
  final bool gradualTrousseauExempt;

  /// آیا سهم سادات مستقیم قابل پرداخت است (بدون اجازه)؟
  final bool sayyidShareDirectPayment;

  /// آیا سهم امام نیاز به اجازه دارد؟
  final bool imamShareRequiresPermission;

  /// آیا کالای خریداری‌شده از درآمد سال (که خمسش پرداخت نشده) مشمول خمس است؟
  final bool capitalBoughtFromUnkhumsedIncome;

  /// آیا هزینه‌های درمان از مؤونه کسر می‌شود؟
  final bool medicalExpensesDeductible;

  /// آیا بدهی‌ها از درآمد سال کسر می‌شود؟
  final bool debtsDeductible;

  /// آیا ارث معاف است؟
  final bool inheritanceExempt;

  /// آیا مهریه معاف است؟
  final bool dowryExempt;

  /// آیا دیه معاف است؟
  final bool bloodMoneyExempt;

  /// یادداشت توضیحی فقهی برای نمایش به کاربر
  final String note;

  /// سلب مسئولیت مخصوص مرجع (در صورت وجود)
  final String? disclaimer;

  /// نرخ خمس (معمولاً ۲۰٪ = ۱/۵، اما قابل تنظیم)
  final double khumsRate;

  /// سهم امام از خمس (معمولاً ۵۰٪)
  final double imamShareRatio;

  /// سهم سادات از خمس (معمولاً ۵۰٪)
  final double sayyidShareRatio;

  const MarjaRules({
    required this.paymentPolicy,
    this.emergencySavingsExempt = false,
    this.futureNecessitiesSavingsExempt = false,
    this.trousseauExempt = false,
    this.gradualTrousseauExempt = false,
    this.sayyidShareDirectPayment = false,
    this.imamShareRequiresPermission = true,
    this.capitalBoughtFromUnkhumsedIncome = true,
    this.medicalExpensesDeductible = true,
    this.debtsDeductible = true,
    this.inheritanceExempt = true,
    this.dowryExempt = true,
    this.bloodMoneyExempt = true,
    this.note = '',
    this.disclaimer,
    this.khumsRate = 0.20,
    this.imamShareRatio = 0.5,
    this.sayyidShareRatio = 0.5,
  });

  factory MarjaRules.fromJson(Map<String, dynamic> json) {
    return MarjaRules(
      paymentPolicy: KhumsPaymentPolicy.values.firstWhere(
        (e) => e.name == json['paymentPolicy'],
        orElse: () => KhumsPaymentPolicy.toMarjaOffice,
      ),
      emergencySavingsExempt: json['emergencySavingsExempt'] as bool? ?? false,
      futureNecessitiesSavingsExempt:
          json['futureNecessitiesSavingsExempt'] as bool? ?? false,
      trousseauExempt: json['trousseauExempt'] as bool? ?? false,
      gradualTrousseauExempt: json['gradualTrousseauExempt'] as bool? ?? false,
      sayyidShareDirectPayment:
          json['sayyidShareDirectPayment'] as bool? ?? false,
      imamShareRequiresPermission:
          json['imamShareRequiresPermission'] as bool? ?? true,
      capitalBoughtFromUnkhumsedIncome:
          json['capitalBoughtFromUnkhumsedIncome'] as bool? ?? true,
      medicalExpensesDeductible:
          json['medicalExpensesDeductible'] as bool? ?? true,
      debtsDeductible: json['debtsDeductible'] as bool? ?? true,
      inheritanceExempt: json['inheritanceExempt'] as bool? ?? true,
      dowryExempt: json['dowryExempt'] as bool? ?? true,
      bloodMoneyExempt: json['bloodMoneyExempt'] as bool? ?? true,
      note: json['note'] as String? ?? '',
      disclaimer: json['disclaimer'] as String?,
      khumsRate: (json['khumsRate'] as num?)?.toDouble() ?? 0.20,
      imamShareRatio: (json['imamShareRatio'] as num?)?.toDouble() ?? 0.5,
      sayyidShareRatio: (json['sayyidShareRatio'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() => {
        'paymentPolicy': paymentPolicy.name,
        'emergencySavingsExempt': emergencySavingsExempt,
        'futureNecessitiesSavingsExempt': futureNecessitiesSavingsExempt,
        'trousseauExempt': trousseauExempt,
        'gradualTrousseauExempt': gradualTrousseauExempt,
        'sayyidShareDirectPayment': sayyidShareDirectPayment,
        'imamShareRequiresPermission': imamShareRequiresPermission,
        'capitalBoughtFromUnkhumsedIncome': capitalBoughtFromUnkhumsedIncome,
        'medicalExpensesDeductible': medicalExpensesDeductible,
        'debtsDeductible': debtsDeductible,
        'inheritanceExempt': inheritanceExempt,
        'dowryExempt': dowryExempt,
        'bloodMoneyExempt': bloodMoneyExempt,
        'note': note,
        'disclaimer': disclaimer,
        'khumsRate': khumsRate,
        'imamShareRatio': imamShareRatio,
        'sayyidShareRatio': sayyidShareRatio,
      };
}

/// سیاست پرداخت خمس
enum KhumsPaymentPolicy {
  /// باید به دفتر مرجع یا وکیل پرداخت شود (مثل آیت‌الله خامنه‌ای)
  toMarjaOffice,

  /// سهم سادات مستقیم، سهم امام با اجازه (مثل آیت‌الله سیستانی)
  sayyidDirectImamPermission,

  /// پرداخت آزاد با نظارت
  freePayment,
}

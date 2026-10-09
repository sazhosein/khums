import 'package:flutter/foundation.dart';

/// نتیجه محاسبه خمس همراه با تفکیک جزئیات
@immutable
class KhumsResult {
  final String marjaId;
  final DateTime calculatedAt;

  /// کل درآمد
  final double totalIncome;

  /// مجموع مخارج مؤونه (قابل کسر)
  final double totalExpensesDeducted;

  /// مؤونه کسر‌شده — خوراک
  final double foodDeducted;
  /// مؤونه کسر‌شده — پوشاک
  final double clothingDeducted;
  /// مؤونه کسر‌شده — مسکن
  final double housingDeducted;
  /// مؤونه کسر‌شده — درمان
  final double medicalDeducted;
  /// مؤونه کسر‌شده — آموزش
  final double educationDeducted;
  /// مؤونه کسر‌شده — بدهی‌ها
  final double debtsDeducted;
  /// مؤونه کسر‌شده — سایر
  final double otherDeducted;
  /// هزینه جهیزیه کسر‌شده
  final double trousseauDeducted;

  /// پس‌انداز معاف (بر اساس قواعد مرجع)
  final double savingsExempted;
  /// جزئیات دلیل معافیت پس‌انداز
  final String? savingsExemptionReason;

  /// اموال معاف (ارث، مهریه، دیه)
  final double exemptAssets;

  /// سرمایه/دارایی‌های مشمول خمس
  final double taxableAssets;

  /// مازاد بر مؤونه (پایه محاسبه خمس)
  final double surplus;

  /// مقدار خمس (یک‌پنجم)
  final double khumsAmount;

  /// سهم امام
  final double imamShare;
  /// سهم سادات
  final double sayyidShare;

  /// نرخ خمس اعمال‌شده
  final double khumsRate;

  /// یادداشت‌های فقهی مرتبط با این محاسبه
  final List<String> notes;

  /// هشدارها (مثلاً نیاز به اجازه برای سهم امام)
  final List<String> warnings;

  const KhumsResult({
    required this.marjaId,
    required this.calculatedAt,
    required this.totalIncome,
    required this.totalExpensesDeducted,
    required this.foodDeducted,
    required this.clothingDeducted,
    required this.housingDeducted,
    required this.medicalDeducted,
    required this.educationDeducted,
    required this.debtsDeducted,
    required this.otherDeducted,
    required this.trousseauDeducted,
    required this.savingsExempted,
    this.savingsExemptionReason,
    required this.exemptAssets,
    required this.taxableAssets,
    required this.surplus,
    required this.khumsAmount,
    required this.imamShare,
    required this.sayyidShare,
    required this.khumsRate,
    this.notes = const [],
    this.warnings = const [],
  });

  Map<String, dynamic> toJson() => {
        'marjaId': marjaId,
        'calculatedAt': calculatedAt.toIso8601String(),
        'totalIncome': totalIncome,
        'totalExpensesDeducted': totalExpensesDeducted,
        'foodDeducted': foodDeducted,
        'clothingDeducted': clothingDeducted,
        'housingDeducted': housingDeducted,
        'medicalDeducted': medicalDeducted,
        'educationDeducted': educationDeducted,
        'debtsDeducted': debtsDeducted,
        'otherDeducted': otherDeducted,
        'trousseauDeducted': trousseauDeducted,
        'savingsExempted': savingsExempted,
        'savingsExemptionReason': savingsExemptionReason,
        'exemptAssets': exemptAssets,
        'taxableAssets': taxableAssets,
        'surplus': surplus,
        'khumsAmount': khumsAmount,
        'imamShare': imamShare,
        'sayyidShare': sayyidShare,
        'khumsRate': khumsRate,
        'notes': notes,
        'warnings': warnings,
      };

  factory KhumsResult.fromJson(Map<String, dynamic> json) {
    double d(String k) => (json[k] as num?)?.toDouble() ?? 0;
    return KhumsResult(
      marjaId: json['marjaId'] as String? ?? '',
      calculatedAt:
          DateTime.tryParse(json['calculatedAt'] as String? ?? '') ??
              DateTime.now(),
      totalIncome: d('totalIncome'),
      totalExpensesDeducted: d('totalExpensesDeducted'),
      foodDeducted: d('foodDeducted'),
      clothingDeducted: d('clothingDeducted'),
      housingDeducted: d('housingDeducted'),
      medicalDeducted: d('medicalDeducted'),
      educationDeducted: d('educationDeducted'),
      debtsDeducted: d('debtsDeducted'),
      otherDeducted: d('otherDeducted'),
      trousseauDeducted: d('trousseauDeducted'),
      savingsExempted: d('savingsExempted'),
      savingsExemptionReason: json['savingsExemptionReason'] as String?,
      exemptAssets: d('exemptAssets'),
      taxableAssets: d('taxableAssets'),
      surplus: d('surplus'),
      khumsAmount: d('khumsAmount'),
      imamShare: d('imamShare'),
      sayyidShare: d('sayyidShare'),
      khumsRate: d('khumsRate'),
      notes: (json['notes'] as List?)?.cast<String>() ?? const [],
      warnings: (json['warnings'] as List?)?.cast<String>() ?? const [],
    );
  }
}

import 'package:flutter/foundation.dart';

/// ورودی‌های محاسبه خمس
@immutable
class KhumsInput {
  /// کل درآمد سالانه (تومان)
  final double totalIncome;

  /// مخارج سالانه — خوراک
  final double foodExpense;
  /// مخارج سالانه — پوشاک
  final double clothingExpense;
  /// مخارج سالانه — مسکن (اجاره، آب، برق، گاز)
  final double housingExpense;
  /// مخارج سالانه — درمان
  final double medicalExpense;
  /// مخارج سالانه — آموزش
  final double educationExpense;
  /// بدهی‌ها
  final double debts;
  /// سایر مخارج
  final double otherExpenses;

  /// سرمایه و اموال تجاری (قیمت‌گذاری کالاها)
  final double businessCapital;

  /// پس‌انداز نقدی
  final double cashSavings;
  /// طلا و جواهر (قیمت روز)
  final double gold;
  /// سکه
  final double coins;
  /// ارز
  final double currency;
  /// سهام و اوراق بهادار
  final double stocks;
  /// پس‌انداز برای پیشامدها (بیماری، حوادث)
  final double emergencySavings;
  /// پس‌انداز برای هزینه‌های ضروری آینده (ازدواج، جهیزیه، خانه)
  final double futureNecessitiesSavings;
  /// سرمایه خریداری‌شده از درآمد سال جاری (خمس آن پرداخت نشده)
  final double capitalFromCurrentYearIncome;

  /// اموال معاف — ارث
  final double inheritance;
  /// اموال معاف — مهریه
  final double dowry;
  /// اموال معاف — دیه
  final double bloodMoney;
  /// اموال معاف — سایر
  final double otherExempt;

  /// هزینه تهیه جهیزیه
  final double trousseauExpense;

  /// اگر true، محاسبه فقط بر مازاد درآمد (بدون سرمایه) انجام شود
  final bool incomeOnlyMode;

  /// تاریخ شروع سال خمسی
  final DateTime? khumsYearStart;

  const KhumsInput({
    this.totalIncome = 0,
    this.foodExpense = 0,
    this.clothingExpense = 0,
    this.housingExpense = 0,
    this.medicalExpense = 0,
    this.educationExpense = 0,
    this.debts = 0,
    this.otherExpenses = 0,
    this.businessCapital = 0,
    this.cashSavings = 0,
    this.gold = 0,
    this.coins = 0,
    this.currency = 0,
    this.stocks = 0,
    this.emergencySavings = 0,
    this.futureNecessitiesSavings = 0,
    this.capitalFromCurrentYearIncome = 0,
    this.inheritance = 0,
    this.dowry = 0,
    this.bloodMoney = 0,
    this.otherExempt = 0,
    this.trousseauExpense = 0,
    this.incomeOnlyMode = false,
    this.khumsYearStart,
  });

  /// مجموع مخارج زندگی (بدون بدهی)
  double get livingExpenses =>
      foodExpense +
      clothingExpense +
      housingExpense +
      medicalExpense +
      educationExpense +
      otherExpenses;

  /// مجموع اموال معاف
  double get exemptAssets => inheritance + dowry + bloodMoney + otherExempt;

  /// مجموع دارایی‌ها و پس‌انداز
  double get totalAssets =>
      cashSavings +
      gold +
      coins +
      currency +
      stocks +
      businessCapital;

  KhumsInput copyWith({
    double? totalIncome,
    double? foodExpense,
    double? clothingExpense,
    double? housingExpense,
    double? medicalExpense,
    double? educationExpense,
    double? debts,
    double? otherExpenses,
    double? businessCapital,
    double? cashSavings,
    double? gold,
    double? coins,
    double? currency,
    double? stocks,
    double? emergencySavings,
    double? futureNecessitiesSavings,
    double? capitalFromCurrentYearIncome,
    double? inheritance,
    double? dowry,
    double? bloodMoney,
    double? otherExempt,
    double? trousseauExpense,
    bool? incomeOnlyMode,
    DateTime? khumsYearStart,
  }) {
    return KhumsInput(
      totalIncome: totalIncome ?? this.totalIncome,
      foodExpense: foodExpense ?? this.foodExpense,
      clothingExpense: clothingExpense ?? this.clothingExpense,
      housingExpense: housingExpense ?? this.housingExpense,
      medicalExpense: medicalExpense ?? this.medicalExpense,
      educationExpense: educationExpense ?? this.educationExpense,
      debts: debts ?? this.debts,
      otherExpenses: otherExpenses ?? this.otherExpenses,
      businessCapital: businessCapital ?? this.businessCapital,
      cashSavings: cashSavings ?? this.cashSavings,
      gold: gold ?? this.gold,
      coins: coins ?? this.coins,
      currency: currency ?? this.currency,
      stocks: stocks ?? this.stocks,
      emergencySavings: emergencySavings ?? this.emergencySavings,
      futureNecessitiesSavings:
          futureNecessitiesSavings ?? this.futureNecessitiesSavings,
      capitalFromCurrentYearIncome:
          capitalFromCurrentYearIncome ?? this.capitalFromCurrentYearIncome,
      inheritance: inheritance ?? this.inheritance,
      dowry: dowry ?? this.dowry,
      bloodMoney: bloodMoney ?? this.bloodMoney,
      otherExempt: otherExempt ?? this.otherExempt,
      trousseauExpense: trousseauExpense ?? this.trousseauExpense,
      incomeOnlyMode: incomeOnlyMode ?? this.incomeOnlyMode,
      khumsYearStart: khumsYearStart ?? this.khumsYearStart,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalIncome': totalIncome,
        'foodExpense': foodExpense,
        'clothingExpense': clothingExpense,
        'housingExpense': housingExpense,
        'medicalExpense': medicalExpense,
        'educationExpense': educationExpense,
        'debts': debts,
        'otherExpenses': otherExpenses,
        'businessCapital': businessCapital,
        'cashSavings': cashSavings,
        'gold': gold,
        'coins': coins,
        'currency': currency,
        'stocks': stocks,
        'emergencySavings': emergencySavings,
        'futureNecessitiesSavings': futureNecessitiesSavings,
        'capitalFromCurrentYearIncome': capitalFromCurrentYearIncome,
        'inheritance': inheritance,
        'dowry': dowry,
        'bloodMoney': bloodMoney,
        'otherExempt': otherExempt,
        'trousseauExpense': trousseauExpense,
        'incomeOnlyMode': incomeOnlyMode,
        'khumsYearStart': khumsYearStart?.toIso8601String(),
      };

  factory KhumsInput.fromJson(Map<String, dynamic> json) {
    double d(String k) => (json[k] as num?)?.toDouble() ?? 0;
    return KhumsInput(
      totalIncome: d('totalIncome'),
      foodExpense: d('foodExpense'),
      clothingExpense: d('clothingExpense'),
      housingExpense: d('housingExpense'),
      medicalExpense: d('medicalExpense'),
      educationExpense: d('educationExpense'),
      debts: d('debts'),
      otherExpenses: d('otherExpenses'),
      businessCapital: d('businessCapital'),
      cashSavings: d('cashSavings'),
      gold: d('gold'),
      coins: d('coins'),
      currency: d('currency'),
      stocks: d('stocks'),
      emergencySavings: d('emergencySavings'),
      futureNecessitiesSavings: d('futureNecessitiesSavings'),
      capitalFromCurrentYearIncome: d('capitalFromCurrentYearIncome'),
      inheritance: d('inheritance'),
      dowry: d('dowry'),
      bloodMoney: d('bloodMoney'),
      otherExempt: d('otherExempt'),
      trousseauExpense: d('trousseauExpense'),
      incomeOnlyMode: json['incomeOnlyMode'] as bool? ?? false,
      khumsYearStart: json['khumsYearStart'] != null
          ? DateTime.tryParse(json['khumsYearStart'] as String)
          : null,
    );
  }
}

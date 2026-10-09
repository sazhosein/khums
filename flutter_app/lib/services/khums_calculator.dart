import '../models/khums_input.dart';
import '../models/khums_result.dart';
import '../models/marja.dart';

/// موتور محاسبه خمس
///
/// ⚠️ این موتور صرفاً ابزار کمک‌آموزشی است و صادرکننده حکم شرعی نیست.
/// قواعد از [MarjaRules] خوانده می‌شود که توسط دفاتر مراجع قابل تأیید است.
///
/// روش کلی (مطابق نظر مشهور فقها):
///   ۱. مخارج سال (مؤونه) از درآمد کسر می‌شود.
///   ۲. اموال معاف (ارث، مهریه، دیه) کنار گذاشته می‌شود.
///   ۳. پس‌انداز معاف طبق قواعد مرجع کسر می‌شود.
///   ۴. مازاد بر مؤونه × ۲۰٪ = خمس.
///   ۵. خمس به سهم امام (۵۰٪) و سهم سادات (۵۰٪) تقسیم می‌شود.
class KhumsCalculator {
  const KhumsCalculator();

  KhumsResult calculate({
    required KhumsInput input,
    required Marja marja,
  }) {
    final rules = marja.rules;
    final notes = <String>[];
    final warnings = <String>[];

    // ── ۱. محاسبه مؤونه (مخارج قابل کسر) ──
    final food = input.foodExpense;
    final clothing = input.clothingExpense;
    final housing = input.housingExpense;

    // هزینه درمان بسته به نظر مرجع
    final medical =
        rules.medicalExpensesDeductible ? input.medicalExpense : 0.0;
    if (!rules.medicalExpensesDeductible && input.medicalExpense > 0) {
      notes.add(
        'طبق نظر ${marja.name}، هزینه‌های درمان در محاسبه مؤونه لحاظ نشده است.',
      );
    }

    final education = input.educationExpense;

    // بدهی‌ها بسته به نظر مرجع
    final debts = rules.debtsDeductible ? input.debts : 0.0;
    if (!rules.debtsDeductible && input.debts > 0) {
      notes.add(
        'طبق نظر ${marja.name}، بدهی‌ها از درآمد سال کسر نشده است.',
      );
    }

    final other = input.otherExpenses;

    // ── جهیزیه ──
    double trousseau = 0;
    if (rules.trousseauExempt) {
      trousseau = input.trousseauExpense;
      if (trousseau > 0) {
        notes.add(
          'هزینه تهیه جهیزیه طبق نظر ${marja.name} معاف است.',
        );
      }
    } else if (rules.gradualTrousseauExempt && input.trousseauExpense > 0) {
      // تهیه تدریجی در شهرهای متعارف
      trousseau = input.trousseauExpense;
      notes.add(
        'طبق نظر ${marja.name}، تهیه تدریجی جهیزیه در شهرهای متعارف معاف است.',
      );
    }

    final totalExpenses =
        food + clothing + housing + medical + education + debts + other + trousseau;

    // ── ۲. اموال معاف ──
    double exemptAssets = 0;
    if (rules.inheritanceExempt) exemptAssets += input.inheritance;
    if (rules.dowryExempt) exemptAssets += input.dowry;
    if (rules.bloodMoneyExempt) exemptAssets += input.bloodMoney;
    exemptAssets += input.otherExempt;

    // ── ۳. پس‌انداز معاف ──
    double savingsExempted = 0;
    String? savingsReason;

    if (rules.emergencySavingsExempt && input.emergencySavings > 0) {
      savingsExempted += input.emergencySavings;
      savingsReason =
          'پس‌انداز برای پیشامدها طبق نظر ${marja.name} (با شرایط) معاف است.';
    }
    if (rules.futureNecessitiesSavingsExempt &&
        input.futureNecessitiesSavings > 0) {
      savingsExempted += input.futureNecessitiesSavings;
      savingsReason =
          'پس‌انداز برای هزینه‌های ضروری آینده طبق نظر ${marja.name} معاف است.';
    }

    if (savingsExempted > 0) {
      notes.add(savingsReason!);
    }

    // ── ۴. دارایی‌های مشمول خمس ──
    // سرمایه خریداری‌شده از درآمد سال که خمس آن پرداخت نشده
    double capitalFromIncome = 0;
    if (rules.capitalBoughtFromUnkhumsedIncome) {
      capitalFromIncome = input.capitalFromCurrentYearIncome;
      if (capitalFromIncome > 0) {
        notes.add(
          'سرمایه‌ای که از درآمد سال خریداری شده و خمس آن پرداخت نشده، مشمول خمس است.',
        );
      }
    }

    // دارایی‌های پس‌اندازی (طلا، سکه، ارز، سهام، سرمایه تجاری)
    final assetsSide = input.incomeOnlyMode
        ? capitalFromIncome
        : input.totalAssets + capitalFromIncome;

    // ── ۵. محاسبه مازاد ──
    // مازاد = درآمد − مؤونه + دارایی‌های مشمول − پس‌انداز معاف
    double surplus =
        input.totalIncome - totalExpenses + assetsSide - savingsExempted;

    // اموال معاف از مازاد کسر نمی‌شود چون جداگانه محاسبه می‌شوند؛
    // اما اگر در درآمد سال لحاظ شده باشند، کسر می‌کنیم.
    surplus -= exemptAssets;

    if (surplus < 0) surplus = 0;

    // ── ۶. خمس ──
    final khumsAmount = surplus * rules.khumsRate;
    final imamShare = khumsAmount * rules.imamShareRatio;
    final sayyidShare = khumsAmount * rules.sayyidShareRatio;

    // ── ۷. هشدارهای شرعی ──
    switch (rules.paymentPolicy) {
      case KhumsPaymentPolicy.toMarjaOffice:
        warnings.add(
          'طبق نظر ${marja.name}، خمس باید به دفتر مرجع یا وکیل ایشان پرداخت شود.',
        );
        break;
      case KhumsPaymentPolicy.sayyidDirectImamPermission:
        warnings.add(
          'طبق نظر ${marja.name}، سهم سادات را می‌توانید مستقیم پرداخت کنید، '
          'اما سهم امام نیاز به اجازه دارد.',
        );
        break;
      case KhumsPaymentPolicy.freePayment:
        warnings.add(
          'طبق نظر ${marja.name}، هنگام پرداخت با دفتر مرجع مشورت کنید.',
        );
        break;
    }

    if (rules.imamShareRequiresPermission &&
        imamShare > 0 &&
        rules.paymentPolicy != KhumsPaymentPolicy.toMarjaOffice) {
      warnings.add('پرداخت سهم امام نیاز به اجازه از دفتر مرجع دارد.');
    }

    if (input.khumsYearStart == null) {
      warnings.add(
        'مبدأ سال خمسی تعیین نشده است. برای محاسبه دقیق، آن را در بخش سال خمسی وارد کنید.',
      );
    }

    if (marja.rules.note.isNotEmpty) {
      notes.add(marja.rules.note);
    }

    return KhumsResult(
      marjaId: marja.id,
      calculatedAt: DateTime.now(),
      totalIncome: input.totalIncome,
      totalExpensesDeducted: totalExpenses,
      foodDeducted: food,
      clothingDeducted: clothing,
      housingDeducted: housing,
      medicalDeducted: medical,
      educationDeducted: education,
      debtsDeducted: debts,
      otherDeducted: other,
      trousseauDeducted: trousseau,
      savingsExempted: savingsExempted,
      savingsExemptionReason: savingsReason,
      exemptAssets: exemptAssets,
      taxableAssets: assetsSide,
      surplus: surplus,
      khumsAmount: khumsAmount,
      imamShare: imamShare,
      sayyidShare: sayyidShare,
      khumsRate: rules.khumsRate,
      notes: notes,
      warnings: warnings,
    );
  }
}

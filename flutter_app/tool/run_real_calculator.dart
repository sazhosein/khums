/// اجرای موتور محاسبه *واقعی* اپ (lib/services/khums_calculator.dart)
/// در محیطی که Flutter نصب نیست.
///
/// این فایل صرفاً برای تأیید اجرایی است و بخشی از توزیع اپ نیست.
/// اجرا: dart run tool/run_real_calculator.dart
library;

import '../lib/data/marja_repository.dart';
import '../lib/models/khums_input.dart';
import '../lib/services/khums_calculator.dart';

void main() {
  const calc = KhumsCalculator();
  const repo = MarjaRepository();
  final marjas = repo.defaultMarjas;

  print('\n=== اجرای موتور محاسبه واقعی اپ ===');
  print('تعداد مراجع بارگذاری‌شده: ${marjas.length}');
  for (final m in marjas) {
    print('  • ${m.name} (${m.id}) — policy=${m.rules.paymentPolicy.name}');
  }

  var ok = 0;
  var fail = 0;

  void runCase(String label, KhumsInput input, String marjaId, double expSurplus) {
    final marja = marjas.firstWhere((m) => m.id == marjaId);
    final r = calc.calculate(input: input, marja: marja);
    final diff = (r.surplus - expSurplus).abs();
    final pass = diff < 1;
    if (pass) {
      ok++;
      print('  ✅ $label → مازاد=${r.surplus.toStringAsFixed(0)} '
          'خمس=${r.khumsAmount.toStringAsFixed(0)}');
    } else {
      fail++;
      print('  ❌ $label → مازاد=${r.surplus.toStringAsFixed(0)} '
          '(انتظار: $expSurplus)');
    }
    // هشدارها باید همیشه حداقل یکی باشند (سلب مسئولیت شرعی)
    if (r.warnings.isEmpty) {
      print('     ⚠️ هشدار شرعی صادر نشد!');
    }
  }

  print('\n--- سناریوها ---');
  runCase(
    'درآمد ۱۰۰M، مخارج ۵۰M (سیستانی)',
    const KhumsInput(
      totalIncome: 100000000,
      foodExpense: 10000000,
      clothingExpense: 5000000,
      housingExpense: 20000000,
      medicalExpense: 3000000,
      educationExpense: 2000000,
      debts: 5000000,
      otherExpenses: 5000000,
    ),
    'sistani',
    50000000,
  );

  runCase(
    'پس‌انداز پیشامد ۱۰M (خامنه‌ای معاف)',
    const KhumsInput(
      totalIncome: 100000000,
      foodExpense: 50000000,
      emergencySavings: 10000000,
    ),
    'khamenei',
    40000000,
  );

  runCase(
    'جهیزیه ۱۰M (مکارم معاف)',
    const KhumsInput(
      totalIncome: 100000000,
      foodExpense: 50000000,
      trousseauExpense: 10000000,
    ),
    'makarem',
    40000000,
  );

  runCase(
    'پس‌انداز آینده ۲۰M (شبیری معاف)',
    const KhumsInput(
      totalIncome: 100000000,
      foodExpense: 50000000,
      futureNecessitiesSavings: 20000000,
    ),
    'shobeiri',
    30000000,
  );

  // چاپ نمونه خروجی کامل
  final marja = marjas.firstWhere((m) => m.id == 'sistani');
  final full = calc.calculate(
    input: const KhumsInput(
      totalIncome: 100000000,
      foodExpense: 20000000,
      housingExpense: 20000000,
      gold: 10000000,
    ),
    marja: marja,
  );
  print('\n--- نمونه جزئیات کامل (سیستانی) ---');
  print('  کل درآمد        : ${full.totalIncome.toStringAsFixed(0)}');
  print('  مخارج مؤونه     : ${full.totalExpensesDeducted.toStringAsFixed(0)}');
  print('  دارایی مشمول    : ${full.taxableAssets.toStringAsFixed(0)}');
  print('  مازاد           : ${full.surplus.toStringAsFixed(0)}');
  print('  خمس (۲۰٪)       : ${full.khumsAmount.toStringAsFixed(0)}');
  print('  سهم امام        : ${full.imamShare.toStringAsFixed(0)}');
  print('  سهم سادات       : ${full.sayyidShare.toStringAsFixed(0)}');
  print('  یادداشت‌ها      : ${full.notes.length}');
  print('  هشدارهای شرعی   : ${full.warnings.length}');
  for (final w in full.warnings) {
    print('     ↳ $w');
  }

  print('\n──────── نتیجه ────────');
  print('  موفق: $ok   ناموفق: $fail');
  print('────────────────────────\n');
}

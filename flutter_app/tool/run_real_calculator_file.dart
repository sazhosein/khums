/// اجرای موتور محاسبه واقعی اپ و نوشتن نتیجه در فایل UTF-8.
///
/// اجرا در محیط بدون Flutter:
///   dart run tool/run_real_calculator_file.dart lib/data/marja_repository.dart
/// یا با مسیرهای نسبی مطابق ساختار پکیج.
library;

import 'dart:io';

import '../lib/data/marja_repository.dart';
import '../lib/models/khums_input.dart';
import '../lib/services/khums_calculator.dart';

void main() {
  const calc = KhumsCalculator();
  const repo = MarjaRepository();
  final marjas = repo.defaultMarjas;
  final buf = StringBuffer();

  void out(Object? o) => buf.writeln(o);

  out('=== اجرای موتور محاسبه واقعی اپ ===');
  out('تعداد مراجع بارگذاری‌شده: ${marjas.length}');
  for (final m in marjas) {
    out('  • ${m.name} (${m.id}) — policy=${m.rules.paymentPolicy.name}');
  }

  var ok = 0;
  var fail = 0;

  void runCase(
    String label,
    KhumsInput input,
    String marjaId,
    double expSurplus,
  ) {
    final marja = marjas.firstWhere((m) => m.id == marjaId);
    final r = calc.calculate(input: input, marja: marja);
    final pass = (r.surplus - expSurplus).abs() < 1;
    if (pass) {
      ok++;
      out('  [PASS] $label -> مازاد=${r.surplus.toStringAsFixed(0)} '
          'خمس=${r.khumsAmount.toStringAsFixed(0)}');
    } else {
      fail++;
      out('  [FAIL] $label -> مازاد=${r.surplus.toStringAsFixed(0)} '
          '(انتظار $expSurplus)');
    }
    if (r.warnings.isEmpty) out('     [WARN] هشدار شرعی صادر نشد!');
  }

  out('');
  out('--- سناریوها ---');
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
  out('');
  out('--- نمونه جزئیات کامل (سیستانی) ---');
  out('  کل درآمد      : ${full.totalIncome.toStringAsFixed(0)}');
  out('  مخارج مؤونه   : ${full.totalExpensesDeducted.toStringAsFixed(0)}');
  out('  دارایی مشمول  : ${full.taxableAssets.toStringAsFixed(0)}');
  out('  مازاد         : ${full.surplus.toStringAsFixed(0)}');
  out('  خمس (۲۰٪)     : ${full.khumsAmount.toStringAsFixed(0)}');
  out('  سهم امام      : ${full.imamShare.toStringAsFixed(0)}');
  out('  سهم سادات     : ${full.sayyidShare.toStringAsFixed(0)}');
  out('  یادداشت‌ها    : ${full.notes.length}');
  out('  هشدارهای شرعی : ${full.warnings.length}');
  for (final w in full.warnings) {
    out('     ↳ $w');
  }

  out('');
  out('──────── نتیجه ────────');
  out('  موفق: $ok   ناموفق: $fail');
  out('────────────────────────');

  final path = Platform.environment['KHUM_VERIFY_OUT'] ??
      'khums_verify_output.txt';
  File(path).writeAsStringSync(buf.toString());
  stdout.writeln('wrote $path');
}

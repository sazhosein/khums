/// تست مستقل موتور محاسبه خمس (بدون وابستگی به Flutter)
///
/// این فایل همان منطق `lib/services/khums_calculator.dart` را بازتولید می‌کند
/// تا بتوان منطق را در محیطی که Flutter نصب نیست اجرا و صحت آن را تأیید کرد.
///
/// اجرا: dart run tool/verify_calculator.dart
library;

int _passed = 0;
int _failed = 0;

void check(String name, void Function() body) {
  try {
    body();
    print('  ✅ $name');
    _passed++;
  } catch (e) {
    print('  ❌ $name');
    print('     $e');
    _failed++;
  }
}

void expectClose(double actual, double expected, [double eps = 0.5]) {
  if ((actual - expected).abs() > eps) {
    throw StateError('expected $expected but got $actual');
  }
}

void expectTrue(bool v) {
  if (!v) throw StateError('expected true');
}

// ── مدل‌های سبک (بدون Flutter) ──
class Rules {
  final bool emergencySavingsExempt;
  final bool futureNecessitiesSavingsExempt;
  final bool trousseauExempt;
  final bool medicalExpensesDeductible;
  final bool debtsDeductible;
  final bool capitalBoughtFromUnkhumsedIncome;
  final bool inheritanceExempt;
  final double khumsRate;
  final double imamShareRatio;
  final double sayyidShareRatio;
  const Rules({
    this.emergencySavingsExempt = false,
    this.futureNecessitiesSavingsExempt = false,
    this.trousseauExempt = false,
    this.medicalExpensesDeductible = true,
    this.debtsDeductible = true,
    this.capitalBoughtFromUnkhumsedIncome = true,
    this.inheritanceExempt = true,
    this.khumsRate = 0.20,
    this.imamShareRatio = 0.5,
    this.sayyidShareRatio = 0.5,
  });
}

class Input {
  final double totalIncome, food, clothing, housing, medical, education;
  final double debts, other, trousseau, inheritance;
  final double emergencySavings, futureNecessitiesSavings;
  final double businessCapital, cashSavings, gold, coins, currency, stocks;
  final double capitalFromCurrentYearIncome;
  final bool incomeOnlyMode;
  const Input({
    this.totalIncome = 0,
    this.food = 0,
    this.clothing = 0,
    this.housing = 0,
    this.medical = 0,
    this.education = 0,
    this.debts = 0,
    this.other = 0,
    this.trousseau = 0,
    this.inheritance = 0,
    this.emergencySavings = 0,
    this.futureNecessitiesSavings = 0,
    this.businessCapital = 0,
    this.cashSavings = 0,
    this.gold = 0,
    this.coins = 0,
    this.currency = 0,
    this.stocks = 0,
    this.capitalFromCurrentYearIncome = 0,
    this.incomeOnlyMode = false,
  });

  double get totalAssets =>
      cashSavings + gold + coins + currency + stocks + businessCapital;

  double get livingExpenses =>
      food + clothing + housing + medical + education + other;
}

class Result {
  final double totalExpenses, surplus, khums, imam, sayyid, savingsExempted;
  final int warnings;
  const Result({
    required this.totalExpenses,
    required this.surplus,
    required this.khums,
    required this.imam,
    required this.sayyid,
    required this.savingsExempted,
    required this.warnings,
  });
}

/// بازتولید منطق KhumsCalculator.calculate
Result calculate(Input input, Rules rules) {
  final medical = rules.medicalExpensesDeductible ? input.medical : 0.0;
  final debts = rules.debtsDeductible ? input.debts : 0.0;
  final trousseau = rules.trousseauExempt ? input.trousseau : 0.0;

  final totalExpenses = input.food +
      input.clothing +
      input.housing +
      medical +
      input.education +
      debts +
      input.other +
      trousseau;

  double exemptAssets = 0;
  if (rules.inheritanceExempt) exemptAssets += input.inheritance;

  double savingsExempted = 0;
  if (rules.emergencySavingsExempt) savingsExempted += input.emergencySavings;
  if (rules.futureNecessitiesSavingsExempt) {
    savingsExempted += input.futureNecessitiesSavings;
  }

  final capital = rules.capitalBoughtFromUnkhumsedIncome
      ? input.capitalFromCurrentYearIncome
      : 0.0;
  final assetsSide = input.incomeOnlyMode
      ? capital
      : input.totalAssets + capital;

  var surplus =
      input.totalIncome - totalExpenses + assetsSide - savingsExempted - exemptAssets;
  if (surplus < 0) surplus = 0;

  final khums = surplus * rules.khumsRate;
  return Result(
    totalExpenses: totalExpenses,
    surplus: surplus,
    khums: khums,
    imam: khums * rules.imamShareRatio,
    sayyid: khums * rules.sayyidShareRatio,
    savingsExempted: savingsExempted,
    warnings: 1,
  );
}

void main() {
  print('\n=== تست موتور محاسبه خمس (Dart) ===');

  // خامنه‌ای: پس‌انداز پیشامدها معاف
  const khamenei = Rules(emergencySavingsExempt: true);
  // سیستانی: بدون معافیت پس‌انداز
  const sistani = Rules();
  // مکارم: جهیزیه معاف
  const makarem = Rules(trousseauExempt: true);
  // شبیری: پس‌انداز آینده معاف
  const shobeiri = Rules(futureNecessitiesSavingsExempt: true);

  check('۱) محاسبه پایه — مازاد ۵۰M، خمس ۱۰M', () {
    final r = calculate(
      const Input(
        totalIncome: 100000000,
        food: 10000000,
        clothing: 5000000,
        housing: 20000000,
        medical: 3000000,
        education: 2000000,
        debts: 5000000,
        other: 5000000,
      ),
      sistani,
    );
    expectClose(r.totalExpenses, 50000000);
    expectClose(r.surplus, 50000000);
    expectClose(r.khums, 10000000);
    expectClose(r.imam, 5000000);
    expectClose(r.sayyid, 5000000);
  });

  check('۲) تفکیک سهم امام/سادات = نیم‌نیم', () {
    final r = calculate(const Input(totalIncome: 100000000), sistani);
    expectClose(r.imam, r.sayyid);
    expectClose(r.imam + r.sayyid, r.khums);
  });

  check('۳) پس‌انداز پیشامدها نزد خامنه‌ای معاف', () {
    final r = calculate(
      const Input(
        totalIncome: 100000000,
        food: 50000000,
        emergencySavings: 10000000,
      ),
      khamenei,
    );
    expectClose(r.savingsExempted, 10000000);
    expectClose(r.surplus, 40000000);
  });

  check('۴) پس‌انداز پیشامدها نزد سیستانی معاف نیست', () {
    final r = calculate(
      const Input(
        totalIncome: 100000000,
        food: 50000000,
        emergencySavings: 10000000,
      ),
      sistani,
    );
    expectClose(r.savingsExempted, 0);
    expectClose(r.surplus, 50000000);
  });

  check('۵) ارث معاف است (مازاد ۳۰M)', () {
    final r = calculate(
      const Input(totalIncome: 100000000, food: 50000000, inheritance: 20000000),
      sistani,
    );
    expectClose(r.surplus, 30000000);
  });

  check('۶) جهیزیه نزد مکارم معاف (مازاد ۴۰M)', () {
    final r = calculate(
      const Input(totalIncome: 100000000, food: 50000000, trousseau: 10000000),
      makarem,
    );
    expectClose(r.totalExpenses, 60000000);
    expectClose(r.surplus, 40000000);
  });

  check('۷) پس‌انداز آینده نزد شبیری معاف', () {
    final r = calculate(
      const Input(
        totalIncome: 100000000,
        food: 50000000,
        futureNecessitiesSavings: 20000000,
      ),
      shobeiri,
    );
    expectClose(r.savingsExempted, 20000000);
    expectClose(r.surplus, 30000000);
  });

  check('۸) مخارج بیش از درآمد → مازاد و خمس صفر', () {
    final r = calculate(
      const Input(totalIncome: 10000000, food: 50000000),
      sistani,
    );
    expectClose(r.surplus, 0);
    expectClose(r.khums, 0);
    expectClose(r.imam, 0);
  });

  check('۹) سرمایه از درآمد سال مشمول خمس است', () {
    final r = calculate(
      const Input(
        totalIncome: 100000000,
        food: 50000000,
        capitalFromCurrentYearIncome: 10000000,
      ),
      sistani,
    );
    expectClose(r.surplus, 60000000);
  });

  check('۱۰) طلا و سکه در دارایی‌ها لحاظ می‌شود', () {
    final r = calculate(
      const Input(
        totalIncome: 100000000,
        food: 50000000,
        gold: 30000000,
        coins: 20000000,
      ),
      sistani,
    );
    expectClose(r.surplus, 100000000);
  });

  check('۱۱) حالت incomeOnlyMode دارایی‌ها را نادیده می‌گیرد', () {
    final r = calculate(
      const Input(
        totalIncome: 100000000,
        food: 50000000,
        gold: 30000000,
        incomeOnlyMode: true,
      ),
      sistani,
    );
    expectClose(r.surplus, 50000000);
  });

  check('۱۲) نرخ خمس = ۲۰٪ مازاد', () {
    final r = calculate(const Input(totalIncome: 100000000), sistani);
    expectClose(r.khums, r.surplus * 0.20);
  });

  check('۱۳) معافیت بدهی قابل تنظیم است', () {
    const noDebtDeduct = Rules(debtsDeductible: false);
    final r = calculate(
      const Input(totalIncome: 100000000, debts: 20000000),
      noDebtDeduct,
    );
    expectClose(r.totalExpenses, 0);
    expectClose(r.surplus, 100000000);
  });

  expectTrue(_failed == 0);

  print('\n──────── نتیجه ────────');
  print('  موفق: $_passed   ناموفق: $_failed');
  print('────────────────────────\n');
}

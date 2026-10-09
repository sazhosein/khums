import 'package:flutter_test/flutter_test.dart';
import 'package:khums_yar/data/marja_repository.dart';
import 'package:khums_yar/models/khums_input.dart';
import 'package:khums_yar/services/khums_calculator.dart';

void main() {
  const calculator = KhumsCalculator();
  const repo = MarjaRepository();

  group('موتور محاسبه خمس', () {
    test('محاسبه پایه: خمس = ۲۰٪ مازاد', () {
      final marja = repo.defaultMarjas.firstWhere((m) => m.id == 'sistani');

      final input = const KhumsInput(
        totalIncome: 100000000, // ۱۰۰ میلیون
        foodExpense: 10000000,
        clothingExpense: 5000000,
        housingExpense: 20000000,
        medicalExpense: 3000000,
        educationExpense: 2000000,
        debts: 5000000,
        otherExpenses: 5000000,
      );

      final result = calculator.calculate(input: input, marja: marja);

      // مخارج = ۵۰ میلیون → مازاد = ۵۰ میلیون
      expect(result.surplus, closeTo(50000000, 1));
      // خمس = ۱۰ میلیون
      expect(result.khumsAmount, closeTo(10000000, 1));
      // سهم امام و سادات = ۵ میلیون هرکدام
      expect(result.imamShare, closeTo(5000000, 1));
      expect(result.sayyidShare, closeTo(5000000, 1));
    });

    test('پس‌انداز پیشامدها نزد خامنه‌ای معاف است', () {
      final marja = repo.defaultMarjas.firstWhere((m) => m.id == 'khamenei');

      final input = const KhumsInput(
        totalIncome: 100000000,
        foodExpense: 50000000,
        emergencySavings: 10000000,
      );

      final result = calculator.calculate(input: input, marja: marja);

      expect(result.savingsExempted, closeTo(10000000, 1));
      // مازاد = ۱۰۰ − ۵۰ − ۱۰ = ۴۰
      expect(result.surplus, closeTo(40000000, 1));
    });

    test('اموال معاف (ارث) از محاسبه خارج می‌شود', () {
      final marja = repo.defaultMarjas.firstWhere((m) => m.id == 'sistani');

      final input = const KhumsInput(
        totalIncome: 100000000,
        foodExpense: 50000000,
        inheritance: 20000000,
      );

      final result = calculator.calculate(input: input, marja: marja);

      expect(result.exemptAssets, closeTo(20000000, 1));
      expect(result.surplus, closeTo(30000000, 1));
    });

    test('جهیزیه نزد مکارم معاف است', () {
      final marja = repo.defaultMarjas.firstWhere((m) => m.id == 'makarem');

      final input = const KhumsInput(
        totalIncome: 100000000,
        foodExpense: 50000000,
        trousseauExpense: 10000000,
      );

      final result = calculator.calculate(input: input, marja: marja);

      expect(result.trousseauDeducted, closeTo(10000000, 1));
      expect(result.surplus, closeTo(40000000, 1));
    });

    test('مخارج بیش از درآمد → مازاد صفر', () {
      final marja = repo.defaultMarjas.firstWhere((m) => m.id == 'sistani');

      final input = const KhumsInput(
        totalIncome: 10000000,
        foodExpense: 50000000,
      );

      final result = calculator.calculate(input: input, marja: marja);

      expect(result.surplus, 0);
      expect(result.khumsAmount, 0);
    });

    test('هشدار شرعی پرداخت برای خامنه‌ای صادر می‌شود', () {
      final marja = repo.defaultMarjas.firstWhere((m) => m.id == 'khamenei');
      final input = const KhumsInput(totalIncome: 100000000);

      final result = calculator.calculate(input: input, marja: marja);

      expect(result.warnings, isNotEmpty);
    });
  });
}

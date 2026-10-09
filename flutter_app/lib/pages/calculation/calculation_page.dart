import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../models/khums_input.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'result_page.dart';

/// فرم محاسبه خمس — تمام بخش‌ها
class CalculationPage extends ConsumerWidget {
  const CalculationPage({super.key});

  void _update(WidgetRef ref, KhumsInput input) {
    ref.read(khumsInputProvider.notifier).state = input;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final input = ref.watch(khumsInputProvider);
    final marja = ref.watch(selectedMarjaProvider);
    final rules = marja?.rules;

    return Scaffold(
      appBar: AppBar(title: Text(s.khumsCalculation)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── درآمد ──
          SectionCard(
            title: s.incomeSection,
            icon: Icons.savings,
            children: [
              MoneyField(
                label: s.totalIncome,
                icon: Icons.account_balance_wallet,
                initialValue: input.totalIncome,
                onChanged: (v) => _update(ref, input.copyWith(totalIncome: v)),
              ),
            ],
          ),

          // ── مخارج ──
          SectionCard(
            title: s.expensesSection,
            icon: Icons.receipt_long,
            children: [
              MoneyField(
                label: s.food,
                icon: Icons.restaurant,
                initialValue: input.foodExpense,
                onChanged: (v) => _update(ref, input.copyWith(foodExpense: v)),
              ),
              MoneyField(
                label: s.clothing,
                icon: Icons.checkroom,
                initialValue: input.clothingExpense,
                onChanged: (v) =>
                    _update(ref, input.copyWith(clothingExpense: v)),
              ),
              MoneyField(
                label: s.housing,
                icon: Icons.home,
                initialValue: input.housingExpense,
                onChanged: (v) =>
                    _update(ref, input.copyWith(housingExpense: v)),
              ),
              MoneyField(
                label: s.medical,
                icon: Icons.local_hospital,
                initialValue: input.medicalExpense,
                helper: rules?.medicalExpensesDeductible == false
                    ? 'طبق نظر این مرجع کسر نمی‌شود'
                    : null,
                onChanged: (v) =>
                    _update(ref, input.copyWith(medicalExpense: v)),
              ),
              MoneyField(
                label: s.education,
                icon: Icons.school,
                initialValue: input.educationExpense,
                onChanged: (v) =>
                    _update(ref, input.copyWith(educationExpense: v)),
              ),
              MoneyField(
                label: s.debts,
                icon: Icons.credit_card,
                initialValue: input.debts,
                helper: rules?.debtsDeductible == false
                    ? 'طبق نظر این مرجع کسر نمی‌شود'
                    : null,
                onChanged: (v) => _update(ref, input.copyWith(debts: v)),
              ),
              MoneyField(
                label: s.other,
                icon: Icons.more_horiz,
                initialValue: input.otherExpenses,
                onChanged: (v) =>
                    _update(ref, input.copyWith(otherExpenses: v)),
              ),
              MoneyField(
                label: s.trousseau,
                icon: Icons.card_giftcard,
                initialValue: input.trousseauExpense,
                helper: (rules?.trousseauExempt ?? false)
                    ? 'طبق نظر این مرجع معاف است'
                    : null,
                onChanged: (v) =>
                    _update(ref, input.copyWith(trousseauExpense: v)),
              ),
            ],
          ),

          // ── سرمایه و اموال ──
          SectionCard(
            title: s.assetsSection,
            icon: Icons.diamond,
            children: [
              MoneyField(
                label: s.businessCapital,
                icon: Icons.storefront,
                initialValue: input.businessCapital,
                onChanged: (v) =>
                    _update(ref, input.copyWith(businessCapital: v)),
              ),
              MoneyField(
                label: s.cashSavings,
                icon: Icons.account_balance,
                initialValue: input.cashSavings,
                onChanged: (v) =>
                    _update(ref, input.copyWith(cashSavings: v)),
              ),
              MoneyField(
                label: s.gold,
                icon: Icons.workspace_premium,
                initialValue: input.gold,
                onChanged: (v) => _update(ref, input.copyWith(gold: v)),
              ),
              MoneyField(
                label: s.coins,
                icon: Icons.paid,
                initialValue: input.coins,
                onChanged: (v) => _update(ref, input.copyWith(coins: v)),
              ),
              MoneyField(
                label: s.currency,
                icon: Icons.currency_exchange,
                initialValue: input.currency,
                onChanged: (v) => _update(ref, input.copyWith(currency: v)),
              ),
              MoneyField(
                label: s.stocks,
                icon: Icons.trending_up,
                initialValue: input.stocks,
                onChanged: (v) => _update(ref, input.copyWith(stocks: v)),
              ),
              MoneyField(
                label: s.emergencySavings,
                icon: Icons.health_and_safety,
                initialValue: input.emergencySavings,
                helper: (rules?.emergencySavingsExempt ?? false)
                    ? 'طبق نظر این مرجع (با شرایط) معاف است'
                    : null,
                onChanged: (v) =>
                    _update(ref, input.copyWith(emergencySavings: v)),
              ),
              MoneyField(
                label: s.futureSavings,
                icon: Icons.event_repeat,
                initialValue: input.futureNecessitiesSavings,
                helper: (rules?.futureNecessitiesSavingsExempt ?? false)
                    ? 'طبق نظر این مرجع معاف است'
                    : null,
                onChanged: (v) =>
                    _update(ref, input.copyWith(futureNecessitiesSavings: v)),
              ),
            ],
          ),

          // ── اموال معاف ──
          SectionCard(
            title: s.exemptSection,
            icon: Icons.verified_user,
            subtitle: 'ارث، مهریه، دیه',
            children: [
              MoneyField(
                label: s.inheritance,
                icon: Icons.family_restroom,
                initialValue: input.inheritance,
                onChanged: (v) => _update(ref, input.copyWith(inheritance: v)),
              ),
              MoneyField(
                label: s.dowry,
                icon: Icons.diamond_outlined,
                initialValue: input.dowry,
                onChanged: (v) => _update(ref, input.copyWith(dowry: v)),
              ),
              MoneyField(
                label: s.bloodMoney,
                icon: Icons.gavel,
                initialValue: input.bloodMoney,
                onChanged: (v) => _update(ref, input.copyWith(bloodMoney: v)),
              ),
              MoneyField(
                label: s.otherExempt,
                icon: Icons.more_horiz,
                initialValue: input.otherExempt,
                onChanged: (v) => _update(ref, input.copyWith(otherExempt: v)),
              ),
            ],
          ),

          // ── حالت محاسبه ──
          Card(
            child: SwitchListTile(
              title: const Text('محاسبه فقط بر مازاد درآمد'),
              subtitle: const Text(
                'در این حالت، دارایی‌های پس‌اندازی لحاظ نمی‌شود.',
              ),
              value: input.incomeOnlyMode,
              activeColor: AppColors.emerald,
              onChanged: (v) =>
                  _update(ref, input.copyWith(incomeOnlyMode: v)),
            ),
          ),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.calculate),
            label: Text(s.calculate),
            onPressed: () {
              ref.read(calculateActionProvider)();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResultPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          InfoBox(text: s.disclaimer, icon: Icons.gavel),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

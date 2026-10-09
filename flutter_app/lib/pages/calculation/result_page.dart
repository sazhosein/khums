import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_strings.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../payment/payment_page.dart';

/// صفحه نتیجه محاسبه با نمایش جزئیات
class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  String _money(double v) {
    final f = NumberFormat('#,##0', 'en');
    return '${f.format(v)} تومان';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final result = ref.watch(khumsResultProvider);
    final marja = ref.watch(selectedMarjaProvider);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.resultTitle)),
        body: const Center(child: Text('نتیجه‌ای یافت نشد.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.resultTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // کارت اصلی خمس واجب
          Card(
            color: AppColors.emerald,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    s.khumsDue,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _money(result.khumsAmount),
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _ShareTile(
                          label: s.imamShare,
                          value: _money(result.imamShare),
                          percent: '${(result.khumsRate * 100 / 2).toStringAsFixed(0)}٪',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white24,
                      ),
                      Expanded(
                        child: _ShareTile(
                          label: s.sayyidShare,
                          value: _money(result.sayyidShare),
                          percent: '${(result.khumsRate * 100 / 2).toStringAsFixed(0)}٪',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // جزئیات محاسبه
          SectionCard(
            title: s.details,
            icon: Icons.list_alt,
            children: [
              ResultTile(
                label: s.totalIncome,
                value: _money(result.totalIncome),
                icon: Icons.savings,
              ),
              ResultTile(
                label: 'مخارج مؤونه (کسر‌شده)',
                value: '- ${_money(result.totalExpensesDeducted)}',
                icon: Icons.receipt_long,
              ),
              if (result.taxableAssets > 0)
                ResultTile(
                  label: 'دارایی‌های مشمول',
                  value: '+ ${_money(result.taxableAssets)}',
                  icon: Icons.diamond,
                ),
              if (result.savingsExempted > 0)
                ResultTile(
                  label: 'پس‌انداز معاف',
                  value: '- ${_money(result.savingsExempted)}',
                  icon: Icons.shield,
                ),
              if (result.exemptAssets > 0)
                ResultTile(
                  label: 'اموال معاف',
                  value: '- ${_money(result.exemptAssets)}',
                  icon: Icons.verified_user,
                ),
              const Divider(),
              ResultTile(
                label: s.surplus,
                value: _money(result.surplus),
                emphasized: true,
                icon: Icons.trending_up,
              ),
              ResultTile(
                label: 'نرخ خمس',
                value: '${(result.khumsRate * 100).toStringAsFixed(0)}٪',
                icon: Icons.percent,
              ),
            ],
          ),

          // جزئیات مخارج
          SectionCard(
            title: 'تفکیک مخارج',
            icon: Icons.pie_chart,
            children: [
              ResultTile(label: s.food, value: _money(result.foodDeducted)),
              ResultTile(label: s.clothing, value: _money(result.clothingDeducted)),
              ResultTile(label: s.housing, value: _money(result.housingDeducted)),
              ResultTile(label: s.medical, value: _money(result.medicalDeducted)),
              ResultTile(label: s.education, value: _money(result.educationDeducted)),
              ResultTile(label: s.debts, value: _money(result.debtsDeducted)),
              ResultTile(label: s.other, value: _money(result.otherDeducted)),
              if (result.trousseauDeducted > 0)
                ResultTile(label: s.trousseau, value: _money(result.trousseauDeducted)),
            ],
          ),

          // هشدارهای شرعی
          if (result.warnings.isNotEmpty)
            SectionCard(
              title: s.warnings,
              icon: Icons.warning_amber,
              children: [
                for (final w in result.warnings)
                  InfoBox(text: w, icon: Icons.gavel, color: AppColors.warn),
              ],
            ),

          // یادداشت‌های فقهی
          if (result.notes.isNotEmpty)
            SectionCard(
              title: s.notes,
              icon: Icons.menu_book,
              children: [
                for (final n in result.notes)
                  InfoBox(text: n, icon: Icons.info_outline),
              ],
            ),

          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.payments),
            label: Text(s.payNow),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentPage(
                  imamShare: result.imamShare,
                  sayyidShare: result.sayyidShare,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          InfoBox(
            text: marja?.rules.disclaimer ?? s.disclaimer,
            icon: Icons.gavel,
            color: AppColors.goldDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  final String label;
  final String value;
  final String percent;

  const _ShareTile({
    required this.label,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        Text(
          percent,
          style: const TextStyle(color: AppColors.goldLight, fontSize: 12),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/islamic_pattern.dart';
import '../calculation/calculation_page.dart';
import '../calculation/khums_year_page.dart';
import '../payment/payment_history_page.dart';
import '../consultation/consultation_page.dart';
import '../settings/settings_page.dart';

/// صفحه اصلی با کارت‌های دسترسی سریع و نمایش وضعیت سال خمسی
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final marja = ref.watch(selectedMarjaProvider);
    final days = ref.watch(daysToKhumsYearProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: IslamicPatternBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // کارت مرجع فعلی
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const IslamicEmblem(size: 56),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرجع تقلید شما',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            marja?.name ?? '—',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // کارت وضعیت سال خمسی (نمایان‌گر ویجت صفحه اصلی)
            Card(
              color: AppColors.emerald,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, color: AppColors.goldLight),
                        const SizedBox(width: 8),
                        Text(
                          s.khumsYear,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (days == null)
                      Text(
                        'برای مشاهده شمارش معکوس، مبدأ سال خمسی را تعیین کنید.',
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$days',
                            style: const TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              s.daysRemaining,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // دسترسی سریع
            _QuickTile(
              icon: Icons.calculate,
              title: s.khumsCalculation,
              subtitle: 'محاسبه خمس بر اساس درآمد و مخارج',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalculationPage()),
              ),
            ),
            _QuickTile(
              icon: Icons.event_available,
              title: s.setupKhumsYear,
              subtitle: 'تعیین مبدأ سال خمسی و یادآور',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KhumsYearPage()),
              ),
            ),
            _QuickTile(
              icon: Icons.payments,
              title: s.payment,
              subtitle: 'پرداخت سهم امام و سهم سادات',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
              ),
            ),
            _QuickTile(
              icon: Icons.support_agent,
              title: s.consultation,
              subtitle: 'چت، تماس و سوالات متداول',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConsultationPage()),
              ),
            ),

            const SizedBox(height: 12),
            InfoBox(text: s.disclaimer, icon: Icons.gavel),
          ],
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.emerald.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.emerald),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left, color: AppColors.gold),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_strings.dart';
import '../../services/notification_service.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// صفحه تعیین سال خمسی با راهنمای تعاملی و یادآور
class KhumsYearPage extends ConsumerWidget {
  const KhumsYearPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final start = ref.watch(khumsYearStartProvider);
    final days = ref.watch(daysToKhumsYearProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.khumsYear)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // راهنمای تعاملی تعیین مبدأ
          SectionCard(
            title: 'راهنمای تعیین مبدأ سال خمسی',
            icon: Icons.help_outline,
            subtitle: 'بر اساس نوع درآمد شما',
            children: const [
              _GuideItem(
                title: 'حقوق و درآمد ثابت ماهانه',
                body: 'مبدأ سال خمسی، اولین روزی است که اولین حقوق را دریافت کرده‌اید.',
              ),
              _GuideItem(
                title: 'درآمد متغیر / آزاد',
                body: 'مبدأ، روزی است که اولین درآمد این نوع کسب را دریافت کرده‌اید.',
              ),
              _GuideItem(
                title: 'کشاورزی',
                body: 'مبدأ، زمان برداشت محصول است.',
              ),
              _GuideItem(
                title: 'تجارت و مغازه',
                body: 'مبدأ، روزی است که سرمایه به گردش افتاده یا اولین فروش انجام شده است.',
              ),
            ],
          ),

          // انتخاب تاریخ مبدأ
          SectionCard(
            title: s.khumsYearStart,
            icon: Icons.calendar_month,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event, color: AppColors.emerald),
                title: Text(
                  start == null
                      ? 'انتخاب نشده'
                      : DateFormat('yyyy/MM/dd').format(start),
                ),
                trailing: const Icon(Icons.edit, color: AppColors.gold),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: start ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    ref.read(khumsYearStartProvider.notifier).state = picked;
                  }
                },
              ),
            ],
          ),

          // وضعیت شمارش معکوس
          if (days != null)
            Card(
              color: AppColors.emerald,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_bottom, color: AppColors.goldLight),
                    const SizedBox(width: 12),
                    Text(
                      '$days ${s.daysRemaining}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // یادآور
          SectionCard(
            title: s.remindMe,
            icon: Icons.notifications_active,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('اعلان ۳۰ روز قبل از سال خمسی'),
                value: true,
                activeColor: AppColors.emerald,
                onChanged: (v) {},
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('اعلان ۷ روز قبل از سال خمسی'),
                value: true,
                activeColor: AppColors.emerald,
                onChanged: (v) {},
              ),
            ],
          ),

          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.alarm_add),
            label: const Text('فعال‌سازی یادآور'),
            onPressed: () async {
              if (start != null) {
                await NotificationService.instance
                    .scheduleKhumsYearReminders(start);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('یادآور سال خمسی فعال شد.'),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String title;
  final String body;
  const _GuideItem({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../onboarding/marja_selection_page.dart';

/// صفحه تنظیمات: زبان، حالت تاریک، تغییر مرجع، تنظیم دستی، حریم خصوصی
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final marja = ref.watch(selectedMarjaProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── مرجع تقلید ──
          SectionCard(
            title: 'مرجع تقلید',
            icon: Icons.mosque,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(marja?.name ?? '—'),
                subtitle: Text(marja?.rules.note ?? ''),
                trailing: const Icon(Icons.chevron_left, color: AppColors.gold),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MarjaSelectionPage(),
                  ),
                ),
              ),
            ],
          ),

          // ── زبان ──
          SectionCard(
            title: s.language,
            icon: Icons.language,
            children: [
              RadioListTile<String>(
                value: 'fa',
                groupValue: locale.languageCode,
                activeColor: AppColors.emerald,
                title: const Text('فارسی'),
                onChanged: (v) =>
                    ref.read(localeProvider.notifier).state = const Locale('fa'),
              ),
              RadioListTile<String>(
                value: 'ar',
                groupValue: locale.languageCode,
                activeColor: AppColors.emerald,
                title: const Text('العربية'),
                onChanged: (v) =>
                    ref.read(localeProvider.notifier).state = const Locale('ar'),
              ),
              RadioListTile<String>(
                value: 'en',
                groupValue: locale.languageCode,
                activeColor: AppColors.emerald,
                title: const Text('English'),
                onChanged: (v) =>
                    ref.read(localeProvider.notifier).state = const Locale('en'),
              ),
            ],
          ),

          // ── ظاهر ──
          SectionCard(
            title: 'ظاهر',
            icon: Icons.palette,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.darkMode),
                value: themeMode == ThemeMode.dark,
                activeColor: AppColors.emerald,
                onChanged: (v) => ref.read(themeModeProvider.notifier).state =
                    v ? ThemeMode.dark : ThemeMode.light,
              ),
            ],
          ),

          // ── تنظیم دستی قواعد ──
          SectionCard(
            title: s.manualOverride,
            icon: Icons.tune,
            subtitle: 'در موارد اختلافی، قواعد را دستی تغییر دهید',
            children: const [
              InfoBox(
                text: 'در صورت تفاوت نظر مرجع شما با قواعد پیش‌فرض، '
                    'می‌توانید کسر یا عدم کسر موارد را در این بخش تنظیم کنید.',
                icon: Icons.tips_and_updates,
                color: AppColors.emerald,
              ),
            ],
          ),

          // ── حریم خصوصی ──
          const SectionCard(
            title: 'حریم خصوصی',
            icon: Icons.privacy_tip,
            children: [
              InfoBox(
                text: 'اطلاعات مالی شما فقط روی دستگاه ذخیره و رمزنگاری می‌شود '
                    'و بدون اجازه شما به سرور ارسال نمی‌گردد.',
                icon: Icons.lock,
                color: AppColors.emerald,
              ),
            ],
          ),

          // ── درباره ──
          const SectionCard(
            title: 'درباره اپلیکیشن',
            icon: Icons.info,
            children: [
              InfoBox(
                text: 'خمس‌یار نسخه ۱.۰.۰ — ابزار کمک‌آموزشی محاسبه خمس. '
                    'این اپلیکیشن صادرکننده حکم شرعی نیست. رایگان و بدون تبلیغات.',
                icon: Icons.volunteer_activism,
                color: AppColors.goldDark,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

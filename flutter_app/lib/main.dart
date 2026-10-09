import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_strings.dart';
import 'state/app_providers.dart';
import 'theme/app_theme.dart';
import 'pages/onboarding/marja_selection_page.dart';
import 'pages/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KhumsYarApp()));
}

class KhumsYarApp extends ConsumerWidget {
  const KhumsYarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final selectedMarja = ref.watch(selectedMarjaProvider);

    return MaterialApp(
      title: 'خمس‌یار',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('fa'),
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      builder: (context, child) {
        // اعمال RTL برای فارسی و عربی
        final direction =
            locale.languageCode == 'en' ? TextDirection.ltr : TextDirection.rtl;
        return Directionality(textDirection: direction, child: child!);
      },
      home: selectedMarja == null
          ? const MarjaSelectionPage(isOnboarding: true)
          : const HomePage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/marja_repository.dart';
import '../models/khums_input.dart';
import '../models/khums_result.dart';
import '../models/marja.dart';
import '../services/khums_calculator.dart';

/// زبان برنامه
final localeProvider = StateProvider<Locale>((ref) => const Locale('fa'));

/// حالت تاریک
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// مرجع انتخاب‌شده
final selectedMarjaProvider = StateProvider<Marja?>((ref) => null);

/// مخزن مراجع (شامل مراجع سفارشی کاربر)
final marjaRepositoryProvider =
    Provider<MarjaRepository>((ref) => const MarjaRepository());

/// لیست مراجع (پیش‌فرض + سفارشی)
final marjasProvider = StateProvider<List<Marja>>((ref) {
  return ref.read(marjaRepositoryProvider).defaultMarjas;
});

/// ورودی محاسبه
final khumsInputProvider = StateProvider<KhumsInput>((ref) => const KhumsInput());

/// موتور محاسبه
final calculatorProvider =
    Provider<KhumsCalculator>((ref) => const KhumsCalculator());

/// نتیجه محاسبه (Nullable)
final khumsResultProvider = StateProvider<KhumsResult?>((ref) => null);

/// اجرای محاسبه با مرجع و ورودی فعلی
final calculateActionProvider = Provider<void Function()>((ref) {
  return () {
    final input = ref.read(khumsInputProvider);
    final marja = ref.read(selectedMarjaProvider);
    if (marja == null) return;
    final result =
        ref.read(calculatorProvider).calculate(input: input, marja: marja);
    ref.read(khumsResultProvider.notifier).state = result;
  };
});

/// تاریخ شروع سال خمسی
final khumsYearStartProvider = StateProvider<DateTime?>((ref) => null);

/// روزهای باقی‌مانده تا سال خمسی
final daysToKhumsYearProvider = Provider<int?>((ref) {
  final start = ref.watch(khumsYearStartProvider);
  if (start == null) return null;
  final now = DateTime.now();
  var next = DateTime(now.year, start.month, start.day);
  if (next.isBefore(now)) {
    next = DateTime(now.year + 1, start.month, start.day);
  }
  return next.difference(now).inDays;
});

/// یک رکورد پرداخت
class PaymentRecord {
  final String id;
  final DateTime date;
  final double amount;
  final String type; // 'imam' | 'sayyid' | 'full'
  final String gateway;
  final String status; // 'success' | 'pending' | 'failed'

  const PaymentRecord({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.gateway,
    required this.status,
  });
}

/// تاریخچه پرداخت‌ها
final paymentHistoryProvider =
    StateProvider<List<PaymentRecord>>((ref) => const []);

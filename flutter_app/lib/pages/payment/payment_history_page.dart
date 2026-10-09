import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_strings.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// تاریخچه پرداخت‌ها
class PaymentHistoryPage extends ConsumerWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final history = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.payment)),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.emerald.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(s.noPayments),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  title: s.paymentHistory,
                  icon: Icons.history,
                  children: [
                    for (final p in history)
                      ResultTile(
                        label:
                            '${_typeLabel(s, p.type)} — ${p.gateway}\n${DateFormat('yyyy/MM/dd HH:mm').format(p.date)}',
                        value: '${NumberFormat('#,##0').format(p.amount)} تومان',
                        icon: _statusIcon(p.status),
                        color: _statusColor(p.status),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  String _typeLabel(AppStrings s, String type) {
    switch (type) {
      case 'imam':
        return s.imamShare;
      case 'sayyid':
        return s.sayyidShare;
      default:
        return 'خمس کامل';
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.hourglass_empty;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.success;
      case 'failed':
        return AppColors.danger;
      default:
        return AppColors.warn;
    }
  }
}

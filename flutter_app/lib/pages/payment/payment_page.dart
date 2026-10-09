import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_strings.dart';
import '../../services/payment_service.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// صفحه پرداخت خمس — انتخاب سهم و درگاه
class PaymentPage extends ConsumerStatefulWidget {
  final double imamShare;
  final double sayyidShare;

  const PaymentPage({
    super.key,
    required this.imamShare,
    required this.sayyidShare,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String _target = 'imam'; // imam | sayyid | full
  PaymentGateway _gateway = PaymentGateway.zarinpal;
  bool _loading = false;

  double get _amount {
    switch (_target) {
      case 'imam':
        return widget.imamShare;
      case 'sayyid':
        return widget.sayyidShare;
      default:
        return widget.imamShare + widget.sayyidShare;
    }
  }

  String _money(double v) => '${NumberFormat('#,##0').format(v)} تومان';

  Future<void> _pay() async {
    final marja = ref.read(selectedMarjaProvider);
    final rules = marja?.rules;

    // بررسی شرط اجازه برای سهم امام
    // اگر پرداخت شامل سهم امام باشد (سهم امام یا هر دو سهم) و مرجع اجازه را
    // الزامی بداند، تأیید از کاربر گرفته می‌شود.
    final imamShareRequested = _target == 'imam' || _target == 'full';
    final needsPermission =
        imamShareRequested && (rules?.imamShareRequiresPermission ?? true);

    if (needsPermission) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('توجه شرعی'),
          content: const Text(
            'پرداخت سهم امام نیاز به اجازه از دفتر مرجع دارد. '
            'آیا از وجود اجازه اطمینان دارید؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ادامه'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _loading = true);

    final service = PaymentService();
    final result = await service.requestPayment(
      amountToman: _amount,
      gateway: _gateway,
      description: 'پرداخت خمس - ${marja?.name ?? ''}',
      callbackUrl: 'https://api.khumsyar.app/v1/payments/callback',
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (result.success && result.paymentUrl != null) {
      // ثبت در تاریخچه
      ref.read(paymentHistoryProvider.notifier).state = [
        PaymentRecord(
          id: result.authority ?? DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          amount: _amount,
          type: _target,
          gateway: _gateway.label,
          status: 'pending',
        ),
        ...ref.read(paymentHistoryProvider),
      ];
      await launchUrl(Uri.parse(result.paymentUrl!),
          mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'خطا در ایجاد پرداخت')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final marja = ref.watch(selectedMarjaProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.payment)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.emerald,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'مبلغ قابل پرداخت',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _money(_amount),
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SectionCard(
            title: 'انتخاب سهم',
            icon: Icons.account_balance_wallet,
            children: [
              RadioListTile<String>(
                value: 'imam',
                groupValue: _target,
                activeColor: AppColors.emerald,
                title: Text('${s.imamShare} — ${_money(widget.imamShare)}'),
                onChanged: (v) => setState(() => _target = v!),
              ),
              RadioListTile<String>(
                value: 'sayyid',
                groupValue: _target,
                activeColor: AppColors.emerald,
                title: Text('${s.sayyidShare} — ${_money(widget.sayyidShare)}'),
                onChanged: (v) => setState(() => _target = v!),
              ),
              RadioListTile<String>(
                value: 'full',
                groupValue: _target,
                activeColor: AppColors.emerald,
                title: Text(
                  'هر دو سهم — ${_money(widget.imamShare + widget.sayyidShare)}',
                ),
                onChanged: (v) => setState(() => _target = v!),
              ),
            ],
          ),

          SectionCard(
            title: s.gateway,
            icon: Icons.credit_score,
            children: [
              for (final g in PaymentGateway.values)
                RadioListTile<PaymentGateway>(
                  value: g,
                  groupValue: _gateway,
                  activeColor: AppColors.emerald,
                  title: Text(g.label),
                  onChanged: (v) => setState(() => _gateway = v!),
                ),
            ],
          ),

          if (marja != null)
            InfoBox(
              text: marja.rules.note,
              icon: Icons.menu_book,
              color: AppColors.goldDark,
            ),

          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.payment),
            label: Text(_loading ? 'در حال اتصال...' : 'پرداخت'),
            onPressed: _loading ? null : _pay,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

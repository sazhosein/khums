import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// قالب کارت یک بخش با عنوان و آیکون
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? subtitle;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.emerald, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// فیلد ورودی مبلغ (تومان) با فرمت‌دهی و جداکننده هزارگان
class MoneyField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final String? helper;

  const MoneyField({
    super.key,
    required this.label,
    required this.onChanged,
    this.icon,
    this.initialValue = 0,
    this.helper,
  });

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue == 0
          ? ''
          : _format(widget.initialValue.toInt().toString()),
    );
  }

  String _format(String digits) {
    if (digits.isEmpty) return '';
    final buf = StringBuffer();
    final reversed = digits.split('').reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) buf.write(',');
      buf.write(reversed[i]);
    }
    return buf.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TextInputFormatter.withFunction((oldValue, newValue) {
            final digits = newValue.text.replaceAll(',', '');
            return TextEditingValue(
              text: _format(digits),
              selection: TextSelection.collapsed(
                offset: _format(digits).length,
              ),
            );
          }),
        ],
        onChanged: (v) {
          final digits = v.replaceAll(',', '');
          widget.onChanged(double.tryParse(digits) ?? 0);
        },
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.helper,
          suffixText: 'تومان',
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        ),
      ),
    );
  }
}

/// کارت نمایش نتیجه با رنگ متمایز
class ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool emphasized;
  final IconData? icon;

  const ResultTile({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.emphasized = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: emphasized
            ? (color ?? AppColors.emerald).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color ?? AppColors.emerald),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: emphasized
                  ? Theme.of(context).textTheme.titleMedium
                  : Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: emphasized ? 18 : 15,
              color: color ?? AppColors.emeraldDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// جعبه هشدار / یادداشت فقهی
class InfoBox extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const InfoBox({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
    this.color = AppColors.warn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

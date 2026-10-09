import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_strings.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// صفحه مشاوره: چت آنلاین، تماس تلفنی، سوالات متداول
class ConsultationPage extends ConsumerStatefulWidget {
  const ConsultationPage({super.key});

  @override
  ConsumerState<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends ConsumerState<ConsultationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final marja = ref.watch(selectedMarjaProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.consultation),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.goldLight,
          tabs: const [
            Tab(text: 'چت', icon: Icon(Icons.chat)),
            Tab(text: 'تماس', icon: Icon(Icons.call)),
            Tab(text: 'سوالات', icon: Icon(Icons.help)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // ── چت آنلاین ──
          _ChatTab(marjaName: marja?.name ?? ''),

          // ── تماس تلفنی ──
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                title: s.callOffice,
                icon: Icons.phone,
                subtitle: marja?.name ?? '',
                children: [
                  if (marja?.officePhone != null)
                    ListTile(
                      leading: const Icon(
                        Icons.call,
                        color: AppColors.emerald,
                      ),
                      title: Text(marja!.officePhone!),
                      subtitle: const Text('دفتر مرکزی'),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                      ),
                      onTap: () => _call(marja.officePhone!),
                    ),
                  if (marja != null)
                    for (final city in marja.offices)
                      ListTile(
                        leading: const Icon(
                          Icons.location_city,
                          color: AppColors.gold,
                        ),
                        title: Text('دفتر $city'),
                      ),
                ],
              ),
              if (marja?.websiteUrl != null)
                InfoBox(
                  text: 'وب‌سایت رسمی: ${marja!.websiteUrl}',
                  icon: Icons.public,
                  color: AppColors.emerald,
                ),
            ],
          ),

          // ── سوالات متداول بر اساس مرجع ──
          _FaqTab(marjaId: marja?.id ?? ''),
        ],
      ),
    );
  }
}

class _ChatTab extends StatefulWidget {
  final String marjaName;
  const _ChatTab({required this.marjaName});

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'from': 'advisor',
      'text': 'سلام! من مشاور فقهی شما هستم. چطور می‌توانم کمکتان کنم؟',
    },
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'from': 'user', 'text': text});
      _messages.add({
        'from': 'advisor',
        'text': 'سوال شما ثبت شد. کارشناسان دفتر مرجع در اسرع وقت پاسخ می‌دهند.',
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final m = _messages[i];
              final isUser = m['from'] == 'user';
              return Align(
                alignment:
                    isUser ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 280),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.emerald
                        : AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    m['text']!,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.emeraldDark,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'پیام خود را بنویسید...',
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _send,
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqTab extends StatelessWidget {
  final String marjaId;
  const _FaqTab({required this.marjaId});

  static const _faqs = [
    {
      'q': 'خمس چیست و بر چه چیزی تعلق می‌گیرد؟',
      'a': 'خمس یک‌پنجم (۲۰٪) مازاد درآمد سالانه پس از کسر مخارج زندگی است.',
    },
    {
      'q': 'سهم امام و سهم سادات چگونه تقسیم می‌شود؟',
      'a': 'خمس به دو نیم تقسیم می‌شود: نیمی سهم امام (عج) و نیمی سهم سادات.',
    },
    {
      'q': 'آیا پس‌انداز مشمول خمس است؟',
      'a': 'بسته به نظر مرجع متفاوت است؛ برخی مراجع پس‌انداز برای پیشامدها را معاف می‌دانند.',
    },
    {
      'q': 'سرمایه تجاری چگونه محاسبه می‌شود؟',
      'a': 'اگر از درآمد سال خریداری شده و خمس آن پرداخت نشده باشد، مشمول خمس است.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final faq in _faqs)
          Card(
            child: ExpansionTile(
              title: Text(faq['q']!),
              childrenPadding: const EdgeInsets.all(16),
              children: [Text(faq['a']!)],
            ),
          ),
        const SizedBox(height: 12),
        const InfoBox(
          text: 'این پاسخ‌ها جنبه عمومی دارند. برای فتوای دقیق با دفتر مرجع خود تماس بگیرید.',
          icon: Icons.gavel,
        ),
      ],
    );
  }
}

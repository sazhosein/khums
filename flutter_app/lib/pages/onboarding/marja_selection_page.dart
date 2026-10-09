import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../models/marja.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/islamic_pattern.dart';

/// صفحه انتخاب مرجع تقلید (ابتدا و قابل تغییر از تنظیمات)
class MarjaSelectionPage extends ConsumerStatefulWidget {
  final bool isOnboarding;
  const MarjaSelectionPage({super.key, this.isOnboarding = false});

  @override
  ConsumerState<MarjaSelectionPage> createState() => _MarjaSelectionPageState();
}

class _MarjaSelectionPageState extends ConsumerState<MarjaSelectionPage> {
  int? _selectedIndex;

  void _confirm() {
    final marjas = ref.read(marjasProvider);
    if (_selectedIndex == null) return;
    ref.read(selectedMarjaProvider.notifier).state = marjas[_selectedIndex!];
    if (!widget.isOnboarding) Navigator.of(context).pop();
  }

  Future<void> _addCustomMarja() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('افزودن مرجع'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'نام مرجع تقلید'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final repo = ref.read(marjaRepositoryProvider);
    final newMarja = repo.createCustomMarja(name: name);
    ref.read(marjasProvider.notifier).state = [
      ...ref.read(marjasProvider),
      newMarja,
    ];
    setState(() {
      _selectedIndex = ref.read(marjasProvider).length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final marjas = ref.watch(marjasProvider);

    return Scaffold(
      body: IslamicPatternBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const IslamicEmblem(size: 80),
              const SizedBox(height: 16),
              Text(
                s.chooseMarja,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  s.chooseMarjaSub,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: marjas.length,
                  itemBuilder: (context, i) {
                    final Marja m = marjas[i];
                    final selected = _selectedIndex == i;
                    return Card(
                      color: selected
                          ? AppColors.emerald.withOpacity(0.08)
                          : null,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => _selectedIndex = i),
                        child: Container(
                          decoration: selected
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.gold,
                                    width: 2,
                                  ),
                                )
                              : null,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    AppColors.emerald.withOpacity(0.12),
                                child: const Icon(
                                  Icons.mosque,
                                  color: AppColors.emerald,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    if (m.rules.note.isNotEmpty)
                                      Text(
                                        m.rules.note,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.emerald,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _addCustomMarja,
                      icon: const Icon(Icons.add),
                      label: Text(s.addOtherMarja),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        foregroundColor: AppColors.emerald,
                        side: const BorderSide(color: AppColors.emerald),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _selectedIndex == null ? null : _confirm,
                      child: Text(widget.isOnboarding ? s.next : s.save),
                    ),
                    const SizedBox(height: 10),
                    InfoBox(
                      text: s.disclaimer,
                      icon: Icons.gavel,
                      color: AppColors.goldDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

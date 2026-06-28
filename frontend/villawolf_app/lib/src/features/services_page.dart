import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _servicesProvider =
    FutureProvider.autoDispose((ref) => ref.read(apiProvider).listServices(includeInactive: true));

class ServicesPage extends ConsumerWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final services = ref.watch(_servicesProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TopBar(
          title: 'Servicios',
          actions: [
            AppButton(
              label: 'Nuevo',
              icon: Icons.add,
              size: AppButtonSize.sm,
              onPressed: () async {
                await context.push('/services/new');
                ref.invalidate(_servicesProvider);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        services.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: RingLoader())),
          error: (e, _) => Text('No se pudieron cargar los servicios.\n$e', style: TextStyle(color: t.textMuted)),
          data: (list) => SectionCard(
            title: 'Catálogo (${list.length})',
            child: Column(children: [
              for (final s in list)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await context.push('/services/edit/${s.id}', extra: s);
                            ref.invalidate(_servicesProvider);
                          },
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.name, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600)),
                            Text('${s.categoryName} · ${s.durationMinutes}′ · ${Formatters.money(s.basePrice)} · ${Formatters.label(s.targetAudience)}',
                                style: TextStyle(color: t.textMuted, fontSize: 12)),
                          ]),
                        ),
                      ),
                      Switch(
                        value: s.isActive,
                        onChanged: (v) async {
                          await ref.read(apiProvider).setServiceActive(s.id, v);
                          ref.invalidate(_servicesProvider);
                        },
                      ),
                    ],
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

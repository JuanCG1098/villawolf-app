import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _servicesProvider =
    FutureProvider.autoDispose((ref) => ref.read(apiProvider).listServices(includeInactive: true));

class ServicesPage extends ConsumerWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(_servicesProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Servicios',
                  style: TextStyle(color: AppColors.onInk, fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            FilledButton.icon(
              onPressed: () async {
                await context.push('/services/new');
                ref.invalidate(_servicesProvider);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nuevo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        services.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Text('No se pudieron cargar los servicios.\n$e', style: const TextStyle(color: AppColors.muted)),
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
                            Text(s.name, style: const TextStyle(color: AppColors.onInk, fontWeight: FontWeight.w600)),
                            Text('${s.categoryName} · ${s.durationMinutes}′ · ${Formatters.money(s.basePrice)} · ${Formatters.label(s.targetAudience)}',
                                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
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

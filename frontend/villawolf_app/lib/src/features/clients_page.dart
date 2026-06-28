import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../ui/widgets.dart';

final _clientSearchProvider = StateProvider.autoDispose<String>((ref) => '');
final _clientsProvider = FutureProvider.autoDispose((ref) {
  final query = ref.watch(_clientSearchProvider);
  return ref.read(apiProvider).listClients(search: query);
});

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final clients = ref.watch(_clientsProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TopBar(
          title: 'Clientes',
          actions: [
            AppButton(
              label: 'Nuevo',
              icon: Icons.add,
              size: AppButtonSize.sm,
              onPressed: () async {
                await context.push('/clients/new');
                ref.invalidate(_clientsProvider);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppSearchField(
          hint: 'Buscar por nombre, teléfono o email…',
          onChanged: (v) => ref.read(_clientSearchProvider.notifier).state = v.trim(),
        ),
        const SizedBox(height: 16),
        clients.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: RingLoader())),
          error: (e, _) => Text('No se pudieron cargar los clientes.\n$e', style: TextStyle(color: t.textMuted)),
          data: (list) => SectionCard(
            title: 'Resultados (${list.length})',
            child: list.isEmpty
                ? const EmptyState(icon: Icons.people_outline, title: 'Sin clientes')
                : DataList(children: [
                    for (final c in list)
                      DataRow2(
                        leading: Avatar(name: c.fullName, size: 34),
                        title: c.fullName,
                        subtitle: [c.phone, c.email].where((x) => x != null && x.isNotEmpty).join(' · '),
                        trailing: Icon(Icons.chevron_right, color: t.textMuted),
                        onTap: () async {
                          await context.push('/clients/edit/${c.id}', extra: c);
                          ref.invalidate(_clientsProvider);
                        },
                      ),
                  ]),
          ),
        ),
      ],
    );
  }
}

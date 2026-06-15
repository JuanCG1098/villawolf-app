import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
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
    final clients = ref.watch(_clientsProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Clientes',
                  style: TextStyle(color: AppColors.onInk, fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            FilledButton.icon(
              onPressed: () async {
                await context.push('/clients/new');
                ref.invalidate(_clientsProvider);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nuevo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar por nombre, teléfono o email…',
            prefixIcon: Icon(Icons.search, color: AppColors.muted),
          ),
          onChanged: (v) => ref.read(_clientSearchProvider.notifier).state = v.trim(),
        ),
        const SizedBox(height: 16),
        clients.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Text('No se pudieron cargar los clientes.\n$e', style: const TextStyle(color: AppColors.muted)),
          data: (list) => SectionCard(
            title: 'Resultados (${list.length})',
            child: list.isEmpty
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Sin clientes.', style: TextStyle(color: AppColors.muted)))
                : Column(children: [
                    for (final c in list)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.fullName, style: const TextStyle(color: AppColors.onInk)),
                        subtitle: Text([c.phone, c.email].where((x) => x != null && x.isNotEmpty).join(' · '),
                            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
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

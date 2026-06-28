import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _productsProvider = FutureProvider.autoDispose((ref) => ref.read(apiProvider).listProducts());

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final products = ref.watch(_productsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_productsProvider),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const TopBar(title: 'Inventario', subtitle: 'Productos y stock'),
          const SizedBox(height: 20),
          products.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: RingLoader())),
            error: (e, _) => Text('No se pudo cargar el inventario.\n$e', style: TextStyle(color: t.textMuted)),
            data: (list) => SectionCard(
              title: 'Productos (${list.length})',
              child: list.isEmpty
                  ? const EmptyState(icon: Icons.inventory_2_outlined, title: 'Sin productos')
                  : Column(children: [
                      for (final p in list)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.name, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600)),
                                Text(p.category, style: TextStyle(color: t.textMuted, fontSize: 12)),
                              ]),
                            ),
                            if (p.salePrice != null) ...[
                              Text(Formatters.money(p.salePrice!), style: TextStyle(color: t.textMuted)),
                              const SizedBox(width: 16),
                            ],
                            Text('Stock: ${p.currentStock}',
                                style: TextStyle(
                                    color: p.isLowStock ? t.dangerFg : t.textPrimary,
                                    fontWeight: FontWeight.w600)),
                            if (p.isLowStock) ...[
                              const SizedBox(width: 10),
                              const AppBadge(label: 'Bajo stock', intent: AppIntent.danger),
                            ],
                          ]),
                        ),
                    ]),
            ),
          ),
        ],
      ),
    );
  }
}

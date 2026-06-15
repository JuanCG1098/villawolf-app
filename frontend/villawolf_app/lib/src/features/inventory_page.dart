import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _productsProvider = FutureProvider.autoDispose((ref) => ref.read(apiProvider).listProducts());

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(_productsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_productsProvider),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Inventario',
              style: TextStyle(color: AppColors.onInk, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Productos y stock', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          products.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => Text('No se pudo cargar el inventario.\n$e', style: const TextStyle(color: AppColors.muted)),
            data: (list) => SectionCard(
              title: 'Productos (${list.length})',
              child: list.isEmpty
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Sin productos.', style: TextStyle(color: AppColors.muted)))
                  : Column(children: [
                      for (final p in list)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.name, style: const TextStyle(color: AppColors.onInk, fontWeight: FontWeight.w600)),
                                Text(p.category, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                              ]),
                            ),
                            if (p.salePrice != null) ...[
                              Text(Formatters.money(p.salePrice!), style: const TextStyle(color: AppColors.muted)),
                              const SizedBox(width: 16),
                            ],
                            Text('Stock: ${p.currentStock}',
                                style: TextStyle(
                                    color: p.isLowStock ? AppColors.red : AppColors.onInk,
                                    fontWeight: FontWeight.w600)),
                            if (p.isLowStock) ...[
                              const SizedBox(width: 10),
                              const _Badge(text: 'Bajo stock', color: AppColors.red),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

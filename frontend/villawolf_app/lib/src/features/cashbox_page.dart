import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _summaryProvider = FutureProvider.autoDispose((ref) => ref.read(apiProvider).cashboxSummary());
final _paymentsProvider = FutureProvider.autoDispose((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return ref.read(apiProvider).listPayments(fromUtc: start, toUtc: start.add(const Duration(days: 1)));
});

class CashboxPage extends ConsumerWidget {
  const CashboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final summary = ref.watch(_summaryProvider);
    final payments = ref.watch(_paymentsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_summaryProvider);
        ref.invalidate(_paymentsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const TopBar(title: 'Caja', subtitle: 'Movimientos del día'),
          const SizedBox(height: 20),
          summary.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: RingLoader())),
            error: (e, _) => Text('No se pudo cargar la caja.\n$e', style: TextStyle(color: t.textMuted)),
            data: (s) {
              final cards = <Widget>[
                StatCard(icon: Icons.payments_outlined, value: Formatters.money(s.total), label: 'Total del día'),
                StatCard(icon: Icons.receipt_long_outlined, value: '${s.count}', label: 'Movimientos'),
                for (final m in s.byMethod)
                  StatCard(icon: Icons.account_balance_wallet_outlined, value: Formatters.money(m.total), label: Formatters.label(m.method)),
              ];
              return LayoutBuilder(builder: (context, c) {
                final cols = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 560 ? 2 : 1);
                const gap = 16.0;
                final w = (c.maxWidth - gap * (cols - 1)) / cols;
                return Wrap(spacing: gap, runSpacing: gap, children: [for (final card in cards) SizedBox(width: w, child: card)]);
              });
            },
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: 'Pagos de hoy',
            child: payments.when(
              loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: RingLoader())),
              error: (e, _) => Text('$e', style: TextStyle(color: t.textMuted)),
              data: (list) => list.isEmpty
                  ? const EmptyState(icon: Icons.point_of_sale_outlined, title: 'Sin pagos registrados hoy')
                  : Column(children: [
                      for (final p in list)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [
                            SizedBox(width: 56, child: Text(Formatters.time(p.createdAtUtc), style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600))),
                            Expanded(child: Text('${Formatters.label(p.method)} · ${Formatters.label(p.type)}', style: TextStyle(color: t.textPrimary))),
                            Text(Formatters.money(p.amount), style: TextStyle(color: t.brand, fontWeight: FontWeight.w600)),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
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
          const Text('Caja',
              style: TextStyle(color: AppColors.onInk, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Movimientos del día', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          summary.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => Text('No se pudo cargar la caja.\n$e', style: const TextStyle(color: AppColors.muted)),
            data: (s) {
              final cards = <Widget>[
                MetricCard(icon: Icons.payments_outlined, value: Formatters.money(s.total), label: 'Total del día'),
                MetricCard(icon: Icons.receipt_long_outlined, value: '${s.count}', label: 'Movimientos'),
                for (final m in s.byMethod)
                  MetricCard(icon: Icons.account_balance_wallet_outlined, value: Formatters.money(m.total), label: Formatters.label(m.method)),
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
              loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('$e', style: const TextStyle(color: AppColors.muted)),
              data: (list) => list.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Sin pagos registrados hoy.', style: TextStyle(color: AppColors.muted)))
                  : Column(children: [
                      for (final p in list)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [
                            SizedBox(width: 56, child: Text(Formatters.time(p.createdAtUtc), style: const TextStyle(color: AppColors.onInk, fontWeight: FontWeight.w600))),
                            Expanded(child: Text('${Formatters.label(p.method)} · ${Formatters.label(p.type)}', style: const TextStyle(color: AppColors.onInk))),
                            Text(Formatters.money(p.amount), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
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

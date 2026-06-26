import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _summaryProvider = FutureProvider.autoDispose((ref) => ref.read(apiProvider).dashboardSummary());
final _todayProvider = FutureProvider.autoDispose((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return ref.read(apiProvider).listAppointments(fromUtc: start, toUtc: start.add(const Duration(days: 1)));
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(_summaryProvider);
    final today = ref.watch(_todayProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_summaryProvider);
        ref.invalidate(_todayProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Dashboard',
              style: TextStyle(color: AppColors.onInk, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Resumen del día', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          summary.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => _ErrorBox(message: '$e', onRetry: () => ref.invalidate(_summaryProvider)),
            data: (s) => _Metrics(s),
          ),
          const SizedBox(height: 20),
          today.maybeWhen(
            data: (appts) => SectionCard(
              title: 'Turnos de hoy',
              child: appts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No hay turnos para hoy.', style: TextStyle(color: AppColors.muted)))
                  : Column(children: [for (final a in appts) _AppointmentRow(a)]),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics(this.s);
  final DashboardSummaryModel s;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      MetricCard(icon: Icons.event_available_outlined, value: '${s.appointmentsToday}', label: 'Turnos hoy'),
      MetricCard(icon: Icons.check_circle_outline, value: '${s.confirmed}', label: 'Confirmados'),
      MetricCard(icon: Icons.hourglass_empty, value: '${s.pending}', label: 'Pendientes'),
      MetricCard(icon: Icons.payments_outlined, value: Formatters.money(s.revenueToday), label: 'Ingresos (hoy)'),
      MetricCard(icon: Icons.people_outline, value: '${s.activeEmployees}', label: 'Empleados'),
      MetricCard(icon: Icons.design_services_outlined, value: '${s.activeServices}', label: 'Servicios'),
      MetricCard(icon: Icons.inventory_2_outlined, value: '${s.lowStockProducts}', label: 'Bajo stock'),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 560 ? 2 : 1);
      const gap = 16.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final c in cards) SizedBox(width: width, child: c)],
      );
    });
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow(this.a);
  final AppointmentModel a;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(Formatters.time(a.startUtc),
                style: const TextStyle(color: AppColors.onInk, fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(a.serviceName, style: const TextStyle(color: AppColors.onInk))),
          Text(Formatters.money(a.totalPrice), style: const TextStyle(color: AppColors.muted)),
          const SizedBox(width: 12),
          StatusChip(status: a.status),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.muted),
          const SizedBox(height: 8),
          const Text('No se pudieron cargar los datos.', style: TextStyle(color: AppColors.onInk)),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

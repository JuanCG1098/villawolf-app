import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _employeesProvider =
    FutureProvider.autoDispose((ref) => ref.read(apiProvider).listEmployees());
final _servicesProvider =
    FutureProvider.autoDispose((ref) => ref.read(apiProvider).listServices());
final _todayProvider = FutureProvider.autoDispose((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return ref.read(apiProvider).listAppointments(fromUtc: start, toUtc: start.add(const Duration(days: 1)));
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(_todayProvider);
    final employees = ref.watch(_employeesProvider);
    final services = ref.watch(_servicesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_todayProvider);
        ref.invalidate(_employeesProvider);
        ref.invalidate(_servicesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Dashboard',
              style: TextStyle(color: AppColors.onInk, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Resumen del día', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          today.when(
            loading: () => const _Loading(),
            error: (e, _) => _ErrorBox(message: '$e', onRetry: () => ref.invalidate(_todayProvider)),
            data: (appts) => _Metrics(
              appts: appts,
              employees: employees.valueOrNull?.length,
              services: services.valueOrNull?.length,
            ),
          ),
          const SizedBox(height: 20),
          today.maybeWhen(
            data: (appts) => SectionCard(
              title: 'Turnos de hoy',
              child: appts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No hay turnos para hoy.', style: TextStyle(color: AppColors.muted)),
                    )
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
  const _Metrics({required this.appts, this.employees, this.services});

  final List<AppointmentModel> appts;
  final int? employees;
  final int? services;

  @override
  Widget build(BuildContext context) {
    final confirmed = appts.where((a) => a.status == 'Confirmed').length;
    final pending = appts.where((a) => a.status == 'Pending').length;
    final revenue = appts
        .where((a) => a.status == 'Completed')
        .fold<num>(0, (sum, a) => sum + a.totalPrice);

    final cards = <Widget>[
      MetricCard(icon: Icons.event_available_outlined, value: '${appts.length}', label: 'Turnos hoy'),
      MetricCard(icon: Icons.check_circle_outline, value: '$confirmed', label: 'Confirmados'),
      MetricCard(icon: Icons.hourglass_empty, value: '$pending', label: 'Pendientes'),
      MetricCard(icon: Icons.payments_outlined, value: Formatters.money(revenue), label: 'Ingresos (hoy)'),
      MetricCard(icon: Icons.people_outline, value: employees?.toString() ?? '—', label: 'Empleados'),
      MetricCard(icon: Icons.design_services_outlined, value: services?.toString() ?? '—', label: 'Servicios'),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 560 ? 2 : 1);
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

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _employeesProvider =
    FutureProvider.autoDispose((ref) => ref.read(apiProvider).listEmployees());

final _selectedEmployeeProvider = StateProvider<String?>((ref) => null);

final _selectedDateProvider = StateProvider<DateTime>((ref) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
});

final _dayAppointmentsProvider = FutureProvider.autoDispose((ref) async {
  final employeeId = ref.watch(_selectedEmployeeProvider);
  final date = ref.watch(_selectedDateProvider);
  return ref.read(apiProvider).listAppointments(
    fromUtc: date,
    toUtc: date.add(const Duration(days: 1)),
    employeeId: employeeId,
  );
});

final _freeSlotsProvider = FutureProvider.autoDispose((ref) async {
  final employeeId = ref.watch(_selectedEmployeeProvider);
  final date = ref.watch(_selectedDateProvider);
  if (employeeId == null) return <FreeSlotModel>[];
  return ref.read(apiProvider).freeSlots(employeeId: employeeId, date: date);
});

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Default to the first employee once the list loads.
    ref.listen(_employeesProvider, (_, next) {
      next.whenData((emps) {
        if (ref.read(_selectedEmployeeProvider) == null && emps.isNotEmpty) {
          ref.read(_selectedEmployeeProvider.notifier).state = emps.first.id;
        }
      });
    });

    final employees = ref.watch(_employeesProvider);
    final date = ref.watch(_selectedDateProvider);
    final selectedEmployee = ref.watch(_selectedEmployeeProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Calendario',
                  style: TextStyle(color: AppColors.onInk, fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            FilledButton.icon(
              onPressed: () async {
                await context.push('/appointments/new');
                ref.invalidate(_dayAppointmentsProvider);
                ref.invalidate(_freeSlotsProvider);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nuevo turno'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            employees.when(
              loading: () => const SizedBox(width: 240, child: LinearProgressIndicator()),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.red)),
              data: (emps) => Container(
                width: 240,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedEmployee,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceAlt,
                    hint: const Text('Profesional', style: TextStyle(color: AppColors.muted)),
                    items: [
                      for (final e in emps)
                        DropdownMenuItem(value: e.id, child: Text(e.fullName)),
                    ],
                    onChanged: (v) => ref.read(_selectedEmployeeProvider.notifier).state = v,
                  ),
                ),
              ),
            ),
            _DateStepper(
              date: date,
              onChange: (d) => ref.read(_selectedDateProvider.notifier).state = d,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(title: 'Turnos — ${Formatters.date(date)}', child: const _Appointments()),
        const SizedBox(height: 16),
        SectionCard(title: 'Disponibilidad', child: const _FreeSlots()),
      ],
    );
  }
}

class _DateStepper extends StatelessWidget {
  const _DateStepper({required this.date, required this.onChange});

  final DateTime date;
  final ValueChanged<DateTime> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onChange(date.subtract(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_left),
        ),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );
            if (picked != null) onChange(DateTime(picked.year, picked.month, picked.day));
          },
          child: Text(Formatters.date(date)),
        ),
        IconButton(
          onPressed: () => onChange(date.add(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _Appointments extends ConsumerWidget {
  const _Appointments();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appts = ref.watch(_dayAppointmentsProvider);
    return appts.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('No se pudieron cargar los turnos.\n$e', style: const TextStyle(color: AppColors.muted)),
      data: (list) {
        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Sin turnos para este día.', style: TextStyle(color: AppColors.muted)),
          );
        }
        return Column(
          children: [
            for (final a in list)
              InkWell(
                onTap: () async {
                  await context.push('/appointments/${a.id}');
                  ref.invalidate(_dayAppointmentsProvider);
                  ref.invalidate(_freeSlotsProvider);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text('${Formatters.time(a.startUtc)} – ${Formatters.time(a.endUtc)}',
                            style: const TextStyle(color: AppColors.onInk, fontWeight: FontWeight.w600)),
                      ),
                      Expanded(child: Text(a.serviceName, style: const TextStyle(color: AppColors.onInk))),
                      StatusChip(status: a.status),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FreeSlots extends ConsumerWidget {
  const _FreeSlots();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(_freeSlotsProvider);
    return slots.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('No se pudo calcular la disponibilidad.\n$e', style: const TextStyle(color: AppColors.muted)),
      data: (list) {
        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Sin horarios disponibles este día.', style: TextStyle(color: AppColors.muted)),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in list)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(s.localStart, style: const TextStyle(color: AppColors.onInk)),
              ),
          ],
        );
      },
    );
  }
}

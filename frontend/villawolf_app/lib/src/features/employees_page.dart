import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../ui/widgets.dart';

final _employeesProvider =
    FutureProvider.autoDispose((ref) => ref.read(apiProvider).listEmployeesAll());

class EmployeesPage extends ConsumerWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final employees = ref.watch(_employeesProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TopBar(
          title: 'Empleados',
          actions: [
            AppButton(
              label: 'Nuevo',
              icon: Icons.add,
              size: AppButtonSize.sm,
              onPressed: () async {
                await context.push('/employees/new');
                ref.invalidate(_employeesProvider);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        employees.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: RingLoader())),
          error: (e, _) => Text('No se pudieron cargar los empleados.\n$e', style: TextStyle(color: t.textMuted)),
          data: (list) => SectionCard(
            title: 'Equipo (${list.length})',
            child: Column(children: [
              for (final emp in list)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _parseColor(emp.colorHex),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(emp.fullName, style: TextStyle(color: t.textPrimary))),
                    Switch(
                      value: emp.isActive,
                      onChanged: (v) async {
                        await ref.read(apiProvider).setEmployeeActive(emp.id, v);
                        ref.invalidate(_employeesProvider);
                      },
                    ),
                  ]),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  static Color _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16);
    return value == null ? const Color(0xFFC8B68A) : Color(value);
  }
}

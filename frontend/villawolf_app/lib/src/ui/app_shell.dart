import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import '../state/theme_controller.dart';
import 'widgets.dart';

class _Dest {
  const _Dest(this.path, this.icon, this.label);
  final String path;
  final IconData icon;
  final String label;
}

const _destinations = [
  _Dest('/', Icons.dashboard_outlined, 'Dashboard'),
  _Dest('/calendar', Icons.calendar_month_outlined, 'Calendario'),
  _Dest('/clients', Icons.people_outline, 'Clientes'),
  _Dest('/services', Icons.design_services_outlined, 'Servicios'),
  _Dest('/employees', Icons.badge_outlined, 'Empleados'),
  _Dest('/cashbox', Icons.point_of_sale_outlined, 'Caja'),
  _Dest('/inventory', Icons.inventory_2_outlined, 'Inventario'),
];

/// App frame: a fixed sidebar on wide screens, a drawer on narrow ones.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final location = GoRouterState.of(context).uri.path;
    final user = ref.watch(authControllerProvider).user;
    final mode = ref.watch(themeControllerProvider);

    Widget sidebar() => Container(
          width: 240,
          color: t.bgBase,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(20, 26, 20, 26), child: BrandMark()),
              for (final d in _destinations)
                NavItem(
                  icon: d.icon,
                  label: d.label,
                  selected: location == d.path,
                  onTap: () {
                    context.go(d.path);
                    if (!wide) Navigator.of(context).maybePop();
                  },
                ),
              const Spacer(),
              Divider(height: 1, color: t.borderSubtle),
              ListTile(
                leading: Avatar(name: user?.displayName, icon: user == null ? Icons.logout : null, size: 32, highlighted: true),
                title: Text(user?.displayName ?? 'Salir',
                    style: TextStyle(color: t.textPrimary, fontSize: 13)),
                subtitle: user != null
                    ? Text(user.role, style: TextStyle(color: t.textMuted, fontSize: 11))
                    : null,
                trailing: AppIconButton(
                  icon: mode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  tooltip: 'Cambiar tema',
                  onPressed: () => ref.read(themeControllerProvider.notifier).toggle(),
                ),
                onTap: () => ref.read(authControllerProvider.notifier).logout(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            sidebar(),
            VerticalDivider(width: 1, color: t.borderSubtle),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const BrandMark(compact: true)),
      drawer: Drawer(backgroundColor: t.bgBase, child: sidebar()),
      body: child,
    );
  }
}

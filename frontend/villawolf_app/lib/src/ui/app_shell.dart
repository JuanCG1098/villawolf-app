import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../state/auth_controller.dart';
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
  _Dest('/cashbox', Icons.point_of_sale_outlined, 'Caja'),
  _Dest('/inventory', Icons.inventory_2_outlined, 'Inventario'),
  _Dest('/cameras', Icons.videocam_outlined, 'Cámaras'),
];

/// App frame: a fixed sidebar on wide screens, a drawer on narrow ones.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final location = GoRouterState.of(context).uri.path;
    final user = ref.watch(authControllerProvider).user;

    Widget sidebar() => Container(
          width: 240,
          color: AppColors.ink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(20, 26, 20, 26), child: BrandMark()),
              for (final d in _destinations)
                _NavItem(
                  dest: d,
                  selected: location == d.path,
                  onTap: () {
                    context.go(d.path);
                    if (!wide) Navigator.of(context).maybePop();
                  },
                ),
              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.muted),
                title: Text(user?.displayName ?? 'Salir',
                    style: const TextStyle(color: AppColors.onInk, fontSize: 13)),
                subtitle: user != null
                    ? Text(user.role, style: const TextStyle(color: AppColors.muted, fontSize: 11))
                    : null,
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
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const BrandMark(compact: true)),
      drawer: Drawer(backgroundColor: AppColors.ink, child: sidebar()),
      body: child,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.dest, required this.selected, required this.onTap});

  final _Dest dest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceAlt : Colors.transparent,
      child: ListTile(
        leading: Icon(dest.icon, color: selected ? AppColors.accent : AppColors.muted),
        title: Text(
          dest.label,
          style: TextStyle(
            color: selected ? AppColors.onInk : AppColors.muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

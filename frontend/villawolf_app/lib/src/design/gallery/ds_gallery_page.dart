import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/theme_controller.dart';
import '../design.dart';

/// Kitchen-sink gallery for the Villa Wolf Design System. Renders every token and component in the
/// active theme so dark/light parity can be verified at a glance. Debug surface, route `/_ds`.
class DsGalleryPage extends ConsumerWidget {
  const DsGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final mode = ref.watch(themeControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System'),
        actions: [
          AppIconButton(
            icon: mode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            tooltip: 'Cambiar tema',
            onPressed: () => ref.read(themeControllerProvider.notifier).toggle(),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            children: [
              const _Section('Colores'),
              _Swatches(t),
              const _Section('Tipografía'),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Display', style: AppTypography.display.copyWith(color: t.textPrimary)),
                    Text('Heading 1', style: AppTypography.h1.copyWith(color: t.textPrimary)),
                    Text('Heading 2', style: AppTypography.h2.copyWith(color: t.textPrimary)),
                    Text('Heading 3', style: AppTypography.h3.copyWith(color: t.textPrimary)),
                    Text('Title', style: AppTypography.title.copyWith(color: t.textPrimary)),
                    Text('Body — the quick brown fox',
                        style: AppTypography.body.copyWith(color: t.textSecondary)),
                    Text('Caption / muted',
                        style: AppTypography.caption.copyWith(color: t.textMuted)),
                    Text('OVERLINE / EYEBROW',
                        style: AppTypography.overline.copyWith(color: t.brand)),
                  ],
                ),
              ),
              const _Section('Botones'),
              SurfaceCard(
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const [
                    AppButton(label: 'Primary', onPressed: _noop),
                    AppButton(label: 'Secondary', variant: AppButtonVariant.secondary, onPressed: _noop),
                    AppButton(label: 'Ghost', variant: AppButtonVariant.ghost, onPressed: _noop),
                    AppButton(label: 'Eliminar', variant: AppButtonVariant.destructive, icon: Icons.delete_outline, onPressed: _noop),
                    AppButton(label: 'Cargando', loading: true),
                    AppButton(label: 'Deshabilitado'),
                    AppButton(label: 'Con ícono', icon: Icons.add, size: AppButtonSize.sm, onPressed: _noop),
                  ],
                ),
              ),
              const _Section('Inputs'),
              SurfaceCard(
                child: Column(
                  children: [
                    const AppTextField(label: 'Nombre', hint: 'Ej. Juan Cruz'),
                    AppSpacing.gapMd,
                    const AppTextField(
                        label: 'Email', hint: 'tu@correo.com', prefixIcon: Icons.mail_outline),
                    AppSpacing.gapMd,
                    const AppTextField(
                        label: 'Con error', hint: '', errorText: 'Campo requerido'),
                    AppSpacing.gapMd,
                    AppDropdown<String>(
                      label: 'Rol',
                      value: 'Barber',
                      items: const [
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'Barber', child: Text('Barbero')),
                      ],
                      onChanged: (_) {},
                    ),
                    AppSpacing.gapMd,
                    const AppSearchField(),
                  ],
                ),
              ),
              const _Section('Badges & estados'),
              SurfaceCard(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: const [
                    StatusBadge(status: 'Confirmed'),
                    StatusBadge(status: 'Pending'),
                    StatusBadge(status: 'Cancelled'),
                    StatusBadge(status: 'InProgress'),
                    AppBadge(label: 'Neutral'),
                    AppBadge(label: 'Brand', intent: AppIntent.brand),
                    CountBadge(count: 8),
                  ],
                ),
              ),
              const _Section('Avatares'),
              SurfaceCard(
                child: Row(
                  children: [
                    const Avatar(name: 'Juan Cruz', highlighted: true),
                    const SizedBox(width: AppSpacing.md),
                    const Avatar(name: 'María López'),
                    const SizedBox(width: AppSpacing.md),
                    const Avatar(icon: Icons.person_outline),
                    const SizedBox(width: AppSpacing.xl),
                    AvatarGroup(names: const ['Juan', 'Ana', 'Leo', 'Sol', 'Max']),
                  ],
                ),
              ),
              const _Section('Stat cards'),
              Row(
                children: const [
                  Expanded(
                      child: StatCard(
                          icon: Icons.event_available_outlined,
                          value: '12',
                          label: 'Turnos hoy',
                          trend: '+8%')),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                      child: StatCard(
                          icon: Icons.payments_outlined,
                          value: r'$84.500',
                          label: 'Ingresos')),
                ],
              ),
              const _Section('Feedback'),
              const Column(
                children: [
                  InlineAlert(message: 'Turno confirmado correctamente.', intent: AppIntent.success),
                  SizedBox(height: AppSpacing.sm),
                  InlineAlert(message: 'El horario se superpone con otro turno.', intent: AppIntent.danger),
                  SizedBox(height: AppSpacing.sm),
                  InlineAlert(message: 'Recordá habilitar la mensualidad.', intent: AppIntent.warning),
                ],
              ),
              AppSpacing.gapMd,
              SurfaceCard(
                child: EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'Sin turnos para hoy',
                  message: 'Cuando cargues turnos van a aparecer acá.',
                  actionLabel: 'Nuevo turno',
                  onAction: () {},
                ),
              ),
              const _Section('Calendario'),
              SurfaceCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DayHeader(weekday: 'Lun', day: '28', today: true),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: Column(
                        children: const [
                          AppointmentBlock(time: '10:00', title: 'Corte + barba', subtitle: 'Juan Cruz', status: 'Confirmed'),
                          SizedBox(height: AppSpacing.xs),
                          AppointmentBlock(time: '11:30', title: 'Color', subtitle: 'María', status: 'Pending'),
                          SizedBox(height: AppSpacing.xs),
                          AppointmentBlock(time: '13:00', title: 'Corte', subtitle: 'Leo', status: 'InProgress'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const _Section('Overlays'),
              SurfaceCard(
                child: Wrap(
                  spacing: AppSpacing.md,
                  children: [
                    AppButton(
                      label: 'Diálogo',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.sm,
                      onPressed: () => showConfirmDialog(context,
                          title: '¿Cancelar turno?',
                          message: 'Esta acción no se puede deshacer.',
                          destructive: true),
                    ),
                    AppButton(
                      label: 'Bottom sheet',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.sm,
                      onPressed: () => showAppBottomSheet(context,
                          title: 'Detalle',
                          child: const Text('Contenido del sheet')),
                    ),
                    AppButton(
                      label: 'Snackbar',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.sm,
                      onPressed: () => showAppSnackBar(context, 'Guardado', intent: AppIntent.success),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl4),
            ],
          ),
        ),
      ),
    );
  }
}

void _noop() {}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.xl2, 0, AppSpacing.md),
      child: Text(title.toUpperCase(),
          style: AppTypography.overline.copyWith(color: context.tokens.textMuted)),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches(this.t);
  final AppTokens t;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, Color)>[
      ('bg.base', t.bgBase),
      ('surface', t.bgSurface),
      ('surfaceAlt', t.bgSurfaceAlt),
      ('border', t.borderDefault),
      ('text', t.textPrimary),
      ('muted', t.textMuted),
      ('brand', t.brand),
      ('success', t.successFg),
      ('warning', t.warningFg),
      ('danger', t.dangerFg),
      ('info', t.infoFg),
    ];
    return SurfaceCard(
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          for (final (name, color) in entries)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadius.brMd,
                    border: Border.all(color: t.borderDefault),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(name, style: AppTypography.caption.copyWith(color: t.textMuted)),
              ],
            ),
        ],
      ),
    );
  }
}

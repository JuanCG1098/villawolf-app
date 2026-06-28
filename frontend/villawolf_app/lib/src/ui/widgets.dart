import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../design/components/components.dart';

// Re-export the design system so existing `import '../ui/widgets.dart'` keeps working and screens
// pick up the new token-driven components (BrandMark, SurfaceCard, SectionCard, AppButton, ...).
export '../design/components/components.dart';

// ── Legacy adapters ───────────────────────────────────────────────────────────────────────────
// Thin wrappers preserving the old constructors so the 13 feature screens compile unchanged. New
// code should use the canonical components (SurfaceCard, StatCard, AppDropdown, StatusBadge).

/// DEPRECATED: use [SurfaceCard].
class PanelCard extends StatelessWidget {
  const PanelCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}

/// DEPRECATED: use [StatCard].
class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) =>
      StatCard(icon: icon, value: value, label: label);
}

/// DEPRECATED: use [AppDropdown].
class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) =>
      AppDropdown<T>(label: label, value: value, items: items, onChanged: onChanged);
}

/// DEPRECATED: use [StatusBadge]. Retains [colorFor] for callers that tint with the status colour.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  static Color colorFor(String status) {
    switch (status) {
      case 'Confirmed':
      case 'Completed':
        return AppColors.green;
      case 'Pending':
        return AppColors.amber;
      case 'Cancelled':
      case 'NoShow':
        return AppColors.red;
      case 'InProgress':
        return AppColors.blue;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) =>
      StatusBadge(status: status, label: Formatters.label(status));
}

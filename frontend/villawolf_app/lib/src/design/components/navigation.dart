import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Sidebar / nav-rail entry with selected + hover states.
class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1),
      child: Material(
        color: selected ? t.bgSurfaceAlt : Colors.transparent,
        borderRadius: AppRadius.brMd,
        child: InkWell(
          borderRadius: AppRadius.brMd,
          hoverColor: t.hoverOverlay,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
            child: Row(
              children: [
                Icon(icon,
                    size: 20, color: selected ? t.brand : t.textMuted),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(label,
                      style: AppTypography.body.copyWith(
                        color: selected ? t.textPrimary : t.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      )),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Page header: title + optional subtitle on the left, actions on the right.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTypography.h1.copyWith(color: t.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: AppTypography.body.copyWith(color: t.textMuted)),
              ],
            ],
          ),
        ),
        for (final a in actions) ...[const SizedBox(width: AppSpacing.sm), a],
      ],
    );
  }
}

/// Lightweight segmented tab control.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.bgSurfaceAlt,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tabs.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: i == selected ? t.bgElevated : Colors.transparent,
                  borderRadius: AppRadius.brSm,
                  border: Border.all(
                      color: i == selected ? t.borderDefault : Colors.transparent),
                ),
                child: Text(tabs[i],
                    style: AppTypography.bodySm.copyWith(
                      color: i == selected ? t.textPrimary : t.textMuted,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
        ],
      ),
    );
  }
}

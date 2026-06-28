import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Base surface: a bordered, optionally elevated panel. The building block for most content.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.elevated = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool elevated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: t.borderDefault),
        boxShadow: elevated ? t.shadowSm : null,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brLg,
      child: card,
    );
  }
}

/// Titled card with an optional trailing action and a hairline divider under the header.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.title.copyWith(color: t.textPrimary)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style:
                              AppTypography.caption.copyWith(color: t.textMuted)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          Divider(height: AppSpacing.xl2, color: t.borderSubtle),
          child,
        ],
      ),
    );
  }
}

/// KPI / stat card: an icon, a big value and a caption.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.trend,
  });

  final IconData icon;
  final String value;
  final String label;

  /// Optional small trailing trend text (e.g. "+12%").
  final String? trend;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: t.brandSubtle,
                  borderRadius: AppRadius.brSm,
                ),
                child: Icon(icon, color: t.brand, size: 18),
              ),
              const Spacer(),
              if (trend != null)
                Text(trend!,
                    style: AppTypography.caption.copyWith(color: t.textMuted)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(value,
              style: AppTypography.h2.copyWith(color: t.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption.copyWith(color: t.textMuted)),
        ],
      ),
    );
  }
}

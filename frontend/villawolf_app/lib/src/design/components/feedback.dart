import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'badges.dart';
import 'buttons.dart';
import 'cards.dart';

/// Brand ring spinner — a thin rotating arc echoing the logo ring.
class RingLoader extends StatelessWidget {
  const RingLoader({super.key, this.size = 24, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size > 28 ? 3 : 2,
        color: color ?? context.tokens.brand,
      ),
    );
  }
}

/// Centred empty state: icon, title, optional message and call-to-action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: t.bgSurfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: t.borderDefault),
              ),
              child: Icon(icon, color: t.textMuted, size: 26),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title,
                textAlign: TextAlign.center,
                style: AppTypography.title.copyWith(color: t.textPrimary)),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: t.textMuted)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.sm),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error panel with a retry action.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SurfaceCard(
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: t.textMuted),
          const SizedBox(height: AppSpacing.sm),
          Text('No se pudieron cargar los datos.',
              style: AppTypography.body.copyWith(color: t.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: t.textMuted)),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
                label: 'Reintentar',
                onPressed: onRetry,
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.sm),
          ],
        ],
      ),
    );
  }
}

/// Inline banner for contextual messages (info / warning / success / danger).
class InlineAlert extends StatelessWidget {
  const InlineAlert({
    super.key,
    required this.message,
    this.intent = AppIntent.info,
    this.icon,
  });

  final String message;
  final AppIntent intent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = BadgeColors.of(context.tokens, intent);
    final defaultIcon = switch (intent) {
      AppIntent.success => Icons.check_circle_outline_rounded,
      AppIntent.warning => Icons.warning_amber_rounded,
      AppIntent.danger => Icons.error_outline_rounded,
      _ => Icons.info_outline_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: c.fg, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: AppTypography.bodySm.copyWith(color: c.fg)),
          ),
        ],
      ),
    );
  }
}

/// Shimmer-free skeleton block for loading placeholders.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.width, this.height = 14, this.radius = AppRadius.sm});
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.tokens.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Themed snackbar helper.
void showAppSnackBar(BuildContext context, String message,
    {AppIntent intent = AppIntent.neutral}) {
  final c = BadgeColors.of(context.tokens, intent);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(children: [
        Container(width: 4, height: 18, color: c.fg),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(message)),
      ]),
    ));
}

import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/radius.dart';
import '../tokens/semantic_tokens.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Semantic intent for badges / alerts, resolved to token colours by [BadgeColors.of].
enum AppIntent { neutral, brand, success, warning, danger, info }

class BadgeColors {
  const BadgeColors(this.fg, this.bg, this.border);
  final Color fg;
  final Color bg;
  final Color border;

  static BadgeColors of(AppTokens t, AppIntent intent) => switch (intent) {
        AppIntent.neutral =>
          BadgeColors(t.textSecondary, t.bgSurfaceAlt, t.borderDefault),
        AppIntent.brand => BadgeColors(t.brand, t.brandSubtle, t.brand),
        AppIntent.success => BadgeColors(t.successFg, t.successBg, t.successBorder),
        AppIntent.warning => BadgeColors(t.warningFg, t.warningBg, t.warningBorder),
        AppIntent.danger => BadgeColors(t.dangerFg, t.dangerBg, t.dangerBorder),
        AppIntent.info => BadgeColors(t.infoFg, t.infoBg, t.infoBorder),
      };

  /// Maps an appointment status string to a semantic intent (per BRAND.md status colours).
  static AppIntent intentForStatus(String status) => switch (status) {
        'Confirmed' || 'Completed' => AppIntent.success,
        'Pending' => AppIntent.warning,
        'Cancelled' || 'NoShow' => AppIntent.danger,
        'InProgress' => AppIntent.info,
        _ => AppIntent.neutral,
      };
}

/// Pill badge with a tinted background + hairline border. Optional leading dot.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.intent = AppIntent.neutral,
    this.dot = false,
  });

  final String label;
  final AppIntent intent;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final c = BadgeColors.of(context.tokens, intent);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 2),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: AppRadius.brFull,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Text(label,
              style: AppTypography.caption
                  .copyWith(color: c.fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Status badge for appointments — resolves colour + label from a status code.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.label});

  final String status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label ?? status,
      intent: BadgeColors.intentForStatus(status),
      dot: true,
    );
  }
}

/// Small count chip (e.g. number of items / notifications).
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, this.intent = AppIntent.brand});

  final int count;
  final AppIntent intent;

  @override
  Widget build(BuildContext context) {
    final c = BadgeColors.of(context.tokens, intent);
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: c.bg, borderRadius: AppRadius.brFull),
      child: Text('$count',
          textAlign: TextAlign.center,
          style: AppTypography.caption
              .copyWith(color: c.fg, fontWeight: FontWeight.w700)),
    );
  }
}

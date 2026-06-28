import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'badges.dart' show AppIntent;

enum AppButtonVariant { primary, secondary, ghost, destructive }

enum AppButtonSize { sm, md, lg }

/// The single button primitive for the app. Variants cover the common hierarchy (primary action,
/// secondary outline, low-emphasis ghost, destructive) with consistent sizing, loading and icon
/// support — all colours read from tokens.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;

  /// Stretch to fill the available width.
  final bool expand;

  double get _height => switch (size) {
        AppButtonSize.sm => 32,
        AppButtonSize.md => 40,
        AppButtonSize.lg => 48,
      };

  double get _hPad => switch (size) {
        AppButtonSize.sm => AppSpacing.md,
        AppButtonSize.md => AppSpacing.lg,
        AppButtonSize.lg => AppSpacing.xl,
      };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final disabled = onPressed == null || loading;

    late final Color bg;
    late final Color fg;
    late final Color? borderColor;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = t.brand;
        fg = t.onBrand;
        borderColor = null;
      case AppButtonVariant.secondary:
        bg = Colors.transparent;
        fg = t.textPrimary;
        borderColor = t.borderStrong;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = t.textSecondary;
        borderColor = null;
      case AppButtonVariant.destructive:
        bg = t.dangerBg;
        fg = t.dangerFg;
        borderColor = t.dangerBorder;
    }

    final textStyle = (size == AppButtonSize.sm ? AppTypography.bodySm : AppTypography.body)
        .copyWith(fontWeight: FontWeight.w600);

    final child = loading
        ? SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: size == AppButtonSize.sm ? 16 : 18, color: fg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: textStyle.copyWith(color: fg)),
            ],
          );

    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (disabled && variant == AppButtonVariant.primary) return t.bgSurfaceAlt;
        if (states.contains(WidgetState.hovered)) {
          if (variant == AppButtonVariant.primary) return t.brandHover;
          return t.hoverOverlay;
        }
        return bg;
      }),
      foregroundColor: WidgetStatePropertyAll(disabled ? t.textDisabled : fg),
      overlayColor: WidgetStatePropertyAll(t.pressedOverlay),
      side: WidgetStatePropertyAll(
          borderColor == null ? null : BorderSide(color: borderColor)),
      shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.brMd)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: _hPad)),
      minimumSize: WidgetStatePropertyAll(Size(0, _height)),
      fixedSize: expand ? null : null,
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(textStyle),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final button = TextButton(
      onPressed: disabled ? null : onPressed,
      style: style,
      child: child,
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Square icon-only button (toolbar actions, theme toggle, ...).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.intent = AppIntent.neutral,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final AppIntent intent;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = intent == AppIntent.danger ? t.dangerFg : t.textSecondary;
    final btn = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        foregroundColor: color,
        hoverColor: t.hoverOverlay,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brSm),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

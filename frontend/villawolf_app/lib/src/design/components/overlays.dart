import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'buttons.dart';

/// Confirmation dialog with a title, message and a confirm/cancel pair. Returns true on confirm.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final t = ctx.tokens;
      return AlertDialog(
        title: Text(title, style: AppTypography.h3.copyWith(color: t.textPrimary)),
        content: Text(message, style: AppTypography.body.copyWith(color: t.textSecondary)),
        actions: [
          AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.sm,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          AppButton(
            label: confirmLabel,
            variant: destructive ? AppButtonVariant.destructive : AppButtonVariant.primary,
            size: AppButtonSize.sm,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Opens a themed bottom sheet with a grab handle and a titled header.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final t = ctx.tokens;
      return Container(
        decoration: BoxDecoration(
          color: t.bgElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: t.borderDefault),
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.md,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: t.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.h3.copyWith(color: t.textPrimary)),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Label → value row for detail panels.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({super.key, required this.label, required this.value, this.valueWidget});

  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTypography.bodySm.copyWith(color: t.textMuted)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: valueWidget ??
                Text(value, style: AppTypography.body.copyWith(color: t.textPrimary)),
          ),
        ],
      ),
    );
  }
}

/// A row in a [DataList]: leading cell, title/subtitle and trailing widget, with hover + tap.
class DataRow2 extends StatelessWidget {
  const DataRow2({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      hoverColor: t.hoverOverlay,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs, vertical: AppSpacing.md),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.md)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTypography.body.copyWith(color: t.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: AppTypography.caption.copyWith(color: t.textMuted)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: AppSpacing.md), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Vertically stacks rows with hairline dividers between them.
class DataList extends StatelessWidget {
  const DataList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, color: t.borderSubtle),
          children[i],
        ],
      ],
    );
  }
}

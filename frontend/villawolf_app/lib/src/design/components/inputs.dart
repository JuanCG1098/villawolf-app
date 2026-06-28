import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Field label rendered above the control (dashboard convention) — reused by the inputs below.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
      child: Text(text,
          style: AppTypography.bodySm
              .copyWith(color: context.tokens.textSecondary, fontWeight: FontWeight.w500)),
    );
  }
}

/// Text input with an optional label, helper/error text and leading/trailing icons.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) FieldLabel(label!),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: AppTypography.body.copyWith(color: t.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            helperText: helper,
            helperStyle: AppTypography.caption.copyWith(color: t.textMuted),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 18, color: t.textMuted),
            suffixIcon: suffixIcon,
            isDense: true,
          ),
        ),
      ],
    );
  }
}

/// Bordered dropdown that matches the input styling. Drop-in for the old LabeledDropdown.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(label),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: t.bgSurfaceAlt,
            borderRadius: AppRadius.brMd,
            border: Border.all(color: t.borderDefault),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: t.bgElevated,
              borderRadius: AppRadius.brMd,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: t.textMuted),
              style: AppTypography.body.copyWith(color: t.textPrimary),
              hint: hint == null
                  ? null
                  : Text(hint!, style: AppTypography.body.copyWith(color: t.textMuted)),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact search field with a leading magnifier.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Buscar…',
    this.onChanged,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint,
      prefixIcon: Icons.search_rounded,
      onChanged: onChanged,
    );
  }
}

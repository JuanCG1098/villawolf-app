import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'badges.dart';

/// Day/column header for the agenda (weekday + day number).
class DayHeader extends StatelessWidget {
  const DayHeader({super.key, required this.weekday, required this.day, this.today = false});

  final String weekday;
  final String day;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      children: [
        Text(weekday.toUpperCase(),
            style: AppTypography.overline.copyWith(color: t.textMuted)),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: today ? t.brand : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(day,
              style: AppTypography.body.copyWith(
                color: today ? t.onBrand : t.textPrimary,
                fontWeight: FontWeight.w600,
              )),
        ),
      ],
    );
  }
}

/// Empty time-grid cell — a selectable slot in the agenda.
class TimeGridCell extends StatelessWidget {
  const TimeGridCell({super.key, this.onTap, this.height = 48});

  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      hoverColor: t.hoverOverlay,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.borderSubtle)),
        ),
      ),
    );
  }
}

/// A booked appointment rendered as a coloured block (left accent + tinted fill from its status).
class AppointmentBlock extends StatelessWidget {
  const AppointmentBlock({
    super.key,
    required this.time,
    required this.title,
    this.status = 'Confirmed',
    this.subtitle,
    this.onTap,
  });

  final String time;
  final String title;
  final String status;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = BadgeColors.of(t, BadgeColors.intentForStatus(status));
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brSm,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: AppRadius.brSm,
          border: Border(left: BorderSide(color: c.fg, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$time · $title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm
                    .copyWith(color: t.textPrimary, fontWeight: FontWeight.w600)),
            if (subtitle != null)
              Text(subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: t.textMuted)),
          ],
        ),
      ),
    );
  }
}

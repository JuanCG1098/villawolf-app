import 'package:flutter/material.dart';

import '../theme/app_tokens_extension.dart';
import '../tokens/typography.dart';

/// Avatar built on the brand's signature thin ring. Shows initials (or an icon fallback) inside a
/// circular ring — reused for clients, staff and the user menu.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.name,
    this.icon,
    this.size = 36,
    this.highlighted = false,
  });

  final String? name;
  final IconData? icon;
  final double size;

  /// Use the brand colour for the ring (e.g. the signed-in user).
  final bool highlighted;

  String get _initials {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ring = highlighted ? t.brand : t.borderStrong;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.bgSurfaceAlt,
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 1.5),
      ),
      child: icon != null
          ? Icon(icon, size: size * 0.5, color: t.textSecondary)
          : Text(_initials,
              style: AppTypography.caption.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: size * 0.34,
              )),
    );
  }
}

/// Overlapping avatar stack with an optional "+N" overflow chip.
class AvatarGroup extends StatelessWidget {
  const AvatarGroup({super.key, required this.names, this.max = 3, this.size = 30});

  final List<String> names;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shown = names.take(max).toList();
    final overflow = names.length - shown.length;
    final overlap = size * 0.62;
    return SizedBox(
      height: size,
      width: shown.length * overlap + (overflow > 0 ? overlap : 0) + (size - overlap),
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.bgBase, width: 2),
                ),
                child: Avatar(name: shown[i], size: size),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: shown.length * overlap,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.bgSurfaceAlt,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.bgBase, width: 2),
                ),
                child: Text('+$overflow',
                    style: AppTypography.caption.copyWith(color: t.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }
}

/// The VILLAWOLF wordmark with the circular ring motif.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: t.textPrimary, width: 2),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('VILLAWOLF',
                  style: TextStyle(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      fontSize: 15,
                      height: 1.0)),
              Text('hair studio',
                  style: TextStyle(color: t.textMuted, fontSize: 10, letterSpacing: 2)),
            ],
          ),
        ],
      ],
    );
  }
}

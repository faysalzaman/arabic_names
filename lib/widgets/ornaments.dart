import 'dart:math' as math;

import 'package:arabic_names/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Path of an eight-pointed star (Rub el Hizb): two squares, one turned 45°.
Path _eightPointStar(Offset center, double radius) {
  final path = Path();
  for (var i = 0; i < 16; i++) {
    // Alternate between the outer tips and the inner corners.
    final r = i.isEven ? radius : radius * 0.765;
    final angle = -math.pi / 2 + i * math.pi / 8;
    final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

/// Repeating geometric girih-style lattice of eight-pointed stars, drawn in code so
/// it is crisp at any size and costs no asset.
class GeometricPattern extends StatelessWidget {
  const GeometricPattern({
    super.key,
    this.color = AppColors.gold,
    this.opacity = 0.18,
    this.tile = 56,
  });

  final Color color;
  final double opacity;
  final double tile;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _PatternPainter(color.withValues(alpha: opacity), tile),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter(this.color, this.tile);

  final Color color;
  final double tile;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var y = 0.0; y < size.height + tile; y += tile) {
      for (var x = 0.0; x < size.width + tile; x += tile) {
        final c = Offset(x, y);
        canvas.drawPath(_eightPointStar(c, tile * 0.42), paint);
        canvas.drawCircle(c, tile * 0.14, paint);
        // Small diamonds where four tiles meet tie the lattice together.
        final d = c + Offset(tile / 2, tile / 2);
        canvas.drawPath(
          Path()
            ..moveTo(d.dx, d.dy - tile * 0.12)
            ..lineTo(d.dx + tile * 0.12, d.dy)
            ..lineTo(d.dx, d.dy + tile * 0.12)
            ..lineTo(d.dx - tile * 0.12, d.dy)
            ..close(),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.color != color || old.tile != tile;
}

/// Filled eight-pointed star with a child (usually a letter) in the middle.
class StarMedallion extends StatelessWidget {
  const StarMedallion({
    super.key,
    required this.child,
    this.size = 48,
    this.color = AppColors.goldSoft,
    this.borderColor = AppColors.gold,
  });

  final Widget child;
  final double size;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StarPainter(color, borderColor),
        child: Center(child: child),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.fill, this.border);

  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final star = _eightPointStar(size.center(Offset.zero), size.shortestSide / 2 - 1);
    canvas.drawPath(star, Paint()..color = fill);
    canvas.drawPath(
      star,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.fill != fill || old.border != border;
}

/// ——◆—— A gold divider used between sections and under titles.
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key, this.width = 160, this.color = AppColors.gold});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.6)));
    return SizedBox(
      width: width,
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: StarMedallion(size: 12, color: color, borderColor: color, child: const SizedBox()),
          ),
          line,
        ],
      ),
    );
  }
}

/// Emerald band with the geometric pattern and rounded lower corners: the header of
/// the home and detail screens.
class PatternHeader extends StatelessWidget {
  const PatternHeader({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.emeraldDark, AppColors.emerald],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: GeometricPattern()),
            Padding(
              padding: padding ?? const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section title: gold star + heading, e.g. "تصفح الأسماء".
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          const StarMedallion(
            size: 16,
            color: AppColors.gold,
            borderColor: AppColors.gold,
            child: SizedBox(),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: AppFonts.naskh,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.emeraldDark,
            ),
          ),
        ],
      ),
    );
  }
}

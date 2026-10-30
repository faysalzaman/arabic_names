import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/widgets/ornaments.dart';
import 'package:flutter/material.dart';

/// Ivory "paper" shared by every screen, with a barely visible geometric pattern so
/// cards and text stay perfectly readable on top of it.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: GeometricPattern(opacity: 0.07, tile: 72)),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

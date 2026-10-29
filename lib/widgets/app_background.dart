import 'package:arabic_names/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The ornamental backdrop shared by every screen. The asset is a 900 px wide JPEG of
/// about 160 KB (the old w.png was 7.7 MB). It is faded into the theme background so
/// text and cards stay readable on top of it.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.opacity = 0.35});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        image: DecorationImage(
          image: const AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
          opacity: opacity,
        ),
      ),
      child: child,
    );
  }
}

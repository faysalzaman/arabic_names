import 'package:flutter/material.dart';

/// The green ornamental backdrop shared by every screen. The asset is a 900 px wide
/// JPEG of about 160 KB (the old w.png was 7.7 MB).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.opacity = 1});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF05201D),
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

// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'package:arabic_names/ui_screens/names/gender_selection_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for a few seconds before navigating to the next screen
    Future.delayed(
      const Duration(seconds: 5),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const GenderSelectionScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          fit: BoxFit.cover,
          'assets/splash_screen.gif',
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading GIF: $error');
            return const Text('Failed to load GIF');
          },
        ),
      ),
    );
  }
}

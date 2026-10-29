import 'package:arabic_names/DataBase/names_repository.dart';
import 'package:arabic_names/ui_screens/names/gender_selection_screen.dart';
import 'package:arabic_names/utils/constants.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:flutter/material.dart';

/// Shows the logo while the names database is prepared (copied on the very first
/// launch only), then opens the menu. Replaces the old fixed 5 s, 23 MB GIF splash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _minimumShown = Duration(milliseconds: 700);

  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    if (_failed) setState(() => _failed = false);
    final started = DateTime.now();
    try {
      await NamesRepository.instance.warmUp();
    } catch (e) {
      debugPrint('Could not prepare the names database: $e');
      if (mounted) setState(() => _failed = true);
      return;
    }

    final remaining = _minimumShown - DateTime.now().difference(started);
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GenderSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/اسماء اولاد وبنات.png', width: 160, height: 160),
              const SizedBox(height: 32),
              if (_failed) ...[
                const Text(
                  'تعذر تحميل البيانات',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _boot, child: const Text('إعادة المحاولة')),
              ] else
                const CircularProgressIndicator(color: Constants.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}

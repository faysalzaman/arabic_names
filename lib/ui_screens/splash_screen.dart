import 'package:arabic_names/DataBase/names_repository.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/ui_screens/menu_screen.dart';
import 'package:arabic_names/widgets/ornaments.dart';
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
    } catch (e, stack) {
      debugPrint('Could not prepare the names database: $e\n$stack');
      if (mounted) setState(() => _failed = true);
      return;
    }

    final remaining = _minimumShown - DateTime.now().difference(started);
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emeraldDark,
      body: Stack(
        children: [
          const Positioned.fill(child: GeometricPattern(opacity: 0.16)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset('assets/اسماء اولاد وبنات.png', width: 128, height: 128),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'أسماء أولاد وبنات',
                  style: TextStyle(
                    fontFamily: AppFonts.ruqaa,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const OrnamentDivider(),
                const SizedBox(height: 10),
                const Text(
                  'أجمل الأسماء العربية ومعانيها',
                  style: TextStyle(color: AppColors.goldSoft, fontSize: 16),
                ),
                const SizedBox(height: 40),
                if (_failed) ...[
                  const Text(
                    'تعذر تحميل البيانات',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.emeraldDark,
                    ),
                    onPressed: _boot,
                    child: const Text('إعادة المحاولة'),
                  ),
                ] else
                  const SizedBox.square(
                    dimension: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ads/ad_units.dart';
import 'package:arabic_names/ads/interstitial_manager.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/ui_screens/fav_names_screen.dart';
import 'package:arabic_names/ui_screens/names_list_screen.dart';
import 'package:arabic_names/utils/labels.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main menu: pick which collection of names to browse.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  /// Ask for a review on every 3rd launch, show an app-open ad on the others.
  static const int _reviewEveryLaunches = 3;

  final InAppReview _inAppReview = InAppReview.instance;
  AppOpenAd? _appOpenAd;

  @override
  void initState() {
    super.initState();
    _reviewOrShowAd();
  }

  Future<void> _reviewOrShowAd() async {
    final prefs = await SharedPreferences.getInstance();
    final launches = (prefs.getInt('appLaunchCount') ?? 0) + 1;

    if (launches >= _reviewEveryLaunches) {
      await prefs.setInt('appLaunchCount', 0);
      await _requestReview();
    } else {
      await prefs.setInt('appLaunchCount', launches);
      _loadAppOpenAd();
    }
  }

  Future<void> _requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        await _inAppReview.openStoreListing();
      }
    } catch (e) {
      debugPrint('In-app review failed: $e');
    }
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdUnits.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          _appOpenAd = ad;
          ad.show();
        },
        onAdFailedToLoad: (error) => debugPrint('AppOpenAd failed to load: $error'),
      ),
    );
  }

  @override
  void dispose() {
    _appOpenAd?.dispose();
    super.dispose();
  }

  void _open(NameCategory category) {
    InterstitialManager.instance.maybeShow(() {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NamesListScreen(category: category)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/اسماء اولاد وبنات.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'أسماء أولاد وبنات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'اكتشف أجمل الأسماء ومعانيها',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
              const SizedBox(height: 28),
              for (final category in NameCategory.values)
                _MenuCard(
                  icon: category.icon,
                  title: category.title,
                  subtitle: category.subtitle,
                  onTap: () => _open(category),
                ),
              _MenuCard(
                icon: Icons.favorite_border,
                title: 'المفضلة',
                subtitle: 'الأسماء التي أعجبتك',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavouritesScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface.withValues(alpha: 0.92),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // chevron_right mirrors itself in right-to-left layouts.
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

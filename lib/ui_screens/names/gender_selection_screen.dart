import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ads/ad_units.dart';
import 'package:arabic_names/ui_screens/names/category_screen.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:arabic_names/widgets/pill_button.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main menu: pick which collection of names to browse.
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
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
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.fade,
        child: CategoryScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PillButton(
                label: 'جميع الأسماء',
                imageAsset: 'assets/popular.png',
                onPressed: () => _open(NameCategory.all),
              ),
              const SizedBox(height: 6),
              PillButton(
                label: 'الأسماء الشائعة',
                imageAsset: 'assets/trending.png',
                onPressed: () => _open(NameCategory.trending),
              ),
              const SizedBox(height: 6),
              PillButton(
                label: 'أسماء المشاهير',
                imageAsset: 'assets/celebrity.png',
                onPressed: () => _open(NameCategory.celebrity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

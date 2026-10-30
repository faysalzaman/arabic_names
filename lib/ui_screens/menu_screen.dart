import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/DataBase/names_repository.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ads/ad_units.dart';
import 'package:arabic_names/ads/interstitial_manager.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/ui_screens/detail_screen.dart';
import 'package:arabic_names/ui_screens/fav_names_screen.dart';
import 'package:arabic_names/ui_screens/names_list_screen.dart';
import 'package:arabic_names/utils/labels.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:arabic_names/widgets/ornaments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Home: search, name of the day, browse by gender or collection.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  /// Ask for a review on every 3rd launch, show an app-open ad on the others.
  static const int _reviewEveryLaunches = 3;

  final InAppReview _inAppReview = InAppReview.instance;
  final Future<NameModel?> _nameOfTheDay =
      NamesRepository.instance.nameOfTheDay(DateTime.now());
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

  void _open(
    NameCategory category, {
    NameGender gender = NameGender.male,
    bool search = false,
  }) {
    InterstitialManager.instance.maybeShow(() {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NamesListScreen(
            category: category,
            initialGender: gender,
            autofocusSearch: search,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FutureBuilder<NameModel?>(
                    future: _nameOfTheDay,
                    builder: (context, snapshot) {
                      final name = snapshot.data;
                      if (name == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _NameOfTheDayCard(name: name),
                      );
                    },
                  ),
                  const SectionTitle('تصفح حسب الجنس'),
                  Row(
                    children: [
                      Expanded(
                        child: _GenderCard(
                          title: 'أسماء أولاد',
                          icon: Icons.boy_rounded,
                          color: AppColors.boy,
                          onTap: () => _open(NameCategory.all),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GenderCard(
                          title: 'أسماء بنات',
                          icon: Icons.girl_rounded,
                          color: AppColors.girl,
                          onTap: () => _open(NameCategory.all, gender: NameGender.female),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SectionTitle('المجموعات'),
                  for (final category in NameCategory.values)
                    _MenuCard(
                      icon: category.icon,
                      title: category.title,
                      subtitle: category.subtitle,
                      onTap: () => _open(category),
                    ),
                  BlocBuilder<FavouriteBloc, FavouriteState>(
                    builder: (context, state) {
                      final count = state is FavouriteSuccess ? state.names.length : 0;
                      return _MenuCard(
                        icon: Icons.favorite_rounded,
                        iconColor: AppColors.favourite,
                        title: 'المفضلة',
                        subtitle: count == 0 ? 'احفظ الأسماء التي أعجبتك' : '$count من الأسماء المحفوظة',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavouritesScreen()),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return PatternHeader(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset('assets/اسماء اولاد وبنات.png', width: 76, height: 76),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'أسماء أولاد وبنات',
              style: TextStyle(
                fontFamily: AppFonts.ruqaa,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const OrnamentDivider(width: 140),
            const SizedBox(height: 6),
            const Text(
              'اكتشف أجمل الأسماء ومعانيها',
              style: TextStyle(color: AppColors.goldSoft, fontSize: 15),
            ),
            const SizedBox(height: 20),
            // Looks like a search box; opens the full list with the keyboard up.
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _open(NameCategory.all, search: true),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.emerald),
                      SizedBox(width: 10),
                      Text(
                        'ابحث عن اسم أو معنى...',
                        style: TextStyle(color: AppColors.muted, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameOfTheDayCard extends StatelessWidget {
  const _NameOfTheDayCard({required this.name});

  final NameModel name;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.goldSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.gold),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPage(model: name)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: GeometricPattern(opacity: 0.22, tile: 44)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✦ اسم اليوم ✦',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name.urduName ?? '',
                    style: const TextStyle(
                      fontFamily: AppFonts.naskh,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emeraldDark,
                      height: 1.4,
                    ),
                  ),
                  if (name.englishName != null)
                    Text(
                      name.englishName!,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    name.urduMeaning ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.naskh,
                      fontSize: 17,
                      color: AppColors.ink,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            const Positioned.fill(
              child: GeometricPattern(color: Colors.white, opacity: 0.12, tile: 40),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Icon(icon, size: 38, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppFonts.naskh,
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    this.iconColor = AppColors.emerald,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                StarMedallion(size: 50, child: Icon(icon, color: iconColor, size: 22)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppFonts.naskh,
                          color: AppColors.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // chevron_right mirrors itself in right-to-left layouts.
                const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

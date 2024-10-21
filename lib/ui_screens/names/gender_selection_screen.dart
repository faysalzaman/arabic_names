// ignore_for_file: avoid_print, library_private_types_in_public_api, file_names

import 'package:arabic_names/ui_screens/names/all_names/all_names_selection_screen.dart';
import 'package:arabic_names/ui_screens/names/trending_names/trending_names_selection_screen.dart';
import 'package:arabic_names/ui_screens/names/celebrity_names/celebrity_names_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:arabic_names/utils/constants.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  // AppOpenAd? appOpenAd;

  // final InAppReview inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    // _checkAndShowRatingDialog();
  }

  // void showRatingDialog() async {
  //   print('Checking in-app review availability...');
  //   bool isAvailable = await inAppReview.isAvailable();
  //   print('In-app review available: $isAvailable');

  //   if (isAvailable) {
  //     print('Requesting in-app review...');
  //     inAppReview.requestReview().then((_) {
  //       print('In-app review requested.');
  //     }).catchError((e) {
  //       print('Failed to request in-app review: $e');
  //     });
  //   } else {
  //     print('In-app review not available, trying to open store listing...');
  //     inAppReview.openStoreListing(appStoreId: '8475602794689359855').then((_) {
  //       print('Store listing opened.');
  //     }).catchError((e) {
  //       print('Failed to open store listing: $e');
  //     });
  //   }
  // }

  // void _checkAndShowRatingDialog() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int appLaunchCount = (prefs.getInt('appLaunchCount') ?? 0) + 1;

  //   print("App Launch Count: $appLaunchCount");

  //   if (appLaunchCount >= 3) {
  //     // Change the threshold as needed
  //     showRatingDialog();
  //     prefs.setInt('appLaunchCount', 0); // Reset the count
  //   } else {
  //     prefs.setInt('appLaunchCount', appLaunchCount);
  //     loadAppOpenAd();
  //   }
  // }

  // void loadAppOpenAd() {
  //   AppOpenAd.load(
  //     adUnitId: 'ca-app-pub-9684723099725802/4009423699',
  //     orientation: AppOpenAd.orientationPortrait,
  //     request: const AdRequest(),
  //     adLoadCallback: AppOpenAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         appOpenAd = ad;
  //         showAppOpenAd();
  //       },
  //       onAdFailedToLoad: (error) {
  //         print('AppOpenAd failed to load: $error');
  //       },
  //     ),
  //   );
  // }

  // void showAppOpenAd() {
  //   if (appOpenAd != null) {
  //     appOpenAd!.show();
  //   }
  // }

  @override
  void dispose() {
    // appOpenAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/w.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(
                'جميع الأسماء',
                'assets/popular.png',
                () => Navigator.of(context).push(
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const AllNamesSelectionScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _buildButton(
                'الأسماء الشائعة',
                'assets/trending.png',
                () => Navigator.of(context).push(
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const TrendingNamesSelectionScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _buildButton(
                'أسماء المشاهير',
                'assets/celebrity.png',
                () => Navigator.of(context).push(
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const CelebrityNamesSelectionScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, String assetPath, VoidCallback onPressed) {
    return MaterialButton(
      onPressed: onPressed,
      color: Constants.buttonColor,
      shape: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: 170,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 30,
                width: 30,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(assetPath),
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  color: Constants.textOnButtonColor,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

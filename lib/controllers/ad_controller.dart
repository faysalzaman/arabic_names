import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdController {
  static final AdController _instance = AdController._internal();

  factory AdController() {
    return _instance;
  }

  AdController._internal();

  BannerAd? _bannerAd;
  bool isAdLoaded = false;

  void initBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId:
          'ca-app-pub-9684723099725802/2015455131', // Your banner ad unit ID
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isAdLoaded = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          isAdLoaded = false;
          ad.dispose();
          onAdFailedToLoad(error);
        },
        onAdOpened: (ad) {
          // Ad opened callback
        },
        onAdClosed: (ad) {
          // Ad closed callback
        },
        onAdImpression: (ad) {
          // Ad impression callback
        },
        onAdWillDismissScreen: (ad) {
          // Ad will dismiss screen callback
        },
      ),
      request: const AdRequest(),
    );
    _bannerAd?.load();
  }

  BannerAd? get bannerAd => _bannerAd;

  /// Get the height of the banner ad for proper padding calculations
  double get bannerHeight => _bannerAd?.size.height.toDouble() ?? 0.0;

  /// Get the width of the banner ad
  double get bannerWidth => _bannerAd?.size.width.toDouble() ?? 0.0;

  /// Check if banner ad is ready to be displayed safely
  bool get canDisplayAd => _bannerAd != null && isAdLoaded;

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    isAdLoaded = false;
  }

  /// Reload the banner ad if it fails to load
  void reloadBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    dispose();
    initBannerAd(
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }
}

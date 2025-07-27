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
      ),
      request: const AdRequest(),
    );
    _bannerAd?.load();
  }

  BannerAd? get bannerAd => _bannerAd;

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    isAdLoaded = false;
  }
}

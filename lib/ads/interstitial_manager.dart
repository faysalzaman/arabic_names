import 'package:arabic_names/ads/ad_units.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// One place that decides when a full-screen ad may appear, so screens only call
/// [maybeShow] at natural transition points (after the user tapped to open something).
class InterstitialManager {
  InterstitialManager._();
  static final InterstitialManager instance = InterstitialManager._();

  /// Show on every Nth call, and never more often than [minGap].
  static const int showEvery = 2;
  static const Duration minGap = Duration(seconds: 60);

  InterstitialAd? _ad;
  bool _loading = false;
  int _calls = 0;
  DateTime? _lastShown;

  void preload() {
    if (_ad != null || _loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdUnits.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          debugPrint('Interstitial failed to load: $error');
        },
      ),
    );
  }

  /// Runs [onDone] right away, or after the ad is dismissed when one is shown.
  void maybeShow(VoidCallback onDone) {
    _calls++;
    final ad = _ad;
    final last = _lastShown;
    final due = _calls % showEvery == 0 &&
        (last == null || DateTime.now().difference(last) >= minGap);

    if (ad == null || !due) {
      preload();
      onDone();
      return;
    }

    _ad = null;
    _lastShown = DateTime.now();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
        onDone();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preload();
        onDone();
      },
    );
    ad.show();
  }
}

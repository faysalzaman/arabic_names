import 'package:flutter/foundation.dart';

/// AdMob unit ids. Debug and profile builds use Google's test ids so development
/// never generates invalid traffic on the real units.
class AdUnits {
  AdUnits._();

  static String get banner => kReleaseMode
      ? 'ca-app-pub-9684723099725802/2015455131'
      : 'ca-app-pub-3940256099942544/9214589741'; // adaptive banner test unit

  static String get interstitial => kReleaseMode
      ? 'ca-app-pub-9684723099725802/9011274170'
      : 'ca-app-pub-3940256099942544/1033173712';

  static String get appOpen => kReleaseMode
      ? 'ca-app-pub-9684723099725802/7545879768'
      : 'ca-app-pub-3940256099942544/9257395921';
}

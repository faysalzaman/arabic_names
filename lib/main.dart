import 'dart:async';

import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/ads/interstitial_manager.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/ui_screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// it will run in fvm version 3.32.0

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Ads must never delay the first frame.
  unawaited(
    MobileAds.instance.initialize().then((_) => InterstitialManager.instance.preload()),
  );

  runApp(
    BlocProvider<FavouriteBloc>(
      create: (_) => FavouriteBloc()..add(GetFavourites()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arabic Names App',
      theme: buildAppTheme(),
      // The UI is Arabic, so lay everything out right-to-left (back arrows, lists and
      // the side rail all mirror automatically).
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

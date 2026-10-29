import 'dart:async';

import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/Bloc/NameBloc/names_bloc.dart';
import 'package:arabic_names/ads/interstitial_manager.dart';
import 'package:arabic_names/ui_screens/splash_screen.dart';
import 'package:arabic_names/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// it will run in fvm version 3.32.0

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Ads must never delay the first frame.
  unawaited(
    MobileAds.instance.initialize().then((_) => InterstitialManager.instance.preload()),
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<NamesBloc>(create: (_) => NamesBloc()),
        BlocProvider<FavouriteBloc>(create: (_) => FavouriteBloc()..add(GetFavourites())),
      ],
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
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: Constants.primaryColor),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Constants.primaryColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

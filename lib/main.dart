//  ignore_for_file: library_private_types_in_public_api

import 'package:arabic_names/ui_screens/splash_screen.dart';
import 'package:arabic_names/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/Bloc/NameBloc/names_bloc.dart';
import 'package:arabic_names/DataBase/SharedPrefrences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();

  // Clear the cache before the app starts
  await DefaultCacheManager().emptyCache();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<NamesBloc>(create: (context) => NamesBloc()),
        BlocProvider<FavouriteBloc>(create: (context) => FavouriteBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  //  ignore: use_key_in_widget_constructors
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SharedPreference.savebool(SharedPreference.isViewedPopUP, false);
  }

  //  This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arabic Names App',
      theme: ThemeData(
        // primarySwatch: Constants.primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Constants.primaryColor,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Constants.primaryColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/ui_screens/home_screen.dart';
import '../Model/names_model.dart';
import 'detail_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  Icon customIcon = const Icon(Icons.search);
  bool fav = false;

  List<NameModel> listofNames = [];
  String? gender;

  List<NameModel> namemodel = [];
  String? names;

  FavouriteBloc? favouriteBloc;

  // InterstitialAd? interstitialAd;
  // BannerAd? bannerAd;

  bool isInterstitialAdReady = false;
  bool isBannerAdReady = false;

  @override
  void initState() {
    favouriteBloc = BlocProvider.of<FavouriteBloc>(context);
    favouriteBloc!.add(GetFavourites());
    super.initState();
    // loadInterstitialAd();
    // loadBannerAd();
  }

  // void loadInterstitialAd() {
  //   InterstitialAd.load(
  //     adUnitId: 'ca-app-pub-9684723099725802/6067690957',
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         print('تم تحميل الإعلان البيني');
  //         interstitialAd = ad;
  //         isInterstitialAdReady = true;
  //       },
  //       onAdFailedToLoad: (error) {
  //         print('فشل تحميل الإعلان البيني: $error');
  //         isInterstitialAdReady = false;
  //       },
  //     ),
  //   );
  // }

  // void loadBannerAd() {
  //   bannerAd = BannerAd(
  //     adUnitId: 'ca-app-pub-9684723099725802/9851819455',
  //     request: const AdRequest(),
  //     size: AdSize.banner,
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         setState(() {
  //           isBannerAdReady = true;
  //         });
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         print('فشل تحميل الإعلان البانر: $error');
  //         ad.dispose();
  //         isBannerAdReady = false;
  //       },
  //     ),
  //   );
  //   bannerAd!.load();
  // }

  // void showInterstitialAd() {
  //   if (isInterstitialAdReady && interstitialAd != null) {
  //     interstitialAd!.show();
  //     interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
  //       onAdDismissedFullScreenContent: (ad) {
  //         ad.dispose();
  //         loadInterstitialAd();
  //       },
  //       onAdFailedToShowFullScreenContent: (ad, error) {
  //         ad.dispose();
  //         loadInterstitialAd();
  //       },
  //     );
  //   } else {
  //     print('الإعلان البيني غير جاهز بعد');
  //   }
  // }

  @override
  void dispose() {
    // interstitialAd?.dispose();
    // bannerAd?.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/w.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: const MyDrawerWidget(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
          ],
          title: const Text(
            "الأسماء المفضلة",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<FavouriteBloc, FavouriteState>(
                builder: (context, state) {
                  if (state is FavouriteLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                      ),
                    );
                  }
                  if (state is FavouriteSuccess) {
                    namemodel = state.model;
                    if (namemodel.isEmpty || namemodel == null) {
                      return const Center(
                        child: Text(
                          'لا توجد أسماء مفضلة بعد',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: namemodel.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        String genderIcon = namemodel[index].gender == "ذكر" ||
                                namemodel[index].gender == "صبي" ||
                                namemodel[index].gender == "ولد"
                            ? "👨"
                            : "👩";
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  model: namemodel[index],
                                ),
                              ),
                            );
                            // showInterstitialAd();
                          },
                          title: Text(
                            "${namemodel[index].urduName} $genderIcon",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                    ),
                  );
                },
              ),
            ),
            // if (isBannerAdReady)
            //   Container(
            //     color: Colors.transparent,
            //     width: bannerAd!.size.width.toDouble(),
            //     height: bannerAd!.size.height.toDouble(),
            //     child: AdWidget(ad: bannerAd!),
            //   ),
          ],
        ),
      ),
    );
  }
}

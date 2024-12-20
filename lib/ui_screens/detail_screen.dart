//  ignore_for_file: must_be_immutable, library_private_types_in_public_api, avoid_print, unrelated_type_equality_checks

import 'package:arabic_names/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import '../Model/names_model.dart';
import 'package:share_plus/share_plus.dart';

class DetailPage extends StatefulWidget {
  final int? isPageOpen;
  final NameModel? model;

  const DetailPage({
    super.key,
    this.model,
    this.isPageOpen,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFav = false;
  // bool isInterstitialAdReady = false;
  // bool isBannerAdReady = false;

  // InterstitialAd? interstitialAd;
  // BannerAd? bannerAd;

  final horizantalSpacing = const SizedBox(height: 12);

  final kboldTextStyle = const TextStyle(
    fontSize: 15,
    color: Colors.white,
  );

  final ktextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  FavouriteBloc? favouriteBloc;

  @override
  void initState() {
    favouriteBloc = BlocProvider.of<FavouriteBloc>(context);
    super.initState();

    // loadInterstitialAd();
    // loadBannerAd();

    isFav = widget.model!.isFavourite == true;
    print(widget.model!.toMap());
  }

  // void loadInterstitialAd() {
  //   InterstitialAd.load(
  //     adUnitId: 'ca-app-pub-9684723099725802/6067690957',
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         print('InterstitialAd loaded');
  //         interstitialAd = ad;
  //         isInterstitialAdReady = true;
  //       },
  //       onAdFailedToLoad: (error) {
  //         print('InterstitialAd failed to load: $error');
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
  //         print('BannerAd failed to load: $error');
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
  //     print('Interstitial ad is not ready yet');
  //   }
  // }

  void toggleFavorite() {
    setState(() {
      isFav = !isFav;
    });

    if (isFav) {
      widget.model!.isFavourite = "1";
    } else {
      widget.model!.isFavourite = "0";
    }

    favouriteBloc!.add(AddtoFavourite(model: widget.model!));

    // showInterstitialAd();
  }

  @override
  void dispose() {
    // interstitialAd?.dispose();
    // bannerAd?.dispose();
    super.dispose();
  }

  //  ... (keep all existing properties and methods)

  Widget _buildInfoRow(String label, String? value, {bool isUrdu = false}) {
    if (value == null || value.isEmpty || value == "null") {
      return const SizedBox
          .shrink(); // Return an empty widget if the value is null or empty
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Wrap(
        children: [
          Text(
            isUrdu ? '$value : ' : '$label : ',
            style: isUrdu ? ktextStyle : kboldTextStyle,
          ),
          Text(
            isUrdu ? label : value,
            style: isUrdu ? kboldTextStyle : ktextStyle,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEnglishContent() {
    return [
      _buildInfoRow('Name', widget.model!.englishName),
      _buildInfoRow('Meaning', widget.model!.englishMeaning),
      _buildInfoRow(
          'Gender',
          widget.model?.gender.toString() == "Male" ||
                  widget.model?.gender.toString() == "Boy" ||
                  widget.model?.gender.toString() == "Larka"
              ? "Male"
              : "Male"),
      _buildInfoRow('Religion', widget.model!.englishReligion),
      _buildInfoRow('Language', widget.model!.englishLanguage),
      _buildInfoRow('Lucky Number', widget.model?.urduLuckyNumber),
      _buildInfoRow('Lucky Color', widget.model!.englishLuckyColor),
      _buildInfoRow('Lucky Day', widget.model!.englishLuckyDay),
      _buildInfoRow('Lucky Metal', widget.model!.englishLuckyMetals),
      _buildInfoRow('Lucky Stone', widget.model!.englishLuckyStones),
      _buildInfoRow('Famous Person', widget.model!.englishFamousPerson),
      _buildInfoRow('Description', widget.model!.englishDescription),
      _buildInfoRow('Known For', widget.model!.englishKnownFor),
      _buildInfoRow('Occupation/Designation', widget.model!.englishOccopation),
    ]
        .where((widget) => widget is! SizedBox)
        .toList(); // Filter out the empty rows
  }

  List<Widget> _buildUrduContent() {
    return [
      _buildInfoRow('الاسم', widget.model!.urduName, isUrdu: true),
      _buildInfoRow('المعنى', widget.model?.urduMeaning, isUrdu: true),
      _buildInfoRow(
          'الجنس',
          widget.model?.gender.toString() == "Male" ||
                  widget.model?.gender.toString() == "Boy" ||
                  widget.model?.gender.toString() == "Larka"
              ? "ذكر"
              : "أنثى",
          isUrdu: true),
      _buildInfoRow('الديانة', widget.model!.urduReligion, isUrdu: true),
      _buildInfoRow('اللغة', widget.model!.urduLanguage, isUrdu: true),
      _buildInfoRow('اللون المفضل', widget.model!.urduLuckyColor, isUrdu: true),
      _buildInfoRow('اليوم المفضل', widget.model!.urduLuckyDay, isUrdu: true),
      _buildInfoRow('المعدن المفضل', widget.model!.urduLuckyMetals,
          isUrdu: true),
      _buildInfoRow('الرقم المفضل', widget.model!.urduLuckyNumber,
          isUrdu: true),
      _buildInfoRow('الحجر المفضل', widget.model!.urduLuckyStones,
          isUrdu: true),
      _buildInfoRow('الشخصية المشهورة', widget.model!.urduFamousPerson,
          isUrdu: true),
      _buildInfoRow('الوصف', widget.model!.urduDescription, isUrdu: true),
      _buildInfoRow('مشهور بـ', widget.model!.urduKnownFor, isUrdu: true),
      _buildInfoRow('الوظيفة / المهنة', widget.model!.urduOccopation,
          isUrdu: true),
    ]
        .where((widget) => widget is! SizedBox)
        .toList(); // Filter out the empty rows
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.5,
            image: AssetImage("assets/w.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Constants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onPressed: () {
              Share.share(
                'Name : ${widget.model!.englishName} \n Urdu Name : ${widget.model!.urduName} \n English Meaning : ${widget.model!.englishMeaning} \n Urdu Meaning : ${widget.model!.urduMeaning} \n Gender : ${widget.model!.gender} \n Religion : ${widget.model!.englishReligion} \n Language : ${widget.model!.englishLanguage} \n Lucky Color : ${widget.model!.englishLuckyColor} \n Lucky Day : ${widget.model!.englishLuckyDay} \n Lucky Metals : ${widget.model!.englishLuckyMetals} \n Lucky Stones : ${widget.model!.englishLuckyStones} \n Famous Person : ${widget.model!.englishFamousPerson} \n Description : ${widget.model!.englishDescription} \n Known For : ${widget.model!.englishKnownFor} \n Occupation/Designation : ${widget.model!.englishOccopation}',
              );
            },
            child: const Icon(Icons.share),
          ),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.keyboard_backspace_outlined)),
            automaticallyImplyLeading: false,
            title: const Text('Islamic Names'),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(child: Text('عربي')),
                Tab(child: Text('English')),
              ],
            ),
            actions: [
              IconButton(
                onPressed: toggleFavorite,
                icon: Icon(
                  isFav
                      ? Icons.favorite_outlined
                      : Icons.favorite_outline_sharp,
                  color: isFav ? Colors.red : Colors.black,
                ),
              ),
            ],
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _buildUrduContent(),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildEnglishContent(),
                        ),
                      ),
                    ),
                  ],
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
      ),
    );
  }
}

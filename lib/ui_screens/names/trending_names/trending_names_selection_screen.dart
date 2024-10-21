// ignore_for_file: avoid_print, library_private_types_in_public_api, file_names

import 'package:arabic_names/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arabic_names/Bloc/NameBloc/names_bloc.dart';
import 'package:arabic_names/DataBase/SharedPrefrences.dart';
import 'package:arabic_names/ui_screens/home_screen.dart';

class TrendingNamesSelectionScreen extends StatefulWidget {
  const TrendingNamesSelectionScreen({super.key});

  @override
  _TrendingNamesSelectionScreenState createState() =>
      _TrendingNamesSelectionScreenState();
}

class _TrendingNamesSelectionScreenState
    extends State<TrendingNamesSelectionScreen> {
  NamesBloc? namesBloc;
  NamesSuccess? namesState;
  bool? isViewed;

  // late BannerAd _bannerAd;
  // bool isAdLoaded = false;

  void getIsViewed() async {
    isViewed = await SharedPreference.getbool(SharedPreference.isViewed);
  }

  @override
  void initState() {
    super.initState();
    // _initBannerAd();
    namesBloc = BlocProvider.of<NamesBloc>(context);
    namesBloc!.add(GetNames());
    getIsViewed();
  }

  // void _initBannerAd() {
  //   _bannerAd = BannerAd(
  //     size: AdSize.banner,
  //     adUnitId:
  //         'ca-app-pub-9684723099725802/9851819455', // Use your real ad unit ID
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         setState(() {
  //           isAdLoaded = true;
  //         });
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //         print(
  //             'Failed to load a banner ad: $error'); // Optional: Add logging for errors
  //       },
  //     ),
  //     request: const AdRequest(),
  //   );
  //   _bannerAd.load();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: isAdLoaded
      //     ? SizedBox(
      //         height: _bannerAd.size.height.toDouble(),
      //         width: _bannerAd.size.width.toDouble(),
      //         child: AdWidget(ad: _bannerAd),
      //       )
      //     : const SizedBox(),
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
              MaterialButton(
                onPressed: () => submit('Boy'),
                color: Constants.buttonColor,
                shape: const StadiumBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
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
                            backgroundImage: AssetImage('assets/boy.jpeg'),
                          ),
                        ),
                        Text(
                          'الأولاد',
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
              ),
              const SizedBox(height: 6),
              MaterialButton(
                onPressed: () => submit('Girl'),
                color: Constants.buttonColor,
                shape: const StadiumBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
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
                            backgroundImage: AssetImage('assets/girl.jpeg'),
                          ),
                        ),
                        Text(
                          'فتيات',
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
              ),
              const SizedBox(height: 6),
              BlocBuilder<NamesBloc, NamesState>(
                builder: ((context, state) {
                  if (state is NamesLoading) {
                    return Column(
                      children: [
                        isViewed == false
                            ? const Text(
                                'Extracting Data...',
                                style: TextStyle(color: Colors.white),
                              )
                            : Container(),
                        const SizedBox(height: 10),
                        isViewed == false
                            ? const CircularProgressIndicator(
                                strokeWidth: 10,
                                strokeCap: StrokeCap.round,
                              )
                            : Container(),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit(String gender) {
    var namestate = BlocProvider.of<NamesBloc>(context).state;
    if (namestate is NamesSuccess) {
      namesState = namestate;
    }
    namesBloc!.add(GetNamesOnGender(gender: gender, list: namesState!.model));
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => HomeScreen(),
      ),
    );
  }
}

import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/ads/banner_ad_bar.dart';
import 'package:arabic_names/ads/interstitial_manager.dart';
import 'package:arabic_names/ui_screens/detail_screen.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:arabic_names/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<FavouriteBloc>().add(GetFavourites());
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: const AppDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ],
          title: const Text(
            'الأسماء المفضلة',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<FavouriteBloc, FavouriteState>(
          builder: (context, state) {
            if (state is! FavouriteSuccess) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                ),
              );
            }
            if (state.names.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد أسماء مفضلة بعد',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 10),
              itemCount: state.names.length,
              itemBuilder: (context, index) {
                final name = state.names[index];
                return ListTile(
                  onTap: () => InterstitialManager.instance.maybeShow(() {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailPage(model: name)),
                    );
                  }),
                  title: Text(
                    '${name.urduName} ${name.genderEmoji}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: const BannerAdBar(),
      ),
    );
  }
}

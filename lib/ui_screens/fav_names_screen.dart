import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/ads/banner_ad_bar.dart';
import 'package:arabic_names/ads/interstitial_manager.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/ui_screens/detail_screen.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:arabic_names/widgets/name_tile.dart';
import 'package:arabic_names/widgets/ornaments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavouriteBloc>().add(GetFavourites());
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('الأسماء المفضلة')),
        body: BlocBuilder<FavouriteBloc, FavouriteState>(
          builder: (context, state) {
            if (state is! FavouriteSuccess) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.names.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StarMedallion(
                        size: 96,
                        child: Icon(
                          Icons.favorite_border_rounded,
                          size: 40,
                          color: AppColors.favourite,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'لا توجد أسماء مفضلة بعد',
                        style: TextStyle(
                          fontFamily: AppFonts.naskh,
                          color: AppColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'اضغط على القلب بجانب أي اسم لإضافته هنا',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              itemCount: state.names.length,
              itemBuilder: (context, index) {
                final name = state.names[index];
                return NameTile(
                  name: name,
                  isFavourite: true,
                  onTap: () => InterstitialManager.instance.maybeShow(() {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailPage(model: name)),
                    );
                  }),
                  onToggleFavourite: () =>
                      context.read<FavouriteBloc>().add(ToggleFavourite(name)),
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

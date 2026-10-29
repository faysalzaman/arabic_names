import 'package:arabic_names/Bloc/NameBloc/names_bloc.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ads/banner_ad_bar.dart';
import 'package:arabic_names/ads/interstitial_manager.dart';
import 'package:arabic_names/ui_screens/home_screen.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:arabic_names/widgets/pill_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Boys / girls chooser for one [NameCategory] (all, trending or celebrity).
/// Replaces the three near-identical selection screens.
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.category});

  final NameCategory category;

  void _open(BuildContext context, NameGender gender) {
    context.read<NamesBloc>().add(LoadNames(category: category, gender: gender));
    InterstitialManager.instance.maybeShow(() {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BannerAdBar(),
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PillButton(
                label: 'الأولاد',
                imageAsset: 'assets/boy.jpeg',
                onPressed: () => _open(context, NameGender.male),
              ),
              const SizedBox(height: 6),
              PillButton(
                label: 'فتيات',
                imageAsset: 'assets/girl.jpeg',
                onPressed: () => _open(context, NameGender.female),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

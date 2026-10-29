import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ads/banner_ad_bar.dart';
import 'package:arabic_names/utils/constants.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

const TextStyle _textStyle = TextStyle(fontSize: 16, color: Colors.white);
const TextStyle _boldTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.model});

  final NameModel model;

  String _shareText() {
    final lines = <String, String?>{
      'Name': model.englishName,
      'Arabic Name': model.urduName,
      'Meaning': model.englishMeaning,
      'Arabic Meaning': model.urduMeaning,
      'Gender': model.genderLabelEn,
      'Religion': model.englishReligion,
      'Language': model.englishLanguage,
      'Lucky Color': model.englishLuckyColor,
      'Lucky Day': model.englishLuckyDay,
      'Lucky Metal': model.englishLuckyMetals,
      'Lucky Stone': model.englishLuckyStones,
      'Famous Person': model.englishFamousPerson,
      'Description': model.englishDescription,
      'Known For': model.englishKnownFor,
      'Occupation/Designation': model.englishOccopation,
    };
    return [
      for (final entry in lines.entries)
        if (entry.value != null) '${entry.key}: ${entry.value}',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppBackground(
        opacity: 0.5,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Constants.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            onPressed: () => Share.share(_shareText()),
            child: const Icon(Icons.share),
          ),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.keyboard_backspace_outlined),
            ),
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
              BlocBuilder<FavouriteBloc, FavouriteState>(
                builder: (context, state) {
                  final isFav = state is FavouriteSuccess && state.keys.contains(model.key);
                  return IconButton(
                    onPressed: () =>
                        context.read<FavouriteBloc>().add(ToggleFavourite(model)),
                    icon: Icon(
                      isFav ? Icons.favorite_outlined : Icons.favorite_outline_sharp,
                      color: isFav ? Colors.red : Colors.black,
                    ),
                  );
                },
              ),
            ],
            centerTitle: true,
          ),
          body: TabBarView(
            children: [
              _buildTab(_arabicRows(), CrossAxisAlignment.end, Alignment.centerRight),
              _buildTab(_englishRows(), CrossAxisAlignment.start, Alignment.centerLeft),
            ],
          ),
          bottomNavigationBar: const BannerAdBar(),
        ),
      ),
    );
  }

  Widget _buildTab(
    List<Widget> rows,
    CrossAxisAlignment crossAxisAlignment,
    Alignment alignment,
  ) {
    return SingleChildScrollView(
      child: Container(
        alignment: alignment,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: crossAxisAlignment, children: rows),
      ),
    );
  }

  /// A "label : value" row; nothing is drawn when [value] is empty.
  Widget _infoRow(String label, String? value, {bool arabic = false}) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Wrap(
        children: [
          Text(arabic ? '$value : ' : '$label : ',
              style: arabic ? _textStyle : _boldTextStyle),
          Text(arabic ? label : value, style: arabic ? _boldTextStyle : _textStyle),
        ],
      ),
    );
  }

  List<Widget> _englishRows() => [
        _infoRow('Name', model.englishName),
        _infoRow('Meaning', model.englishMeaning),
        _infoRow('Gender', model.genderLabelEn),
        _infoRow('Religion', model.englishReligion),
        _infoRow('Language', model.englishLanguage),
        _infoRow('Lucky Number', model.urduLuckyNumber),
        _infoRow('Lucky Color', model.englishLuckyColor),
        _infoRow('Lucky Day', model.englishLuckyDay),
        _infoRow('Lucky Metal', model.englishLuckyMetals),
        _infoRow('Lucky Stone', model.englishLuckyStones),
        _infoRow('Famous Person', model.englishFamousPerson),
        _infoRow('Description', model.englishDescription),
        _infoRow('Known For', model.englishKnownFor),
        _infoRow('Occupation/Designation', model.englishOccopation),
      ];

  List<Widget> _arabicRows() => [
        _infoRow('الاسم', model.urduName, arabic: true),
        _infoRow('المعنى', model.urduMeaning, arabic: true),
        _infoRow('الجنس', model.genderLabelAr, arabic: true),
        _infoRow('الديانة', model.urduReligion, arabic: true),
        _infoRow('اللغة', model.urduLanguage, arabic: true),
        _infoRow('اللون المفضل', model.urduLuckyColor, arabic: true),
        _infoRow('اليوم المفضل', model.urduLuckyDay, arabic: true),
        _infoRow('المعدن المفضل', model.urduLuckyMetals, arabic: true),
        _infoRow('الرقم المفضل', model.urduLuckyNumber, arabic: true),
        _infoRow('الحجر المفضل', model.urduLuckyStones, arabic: true),
        _infoRow('الشخصية المشهورة', model.urduFamousPerson, arabic: true),
        _infoRow('الوصف', model.urduDescription, arabic: true),
        _infoRow('مشهور بـ', model.urduKnownFor, arabic: true),
        _infoRow('الوظيفة / المهنة', model.urduOccopation, arabic: true),
      ];
}

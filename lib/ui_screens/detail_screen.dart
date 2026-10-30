import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ads/banner_ad_bar.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:arabic_names/widgets/ornaments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class _Field {
  const _Field(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String? value;
}

class _Section {
  const _Section(this.title, this.fields, {this.grid = false});
  final String title;
  final List<_Field> fields;

  /// Short values shown as two-column tiles instead of rows.
  final bool grid;
}

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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            actions: [
              BlocBuilder<FavouriteBloc, FavouriteState>(
                builder: (context, state) {
                  final isFav = state is FavouriteSuccess && state.keys.contains(model.key);
                  return IconButton(
                    tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                    onPressed: () {
                      context.read<FavouriteBloc>().add(ToggleFavourite(model));
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          duration: const Duration(seconds: 2),
                          content: Text(isFav ? 'أُزيل من المفضلة' : 'أُضيف إلى المفضلة ❤'),
                        ));
                    },
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? AppColors.favourite : Colors.white,
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'مشاركة',
                onPressed: () => Share.share(_shareText()),
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              _Header(model: model),
              const TabBar(tabs: [Tab(text: 'عربي'), Tab(text: 'English')]),
              Expanded(
                child: TabBarView(
                  children: [
                    _SectionList(
                      sections: _arabicSections(),
                      meaning: model.urduMeaning,
                      meaningLabel: 'معنى الاسم',
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: _SectionList(
                        sections: _englishSections(),
                        meaning: model.englishMeaning,
                        meaningLabel: 'Meaning',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BannerAdBar(),
        ),
      ),
    );
  }

  List<_Section> _arabicSections() => [
        _Section('التفاصيل', grid: true, [
          _Field(Icons.translate_rounded, 'اللغة', model.urduLanguage),
          _Field(Icons.mosque_rounded, 'الديانة', model.urduReligion),
          _Field(Icons.tag_rounded, 'الرقم المفضل', model.urduLuckyNumber),
          _Field(Icons.palette_rounded, 'اللون المفضل', model.urduLuckyColor),
          _Field(Icons.event_rounded, 'اليوم المفضل', model.urduLuckyDay),
          _Field(Icons.hexagon_rounded, 'المعدن المفضل', model.urduLuckyMetals),
          _Field(Icons.diamond_rounded, 'الحجر المفضل', model.urduLuckyStones),
        ]),
        _Section('نبذة', [
          _Field(Icons.person_rounded, 'الشخصية المشهورة', model.urduFamousPerson),
          _Field(Icons.notes_rounded, 'الوصف', model.urduDescription),
          _Field(Icons.star_rounded, 'مشهور بـ', model.urduKnownFor),
          _Field(Icons.work_rounded, 'الوظيفة / المهنة', model.urduOccopation),
        ]),
      ];

  List<_Section> _englishSections() => [
        _Section('Details', grid: true, [
          _Field(Icons.translate_rounded, 'Language', model.englishLanguage),
          _Field(Icons.mosque_rounded, 'Religion', model.englishReligion),
          _Field(Icons.tag_rounded, 'Lucky Number', model.urduLuckyNumber),
          _Field(Icons.palette_rounded, 'Lucky Color', model.englishLuckyColor),
          _Field(Icons.event_rounded, 'Lucky Day', model.englishLuckyDay),
          _Field(Icons.hexagon_rounded, 'Lucky Metal', model.englishLuckyMetals),
          _Field(Icons.diamond_rounded, 'Lucky Stone', model.englishLuckyStones),
        ]),
        _Section('About', [
          _Field(Icons.person_rounded, 'Famous Person', model.englishFamousPerson),
          _Field(Icons.notes_rounded, 'Description', model.englishDescription),
          _Field(Icons.star_rounded, 'Known For', model.englishKnownFor),
          _Field(Icons.work_rounded, 'Occupation/Designation', model.englishOccopation),
        ]),
      ];
}

class _Header extends StatelessWidget {
  const _Header({required this.model});

  final NameModel model;

  @override
  Widget build(BuildContext context) {
    final genderColor = switch (model.gender) {
      'Male' => AppColors.boy,
      'Female' => AppColors.girl,
      _ => AppColors.gold,
    };

    return PatternHeader(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Text(
              model.urduName ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.naskh,
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            if (model.englishName != null)
              Text(
                model.englishName!,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            const SizedBox(height: 10),
            const OrnamentDivider(width: 120),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _Chip(icon: Icons.person_rounded, label: model.genderLabelAr, color: genderColor),
                if (model.urduLanguage != null)
                  _Chip(
                    icon: Icons.translate_rounded,
                    label: model.urduLanguage!,
                    color: AppColors.gold,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({
    required this.sections,
    required this.meaning,
    required this.meaningLabel,
  });

  final List<_Section> sections;
  final String? meaning;
  final String meaningLabel;

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final section in sections)
        _Section(section.title, grid: section.grid, [
          for (final field in section.fields)
            if (field.value != null) field,
        ]),
    ].where((section) => section.fields.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (meaning != null) _MeaningCard(label: meaningLabel, meaning: meaning!),
        for (final section in visible) ...[
          SectionTitle(section.title),
          if (section.grid)
            _FactGrid(fields: section.fields)
          else
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  children: [
                    for (final (i, field) in section.fields.indexed) ...[
                      if (i > 0) const Divider(height: 1, color: AppColors.line),
                      _FactRow(field: field),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _MeaningCard extends StatelessWidget {
  const _MeaningCard({required this.label, required this.meaning});

  final String label;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: GeometricPattern(opacity: 0.18, tile: 44)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const OrnamentDivider(width: 90),
                const SizedBox(height: 10),
                Text(
                  meaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppFonts.naskh,
                    color: AppColors.ink,
                    fontSize: 22,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Short facts (lucky day, colour, ...) as two-column tiles.
class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.fields});

  final List<_Field> fields;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 10) / 2;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final field in fields)
                SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          StarMedallion(
                            size: 36,
                            child: Icon(field.icon, size: 16, color: AppColors.emerald),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  field.label,
                                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                ),
                                Text(
                                  field.value!,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.field});

  final _Field field;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(field.icon, size: 20, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  field.value!,
                  style: const TextStyle(color: AppColors.ink, fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ads/banner_ad_bar.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class _Field {
  const _Field(this.label, this.value);
  final String label;
  final String? value;
}

class _Section {
  const _Section(this.title, this.fields);
  final String title;
  final List<_Field> fields;
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
            title: Text(model.urduName ?? ''),
            actions: [
              BlocBuilder<FavouriteBloc, FavouriteState>(
                builder: (context, state) {
                  final isFav = state is FavouriteSuccess && state.keys.contains(model.key);
                  return IconButton(
                    tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                    onPressed: () =>
                        context.read<FavouriteBloc>().add(ToggleFavourite(model)),
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.favourite : Colors.white,
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'مشاركة',
                onPressed: () => Share.share(_shareText()),
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          body: Column(
            children: [
              _Header(model: model),
              const TabBar(
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.accent,
                dividerColor: Colors.transparent,
                tabs: [Tab(text: 'عربي'), Tab(text: 'English')],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _SectionList(sections: _arabicSections(), meaning: model.urduMeaning),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: _SectionList(
                        sections: _englishSections(),
                        meaning: model.englishMeaning,
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
        _Section('التفاصيل', [
          _Field('اللغة', model.urduLanguage),
          _Field('الديانة', model.urduReligion),
          _Field('الرقم المفضل', model.urduLuckyNumber),
          _Field('اللون المفضل', model.urduLuckyColor),
          _Field('اليوم المفضل', model.urduLuckyDay),
          _Field('المعدن المفضل', model.urduLuckyMetals),
          _Field('الحجر المفضل', model.urduLuckyStones),
        ]),
        _Section('نبذة', [
          _Field('الشخصية المشهورة', model.urduFamousPerson),
          _Field('الوصف', model.urduDescription),
          _Field('مشهور بـ', model.urduKnownFor),
          _Field('الوظيفة / المهنة', model.urduOccopation),
        ]),
      ];

  List<_Section> _englishSections() => [
        _Section('Details', [
          _Field('Language', model.englishLanguage),
          _Field('Religion', model.englishReligion),
          _Field('Lucky Number', model.urduLuckyNumber),
          _Field('Lucky Color', model.englishLuckyColor),
          _Field('Lucky Day', model.englishLuckyDay),
          _Field('Lucky Metal', model.englishLuckyMetals),
          _Field('Lucky Stone', model.englishLuckyStones),
        ]),
        _Section('About', [
          _Field('Famous Person', model.englishFamousPerson),
          _Field('Description', model.englishDescription),
          _Field('Known For', model.englishKnownFor),
          _Field('Occupation/Designation', model.englishOccopation),
        ]),
      ];
}

class _Header extends StatelessWidget {
  const _Header({required this.model});

  final NameModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          Text(
            model.urduName ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (model.englishName != null)
            Text(
              model.englishName!,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: AppColors.muted, fontSize: 18),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _Chip(icon: Icons.person_outline, label: model.genderLabelAr),
              if (model.urduLanguage != null)
                _Chip(icon: Icons.translate, label: model.urduLanguage!),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.accent),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      side: BorderSide.none,
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.sections, required this.meaning});

  final List<_Section> sections;
  final String? meaning;

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final section in sections)
        _Section(section.title, [
          for (final field in section.fields)
            if (field.value != null) field,
        ]),
    ].where((section) => section.fields.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (meaning != null)
          _CardShell(
            child: Text(
              meaning!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        for (final section in visible)
          _CardShell(
            title: section.title,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final field in section.fields)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
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
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface.withValues(alpha: 0.92),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

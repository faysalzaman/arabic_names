import 'dart:async';

import 'package:arabic_names/Bloc/FavouriteBloc/favourite_bloc.dart';
import 'package:arabic_names/Bloc/NameBloc/names_bloc.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ads/banner_ad_bar.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/ui_screens/detail_screen.dart';
import 'package:arabic_names/ui_screens/fav_names_screen.dart';
import 'package:arabic_names/utils/labels.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:arabic_names/widgets/name_tile.dart';
import 'package:arabic_names/widgets/ornaments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Letters shown in the side rail. Names are normalised in the database (see
/// tool/build_names_db.py), so each name's `letter` is always one of these.
const List<String> _alphabet = [
  'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص', //
  'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي',
];

/// Browse one [NameCategory]: boys/girls switch, search, A-Z rail, tap to open a name.
/// Each visit gets its own [NamesBloc], so a list never shows another list's data.
class NamesListScreen extends StatelessWidget {
  const NamesListScreen({
    super.key,
    required this.category,
    this.initialGender = NameGender.male,
    this.autofocusSearch = false,
  });

  final NameCategory category;
  final NameGender initialGender;

  /// Opens with the keyboard up (from the home screen search box).
  final bool autofocusSearch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NamesBloc()
        ..add(LoadNames(category: category, gender: initialGender)),
      child: _NamesListView(
        category: category,
        initialGender: initialGender,
        autofocusSearch: autofocusSearch,
      ),
    );
  }
}

class _NamesListView extends StatefulWidget {
  const _NamesListView({
    required this.category,
    required this.initialGender,
    required this.autofocusSearch,
  });

  final NameCategory category;
  final NameGender initialGender;
  final bool autofocusSearch;

  @override
  State<_NamesListView> createState() => _NamesListViewState();
}

class _NamesListViewState extends State<_NamesListView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  Timer? _scrollDebounce;
  late NameGender _gender = widget.initialGender;
  List<NameModel> _names = const [];
  String? _selectedLetter;
  bool _isJumping = false;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_updateSelectedLetterOnScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollDebounce?.cancel();
    _itemPositionsListener.itemPositions.removeListener(_updateSelectedLetterOnScroll);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {}); // shows/hides the clear button
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _selectedLetter = null);
      context.read<NamesBloc>().add(SearchNames(query));
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _onGenderChanged(NameGender gender) {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _gender = gender;
      _selectedLetter = null;
    });
    context.read<NamesBloc>().add(LoadNames(category: widget.category, gender: gender));
  }

  Future<void> _scrollToLetter(String letter) async {
    if (_isJumping) return;
    final index = _names.indexWhere((name) => name.letter == letter);
    if (index == -1) return;

    _isJumping = true;
    setState(() => _selectedLetter = letter);
    try {
      await _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
      );
    } finally {
      _isJumping = false;
    }
  }

  void _updateSelectedLetterOnScroll() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted || _isJumping || _names.isEmpty) return;

      final visible = _itemPositionsListener.itemPositions.value
          .where((p) => p.itemLeadingEdge < 0.5 && p.itemTrailingEdge > 0.0);
      if (visible.isEmpty) return;

      final first = visible.reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b);
      if (first.index < 0 || first.index >= _names.length) return;

      final letter = _names[first.index].letter;
      if (letter != _selectedLetter) setState(() => _selectedLetter = letter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.category.title),
          actions: [
            IconButton(
              tooltip: 'المفضلة',
              icon: const Icon(Icons.favorite_border_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavouritesScreen()),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildControls(),
            Expanded(
              child: BlocBuilder<NamesBloc, NamesState>(
                builder: (context, state) {
                  if (state is NamesSuccess) {
                    _names = state.names;
                    return _buildResults(state);
                  }
                  if (state is NamesFailure) {
                    return const Center(
                      child: Text(
                        'تعذر تحميل الأسماء',
                        style: TextStyle(color: AppColors.ink, fontSize: 16),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BannerAdBar(),
      ),
    );
  }

  Widget _buildControls() {
    return PatternHeader(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _genderPill(NameGender.male, 'الأولاد', Icons.boy_rounded, AppColors.boy),
                _genderPill(NameGender.female, 'البنات', Icons.girl_rounded, AppColors.girl),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            autofocus: widget.autofocusSearch,
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: AppColors.ink, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو المعنى',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'مسح',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _clearSearch,
                    ),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderPill(NameGender gender, String label, IconData icon, Color color) {
    final selected = _gender == gender;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: selected ? null : () => _onGenderChanged(gender),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: selected ? color : Colors.white70),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selected ? color : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(NamesSuccess state) {
    if (state.names.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StarMedallion(
              size: 72,
              child: Icon(Icons.search_off_rounded, size: 30, color: AppColors.emerald),
            ),
            const SizedBox(height: 14),
            Text(
              state.query.isEmpty ? 'لا توجد أسماء' : 'لا توجد نتائج لـ "${state.query}"',
              style: const TextStyle(color: AppColors.ink, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            if (state.query.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text(
                'جرّب كتابة الاسم بطريقة أخرى',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                '${state.names.length} اسم',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildLetterRail(),
              Expanded(
                child: BlocBuilder<FavouriteBloc, FavouriteState>(
                  builder: (context, favourites) {
                    final favouriteKeys =
                        favourites is FavouriteSuccess ? favourites.keys : const <String>{};
                    return ScrollablePositionedList.builder(
                      padding: const EdgeInsets.only(top: 2, bottom: 16),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: state.names.length,
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      itemBuilder: (context, index) {
                        final name = state.names[index];
                        return NameTile(
                          name: name,
                          isFavourite: favouriteKeys.contains(name.key),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailPage(model: name)),
                          ),
                          onToggleFavourite: () =>
                              context.read<FavouriteBloc>().add(ToggleFavourite(name)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLetterRail() {
    return Container(
      width: 38,
      margin: const EdgeInsetsDirectional.only(start: 8, top: 4, bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.line),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        physics: const BouncingScrollPhysics(),
        children: [for (final letter in _alphabet) _buildLetter(letter)],
      ),
    );
  }

  Widget _buildLetter(String letter) {
    final selected = _selectedLetter == letter;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _scrollToLetter(letter),
      child: Container(
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.emerald : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          letter,
          style: TextStyle(
            fontFamily: AppFonts.naskh,
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : AppColors.emerald,
          ),
        ),
      ),
    );
  }
}

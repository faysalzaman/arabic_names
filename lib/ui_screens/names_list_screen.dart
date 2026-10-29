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
  const NamesListScreen({super.key, required this.category});

  final NameCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NamesBloc()
        ..add(LoadNames(category: category, gender: NameGender.male)),
      child: _NamesListView(category: category),
    );
  }
}

class _NamesListView extends StatefulWidget {
  const _NamesListView({required this.category});

  final NameCategory category;

  @override
  State<_NamesListView> createState() => _NamesListViewState();
}

class _NamesListViewState extends State<_NamesListView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  Timer? _scrollDebounce;
  NameGender _gender = NameGender.male;
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
              icon: const Icon(Icons.favorite_border),
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          SegmentedButton<NameGender>(
            expandedInsets: EdgeInsets.zero,
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              backgroundColor: AppColors.surface.withValues(alpha: 0.9),
              foregroundColor: Colors.white,
              selectedBackgroundColor: AppColors.accent,
              selectedForegroundColor: AppColors.onAccent,
            ),
            segments: const [
              ButtonSegment(
                value: NameGender.male,
                icon: Icon(Icons.boy),
                label: Text('الأولاد'),
              ),
              ButtonSegment(
                value: NameGender.female,
                icon: Icon(Icons.girl),
                label: Text('الفتيات'),
              ),
            ],
            selected: {_gender},
            onSelectionChanged: (selection) => _onGenderChanged(selection.first),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو المعنى',
              hintStyle: const TextStyle(color: AppColors.muted),
              filled: true,
              fillColor: AppColors.surface.withValues(alpha: 0.9),
              prefixIcon: const Icon(Icons.search, color: AppColors.muted),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'مسح',
                      icon: const Icon(Icons.close, color: AppColors.muted),
                      onPressed: _clearSearch,
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(NamesSuccess state) {
    if (state.names.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(
              state.query.isEmpty ? 'لا توجد أسماء' : 'لا توجد نتائج لـ "${state.query}"',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              '${state.names.length} اسم',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
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
                      padding: const EdgeInsets.only(bottom: 12),
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
    return SizedBox(
      width: 34,
      child: ListView(
        shrinkWrap: true,
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
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? AppColors.onAccent : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

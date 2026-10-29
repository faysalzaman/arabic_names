import 'dart:async';

import 'package:arabic_names/Bloc/NameBloc/names_bloc.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ads/banner_ad_bar.dart';
import 'package:arabic_names/ui_screens/detail_screen.dart';
import 'package:arabic_names/utils/constants.dart';
import 'package:arabic_names/widgets/app_background.dart';
import 'package:arabic_names/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Letters shown in the side rail. Names are normalised in the database (see
/// tool/build_names_db.py), so each name's `letter` is always one of these.
const List<String> _alphabet = [
  'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص', //
  'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? _searchDebounce;
  Timer? _scrollDebounce;
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
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _selectedLetter = null);
      context.read<NamesBloc>().add(SearchNames(query));
    });
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: ListTile(
          title: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textDirection: TextDirection.rtl,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'ابحث عن اسم أو معنى',
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _searchFocusNode.requestFocus,
            icon: const Icon(Icons.search, color: Colors.black),
          ),
          IconButton(
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ],
        centerTitle: true,
      ),
      body: AppBackground(
        opacity: 0.5,
        child: BlocBuilder<NamesBloc, NamesState>(
          builder: (context, state) {
            if (state is NamesSuccess) {
              _names = state.names;
              if (_names.isEmpty) {
                return const Center(
                  child: Text(
                    'لم يتم العثور على أسماء',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }
              return _buildList(_names);
            }
            if (state is NamesFailure) {
              return Center(
                child: Text(
                  'تعذر تحميل الأسماء',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor),
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BannerAdBar(),
    );
  }

  Widget _buildList(List<NameModel> names) {
    return Row(
      children: [
        Container(
          width: 45,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              for (final letter in _alphabet) _buildLetter(letter),
            ],
          ),
        ),
        Expanded(
          child: ScrollablePositionedList.builder(
            padding: const EdgeInsets.only(bottom: 10),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: names.length,
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            itemBuilder: (context, index) {
              final name = names[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                title: Text(
                  '${name.urduName} ${name.genderEmoji}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(model: name)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLetter(String letter) {
    final selected = _selectedLetter == letter;
    return GestureDetector(
      onTap: () => _scrollToLetter(letter),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          height: 24,
          margin: const EdgeInsets.symmetric(vertical: 1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Constants.primaryColor.withOpacity(0.4) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected ? Border.all(color: Constants.primaryColor) : null,
          ),
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 13,
              color: selected ? Colors.white : Colors.white.withOpacity(0.8),
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

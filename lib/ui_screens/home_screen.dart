// ignore_for_file: must_be_immutable, library_private_types_in_public_api, unused_element

import 'dart:async';
import 'package:arabic_names/ui_screens/names/celebrity_names/celebrity_names_selection_screen.dart';
import 'package:arabic_names/ui_screens/names/gender_selection_screen.dart';
import 'package:arabic_names/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arabic_names/Bloc/NameBloc/names_bloc.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ui_screens/fav_names_screen.dart';
import 'package:arabic_names/ui_screens/names/all_names/all_names_selection_screen.dart';
import 'package:arabic_names/ui_screens/names/trending_names/trending_names_selection_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'detail_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  int? isHomeScreenOpen = 0;
  HomeScreen({
    super.key,
    this.isHomeScreenOpen,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAdLoaded = false;
  late BannerAd _bannerAd;
  List<NameModel> namemodel = [];
  List<NameModel> filteredNames = [];
  String? searchQuery;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<String> alphabet = [];
  String? selectedLetter;
  Timer? _scrollDebounceTimer;
  bool _isScrolling = false;

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initBannerAd();
    itemPositionsListener.itemPositions
        .addListener(_updateSelectedLetterOnScroll);
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId:
          'ca-app-pub-9684723099725802/2015455131', // Your banner ad unit ID
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _scrollDebounceTimer?.cancel();
    itemPositionsListener.itemPositions
        .removeListener(_updateSelectedLetterOnScroll);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _filterNames(String query) {
    setState(() {
      searchQuery = query.isEmpty ? null : query;
      if (searchQuery == null) {
        filteredNames = List.from(namemodel);
      } else {
        filteredNames = namemodel
            .where((name) => name.urduName!.contains(searchQuery!))
            .toList();
      }
      _updateAlphabet();
      selectedLetter = null;
    });
  }

  void _updateAlphabet() {
    alphabet = [
      'ا',
      'ب',
      'ت',
      'ث',
      'ج',
      'ح',
      'خ',
      'د',
      'ذ',
      'ر',
      'ز',
      'س',
      'ش',
      'ص',
      'ض',
      'ط',
      'ظ',
      'ع',
      'غ',
      'ف',
      'ق',
      'ك',
      'ل',
      'م',
      'ن',
      'ه',
      'و',
      'ي'
    ];
  }

  void _scrollToLetter(String letter) {
    if (_isScrolling) return; // Prevent multiple rapid scrolls

    // Find the first name that starts with the selected letter
    final index = filteredNames.indexWhere((name) =>
        name.urduName != null &&
        name.urduName!.isNotEmpty &&
        _getFirstArabicLetter(name.urduName!) == letter);

    if (index != -1 && index < filteredNames.length) {
      _isScrolling = true;
      setState(() {
        selectedLetter = letter;
      });

      itemScrollController
          .scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
      )
          .then((_) {
        // Reset scrolling flag after animation completes
        _isScrolling = false;
      }).catchError((error) {
        _isScrolling = false;
      });
    }
  }

  void _updateSelectedLetterOnScroll() {
    // Debounce scroll events to improve performance
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;

      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isEmpty || filteredNames.isEmpty) return;

      try {
        // Get the first visible item that's more than 50% visible
        final visiblePositions = positions.where((position) =>
            position.itemLeadingEdge < 0.5 && position.itemTrailingEdge > 0.0);

        if (visiblePositions.isEmpty) return;

        final firstVisibleIndex = visiblePositions
            .reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b)
            .index;

        if (firstVisibleIndex >= 0 &&
            firstVisibleIndex < filteredNames.length) {
          final currentName = filteredNames[firstVisibleIndex];
          if (currentName.urduName != null &&
              currentName.urduName!.isNotEmpty) {
            final currentLetter = _getFirstArabicLetter(currentName.urduName!);

            if (currentLetter != selectedLetter && !_isScrolling) {
              setState(() {
                selectedLetter = currentLetter;
              });
            }
          }
        }
      } catch (e) {
        // Handle any errors gracefully
        debugPrint('Error in scroll listener: $e');
      }
    });
  }

  // Helper method to extract the first Arabic letter correctly
  String _getFirstArabicLetter(String text) {
    if (text.isEmpty) return '';

    // Remove diacritics and get the first character
    String firstChar = text.trim()[0];

    // Map similar Arabic letters to their base form
    switch (firstChar) {
      case '\u0623':
      case '\u0625':
      case '\u0622':
      case '\u0627':
        return '\u0627';
      case '\u0629':
        return '\u062a';
      case '\u0649':
        return '\u064a';
      default:
        return firstChar;
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: const MyDrawerWidget(),
      appBar: AppBar(
        title: ListTile(
          title: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            textDirection: TextDirection.rtl,
            onChanged: _filterNames,
            decoration: const InputDecoration(
              hintText: 'ابحث عن اسم',
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              searchFocusNode.requestFocus();
            },
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.5,
            image: AssetImage("assets/w.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: BlocBuilder<NamesBloc, NamesState>(
          builder: (context, state) {
            if (state is NamesLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Constants.primaryColor),
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                ),
              );
            } else if (state is NamesSuccess) {
              namemodel = state.filteredList ?? [];
              if (filteredNames.isEmpty) filteredNames = List.from(namemodel);
              _updateAlphabet();

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Alphabet list
                  Container(
                    width: 45,
                    height: MediaQuery.of(context).size.height * 1,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        for (var letter in alphabet)
                          GestureDetector(
                            onTap: () => _scrollToLetter(letter),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                height: 24,
                                margin: const EdgeInsets.symmetric(vertical: 1),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selectedLetter == letter
                                      ? Constants.primaryColor.withOpacity(0.4)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: selectedLetter == letter
                                      ? Border.all(
                                          color: Constants.primaryColor,
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: selectedLetter == letter
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.8),
                                    fontWeight: selectedLetter == letter
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Main list of names
                  Expanded(
                    child: ScrollablePositionedList.builder(
                      padding: EdgeInsets.only(
                        bottom: isAdLoaded
                            ? _bannerAd.size.height.toDouble() + 10
                            : 10,
                      ),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: filteredNames.length,
                      itemBuilder: (context, index) {
                        final name = filteredNames[index];
                        final genderIcon = name.gender == "Male" ? "👨" : "👩";
                        return ListTile(
                          dense: false,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          title: Text(
                            "${name.urduName} $genderIcon",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(
                                    isPageOpen: widget.isHomeScreenOpen,
                                    model: name)),
                          ),
                        );
                      },
                      itemScrollController: itemScrollController,
                      itemPositionsListener: itemPositionsListener,
                    ),
                  ),
                ],
              );
            }
            return const Center(
                child: Text('لم يتم العثور على بيانات',
                    style: TextStyle(color: Colors.white)));
          },
        ),
      ),
      bottomNavigationBar: isAdLoaded
          ? SafeArea(
              child: Container(
                height: _bannerAd.size.height.toDouble(),
                width: _bannerAd.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            )
          : null,
    );
  }
}

Widget _buildPopupDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('قيمنا'),
    content: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(child: Text("قيم هذا التطبيق")),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Constants.primaryColor),
            Icon(Icons.star, color: Constants.primaryColor),
            Icon(Icons.star, color: Constants.primaryColor),
            Icon(Icons.star_border, color: Constants.primaryColor),
            Icon(Icons.star_border, color: Constants.primaryColor),
          ],
        )
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          // StoreRedirect.redirect(
          //   androidAppId: "com.namesapp.islamic_names_dictionary",
          // );
        },
        child: const Text('فتح'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('إغلاق'),
      ),
    ],
  );
}

class MyDrawerWidget extends StatelessWidget {
  const MyDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 4, 48, 2),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            width: 200,
            child: Image.asset(
              "assets/اسماء اولاد وبنات.png",
              fit: BoxFit.fill,
            ),
          ),
          // Home
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.home_outlined, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'الرئيسية',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                PageTransition(
                  type: PageTransitionType.fade,
                  child: GenderSelectionScreen(),
                ),
              );
            },
          ),
          // All Names
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.list_alt_outlined, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'جميع الأسماء',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const AllNamesSelectionScreen(),
                ),
              );
            },
          ),
          // Celebrity Names
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.star_outline, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'أسماء المشاهير',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const CelebrityNamesSelectionScreen(),
                ),
              );
            },
          ),
          // Trending Names
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'الأسماء الشائعة',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const TrendingNamesSelectionScreen(),
                ),
              );
            },
          ),
          // Favorites
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.favorite_outline, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'المفضلة',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const FavouritesScreen()));
            },
          ),
        ],
      ),
    );
  }
}

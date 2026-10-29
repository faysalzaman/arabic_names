import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/ui_screens/fav_names_screen.dart';
import 'package:arabic_names/ui_screens/names/category_screen.dart';
import 'package:arabic_names/ui_screens/names/gender_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _item(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      title: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
      onTap: onTap,
    );
  }

  void _openCategory(BuildContext context, NameCategory category) {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.fade,
        child: CategoryScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 4, 48, 2),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            width: 200,
            child: Image.asset('assets/اسماء اولاد وبنات.png', fit: BoxFit.fill),
          ),
          _item(
            context,
            Icons.home_outlined,
            'الرئيسية',
            () => Navigator.of(context).pushReplacement(
              PageTransition(
                type: PageTransitionType.fade,
                child: const GenderSelectionScreen(),
              ),
            ),
          ),
          _item(context, Icons.list_alt_outlined, 'جميع الأسماء',
              () => _openCategory(context, NameCategory.all)),
          _item(context, Icons.star_outline, 'أسماء المشاهير',
              () => _openCategory(context, NameCategory.celebrity)),
          _item(context, Icons.trending_up, 'الأسماء الشائعة',
              () => _openCategory(context, NameCategory.trending)),
          _item(
            context,
            Icons.favorite_outline,
            'المفضلة',
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavouritesScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

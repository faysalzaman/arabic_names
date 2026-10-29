import 'package:arabic_names/Model/names_model.dart';
import 'package:flutter/material.dart';

extension NameCategoryLabels on NameCategory {
  String get title => switch (this) {
        NameCategory.all => 'جميع الأسماء',
        NameCategory.trending => 'الأسماء الشائعة',
        NameCategory.celebrity => 'أسماء المشاهير',
      };

  String get subtitle => switch (this) {
        NameCategory.all => 'تصفح كل الأسماء ومعانيها',
        NameCategory.trending => 'الأسماء الأكثر استخداماً اليوم',
        NameCategory.celebrity => 'أسماء المشاهير والشخصيات المعروفة',
      };

  IconData get icon => switch (this) {
        NameCategory.all => Icons.menu_book_outlined,
        NameCategory.trending => Icons.trending_up,
        NameCategory.celebrity => Icons.star_outline,
      };
}

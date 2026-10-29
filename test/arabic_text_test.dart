import 'package:arabic_names/utils/arabic_text.dart';
import 'package:flutter_test/flutter_test.dart';

// Expected values come from normalize_ar() in tool/build_names_db.py, which builds the
// database: if these drift apart, search stops matching the stored names.
void main() {
  group('normalizeArabic', () {
    test('folds alef variants and ta marbuta', () {
      expect(normalizeArabic('آمنة'), 'امنه');
      expect(normalizeArabic('إبراهيم'), 'ابراهيم');
      expect(normalizeArabic('فاطمة'), 'فاطمه');
    });

    test('strips diacritics', () {
      expect(normalizeArabic('مُحَمَّد'), 'محمد');
      expect(normalizeArabic('أَحْمَد'), 'احمد');
    });

    test('folds Urdu/Persian letters to Arabic base letters', () {
      expect(normalizeArabic('آبگینہ'), 'ابكينه');
      expect(normalizeArabic('چوہدری'), 'جوهدري');
    });

    test('folds hamza carriers', () {
      expect(normalizeArabic('عائشة'), 'عايشه');
      expect(normalizeArabic('مؤمن'), 'مومن');
    });

    test('leaves Latin text alone', () {
      expect(normalizeArabic('Ali'), 'Ali');
    });
  });

  test('nameKey is case- and whitespace-insensitive for the English part', () {
    expect(nameKey(' Ali ', 'علي'), 'ali|علي');
    expect(nameKey(null, null), '|');
  });
}

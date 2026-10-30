/// Text helpers shared by search, sorting and favourites.
///
/// KEEP [normalizeArabic] IN SYNC with `normalize_ar()` in tool/build_names_db.py:
/// the database stores names already normalised with that function.
library;

final RegExp _diacritics = RegExp('[ً-ٰٟـۖ-ۭ]');

const Map<String, String> _fold = {
  'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
  'ى': 'ي', 'ی': 'ي', 'ے': 'ي', 'ئ': 'ي',
  'ة': 'ه', 'ہ': 'ه', 'ھ': 'ه', 'ۃ': 'ه',
  'ک': 'ك', 'گ': 'ك',
  'پ': 'ب', 'چ': 'ج', 'ژ': 'ز',
  'ٹ': 'ت', 'ڈ': 'د', 'ڑ': 'ر', 'ں': 'ن',
  'ؤ': 'و',
};

/// Removes diacritics/tatweel and folds look-alike letters (أ إ آ -> ا, ة -> ه,
/// Urdu/Persian forms -> Arabic base letters) so "آمنة" matches "امنه".
String normalizeArabic(String text) {
  final stripped = text.replaceAll(_diacritics, '');
  final buffer = StringBuffer();
  for (final rune in stripped.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_fold[char] ?? char);
  }
  return buffer.toString().trim();
}

/// Stable identity of a name across database updates (used by favourites).
String nameKey(String? english, String? arabic) =>
    '${(english ?? '').trim().toLowerCase()}|${(arabic ?? '').trim()}';

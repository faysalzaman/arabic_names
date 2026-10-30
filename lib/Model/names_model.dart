// ignore_for_file: file_names

enum NameCategory { all, trending, celebrity }

enum NameGender { male, female }

String? _text(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty || text == 'null' ? null : text;
}

class NameModel {
  final int id;

  /// Stable identity, see `nameKey` in utils/arabic_text.dart.
  final String key;

  /// First letter of the normalised Arabic name (drives the A-Z rail).
  final String letter;

  /// 'Male', 'Female' or 'Unisex'.
  final String gender;

  final String? englishName;
  final String? englishMeaning;
  final String? englishReligion;
  final String? englishLuckyDay;
  final String? englishLuckyColor;
  final String? englishLuckyStones;
  final String? englishLanguage;
  final String? englishLuckyMetals;
  final String? englishFamousPerson;
  final String? englishDescription;
  final String? englishKnownFor;
  final String? englishOccopation;
  final String? urduName;
  final String? urduMeaning;
  final String? urduReligion;
  final String? urduLuckyNumber;
  final String? urduLuckyDay;
  final String? urduLuckyColor;
  final String? urduLuckyStones;
  final String? urduLanguage;
  final String? urduLuckyMetals;
  final String? urduFamousPerson;
  final String? urduDescription;
  final String? urduKnownFor;
  final String? urduOccopation;

  const NameModel({
    required this.id,
    required this.key,
    required this.letter,
    required this.gender,
    this.englishName,
    this.englishMeaning,
    this.englishReligion,
    this.englishLuckyDay,
    this.englishLuckyColor,
    this.englishLuckyStones,
    this.englishLanguage,
    this.englishLuckyMetals,
    this.englishFamousPerson,
    this.englishDescription,
    this.englishKnownFor,
    this.englishOccopation,
    this.urduName,
    this.urduMeaning,
    this.urduReligion,
    this.urduLuckyNumber,
    this.urduLuckyDay,
    this.urduLuckyColor,
    this.urduLuckyStones,
    this.urduLanguage,
    this.urduLuckyMetals,
    this.urduFamousPerson,
    this.urduDescription,
    this.urduKnownFor,
    this.urduOccopation,
  });

  factory NameModel.fromDb(Map<String, Object?> row) {
    return NameModel(
      id: row['id'] as int,
      key: row['key'] as String,
      letter: row['letter'] as String,
      gender: row['Gender'] as String,
      englishName: _text(row['EnglishName']),
      englishMeaning: _text(row['EnglishMeaning']),
      englishReligion: _text(row['EnglishReligion']),
      englishLuckyDay: _text(row['EnglishLuckyDay']),
      englishLuckyColor: _text(row['EnglishLuckyColor']),
      englishLuckyStones: _text(row['EnglishLuckyStones']),
      englishLanguage: _text(row['EnglishLanguage']),
      englishLuckyMetals: _text(row['EnglishLuckyMetals']),
      englishFamousPerson: _text(row['EnglishFamousPerson']),
      englishDescription: _text(row['EnglishDescription']),
      englishKnownFor: _text(row['EnglishKnownFor']),
      englishOccopation: _text(row['EnglishOccopation']),
      urduName: _text(row['UrduName']),
      urduMeaning: _text(row['UrduMeaning']),
      urduReligion: _text(row['UrduReligion']),
      urduLuckyNumber: _text(row['UrduLuckyNumber']),
      urduLuckyDay: _text(row['UrduLuckyDay']),
      urduLuckyColor: _text(row['UrduLuckyColor']),
      urduLuckyStones: _text(row['UrduLuckyStones']),
      urduLanguage: _text(row['UrduLanguage']),
      urduLuckyMetals: _text(row['UrduLuckyMetals']),
      urduFamousPerson: _text(row['UrduFamousPerson']),
      urduDescription: _text(row['UrduDescription']),
      urduKnownFor: _text(row['UrduKnownFor']),
      urduOccopation: _text(row['UrduOccopation']),
    );
  }

  String get genderEmoji => switch (gender) {
        'Male' => '👨',
        'Female' => '👩',
        _ => '🧑',
      };

  String get genderLabelAr => switch (gender) {
        'Male' => 'ذكر',
        'Female' => 'أنثى',
        _ => 'للجنسين',
      };

  String get genderLabelEn => gender;

  @override
  bool operator ==(Object other) => other is NameModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

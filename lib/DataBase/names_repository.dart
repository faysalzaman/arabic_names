import 'dart:io';

import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/utils/arabic_text.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

/// Read-only access to the pre-built `assets/names.db` (see tool/build_names_db.py).
///
/// The asset is copied once into the app's database folder. When the data changes,
/// bump [_dbFile] (names_v2.db, ...) so existing installs pick up the new copy.
class NamesRepository {
  NamesRepository._();
  static final NamesRepository instance = NamesRepository._();

  static const String _assetPath = 'assets/names.db';
  static const String _dbFile = 'names_v1.db';

  // Every column except `search`, which is only used in WHERE clauses.
  static const String _columns =
      'id, key, letter, Gender, EnglishName, EnglishMeaning, EnglishReligion, '
      'EnglishLuckyDay, EnglishLuckyColor, EnglishLuckyStones, EnglishLanguage, '
      'EnglishLuckyMetals, EnglishFamousPerson, EnglishDescription, EnglishKnownFor, '
      'EnglishOccopation, UrduName, UrduMeaning, UrduReligion, UrduLuckyNumber, '
      'UrduLuckyDay, UrduLuckyColor, UrduLuckyStones, UrduLanguage, UrduLuckyMetals, '
      'UrduFamousPerson, UrduDescription, UrduKnownFor, UrduOccopation';

  Future<Database>? _opening;

  /// Copies the database on first launch. Safe to call many times.
  Future<void> warmUp() => _database();

  Future<Database> _database() {
    return _opening ??= _open().catchError((Object error) {
      _opening = null; // allow a retry
      throw error;
    });
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = '$dir/$_dbFile';

    if (!await databaseExists(path)) {
      await Directory(dir).create(recursive: true);
      final data = await rootBundle.load(_assetPath);
      final tmp = File('$path.tmp');
      await tmp.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      await tmp.rename(path);
      // The old app created an empty Names.db that was never used.
      deleteDatabase('$dir/Names.db').ignore();
    }
    return openDatabase(path, readOnly: true);
  }

  /// Names of one category/gender, sorted A-Z. With a [query], names that start with
  /// it come first, then any name whose name or meaning (Arabic or English) contains it.
  Future<List<NameModel>> getNames({
    required NameCategory category,
    required NameGender gender,
    String query = '',
  }) async {
    final db = await _database();
    final args = <Object?>[
      category.name,
      gender == NameGender.male ? 'Male' : 'Female',
    ];
    var where = "category = ? AND (Gender = ? OR Gender = 'Unisex')";
    var order = 'norm, EnglishName';

    final q = _escapeLike(normalizeArabic(query).toLowerCase());
    if (q.isNotEmpty) {
      where += r" AND search LIKE ? ESCAPE '\'";
      args.add('%$q%');
      order = r"CASE WHEN norm LIKE ? ESCAPE '\' OR lower(EnglishName) LIKE ? ESCAPE '\' "
          'THEN 0 ELSE 1 END, norm, EnglishName';
      args
        ..add('$q%')
        ..add('$q%');
    }

    final rows = await db.rawQuery(
      'SELECT $_columns FROM names WHERE $where ORDER BY $order',
      args,
    );
    return rows.map(NameModel.fromDb).toList(growable: false);
  }

  /// Looks names up by [nameKey]; the result follows the order of [keys].
  Future<List<NameModel>> getByKeys(List<String> keys) async {
    if (keys.isEmpty) return const [];
    final db = await _database();
    final byKey = <String, NameModel>{};
    for (var i = 0; i < keys.length; i += 500) {
      final chunk = keys.sublist(i, i + 500 > keys.length ? keys.length : i + 500);
      final rows = await db.rawQuery(
        'SELECT $_columns FROM names WHERE key IN (${List.filled(chunk.length, '?').join(',')}) '
        'GROUP BY key',
        chunk,
      );
      for (final row in rows) {
        final model = NameModel.fromDb(row);
        byKey[model.key] = model;
      }
    }
    return [
      for (final key in keys)
        if (byKey[key] != null) byKey[key]!,
    ];
  }

  static String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}

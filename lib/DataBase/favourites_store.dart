import 'package:arabic_names/utils/arabic_text.dart';
import 'package:sqflite/sqflite.dart';

/// User favourites, stored as name keys (see `nameKey`) so they survive data updates.
class FavouritesStore {
  FavouritesStore._();
  static final FavouritesStore instance = FavouritesStore._();

  Future<Database>? _opening;

  Future<Database> _database() {
    return _opening ??= _open().catchError((Object error) {
      _opening = null;
      throw error;
    });
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      '$dir/favourites_v2.db',
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE favourites (key TEXT PRIMARY KEY, added_at INTEGER NOT NULL)',
      ),
    );
    await _migrateLegacy(db, '$dir/Favourites.db');
    return db;
  }

  /// Imports favourites saved by older app versions. The old table appended a new row
  /// for every tap (isFavourite '1' / '0'), so the last row per name wins.
  Future<void> _migrateLegacy(Database db, String legacyPath) async {
    try {
      if (!await databaseExists(legacyPath)) return;
      final legacy = await openDatabase(legacyPath, readOnly: true);
      final rows = await legacy.query(
        'Favourites',
        columns: ['EnglishName', 'UrduName', 'isFavourite'],
        orderBy: 'id',
      );
      await legacy.close();

      final state = <String, bool>{};
      for (final row in rows) {
        final key = nameKey(row['EnglishName'] as String?, row['UrduName'] as String?);
        state[key] = row['isFavourite']?.toString() == '1';
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      final batch = db.batch();
      for (final entry in state.entries) {
        if (entry.value) {
          batch.insert(
            'favourites',
            {'key': entry.key, 'added_at': now},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
      await batch.commit(noResult: true);
      await deleteDatabase(legacyPath);
    } catch (_) {
      // Leave the old file in place; we will try again on the next launch.
    }
  }

  /// Favourite keys, newest first.
  Future<List<String>> keys() async {
    final db = await _database();
    final rows = await db.query('favourites', columns: ['key'], orderBy: 'added_at DESC');
    return [for (final row in rows) row['key']! as String];
  }

  /// Flips the favourite state of [key] and returns the new state.
  Future<bool> toggle(String key) async {
    final db = await _database();
    // One transaction, so rapid double taps cannot interleave the delete and insert.
    return db.transaction((txn) async {
      final removed = await txn.delete('favourites', where: 'key = ?', whereArgs: [key]);
      if (removed > 0) return false;
      await txn.insert(
        'favourites',
        {'key': key, 'added_at': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    });
  }
}

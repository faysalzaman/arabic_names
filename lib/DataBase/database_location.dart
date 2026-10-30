import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// Folder that holds the app's databases. The web SQLite factory has no real folder,
/// so databases there live at the root of its virtual storage.
Future<String> databasesDirectory() async {
  if (kIsWeb) return '';
  return getDatabasesPath();
}

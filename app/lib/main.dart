import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/content/book.dart';
import 'src/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait and landscape are both supported (STRAT-OBJ-001); no orientation lock.
  final prefs = await SharedPreferences.getInstance();
  final book = await Book.load(rootBundle);
  if (book == null) {
    runApp(const MissingContentApp());
    return;
  }
  final settings = Settings(
    prefs,
    available: book.languages,
    systemLanguage: PlatformDispatcher.instance.locale.languageCode,
  );
  runApp(BullApp(book: book, settings: settings));
}

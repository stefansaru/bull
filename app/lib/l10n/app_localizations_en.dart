// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bull\'s Head 1858';

  @override
  String get contents => 'Contents';

  @override
  String get reference => 'Reference';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get continueReading => 'Continue reading';

  @override
  String get previousSection => 'Previous';

  @override
  String get nextSection => 'Next';

  @override
  String get searchHint => 'Search the book';

  @override
  String get noResults => 'No results';

  @override
  String get language => 'Book language';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacySummary =>
      'This app collects no personal data and works fully offline.';

  @override
  String get about => 'About';

  @override
  String get publisher => 'Published by Jini Solutions';

  @override
  String get contentMissing =>
      'The book content is missing. Run the wizard to build it.';

  @override
  String get zoomHint => 'Pinch or press select to zoom';

  @override
  String get close => 'Close';

  @override
  String get imagesNote => 'Some images are not included in this edition.';

  @override
  String version(String version) {
    return 'Version $version';
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Auerochsenkopf 1858';

  @override
  String get contents => 'Inhalt';

  @override
  String get reference => 'Nachschlagen';

  @override
  String get search => 'Suche';

  @override
  String get settings => 'Einstellungen';

  @override
  String get continueReading => 'Weiterlesen';

  @override
  String get previousSection => 'Zurück';

  @override
  String get nextSection => 'Weiter';

  @override
  String get searchHint => 'Im Buch suchen';

  @override
  String get noResults => 'Keine Treffer';

  @override
  String get language => 'Sprache des Buches';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get privacySummary =>
      'Diese App erhebt keine personenbezogenen Daten und funktioniert vollständig offline.';

  @override
  String get about => 'Über';

  @override
  String get publisher => 'Herausgegeben von Jini Solutions';

  @override
  String get contentMissing =>
      'Der Buchinhalt fehlt. Führe den Assistenten aus, um ihn zu erzeugen.';

  @override
  String get zoomHint => 'Zum Zoomen ziehen oder OK drücken';

  @override
  String get close => 'Schließen';

  @override
  String get imagesNote =>
      'Einige Bilder sind in dieser Ausgabe nicht enthalten.';

  @override
  String version(String version) {
    return 'Version $version';
  }
}

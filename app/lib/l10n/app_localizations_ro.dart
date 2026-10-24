// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Cap de bour 1858';

  @override
  String get contents => 'Cuprins';

  @override
  String get reference => 'Referințe';

  @override
  String get search => 'Căutare';

  @override
  String get settings => 'Setări';

  @override
  String get continueReading => 'Continuă lectura';

  @override
  String get previousSection => 'Înapoi';

  @override
  String get nextSection => 'Înainte';

  @override
  String get searchHint => 'Caută în carte';

  @override
  String get noResults => 'Niciun rezultat';

  @override
  String get language => 'Limba cărții';

  @override
  String get privacyPolicy => 'Politica de confidențialitate';

  @override
  String get privacySummary =>
      'Aplicația nu colectează date personale și funcționează complet offline.';

  @override
  String get about => 'Despre';

  @override
  String get publisher => 'Publicată de Jini Solutions';

  @override
  String get contentMissing =>
      'Conținutul cărții lipsește. Rulează wizard-ul pentru a-l genera.';

  @override
  String get zoomHint => 'Ciupește sau apasă OK pentru zoom';

  @override
  String get close => 'Închide';

  @override
  String get imagesNote => 'Unele imagini nu sunt incluse în această ediție.';

  @override
  String version(String version) {
    return 'Versiunea $version';
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Tête d\'aurochs 1858';

  @override
  String get contents => 'Sommaire';

  @override
  String get reference => 'Référence';

  @override
  String get search => 'Rechercher';

  @override
  String get settings => 'Paramètres';

  @override
  String get continueReading => 'Reprendre la lecture';

  @override
  String get previousSection => 'Précédent';

  @override
  String get nextSection => 'Suivant';

  @override
  String get searchHint => 'Rechercher dans le livre';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get language => 'Langue du livre';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get privacySummary =>
      'Cette application ne collecte aucune donnée personnelle et fonctionne entièrement hors ligne.';

  @override
  String get about => 'À propos';

  @override
  String get publisher => 'Publié par Jini Solutions';

  @override
  String get contentMissing =>
      'Le contenu du livre est manquant. Lancez l\'assistant pour le générer.';

  @override
  String get zoomHint => 'Pincez ou appuyez sur OK pour zoomer';

  @override
  String get close => 'Fermer';

  @override
  String get imagesNote =>
      'Certaines images ne figurent pas dans cette édition.';

  @override
  String version(String version) {
    return 'Version $version';
  }
}

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

  @override
  String get back => 'Retour';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get showTitle => 'Afficher le titre';

  @override
  String get hideTitle => 'Masquer le titre';

  @override
  String get breadcrumb => 'Vous êtes ici';

  @override
  String calendarOf(String year) {
    return 'Calendrier de $year';
  }

  @override
  String get more => 'Plus';

  @override
  String previewOf(String title) {
    return 'Aperçu : $title';
  }

  @override
  String get linksHere => 'Liens de ce paragraphe';

  @override
  String get related => 'Voir aussi';

  @override
  String get relRelated => 'apparenté';

  @override
  String get relSee => 'voir';

  @override
  String get relIssue => 'émission';

  @override
  String get relDenomination => 'valeur';

  @override
  String get relHandstamp => 'cachet';

  @override
  String get relSeries => 'série de catalogue';

  @override
  String get relPublishedIn => 'publié dans';

  @override
  String get relInTheBook => 'dans le livre';

  @override
  String get relReference => 'référence';

  @override
  String get indexes => 'Index';

  @override
  String get images => 'Images';

  @override
  String get abbreviations => 'Abréviations';

  @override
  String get colours => 'Couleurs';

  @override
  String get favorites => 'Favoris';

  @override
  String get recentlyVisited => 'Consultés récemment';

  @override
  String get noImagesYet => 'Cette édition ne contient pas encore d\'images.';

  @override
  String startingWith(String letter) {
    return 'Commençant par $letter';
  }

  @override
  String get allAbbreviations => 'Toutes les abréviations';

  @override
  String get swatchNote =>
      'Les couleurs reproduisent les échantillons du tableau de couleurs de l\'auteur. Les écrans ne les rendent qu\'approximativement ; le code de la norme fait foi.';

  @override
  String colourFamily(String family) {
    String _temp0 = intl.Intl.selectLogic(family, {
      'blue': 'Bleus',
      'green': 'Verts',
      'red': 'Rouges',
      'neutral': 'Noir et blanc',
      'other': 'Autres',
    });
    return '$_temp0';
  }

  @override
  String get typeNarrative => 'Chapitres du livre';

  @override
  String get filters => 'Filtres';

  @override
  String filtersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filtres ($count)',
      zero: 'Filtres',
    );
    return '$_temp0';
  }

  @override
  String get filterType => 'Type';

  @override
  String get filterChapter => 'Chapitre';

  @override
  String get allChapters => 'Tous les chapitres';

  @override
  String get favoritesOnly => 'Favoris seulement';

  @override
  String get clearFilters => 'Effacer';

  @override
  String get apply => 'Appliquer';

  @override
  String get searchFavorites => 'Rechercher dans les favoris';

  @override
  String get noFavorites =>
      'Rien d\'enregistré pour l\'instant. Touchez l\'étoile d\'une page pour la garder ici.';

  @override
  String get wholePage => 'Page entière';

  @override
  String get passage => 'Passage';

  @override
  String get image => 'Image';

  @override
  String tableSelection(int rows, int cols) {
    return 'Sélection de tableau : $rows lignes, $cols colonnes';
  }

  @override
  String bookmarksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count signets',
      one: '1 signet',
    );
    return '$_temp0';
  }

  @override
  String get deleteBookmark => 'Supprimer le signet';

  @override
  String get deleteAllFor => 'Supprimer tous les signets de cette page';

  @override
  String get deleteAll => 'Supprimer tous les signets';

  @override
  String get confirmDeleteAll => 'Supprimer tous les favoris et signets ?';

  @override
  String confirmDeleteFor(String title) {
    return 'Supprimer tous les signets de « $title » ?';
  }

  @override
  String get noLongerAvailable => 'N\'est plus dans le livre';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String imageNumber(int number, int total) {
    return 'Image $number sur $total';
  }

  @override
  String get zoomIn => 'Agrandir';

  @override
  String get zoomOut => 'Réduire';

  @override
  String get fit => 'Ajuster à l\'écran';

  @override
  String get previousImage => 'Image précédente';

  @override
  String get nextImage => 'Image suivante';

  @override
  String get bookmarkImage => 'Ajouter un signet à cette image';

  @override
  String get removeBookmark => 'Retirer le signet';

  @override
  String get readAloud => 'Lire cette page à voix haute';

  @override
  String get audio => 'Son';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get speechRate => 'Vitesse de lecture';

  @override
  String readAloudUnavailable(String language) {
    return 'La lecture à voix haute n\'est pas disponible en $language sur cet appareil.';
  }

  @override
  String get readAloudSetup =>
      'Pour ajouter une voix, ouvrez les paramètres de l\'appareil, puis Système › Langues › Synthèse vocale, et installez les données vocales de cette langue.';

  @override
  String get previousParagraph => 'Paragraphe précédent';

  @override
  String get nextParagraph => 'Paragraphe suivant';

  @override
  String get stopReading => 'Arrêter la lecture';

  @override
  String get help => 'Aide';

  @override
  String get helpTour => 'Visite des commandes';

  @override
  String get helpLinksTitle => 'Liens et aperçus';

  @override
  String get helpLinksBody =>
      'Un soulignement en pointillé signale un lien. Dans le texte, le toucher affiche une courte description ; Plus ouvre sa page. Les listes, les index et les résultats de recherche ouvrent les pages directement. Retour vous ramène toujours là où vous étiez.';

  @override
  String get helpDatesTitle => 'Dates';

  @override
  String get helpDatesBody =>
      'En 1858, la Moldavie utilisait le calendrier julien, en retard de 12 jours sur le nôtre. Une date comme 1 (13) juin 1865 ᴶ⁄ᴳ donne d\'abord la date julienne, puis la date grégorienne entre parenthèses. Touchez ᴶ⁄ᴳ pour en savoir plus.';

  @override
  String get helpFavoritesTitle => 'Favoris et signets';

  @override
  String get helpFavoritesBody =>
      'L\'étoile garde une page parmi vos favoris. Les images et les passages peuvent aussi recevoir un signet. Ouvrez les favoris depuis le sommaire ou Plus d\'options.';

  @override
  String get helpImagesTitle => 'Images';

  @override
  String get helpImagesBody =>
      'Touchez une image pour l\'agrandir. Pincez pour zoomer ; quand l\'image tient dans l\'écran, balayez vers la suivante ou la précédente. Avec une télécommande, OK zoome et les flèches déplacent.';

  @override
  String get helpTablesTitle => 'Tableaux';

  @override
  String get helpTablesBody =>
      'Les tableaux larges défilent latéralement tandis que leur première colonne reste en place ; le bouton plein écran donne tout l\'écran au tableau. Touchez un en-tête pour sélectionner sa ligne ou sa colonne, touchez des cellules pour sélectionner une plage (ou appuyez longuement et faites glisser), puis ajoutez un signet. Avec une télécommande : les flèches déplacent, OK commence et termine la sélection, Retour l\'annule.';

  @override
  String get colourSettings => 'Couleurs';

  @override
  String get theme => 'Thème';

  @override
  String get themeAutomatic => 'Automatique';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get visionMode => 'Vision des couleurs';

  @override
  String get visionStandard => 'Standard';

  @override
  String get visionRedGreen => 'Sûr rouge-vert';

  @override
  String get visionRedGreenNote => 'Pour la protanopie et la deutéranopie';

  @override
  String get visionTritan => 'Sûr tritan';

  @override
  String get visionTritanNote => 'Pour la tritanopie (bleu-jaune)';

  @override
  String get visionGrayscale => 'Niveaux de gris';

  @override
  String get visionGrayscaleNote => 'Aucune couleur (achromatopsie)';

  @override
  String get visionKeepsEvidence =>
      'Les images des timbres et les échantillons de couleur gardent toujours leurs couleurs.';

  @override
  String get moveUp => 'Monter';

  @override
  String get moveDown => 'Descendre';

  @override
  String get tourWelcome =>
      'Bienvenue ! Voici une courte visite des commandes.';

  @override
  String get tourBack => 'Retour revient à la page d\'où vous venez.';

  @override
  String get tourSections =>
      'Le sommaire : les chapitres, les index des images, abréviations, couleurs et calendriers, et vos favoris.';

  @override
  String get tourStar => 'L\'étoile garde cette page parmi vos favoris.';

  @override
  String get tourSearch => 'Recherchez dans tout le livre, avec des filtres.';

  @override
  String get tourTitle =>
      'En paysage, le titre est masqué pour laisser de la place au texte. Affichez-le ici.';

  @override
  String get tourMore => 'Lecture à voix haute, son, langue, couleurs et aide.';

  @override
  String get tourLinks =>
      'Les mots soulignés en pointillé sont des liens : touchez-en un pour une courte description.';

  @override
  String get next => 'Suivant';

  @override
  String get done => 'Terminé';

  @override
  String get skip => 'Passer';

  @override
  String get keyboardSpace => 'Espace';

  @override
  String get keyboardBackspace => 'Retour arrière';

  @override
  String get keyboardShift => 'Majuscule';

  @override
  String get keyboardSymbols => 'Symboles';

  @override
  String get keyboardLetters => 'Lettres';

  @override
  String get showKeyboard => 'Afficher le clavier à l\'écran';

  @override
  String get hideKeyboard => 'Masquer le clavier à l\'écran';

  @override
  String get fullScreenTable => 'Afficher le tableau en plein écran';

  @override
  String get bookmarkSelection => 'Ajouter un signet à la sélection';

  @override
  String get clearSelection => 'Effacer la sélection';

  @override
  String get selectionBookmarked => 'Signet ajouté à la sélection';

  @override
  String get bookmarkPassage => 'Ajouter un signet à ce passage';

  @override
  String get passageBookmarked => 'Signet ajouté au passage';

  @override
  String get undo => 'Annuler';
}

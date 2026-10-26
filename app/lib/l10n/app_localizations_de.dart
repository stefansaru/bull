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

  @override
  String get back => 'Zurück';

  @override
  String get addFavorite => 'Zu Favoriten hinzufügen';

  @override
  String get removeFavorite => 'Aus Favoriten entfernen';

  @override
  String get moreOptions => 'Weitere Optionen';

  @override
  String get showTitle => 'Titel zeigen';

  @override
  String get hideTitle => 'Titel ausblenden';

  @override
  String get breadcrumb => 'Sie sind hier';

  @override
  String calendarOf(String year) {
    return 'Kalender $year';
  }

  @override
  String get more => 'Mehr';

  @override
  String previewOf(String title) {
    return 'Vorschau: $title';
  }

  @override
  String get linksHere => 'Links in diesem Absatz';

  @override
  String get related => 'Verwandt';

  @override
  String get relRelated => 'verwandt';

  @override
  String get relSee => 'siehe';

  @override
  String get relIssue => 'Ausgabe';

  @override
  String get relDenomination => 'Wertstufe';

  @override
  String get relHandstamp => 'Stempel';

  @override
  String get relSeries => 'Katalogreihe';

  @override
  String get relPublishedIn => 'erschienen in';

  @override
  String get relInTheBook => 'im Buch';

  @override
  String get relReference => 'Quelle';

  @override
  String get indexes => 'Verzeichnisse';

  @override
  String get images => 'Bilder';

  @override
  String get abbreviations => 'Abkürzungen';

  @override
  String get colours => 'Farben';

  @override
  String get favorites => 'Favoriten';

  @override
  String get recentlyVisited => 'Zuletzt angesehen';

  @override
  String get noImagesYet => 'Diese Ausgabe enthält noch keine Bilder.';

  @override
  String startingWith(String letter) {
    return 'Beginnend mit $letter';
  }

  @override
  String get allAbbreviations => 'Alle Abkürzungen';

  @override
  String get swatchNote =>
      'Die Farben geben die Muster der Farbtabelle des Autors wieder. Bildschirme zeigen sie nur annähernd; maßgeblich ist der Code des Standards.';

  @override
  String colourFamily(String family) {
    String _temp0 = intl.Intl.selectLogic(family, {
      'blue': 'Blautöne',
      'green': 'Grüntöne',
      'red': 'Rottöne',
      'neutral': 'Schwarz und Weiß',
      'other': 'Andere',
    });
    return '$_temp0';
  }

  @override
  String get typeNarrative => 'Buchkapitel';

  @override
  String get filters => 'Filter';

  @override
  String filtersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filter ($count)',
      zero: 'Filter',
    );
    return '$_temp0';
  }

  @override
  String get filterType => 'Art';

  @override
  String get filterChapter => 'Kapitel';

  @override
  String get allChapters => 'Alle Kapitel';

  @override
  String get favoritesOnly => 'Nur Favoriten';

  @override
  String get clearFilters => 'Zurücksetzen';

  @override
  String get apply => 'Anwenden';

  @override
  String get searchFavorites => 'Favoriten durchsuchen';

  @override
  String get noFavorites =>
      'Noch nichts gespeichert. Tippen Sie auf einer Seite auf den Stern, um sie hier aufzubewahren.';

  @override
  String get wholePage => 'Ganze Seite';

  @override
  String get passage => 'Textstelle';

  @override
  String get image => 'Bild';

  @override
  String tableSelection(int rows, int cols) {
    return 'Tabellenauswahl: $rows Zeilen, $cols Spalten';
  }

  @override
  String bookmarksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lesezeichen',
      one: '1 Lesezeichen',
    );
    return '$_temp0';
  }

  @override
  String get deleteBookmark => 'Lesezeichen löschen';

  @override
  String get deleteAllFor => 'Alle Lesezeichen dieser Seite löschen';

  @override
  String get deleteAll => 'Alle Lesezeichen löschen';

  @override
  String get confirmDeleteAll => 'Alle Favoriten und Lesezeichen löschen?';

  @override
  String confirmDeleteFor(String title) {
    return 'Alle Lesezeichen von „$title“ löschen?';
  }

  @override
  String get noLongerAvailable => 'Nicht mehr im Buch';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String imageNumber(int number, int total) {
    return 'Bild $number von $total';
  }

  @override
  String get zoomIn => 'Vergrößern';

  @override
  String get zoomOut => 'Verkleinern';

  @override
  String get fit => 'An Bildschirm anpassen';

  @override
  String get previousImage => 'Vorheriges Bild';

  @override
  String get nextImage => 'Nächstes Bild';

  @override
  String get bookmarkImage => 'Lesezeichen für dieses Bild';

  @override
  String get removeBookmark => 'Lesezeichen entfernen';

  @override
  String get readAloud => 'Diese Seite vorlesen';

  @override
  String get audio => 'Ton';

  @override
  String get soundEffects => 'Toneffekte';

  @override
  String get speechRate => 'Lesegeschwindigkeit';

  @override
  String readAloudUnavailable(String language) {
    return 'Vorlesen ist auf diesem Gerät für $language nicht verfügbar.';
  }

  @override
  String get readAloudSetup =>
      'Um eine Stimme hinzuzufügen, öffnen Sie die Geräteeinstellungen, dann System › Sprachen › Sprachausgabe, und installieren Sie die Sprachdaten für diese Sprache.';

  @override
  String get previousParagraph => 'Vorheriger Absatz';

  @override
  String get nextParagraph => 'Nächster Absatz';

  @override
  String get stopReading => 'Vorlesen beenden';

  @override
  String get help => 'Hilfe';

  @override
  String get helpTour => 'Rundgang durch die Bedienung';

  @override
  String get helpLinksTitle => 'Links und Vorschauen';

  @override
  String get helpLinksBody =>
      'Eine gepunktete Unterstreichung kennzeichnet einen Link. Im Text zeigt ein Tippen eine kurze Beschreibung; Mehr öffnet die Seite. Listen, Verzeichnisse und Suchergebnisse öffnen Seiten direkt. Zurück führt immer dorthin zurück, wo Sie waren.';

  @override
  String get helpDatesTitle => 'Daten';

  @override
  String get helpDatesBody =>
      '1858 verwendete die Moldau den julianischen Kalender, 12 Tage hinter unserem. Ein Datum wie 1. (13.) Juni 1865 ᴶ⁄ᴳ nennt zuerst das julianische und in Klammern das gregorianische Datum. Tippen Sie auf ᴶ⁄ᴳ für mehr.';

  @override
  String get helpFavoritesTitle => 'Favoriten und Lesezeichen';

  @override
  String get helpFavoritesBody =>
      'Der Stern bewahrt eine Seite unter Ihren Favoriten auf. Auch Bilder und Textstellen lassen sich mit Lesezeichen versehen. Die Favoriten öffnen Sie über den Inhalt oder Weitere Optionen.';

  @override
  String get helpImagesTitle => 'Bilder';

  @override
  String get helpImagesBody =>
      'Tippen Sie auf ein Bild, um es zu vergrößern. Mit zwei Fingern zoomen; passt das Bild auf den Bildschirm, wischen Sie zum nächsten oder vorherigen. Mit der Fernbedienung zoomt OK, die Pfeiltasten verschieben.';

  @override
  String get helpTablesTitle => 'Tabellen';

  @override
  String get helpTablesBody =>
      'Breite Tabellen scrollen seitwärts, während ihre erste Spalte stehen bleibt; die Vollbildtaste gibt einer Tabelle den ganzen Bildschirm. Tippen Sie auf eine Kopfzelle, um ihre Zeile oder Spalte auszuwählen, auf Zellen für einen Bereich (oder lange drücken und ziehen), und setzen Sie dann ein Lesezeichen. Mit der Fernbedienung: Pfeile bewegen, OK beginnt und beendet die Auswahl, Zurück bricht ab.';

  @override
  String get colourSettings => 'Farben';

  @override
  String get theme => 'Design';

  @override
  String get themeAutomatic => 'Automatisch';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get visionMode => 'Farbsehen';

  @override
  String get visionStandard => 'Standard';

  @override
  String get visionRedGreen => 'Rot-Grün-sicher';

  @override
  String get visionRedGreenNote => 'Bei Protanopie und Deuteranopie';

  @override
  String get visionTritan => 'Tritan-sicher';

  @override
  String get visionTritanNote => 'Bei Tritanopie (Blau-Gelb)';

  @override
  String get visionGrayscale => 'Graustufen';

  @override
  String get visionGrayscaleNote => 'Ganz ohne Farbe (Achromatopsie)';

  @override
  String get visionKeepsEvidence =>
      'Markenbilder und Farbmuster behalten immer ihre eigenen Farben.';

  @override
  String get moveUp => 'Nach oben';

  @override
  String get moveDown => 'Nach unten';

  @override
  String get tourWelcome =>
      'Willkommen! Hier ein kurzer Rundgang durch die Bedienung.';

  @override
  String get tourBack => 'Zurück führt zur Seite, von der Sie kamen.';

  @override
  String get tourSections =>
      'Der Inhalt: die Kapitel, die Verzeichnisse der Bilder, Abkürzungen, Farben und Kalender, und Ihre Favoriten.';

  @override
  String get tourStar =>
      'Der Stern bewahrt diese Seite unter Ihren Favoriten auf.';

  @override
  String get tourSearch => 'Das ganze Buch durchsuchen, mit Filtern.';

  @override
  String get tourTitle =>
      'Im Querformat ist der Titel ausgeblendet, damit der Text Platz hat. Hier blenden Sie ihn ein.';

  @override
  String get tourMore => 'Vorlesen, Ton, Sprache, Farben und Hilfe.';

  @override
  String get tourLinks =>
      'Gepunktet unterstrichene Wörter sind Links: Tippen Sie eines an für eine kurze Beschreibung.';

  @override
  String get next => 'Weiter';

  @override
  String get done => 'Fertig';

  @override
  String get skip => 'Überspringen';

  @override
  String get skipAll => 'Alle überspringen';

  @override
  String get previous => 'Zurück';

  @override
  String get keyboardSpace => 'Leerzeichen';

  @override
  String get keyboardBackspace => 'Rücktaste';

  @override
  String get keyboardShift => 'Umschalt';

  @override
  String get keyboardSymbols => 'Symbole';

  @override
  String get keyboardLetters => 'Buchstaben';

  @override
  String get showKeyboard => 'Bildschirmtastatur zeigen';

  @override
  String get hideKeyboard => 'Bildschirmtastatur ausblenden';

  @override
  String get fullScreenTable => 'Tabelle im Vollbild zeigen';

  @override
  String get bookmarkSelection => 'Lesezeichen für die Auswahl';

  @override
  String get clearSelection => 'Auswahl aufheben';

  @override
  String get selectionBookmarked => 'Auswahl mit Lesezeichen versehen';

  @override
  String get bookmarkPassage => 'Lesezeichen für diese Textstelle';

  @override
  String get passageBookmarked => 'Textstelle mit Lesezeichen versehen';

  @override
  String get undo => 'Rückgängig';
}

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

  @override
  String get back => 'Înapoi';

  @override
  String get addFavorite => 'Adaugă la favorite';

  @override
  String get removeFavorite => 'Scoate din favorite';

  @override
  String get moreOptions => 'Mai multe opțiuni';

  @override
  String get showTitle => 'Arată titlul';

  @override
  String get hideTitle => 'Ascunde titlul';

  @override
  String get breadcrumb => 'Te afli aici';

  @override
  String calendarOf(String year) {
    return 'Calendarul anului $year';
  }

  @override
  String get more => 'Mai mult';

  @override
  String previewOf(String title) {
    return 'Previzualizare: $title';
  }

  @override
  String get linksHere => 'Legături din acest paragraf';

  @override
  String get related => 'Legat de';

  @override
  String get relRelated => 'înrudit';

  @override
  String get relSee => 'vezi';

  @override
  String get relIssue => 'emisiune';

  @override
  String get relDenomination => 'valoare';

  @override
  String get relHandstamp => 'ștampilă';

  @override
  String get relSeries => 'serie de catalog';

  @override
  String get relPublishedIn => 'publicat în';

  @override
  String get relInTheBook => 'în carte';

  @override
  String get relReference => 'referință';

  @override
  String get indexes => 'Indexuri';

  @override
  String get images => 'Imagini';

  @override
  String get abbreviations => 'Abrevieri';

  @override
  String get colours => 'Culori';

  @override
  String get favorites => 'Favorite';

  @override
  String get recentlyVisited => 'Vizitate recent';

  @override
  String get noImagesYet => 'Această ediție nu include încă imagini.';

  @override
  String startingWith(String letter) {
    return 'Încep cu $letter';
  }

  @override
  String get allAbbreviations => 'Toate abrevierile';

  @override
  String get swatchNote =>
      'Culorile reproduc mostrele din tabelul de culori al autorului. Ecranele le redau doar aproximativ; codul standardului este cel de referință.';

  @override
  String colourFamily(String family) {
    String _temp0 = intl.Intl.selectLogic(family, {
      'blue': 'Albastre',
      'green': 'Verzi',
      'red': 'Roșii',
      'neutral': 'Alb și negru',
      'other': 'Altele',
    });
    return '$_temp0';
  }

  @override
  String get typeNarrative => 'Capitolele cărții';

  @override
  String get filters => 'Filtre';

  @override
  String filtersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filtre ($count)',
      zero: 'Filtre',
    );
    return '$_temp0';
  }

  @override
  String get filterType => 'Tip';

  @override
  String get filterChapter => 'Capitol';

  @override
  String get allChapters => 'Toate capitolele';

  @override
  String get favoritesOnly => 'Doar favorite';

  @override
  String get clearFilters => 'Șterge';

  @override
  String get apply => 'Aplică';

  @override
  String get searchFavorites => 'Caută în favorite';

  @override
  String get noFavorites =>
      'Nimic salvat încă. Atinge steaua de pe orice pagină ca s-o păstrezi aici.';

  @override
  String get wholePage => 'Pagina întreagă';

  @override
  String get passage => 'Pasaj';

  @override
  String get image => 'Imagine';

  @override
  String tableSelection(int rows, int cols) {
    return 'Selecție din tabel: $rows rânduri, $cols coloane';
  }

  @override
  String bookmarksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de semne de carte',
      few: '$count semne de carte',
      one: '1 semn de carte',
    );
    return '$_temp0';
  }

  @override
  String get deleteBookmark => 'Șterge semnul de carte';

  @override
  String get deleteAllFor => 'Șterge toate semnele acestei pagini';

  @override
  String get deleteAll => 'Șterge toate semnele de carte';

  @override
  String get confirmDeleteAll => 'Ștergi toate favoritele și semnele de carte?';

  @override
  String confirmDeleteFor(String title) {
    return 'Ștergi toate semnele de carte din „$title”?';
  }

  @override
  String get noLongerAvailable => 'Nu mai există în carte';

  @override
  String get cancel => 'Renunță';

  @override
  String get delete => 'Șterge';

  @override
  String imageNumber(int number, int total) {
    return 'Imaginea $number din $total';
  }

  @override
  String get zoomIn => 'Mărește';

  @override
  String get zoomOut => 'Micșorează';

  @override
  String get fit => 'Potrivește pe ecran';

  @override
  String get previousImage => 'Imaginea anterioară';

  @override
  String get nextImage => 'Imaginea următoare';

  @override
  String get bookmarkImage => 'Pune semn la această imagine';

  @override
  String get removeBookmark => 'Scoate semnul de carte';

  @override
  String get readAloud => 'Citește pagina cu voce tare';

  @override
  String get audio => 'Sunet';

  @override
  String get soundEffects => 'Efecte sonore';

  @override
  String get speechRate => 'Viteza de citire';

  @override
  String readAloudUnavailable(String language) {
    return 'Citirea cu voce tare nu este disponibilă în $language pe acest dispozitiv.';
  }

  @override
  String get readAloudSetup =>
      'Pentru a adăuga o voce, deschide setările dispozitivului, apoi Sistem › Limbi › Redare text în vorbire, și instalează datele vocale pentru această limbă.';

  @override
  String get previousParagraph => 'Paragraful anterior';

  @override
  String get nextParagraph => 'Paragraful următor';

  @override
  String get stopReading => 'Oprește citirea';

  @override
  String get help => 'Ajutor';

  @override
  String get helpTour => 'Turul comenzilor';

  @override
  String get helpLinksTitle => 'Legături și previzualizări';

  @override
  String get helpLinksBody =>
      'O subliniere punctată marchează o legătură. În text, atingerea ei arată o scurtă descriere; Mai mult deschide pagina. Listele, indexurile și rezultatele căutării deschid paginile direct. Înapoi te duce mereu unde erai.';

  @override
  String get helpDatesTitle => 'Date';

  @override
  String get helpDatesBody =>
      'În 1858 Moldova folosea calendarul iulian, cu 12 zile în urma celui de azi. O dată ca 1 (13) iunie 1865 ᴶ⁄ᴳ dă întâi data iuliană și, în paranteză, data gregoriană. Atinge ᴶ⁄ᴳ pentru detalii.';

  @override
  String get helpFavoritesTitle => 'Favorite și semne de carte';

  @override
  String get helpFavoritesBody =>
      'Steaua păstrează o pagină printre favorite. Poți pune semne și la imagini și pasaje. Favoritele se deschid din Cuprins sau din Mai multe opțiuni.';

  @override
  String get helpImagesTitle => 'Imagini';

  @override
  String get helpImagesBody =>
      'Atinge o imagine ca s-o mărești. Ciupește pentru zoom; când imaginea încape pe ecran, glisează la următoarea sau la cea anterioară. Pe telecomandă, OK mărește, iar săgețile deplasează.';

  @override
  String get helpTablesTitle => 'Tabele';

  @override
  String get helpTablesBody =>
      'Tabelele late se derulează lateral, iar prima coloană rămâne pe loc; butonul de ecran complet dă tabelului tot ecranul. Atinge un antet ca să selectezi rândul sau coloana, atinge celule ca să selectezi o zonă (sau apasă lung și trage), apoi pune semn la selecție. Pe telecomandă: săgețile deplasează, OK începe și încheie selecția, Înapoi o anulează.';

  @override
  String get colourSettings => 'Culori';

  @override
  String get theme => 'Temă';

  @override
  String get themeAutomatic => 'Automată';

  @override
  String get themeLight => 'Luminoasă';

  @override
  String get themeDark => 'Întunecată';

  @override
  String get visionMode => 'Vederea culorilor';

  @override
  String get visionStandard => 'Standard';

  @override
  String get visionRedGreen => 'Sigur roșu-verde';

  @override
  String get visionRedGreenNote => 'Pentru protanopie și deuteranopie';

  @override
  String get visionTritan => 'Sigur tritan';

  @override
  String get visionTritanNote => 'Pentru tritanopie (albastru-galben)';

  @override
  String get visionGrayscale => 'Tonuri de gri';

  @override
  String get visionGrayscaleNote => 'Fără nicio culoare (acromatopsie)';

  @override
  String get visionKeepsEvidence =>
      'Imaginile mărcilor și mostrele de culoare își păstrează mereu culorile.';

  @override
  String get moveUp => 'Mută în sus';

  @override
  String get moveDown => 'Mută în jos';

  @override
  String get tourWelcome => 'Bun venit! Iată un scurt tur al comenzilor.';

  @override
  String get tourBack => 'Înapoi te duce la pagina de unde ai venit.';

  @override
  String get tourSections =>
      'Cuprinsul: capitolele, indexurile de imagini, abrevieri, culori și calendare, și favoritele tale.';

  @override
  String get tourStar => 'Steaua păstrează această pagină printre favorite.';

  @override
  String get tourSearch => 'Caută în toată cartea, cu filtre.';

  @override
  String get tourTitle =>
      'În modul peisaj titlul e ascuns, ca să rămână loc pentru text. Îl poți arăta de aici.';

  @override
  String get tourMore => 'Citire cu voce tare, sunet, limbă, culori și ajutor.';

  @override
  String get tourLinks =>
      'Cuvintele subliniate punctat sunt legături: atinge unul pentru o scurtă descriere.';

  @override
  String get next => 'Înainte';

  @override
  String get done => 'Gata';

  @override
  String get skip => 'Sari peste';

  @override
  String get keyboardSpace => 'Spațiu';

  @override
  String get keyboardBackspace => 'Șterge înapoi';

  @override
  String get keyboardShift => 'Majuscule';

  @override
  String get keyboardSymbols => 'Simboluri';

  @override
  String get keyboardLetters => 'Litere';

  @override
  String get showKeyboard => 'Arată tastatura de pe ecran';

  @override
  String get hideKeyboard => 'Ascunde tastatura de pe ecran';

  @override
  String get fullScreenTable => 'Arată tabelul pe tot ecranul';

  @override
  String get bookmarkSelection => 'Pune semn la selecție';

  @override
  String get clearSelection => 'Șterge selecția';

  @override
  String get selectionBookmarked => 'Selecția a primit semn de carte';

  @override
  String get bookmarkPassage => 'Pune semn la acest pasaj';

  @override
  String get passageBookmarked => 'Pasajul a primit semn de carte';

  @override
  String get undo => 'Anulează';
}

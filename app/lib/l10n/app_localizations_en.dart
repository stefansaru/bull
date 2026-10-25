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

  @override
  String get back => 'Back';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get moreOptions => 'More options';

  @override
  String get showTitle => 'Show title';

  @override
  String get hideTitle => 'Hide title';

  @override
  String get breadcrumb => 'You are here';

  @override
  String calendarOf(String year) {
    return 'Calendar of $year';
  }

  @override
  String get more => 'More';

  @override
  String previewOf(String title) {
    return 'Preview: $title';
  }

  @override
  String get linksHere => 'Links in this paragraph';

  @override
  String get related => 'Related';

  @override
  String get relRelated => 'related';

  @override
  String get relSee => 'see';

  @override
  String get relIssue => 'issue';

  @override
  String get relDenomination => 'denomination';

  @override
  String get relHandstamp => 'handstamp';

  @override
  String get relSeries => 'catalogue series';

  @override
  String get relPublishedIn => 'published in';

  @override
  String get relInTheBook => 'in the book';

  @override
  String get relReference => 'reference';

  @override
  String get indexes => 'Indexes';

  @override
  String get images => 'Images';

  @override
  String get abbreviations => 'Abbreviations';

  @override
  String get colours => 'Colours';

  @override
  String get favorites => 'Favorites';

  @override
  String get recentlyVisited => 'Recently visited';

  @override
  String get noImagesYet => 'No images are included in this edition yet.';

  @override
  String startingWith(String letter) {
    return 'Starting with $letter';
  }

  @override
  String get allAbbreviations => 'All abbreviations';

  @override
  String get swatchNote =>
      'The colours reproduce the swatches of the author\'s colour table. Screens show them only approximately; the standard\'s code is the authority.';

  @override
  String colourFamily(String family) {
    String _temp0 = intl.Intl.selectLogic(family, {
      'blue': 'Blues',
      'green': 'Greens',
      'red': 'Reds',
      'neutral': 'Black and white',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get typeNarrative => 'Book chapters';

  @override
  String get filters => 'Filters';

  @override
  String filtersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filters ($count)',
      zero: 'Filters',
    );
    return '$_temp0';
  }

  @override
  String get filterType => 'Type';

  @override
  String get filterChapter => 'Chapter';

  @override
  String get allChapters => 'All chapters';

  @override
  String get favoritesOnly => 'Favorites only';

  @override
  String get clearFilters => 'Clear';

  @override
  String get apply => 'Apply';

  @override
  String get searchFavorites => 'Search favorites';

  @override
  String get noFavorites =>
      'Nothing saved yet. Tap the star on any page to keep it here.';

  @override
  String get wholePage => 'Whole page';

  @override
  String get passage => 'Passage';

  @override
  String get image => 'Image';

  @override
  String tableSelection(int rows, int cols) {
    return 'Table selection: $rows rows, $cols columns';
  }

  @override
  String bookmarksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookmarks',
      one: '1 bookmark',
    );
    return '$_temp0';
  }

  @override
  String get deleteBookmark => 'Delete bookmark';

  @override
  String get deleteAllFor => 'Delete all bookmarks of this page';

  @override
  String get deleteAll => 'Delete all bookmarks';

  @override
  String get confirmDeleteAll => 'Delete all favorites and bookmarks?';

  @override
  String confirmDeleteFor(String title) {
    return 'Delete all bookmarks of “$title”?';
  }

  @override
  String get noLongerAvailable => 'No longer in the book';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String imageNumber(int number, int total) {
    return 'Image $number of $total';
  }

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get fit => 'Fit to screen';

  @override
  String get previousImage => 'Previous image';

  @override
  String get nextImage => 'Next image';

  @override
  String get bookmarkImage => 'Bookmark this image';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get readAloud => 'Read this page aloud';

  @override
  String get audio => 'Audio';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get speechRate => 'Reading speed';

  @override
  String readAloudUnavailable(String language) {
    return 'Read aloud is unavailable for $language on this device.';
  }

  @override
  String get readAloudSetup =>
      'To add a voice, open the device settings, then System › Languages › Text-to-speech output, and install the voice data for this language.';

  @override
  String get previousParagraph => 'Previous paragraph';

  @override
  String get nextParagraph => 'Next paragraph';

  @override
  String get stopReading => 'Stop reading';

  @override
  String get help => 'Help';

  @override
  String get helpTour => 'Tour of the controls';

  @override
  String get helpLinksTitle => 'Links and previews';

  @override
  String get helpLinksBody =>
      'A dotted underline marks a link. In the text, tapping it shows a short description; More opens its page. Lists, indexes and search results open pages directly. Back always returns to where you were.';

  @override
  String get helpDatesTitle => 'Dates';

  @override
  String get helpDatesBody =>
      'In 1858 Moldavia used the Julian calendar, 12 days behind ours. A date like 1 (13) June 1865 ᴶ⁄ᴳ gives the Julian date first and the Gregorian date in parentheses. Tap ᴶ⁄ᴳ to read more.';

  @override
  String get helpFavoritesTitle => 'Favorites and bookmarks';

  @override
  String get helpFavoritesBody =>
      'The star keeps a page among your favorites. Images and passages can be bookmarked too. Open Favorites from Contents or from More options.';

  @override
  String get helpImagesTitle => 'Images';

  @override
  String get helpImagesBody =>
      'Tap an image to enlarge it. Pinch to zoom; when the image fits the screen, swipe to the next or previous one. On a remote, Select zooms and the arrows move.';

  @override
  String get helpTablesTitle => 'Tables';

  @override
  String get helpTablesBody =>
      'Wide tables scroll sideways while their first column and header stay in place.';

  @override
  String get colourSettings => 'Colours';

  @override
  String get theme => 'Theme';

  @override
  String get themeAutomatic => 'Automatic';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get visionMode => 'Colour vision';

  @override
  String get visionStandard => 'Standard';

  @override
  String get visionRedGreen => 'Red-Green Safe';

  @override
  String get visionRedGreenNote => 'For protanopia and deuteranopia';

  @override
  String get visionTritan => 'Tritan Safe';

  @override
  String get visionTritanNote => 'For tritanopia (blue-yellow)';

  @override
  String get visionGrayscale => 'Grayscale';

  @override
  String get visionGrayscaleNote => 'No colour at all (achromatopsia)';

  @override
  String get visionKeepsEvidence =>
      'Stamp images and colour swatches always keep their own colours.';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get tourWelcome => 'Welcome! Here is a short tour of the controls.';

  @override
  String get tourBack => 'Back returns to the page you came from.';

  @override
  String get tourSections =>
      'Contents: the chapters, the indexes of images, abbreviations, colours and calendars, and your favorites.';

  @override
  String get tourStar => 'The star keeps this page among your favorites.';

  @override
  String get tourSearch => 'Search the whole book, with filters.';

  @override
  String get tourTitle =>
      'In landscape the title is hidden to leave room for the text. Show it here.';

  @override
  String get tourMore => 'Read aloud, audio, language, colours and help.';

  @override
  String get tourLinks =>
      'Words with a dotted underline are links: tap one for a short description.';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';
}

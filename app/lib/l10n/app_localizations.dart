import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('ro'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bull\'s Head 1858'**
  String get appTitle;

  /// No description provided for @contents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get contents;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReading;

  /// No description provided for @previousSection.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousSection;

  /// No description provided for @nextSection.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextSection;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search the book'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Book language'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacySummary.
  ///
  /// In en, this message translates to:
  /// **'This app collects no personal data and works fully offline.'**
  String get privacySummary;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'Published by Jini Solutions'**
  String get publisher;

  /// No description provided for @contentMissing.
  ///
  /// In en, this message translates to:
  /// **'The book content is missing. Run the wizard to build it.'**
  String get contentMissing;

  /// No description provided for @zoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch or press select to zoom'**
  String get zoomHint;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @imagesNote.
  ///
  /// In en, this message translates to:
  /// **'Some images are not included in this edition.'**
  String get imagesNote;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @showTitle.
  ///
  /// In en, this message translates to:
  /// **'Show title'**
  String get showTitle;

  /// No description provided for @hideTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide title'**
  String get hideTitle;

  /// No description provided for @breadcrumb.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get breadcrumb;

  /// No description provided for @calendarOf.
  ///
  /// In en, this message translates to:
  /// **'Calendar of {year}'**
  String calendarOf(String year);

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @previewOf.
  ///
  /// In en, this message translates to:
  /// **'Preview: {title}'**
  String previewOf(String title);

  /// No description provided for @linksHere.
  ///
  /// In en, this message translates to:
  /// **'Links in this paragraph'**
  String get linksHere;

  /// No description provided for @related.
  ///
  /// In en, this message translates to:
  /// **'Related'**
  String get related;

  /// No description provided for @relRelated.
  ///
  /// In en, this message translates to:
  /// **'related'**
  String get relRelated;

  /// No description provided for @relSee.
  ///
  /// In en, this message translates to:
  /// **'see'**
  String get relSee;

  /// No description provided for @relIssue.
  ///
  /// In en, this message translates to:
  /// **'issue'**
  String get relIssue;

  /// No description provided for @relDenomination.
  ///
  /// In en, this message translates to:
  /// **'denomination'**
  String get relDenomination;

  /// No description provided for @relHandstamp.
  ///
  /// In en, this message translates to:
  /// **'handstamp'**
  String get relHandstamp;

  /// No description provided for @relSeries.
  ///
  /// In en, this message translates to:
  /// **'catalogue series'**
  String get relSeries;

  /// No description provided for @relPublishedIn.
  ///
  /// In en, this message translates to:
  /// **'published in'**
  String get relPublishedIn;

  /// No description provided for @relInTheBook.
  ///
  /// In en, this message translates to:
  /// **'in the book'**
  String get relInTheBook;

  /// No description provided for @relReference.
  ///
  /// In en, this message translates to:
  /// **'reference'**
  String get relReference;

  /// No description provided for @indexes.
  ///
  /// In en, this message translates to:
  /// **'Indexes'**
  String get indexes;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @abbreviations.
  ///
  /// In en, this message translates to:
  /// **'Abbreviations'**
  String get abbreviations;

  /// No description provided for @colours.
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get colours;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @recentlyVisited.
  ///
  /// In en, this message translates to:
  /// **'Recently visited'**
  String get recentlyVisited;

  /// No description provided for @noImagesYet.
  ///
  /// In en, this message translates to:
  /// **'No images are included in this edition yet.'**
  String get noImagesYet;

  /// No description provided for @startingWith.
  ///
  /// In en, this message translates to:
  /// **'Starting with {letter}'**
  String startingWith(String letter);

  /// No description provided for @allAbbreviations.
  ///
  /// In en, this message translates to:
  /// **'All abbreviations'**
  String get allAbbreviations;

  /// No description provided for @swatchNote.
  ///
  /// In en, this message translates to:
  /// **'The colours reproduce the swatches of the author\'s colour table. Screens show them only approximately; the standard\'s code is the authority.'**
  String get swatchNote;

  /// No description provided for @colourFamily.
  ///
  /// In en, this message translates to:
  /// **'{family, select, blue{Blues} green{Greens} red{Reds} neutral{Black and white} other{Other}}'**
  String colourFamily(String family);

  /// No description provided for @typeNarrative.
  ///
  /// In en, this message translates to:
  /// **'Book chapters'**
  String get typeNarrative;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filtersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Filters} other{Filters ({count})}}'**
  String filtersCount(int count);

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get filterChapter;

  /// No description provided for @allChapters.
  ///
  /// In en, this message translates to:
  /// **'All chapters'**
  String get allChapters;

  /// No description provided for @favoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get favoritesOnly;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilters;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @searchFavorites.
  ///
  /// In en, this message translates to:
  /// **'Search favorites'**
  String get searchFavorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet. Tap the star on any page to keep it here.'**
  String get noFavorites;

  /// No description provided for @wholePage.
  ///
  /// In en, this message translates to:
  /// **'Whole page'**
  String get wholePage;

  /// No description provided for @passage.
  ///
  /// In en, this message translates to:
  /// **'Passage'**
  String get passage;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @tableSelection.
  ///
  /// In en, this message translates to:
  /// **'Table selection: {rows} rows, {cols} columns'**
  String tableSelection(int rows, int cols);

  /// No description provided for @bookmarksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bookmark} other{{count} bookmarks}}'**
  String bookmarksCount(int count);

  /// No description provided for @deleteBookmark.
  ///
  /// In en, this message translates to:
  /// **'Delete bookmark'**
  String get deleteBookmark;

  /// No description provided for @deleteAllFor.
  ///
  /// In en, this message translates to:
  /// **'Delete all bookmarks of this page'**
  String get deleteAllFor;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all bookmarks'**
  String get deleteAll;

  /// No description provided for @confirmDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all favorites and bookmarks?'**
  String get confirmDeleteAll;

  /// No description provided for @confirmDeleteFor.
  ///
  /// In en, this message translates to:
  /// **'Delete all bookmarks of “{title}”?'**
  String confirmDeleteFor(String title);

  /// No description provided for @noLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'No longer in the book'**
  String get noLongerAvailable;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @imageNumber.
  ///
  /// In en, this message translates to:
  /// **'Image {number} of {total}'**
  String imageNumber(int number, int total);

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @fit.
  ///
  /// In en, this message translates to:
  /// **'Fit to screen'**
  String get fit;

  /// No description provided for @previousImage.
  ///
  /// In en, this message translates to:
  /// **'Previous image'**
  String get previousImage;

  /// No description provided for @nextImage.
  ///
  /// In en, this message translates to:
  /// **'Next image'**
  String get nextImage;

  /// No description provided for @bookmarkImage.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this image'**
  String get bookmarkImage;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read this page aloud'**
  String get readAloud;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @speechRate.
  ///
  /// In en, this message translates to:
  /// **'Reading speed'**
  String get speechRate;

  /// No description provided for @readAloudUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Read aloud is unavailable for {language} on this device.'**
  String readAloudUnavailable(String language);

  /// No description provided for @readAloudSetup.
  ///
  /// In en, this message translates to:
  /// **'To add a voice, open the device settings, then System › Languages › Text-to-speech output, and install the voice data for this language.'**
  String get readAloudSetup;

  /// No description provided for @previousParagraph.
  ///
  /// In en, this message translates to:
  /// **'Previous paragraph'**
  String get previousParagraph;

  /// No description provided for @nextParagraph.
  ///
  /// In en, this message translates to:
  /// **'Next paragraph'**
  String get nextParagraph;

  /// No description provided for @stopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get stopReading;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpTour.
  ///
  /// In en, this message translates to:
  /// **'Tour of the controls'**
  String get helpTour;

  /// No description provided for @helpLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Links and previews'**
  String get helpLinksTitle;

  /// No description provided for @helpLinksBody.
  ///
  /// In en, this message translates to:
  /// **'A dotted underline marks a link. In the text, tapping it shows a short description; More opens its page. Lists, indexes and search results open pages directly. Back always returns to where you were.'**
  String get helpLinksBody;

  /// No description provided for @helpDatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get helpDatesTitle;

  /// No description provided for @helpDatesBody.
  ///
  /// In en, this message translates to:
  /// **'In 1858 Moldavia used the Julian calendar, 12 days behind ours. A date like 1 (13) June 1865 ᴶ⁄ᴳ gives the Julian date first and the Gregorian date in parentheses. Tap ᴶ⁄ᴳ to read more.'**
  String get helpDatesBody;

  /// No description provided for @helpFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites and bookmarks'**
  String get helpFavoritesTitle;

  /// No description provided for @helpFavoritesBody.
  ///
  /// In en, this message translates to:
  /// **'The star keeps a page among your favorites. Images and passages can be bookmarked too. Open Favorites from Contents or from More options.'**
  String get helpFavoritesBody;

  /// No description provided for @helpImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get helpImagesTitle;

  /// No description provided for @helpImagesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap an image to enlarge it. Pinch to zoom; when the image fits the screen, swipe to the next or previous one. On a remote, Select zooms and the arrows move.'**
  String get helpImagesBody;

  /// No description provided for @helpTablesTitle.
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get helpTablesTitle;

  /// No description provided for @helpTablesBody.
  ///
  /// In en, this message translates to:
  /// **'Wide tables scroll sideways while their first column and header stay in place.'**
  String get helpTablesBody;

  /// No description provided for @colourSettings.
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get colourSettings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get themeAutomatic;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @visionMode.
  ///
  /// In en, this message translates to:
  /// **'Colour vision'**
  String get visionMode;

  /// No description provided for @visionStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get visionStandard;

  /// No description provided for @visionRedGreen.
  ///
  /// In en, this message translates to:
  /// **'Red-Green Safe'**
  String get visionRedGreen;

  /// No description provided for @visionRedGreenNote.
  ///
  /// In en, this message translates to:
  /// **'For protanopia and deuteranopia'**
  String get visionRedGreenNote;

  /// No description provided for @visionTritan.
  ///
  /// In en, this message translates to:
  /// **'Tritan Safe'**
  String get visionTritan;

  /// No description provided for @visionTritanNote.
  ///
  /// In en, this message translates to:
  /// **'For tritanopia (blue-yellow)'**
  String get visionTritanNote;

  /// No description provided for @visionGrayscale.
  ///
  /// In en, this message translates to:
  /// **'Grayscale'**
  String get visionGrayscale;

  /// No description provided for @visionGrayscaleNote.
  ///
  /// In en, this message translates to:
  /// **'No colour at all (achromatopsia)'**
  String get visionGrayscaleNote;

  /// No description provided for @visionKeepsEvidence.
  ///
  /// In en, this message translates to:
  /// **'Stamp images and colour swatches always keep their own colours.'**
  String get visionKeepsEvidence;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @tourWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Here is a short tour of the controls.'**
  String get tourWelcome;

  /// No description provided for @tourBack.
  ///
  /// In en, this message translates to:
  /// **'Back returns to the page you came from.'**
  String get tourBack;

  /// No description provided for @tourSections.
  ///
  /// In en, this message translates to:
  /// **'Contents: the chapters, the indexes of images, abbreviations, colours and calendars, and your favorites.'**
  String get tourSections;

  /// No description provided for @tourStar.
  ///
  /// In en, this message translates to:
  /// **'The star keeps this page among your favorites.'**
  String get tourStar;

  /// No description provided for @tourSearch.
  ///
  /// In en, this message translates to:
  /// **'Search the whole book, with filters.'**
  String get tourSearch;

  /// No description provided for @tourTitle.
  ///
  /// In en, this message translates to:
  /// **'In landscape the title is hidden to leave room for the text. Show it here.'**
  String get tourTitle;

  /// No description provided for @tourMore.
  ///
  /// In en, this message translates to:
  /// **'Read aloud, audio, language, colours and help.'**
  String get tourMore;

  /// No description provided for @tourLinks.
  ///
  /// In en, this message translates to:
  /// **'Words with a dotted underline are links: tap one for a short description.'**
  String get tourLinks;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

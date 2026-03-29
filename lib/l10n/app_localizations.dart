import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('id'),
  ];

  /// App bar title shown throughout the app
  ///
  /// In en, this message translates to:
  /// **'Smritive'**
  String get appTitle;

  /// Login screen heading
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to continue your story journey'**
  String get login_subtitle;

  /// Register screen heading
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register_title;

  /// No description provided for @register_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Start sharing your story with the world'**
  String get register_subtitle;

  /// No description provided for @stories_title.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories_title;

  /// No description provided for @detail_title.
  ///
  /// In en, this message translates to:
  /// **'Story Detail'**
  String get detail_title;

  /// No description provided for @add_story_title.
  ///
  /// In en, this message translates to:
  /// **'Add Story'**
  String get add_story_title;

  /// No description provided for @field_email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get field_email;

  /// No description provided for @field_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get field_password;

  /// No description provided for @field_name.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get field_name;

  /// No description provided for @field_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get field_description;

  /// No description provided for @field_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Tell your story…'**
  String get field_description_hint;

  /// No description provided for @btn_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get btn_login;

  /// No description provided for @btn_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get btn_register;

  /// No description provided for @btn_share_story.
  ///
  /// In en, this message translates to:
  /// **'Share Story'**
  String get btn_share_story;

  /// No description provided for @error_photo_too_large.
  ///
  /// In en, this message translates to:
  /// **'Photo must be smaller than 1 MB. Please choose a different image.'**
  String get error_photo_too_large;

  /// No description provided for @state_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get state_loading;

  /// No description provided for @state_empty.
  ///
  /// In en, this message translates to:
  /// **'No stories yet'**
  String get state_empty;

  /// No description provided for @state_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get state_error;

  /// No description provided for @action_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get action_retry;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get nav_search;

  /// No description provided for @nav_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get nav_saved;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @section_popular.
  ///
  /// In en, this message translates to:
  /// **'Popular story'**
  String get section_popular;

  /// No description provided for @section_you_may_like.
  ///
  /// In en, this message translates to:
  /// **'You may also like'**
  String get section_you_may_like;

  /// No description provided for @section_recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get section_recent;

  /// No description provided for @link_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get link_view_all;

  /// No description provided for @link_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh to update'**
  String get link_refresh;

  /// No description provided for @auth_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get auth_no_account;

  /// No description provided for @auth_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get auth_have_account;

  /// No description provided for @photo_select_label.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a photo'**
  String get photo_select_label;

  /// No description provided for @photo_select_hint.
  ///
  /// In en, this message translates to:
  /// **'Max 1 MB · JPG, PNG'**
  String get photo_select_hint;

  /// No description provided for @photo_source_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photo_source_gallery;

  /// No description provided for @photo_source_camera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photo_source_camera;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @btn_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btn_close;

  /// No description provided for @photo_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a photo first.'**
  String get photo_required;

  /// No description provided for @story_section_label.
  ///
  /// In en, this message translates to:
  /// **'The Story'**
  String get story_section_label;

  /// No description provided for @validation_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validation_required;

  /// No description provided for @validation_password_min.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validation_password_min;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get error_generic;

  /// No description provided for @story_author_label.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String story_author_label(String name);

  /// Label shown on the language toggle button when current language is EN; tap switches to ID
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get lang_switch_label;

  /// Label shown when current language is ID; tap switches to EN
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get lang_switch_label_inverse;

  /// Persuasive catchphrase shown on login and register screens
  ///
  /// In en, this message translates to:
  /// **'Turn fleeting moments into everlasting stories.'**
  String get auth_tagline;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

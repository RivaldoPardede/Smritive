// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smritive';

  @override
  String get login_title => 'Welcome Back';

  @override
  String get login_subtitle => 'Login to continue your story journey';

  @override
  String get register_title => 'Create Account';

  @override
  String get register_subtitle => 'Start sharing your story with the world';

  @override
  String get stories_title => 'Stories';

  @override
  String get detail_title => 'Story Detail';

  @override
  String get add_story_title => 'Add Story';

  @override
  String get field_email => 'Email address';

  @override
  String get field_password => 'Password';

  @override
  String get field_name => 'Full name';

  @override
  String get field_description => 'Description';

  @override
  String get field_description_hint => 'Tell your story…';

  @override
  String get btn_login => 'Login';

  @override
  String get btn_register => 'Register';

  @override
  String get btn_share_story => 'Share Story';

  @override
  String get error_photo_too_large =>
      'Photo must be smaller than 1 MB. Please choose a different image.';

  @override
  String get state_loading => 'Loading…';

  @override
  String get state_empty => 'No stories yet';

  @override
  String get state_error => 'Something went wrong';

  @override
  String get action_retry => 'Retry';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_search => 'Search';

  @override
  String get nav_saved => 'Saved';

  @override
  String get nav_profile => 'Profile';

  @override
  String get section_popular => 'Popular story';

  @override
  String get section_you_may_like => 'You may also like';

  @override
  String get section_recent => 'Recent';

  @override
  String get link_view_all => 'View all';

  @override
  String get link_refresh => 'Refresh to update';

  @override
  String get auth_no_account => 'Don\'t have an account? ';

  @override
  String get auth_have_account => 'Already have an account? ';

  @override
  String get photo_select_label => 'Tap to select a photo';

  @override
  String get photo_select_hint => 'Max 1 MB · JPG, PNG';

  @override
  String get photo_source_gallery => 'Choose from gallery';

  @override
  String get photo_source_camera => 'Take a photo';

  @override
  String get logout => 'Logout';

  @override
  String get btn_close => 'Close';

  @override
  String get photo_required => 'Please select a photo first.';

  @override
  String get story_section_label => 'The Story';

  @override
  String get validation_required => 'Required';

  @override
  String get validation_password_min =>
      'Password must be at least 8 characters';

  @override
  String get error_generic => 'An unexpected error occurred. Please try again.';

  @override
  String story_author_label(String name) {
    return 'by $name';
  }

  @override
  String get lang_switch_label => 'ID';

  @override
  String get lang_switch_label_inverse => 'EN';

  @override
  String get auth_tagline => 'Turn fleeting moments into everlasting stories.';
}

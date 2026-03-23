// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Explore';

  @override
  String get login => 'Sign In';

  @override
  String get register => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get account => 'Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccountSubtitle => 'Permanently delete your account';

  @override
  String get deleteAccountIrreversible => 'This action is irreversible.';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get notifications => 'Notifications';

  @override
  String get map => 'Map';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get welcome => 'Welcome!';

  @override
  String get createAccountToSave => 'Create an account to save your tracklogs';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get passwordRequirements =>
      'Password must be at least 8 characters with uppercase, lowercase, and number';

  @override
  String get storageWarning => 'Storage Warning';

  @override
  String get storageWarningMessage =>
      'Your map cache is using a significant amount of storage space. Would you like to clear some old tiles to free up space?';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get notNow => 'Not Now';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get importTrack => 'Import Track';

  @override
  String get centerOnLocation => 'Center on Location';

  @override
  String get toNorth => 'To North';

  @override
  String get anonymousUser => 'Anonymous User';

  @override
  String get noUserSignedIn => 'No user signed in';

  @override
  String get editDisplayName => 'Edit Display Name';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayNameUpdatedSuccessfully =>
      'Display name updated successfully';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get unableToUpdateProfile =>
      'Unable to update profile. Please check your internet connection and try again.';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get memberSince => 'Member Since';

  @override
  String get emailVerified => 'Email Verified';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get viewAndEditYourProfile => 'View and edit your profile';

  @override
  String get changeProfilePicture => 'Change profile picture';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get legal => 'Legal';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get logoutConfirmationTitle => 'Logout?';

  @override
  String get logoutConfirmationBody =>
      'Are you sure you want to sign out of your account?';

  @override
  String logoutFailed(String error) {
    return 'Logout failed: $error';
  }

  @override
  String get deleteAccountConfirm => 'Delete Account?';

  @override
  String get deletionWarning => 'This cannot be undone!';

  @override
  String get deletionItems => 'Deleting your account will:';

  @override
  String get deletionPermanentlyRemove =>
      'Permanently remove all your account data';

  @override
  String get deletionDeleteTracks => 'Delete all your saved tracklogs';

  @override
  String get deletionCancelSessions => 'Cancel any active sessions';

  @override
  String get deletionRemoveProfile => 'Remove your profile information';

  @override
  String get enterPasswordToConfirm => 'To confirm, enter your password:';

  @override
  String get loading => 'Loading...';

  @override
  String get verifying => 'Verifying...';

  @override
  String get updating => 'Updating...';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get photoPickerCancelled => 'No photo selected.';

  @override
  String get photoPermissionDenied => 'Photo access was denied.';

  @override
  String get photoPickerFailed => 'Could not select photo. Please try again.';

  @override
  String get couldNotOpenLink => 'Could not open link.';

  @override
  String get couldNotLoadTracklogs => 'Could not load saved tracklogs';

  @override
  String trackImportedSuccessfully(String name) {
    return 'Track \"$name\" imported successfully';
  }

  @override
  String get importingTrack => 'Importing track...';

  @override
  String failedToImportTrack(String error) {
    return 'Failed to import track: $error';
  }

  @override
  String failedToUpdateTracklog(String error) {
    return 'Failed to update tracklog: $error';
  }

  @override
  String failedToDeleteTracklog(String error) {
    return 'Failed to delete tracklog: $error';
  }

  @override
  String get cacheStorageInfo => 'Cache Storage Info';

  @override
  String get totalSize => 'Total Size';

  @override
  String get tileCount => 'Tile Count';

  @override
  String get storageUsage => 'Storage Usage';

  @override
  String get storageWarningThresholdReached =>
      'Storage warning threshold reached';

  @override
  String get storageUsageNormal => 'Storage usage is normal';

  @override
  String get close => 'Close';

  @override
  String get undo => 'Undo';

  @override
  String get tracklogs => 'Tracklogs';

  @override
  String get noTracklogsAdded => 'No tracklogs added yet';

  @override
  String get imported => 'Imported';

  @override
  String get hide => 'Hide';

  @override
  String get show => 'Show';

  @override
  String get rename => 'Rename';

  @override
  String get changeColor => 'Change Color';

  @override
  String get remove => 'Remove';

  @override
  String get renameTracklog => 'Rename Tracklog';

  @override
  String isVisibleNow(String name) {
    return '$name is now visible';
  }

  @override
  String isHiddenNow(String name) {
    return '$name is now hidden';
  }

  @override
  String get nameTracklog => 'Name Tracklog';

  @override
  String get name => 'Name';

  @override
  String get enterTracklogName => 'Enter tracklog name';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get ok => 'OK';

  @override
  String get chooseColor => 'Choose Color';

  @override
  String get addMarker => 'Add marker';

  @override
  String get addMarkerQuestion => 'Add marker?';

  @override
  String get addMarkerAtLocation => 'Add a marker at this location?';

  @override
  String get chooseIcon => 'Choose icon';

  @override
  String get nameMarker => 'Name marker';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get create => 'Create';

  @override
  String get markerName => 'Marker name';

  @override
  String get enterName => 'Enter a name';

  @override
  String get markerStepInstruction =>
      'You can choose an icon, a color, and a name in the next steps.';
}

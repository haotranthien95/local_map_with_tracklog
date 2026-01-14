/// Centralized asset paths used by the app.
///
/// Keep all asset paths in one place to avoid typos and make refactors easy.
class AppAssets {
  AppAssets._();

  static const String _iconsDir = 'assets/icons';
  static const String _imagesDir = 'assets/images';

  // Common / known assets
  static const String logo = '$_iconsDir/ic_logo.svg';

  /// Builds an icon asset path inside `assets/icons/`.
  ///
  /// Example: `AppAssets.icon('ic_pin.svg')` -> `assets/icons/ic_pin.svg`
  static String icon(String fileName) => '$_iconsDir/$fileName';

  /// Builds an image asset path inside `assets/images/`.
  ///
  /// Example: `AppAssets.image('onboarding.png')` -> `assets/images/onboarding.png`
  static String image(String fileName) => '$_imagesDir/$fileName';
}

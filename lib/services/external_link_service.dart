import 'package:url_launcher/url_launcher.dart';

class ExternalLinkService {
  const ExternalLinkService();

  Future<bool> openHttpsUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.scheme.toLowerCase() != 'https') {
      return false;
    }

    if (!await canLaunchUrl(uri)) {
      return false;
    }

    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}

import 'package:flutter/material.dart';
import 'profile_screen.dart'; // T085
import '../services/authentication_service.dart'; // T098-T102
import '../main.dart';
import 'package:local_map_with_tracklog/l10n/l10n_extension.dart';

/// Settings screen with profile and logout sections
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthenticationService();
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSectionHeader(context.l10n.profile),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(context.l10n.profile),
            subtitle: const Text('View and edit your profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // T085: Navigate to profile screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 20),
          _buildSectionHeader(context.l10n.theme),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(context.l10n.theme),
            trailing: DropdownButton<ThemeMode>(
              value: Theme.of(context).brightness == Brightness.light
                  ? ThemeMode.light
                  : ThemeMode.dark, // Simplified
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  MyApp.of(context).setThemeMode(newMode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(context.l10n.system),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(context.l10n.light),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(context.l10n.dark),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 20),
          _buildSectionHeader(context.l10n.language),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.l10n.language),
            trailing: DropdownButton<Locale>(
              value: Localizations.localeOf(context),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  MyApp.of(context).setLocale(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('vi'),
                  child: Text('Tiếng Việt'),
                ),
                DropdownMenuItem(
                  value: Locale('zh'),
                  child: Text('中文'),
                ),
                DropdownMenuItem(
                  value: Locale('ja'),
                  child: Text('日本語'),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 20),
          _buildSectionHeader(context.l10n.account),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(context.l10n.logout),
            subtitle: const Text('Sign out of your account'),
            enabled: !_isLoggingOut,
            onTap: _isLoggingOut ? null : _handleLogout,
          ),
        ],
      ),
    );
  }

  /// T099-T102: Handle logout with confirmation dialog
  Future<void> _handleLogout() async {
    // T100: Show confirmation dialog before logout
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.logout + '?'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(context.l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoggingOut = true);

      try {
        // T098: Call signOut service method
        await _authService.signOut();

        if (mounted) {
          // T101: Clear navigation stack and redirect to LoginScreen
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        // T102: Handle logout errors gracefully
        if (mounted) {
          setState(() => _isLoggingOut = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: ${e.toString()}')),
          );
        }
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

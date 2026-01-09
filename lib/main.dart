import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart'; // T054
import 'screens/login_screen.dart'; // T070
import 'services/authentication_service.dart'; // T104
import 'features/auth/screens/delete_account_flow.dart'; // T011 - Feature 004
import 'services/theme_service_impl.dart';
import 'theme/app_theme_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();

  // Static method to access the state and change settings
  static _MyAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>()!;
  }
}

class _MyAppState extends State<MyApp> {
  late final ThemeServiceImpl _themeService;
  final _authService = AuthenticationService();
  late final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeServiceImpl(widget.prefs);
    _loadLocale();

    // T104: Listen to auth state changes and redirect on logout
    _authService.authStateChanges().listen((user) {
      if (user == null && _navigatorKey.currentContext != null) {
        // User logged out, redirect to login screen
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  void _loadLocale() {
    final languageCode = widget.prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
  }

  void setThemeMode(ThemeMode mode) async {
    await _themeService.setThemeMode(mode);
    setState(() {});
  }

  void setLocale(Locale locale) async {
    await widget.prefs.setString('language_code', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Map with Track Log',
      theme: AppThemeData.lightTheme,
      darkTheme: AppThemeData.darkTheme,
      themeMode: _themeService.themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      home: const HomeScreen(),
      // T054, T070: Add named routes for authentication screens
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(), // T070 - Phase 4
        '/delete_account': (context) => const DeleteAccountFlow(), // T011 - Feature 004
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart'; // T054
import 'screens/login_screen.dart'; // T070
import 'services/authentication_service.dart'; // T104
import 'features/auth/screens/delete_account_flow.dart'; // T011 - Feature 004

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authService = AuthenticationService();
  late final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // T104: Listen to auth state changes and redirect on logout
    _authService.authStateChanges().listen((user) {
      if (user == null && _navigatorKey.currentContext != null) {
        // User logged out, redirect to login screen
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Map with Track Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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

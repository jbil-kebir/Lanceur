import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/catalogue_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SesameApp());
}

class SesameApp extends StatelessWidget {
  const SesameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sésame',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const AppRouter(),
      routes: {
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

/// Redirige vers l'onboarding au premier lancement, HomeScreen ensuite.
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  @override
  void initState() {
    super.initState();
    _router();
  }

  Future<void> _router() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;

    if (onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CatalogueScreen(
            premierLancement: true,
            urlsExistantes: {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

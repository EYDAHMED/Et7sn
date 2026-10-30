import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'providers/diet_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/session_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/location_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    // Reads android/app/google-services.json (added by the Google Services plugin).
    await Firebase.initializeApp();
  } catch (error) {
    runApp(_StartupErrorApp(message: '$error'));
    return;
  }
  runApp(Et7snApp(prefs: prefs));
}

class Et7snApp extends StatelessWidget {
  const Et7snApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<LocationService>(create: (_) => LocationService()),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefs),
        ),
        ChangeNotifierProvider<SessionProvider>(
          create: (context) => SessionProvider(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider<DietProvider>(
          create: (context) => DietProvider(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<PrayerProvider>(
          create: (context) => PrayerProvider(
            prefs,
            context.read<LocationService>(),
          ),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).t('appName'),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      // A null locale follows the device language (automatic detection).
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supported) {
        if (deviceLocale != null) {
          for (final locale in supported) {
            if (locale.languageCode == deviceLocale.languageCode) return locale;
          }
        }
        return const Locale('en');
      },
      home: const AuthGate(),
    );
  }
}

/// Shown instead of the app when Firebase could not start (for example when
/// google-services.json is missing), so the problem is visible, not a blank screen.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Firebase is not configured',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add android/app/google-services.json from your Firebase '
                  'project and rebuild the app.',
                ),
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

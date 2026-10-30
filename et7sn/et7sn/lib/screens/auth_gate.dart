import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/session_provider.dart';
import '../widgets/common_widgets.dart';
import 'auth/login_screen.dart';
import 'home_shell.dart';
import 'onboarding_screen.dart';

/// Chooses the right screen from the current session state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    switch (session.status) {
      case SessionStatus.loading:
        return const _SplashScreen();
      case SessionStatus.signedOut:
        return const LoginScreen();
      case SessionStatus.needsOnboarding:
        return const OnboardingScreen();
      case SessionStatus.ready:
        return const HomeShell();
      case SessionStatus.error:
        return const _SessionErrorScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 88),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionErrorScreen extends StatelessWidget {
  const _SessionErrorScreen();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = context.read<SessionProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 56),
                const SizedBox(height: 16),
                Text(
                  l.t('loadErrorTitle'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l.t('loadErrorBody'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: session.retry,
                  child: Text(l.t('retry')),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: session.signOut,
                  child: Text(l.t('signOut')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

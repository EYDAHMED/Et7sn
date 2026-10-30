import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/prayer_provider.dart';
import '../providers/session_provider.dart';
import 'admin/admin_dashboard_screen.dart';
import 'diet_screen.dart';
import 'leaderboard_screen.dart';
import 'prayer_screen.dart';
import 'profile_screen.dart';

/// Bottom-navigation container for the signed-in experience.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final PrayerProvider _prayer;
  int _lastArrival = 0;

  @override
  void initState() {
    super.initState();
    _prayer = context.read<PrayerProvider>();
    _lastArrival = _prayer.arrival?.sequence ?? 0;
    _prayer.addListener(_onPrayerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _prayer.start();
    });
  }

  @override
  void dispose() {
    _prayer.removeListener(_onPrayerChanged);
    super.dispose();
  }

  void _onPrayerChanged() {
    final arrival = _prayer.arrival;
    if (arrival == null || arrival.sequence == _lastArrival) return;
    _lastArrival = arrival.sequence;
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: Text(
          l.tr('prayerTimeNow', {'name': l.t('prayer_${arrival.name.name}')}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAdmin = context.select<SessionProvider, bool>((s) => s.isAdmin);

    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.restaurant_menu_outlined),
        selectedIcon: const Icon(Icons.restaurant_menu),
        label: l.t('tabDiet'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.schedule_outlined),
        selectedIcon: const Icon(Icons.schedule),
        label: l.t('tabPrayer'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.emoji_events_outlined),
        selectedIcon: const Icon(Icons.emoji_events),
        label: l.t('tabLeaderboard'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: l.t('tabProfile'),
      ),
      if (isAdmin)
        NavigationDestination(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: const Icon(Icons.admin_panel_settings),
          label: l.t('tabAdmin'),
        ),
    ];

    final pages = <Widget>[
      const DietScreen(),
      const PrayerScreen(),
      const LeaderboardScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminDashboardScreen(),
    ];

    final index = _index >= pages.length ? 0 : _index;

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: destinations,
      ),
    );
  }
}

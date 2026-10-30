import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/leaderboard_entry.dart';
import '../../models/user_profile.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/format.dart';
import '../../utils/week_utils.dart';
import '../../widgets/common_widgets.dart';
import 'admin_user_detail_screen.dart';

/// Super admin overview: every registered user, live from Firestore.
///
/// Only accounts that have a document in the `admins` collection see this tab,
/// and the Firestore rules enforce the same restriction on the server.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Stream<List<UserProfile>> _users;
  late Stream<List<LeaderboardEntry>> _board;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    final service = context.read<FirestoreService>();
    _users = service.watchAllUsers();
    _board = service.watchLeaderboard();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final week = WeekUtils.weekIndex(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text(l.t('adminDashboard'))),
      body: StreamBuilder<List<UserProfile>>(
        stream: _users,
        builder: (context, usersSnapshot) {
          if (usersSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(l.t('adminLoadError'), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(_connect),
                      child: Text(l.t('retry')),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!usersSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = usersSnapshot.data!;

          return StreamBuilder<List<LeaderboardEntry>>(
            stream: _board,
            builder: (context, boardSnapshot) {
              final board = <String, LeaderboardEntry>{
                for (final entry in boardSnapshot.data ?? const <LeaderboardEntry>[])
                  entry.uid: entry,
              };
              final updatedCount =
                  board.values.where((e) => e.updatedThisWeek(week)).length;
              final totalChange = users.fold<double>(
                0,
                (sum, u) => sum + (u.weightKg - u.startWeightKg),
              );

              final query = _query.trim().toLowerCase();
              final filtered = users.where((u) {
                if (query.isEmpty) return true;
                return u.name.toLowerCase().contains(query) ||
                    u.username.toLowerCase().contains(query);
              }).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.groups_outlined,
                          label: l.t('totalUsers'),
                          value: '${users.length}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.check_circle_outline,
                          label: l.t('updatedThisWeek'),
                          value: '$updatedCount/${users.length}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.trending_down,
                          label: l.t('totalChange'),
                          value: Format.signedKg(totalChange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _search,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: l.t('searchUsers'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _search.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                  SectionTitle(l.t('allUsers')),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Center(child: Text(l.t('noUsersFound'))),
                    )
                  else
                    for (final user in filtered) ...[
                      _UserTile(
                        user: user,
                        entry: board[user.uid],
                        week: week,
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.entry, required this.week});

  final UserProfile user;
  final LeaderboardEntry? entry;
  final int week;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final change = user.weightKg - user.startWeightKg;
    final updated = entry?.updatedThisWeek(week) ?? false;

    Color changeColor = scheme.onSurfaceVariant;
    final good = switch (user.goal) {
      Goal.lose => change < -0.049,
      Goal.gain => change > 0.049,
      Goal.maintain => change.abs() < 0.5 && change != 0,
    };
    final bad = switch (user.goal) {
      Goal.lose => change > 0.049,
      Goal.gain => change < -0.049,
      Goal.maintain => change.abs() >= 1,
    };
    if (good) changeColor = AppColors.positive;
    if (bad) changeColor = scheme.error;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AdminUserDetailScreen(uid: user.uid),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(
                  user.name.trim().isEmpty
                      ? '?'
                      : String.fromCharCode(user.name.trim().runes.first)
                          .toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? '—' : user.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        InfoPill(text: l.t('goal_${user.goal.name}')),
                        InfoPill(
                          text: updated ? l.t('updated') : l.t('notUpdatedYet'),
                          icon: updated
                              ? Icons.check_circle_outline
                              : Icons.hourglass_empty,
                          color: updated ? AppColors.positive : AppColors.gold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${Format.kg(user.weightKg)} ${l.t('kg')}',
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Format.signedKg(change),
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

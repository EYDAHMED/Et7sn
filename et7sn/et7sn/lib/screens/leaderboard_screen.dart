import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/leaderboard_entry.dart';
import '../providers/session_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../utils/week_utils.dart';
import '../widgets/common_widgets.dart';
import '../widgets/weight_sheet.dart';

/// Weekly leaderboard. Members update their weight once a week and are ranked
/// by progress towards their own goal (lose / maintain / gain).
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardMode _mode = LeaderboardMode.week;
  late Stream<List<LeaderboardEntry>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<FirestoreService>().watchLeaderboard();
  }

  void _reload() {
    setState(() {
      _stream = context.read<FirestoreService>().watchLeaderboard();
    });
  }

  List<LeaderboardEntry> _ranked(List<LeaderboardEntry> all, int week) {
    final list = List<LeaderboardEntry>.of(all);
    list.sort((a, b) {
      if (_mode == LeaderboardMode.week) {
        final aUpdated = a.updatedThisWeek(week);
        final bUpdated = b.updatedThisWeek(week);
        if (aUpdated != bUpdated) return aUpdated ? -1 : 1;
      }
      final byScore = b.score(_mode, week).compareTo(a.score(_mode, week));
      if (byScore != 0) return byScore;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final uid = context.select<SessionProvider, String?>((s) => s.user?.uid);
    final week = WeekUtils.weekIndex(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text(l.t('tabLeaderboard'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showWeightSheet(context),
        icon: const Icon(Icons.monitor_weight_outlined),
        label: Text(l.t('updateWeight')),
      ),
      body: StreamBuilder<List<LeaderboardEntry>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorView(onRetry: _reload);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final ranked = _ranked(snapshot.data!, week);
          final mine = ranked.where((e) => e.uid == uid).toList();
          final needsUpdate = mine.isNotEmpty && !mine.first.updatedThisWeek(week);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              Text(
                l.tr('weekOf', {
                  'date': l.formatShortDate(WeekUtils.weekStart(week)),
                }),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<LeaderboardMode>(
                segments: [
                  ButtonSegment<LeaderboardMode>(
                    value: LeaderboardMode.week,
                    icon: const Icon(Icons.calendar_view_week),
                    label: Text(l.t('thisWeek')),
                  ),
                  ButtonSegment<LeaderboardMode>(
                    value: LeaderboardMode.overall,
                    icon: const Icon(Icons.all_inclusive),
                    label: Text(l.t('overall')),
                  ),
                ],
                selected: {_mode},
                showSelectedIcon: false,
                onSelectionChanged: (value) => setState(() => _mode = value.first),
              ),
              if (needsUpdate) ...[
                const SizedBox(height: 14),
                _ReminderCard(onUpdate: () => showWeightSheet(context)),
              ],
              const SizedBox(height: 14),
              if (ranked.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: Text(l.t('leaderboardEmpty'))),
                )
              else
                for (var i = 0; i < ranked.length; i++) ...[
                  _RankTile(
                    rank: i + 1,
                    entry: ranked[i],
                    mode: _mode,
                    week: week,
                    isMe: ranked[i].uid == uid,
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 4),
              Text(
                l.t('leaderboardHint'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(l.t('loadErrorTitle'), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l.t('retry'))),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.onUpdate});

  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: scheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.t('weeklyReminder'),
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onUpdate,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: Text(l.t('update')),
          ),
        ],
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.rank,
    required this.entry,
    required this.mode,
    required this.week,
    required this.isMe,
  });

  final int rank;
  final LeaderboardEntry entry;
  final LeaderboardMode mode;
  final int week;
  final bool isMe;

  Color _badgeColor(ColorScheme scheme) {
    switch (rank) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final updated = mode == LeaderboardMode.overall || entry.updatedThisWeek(week);
    final change = entry.changeKg(mode, week);
    final score = entry.score(mode, week);

    Color changeColor = scheme.onSurfaceVariant;
    if (updated && score > 0.049) changeColor = AppColors.positive;
    if (updated && score < -0.049) changeColor = scheme.error;

    final badgeColor = _badgeColor(scheme);
    final displayName = entry.name.isEmpty ? '—' : entry.name;

    return Opacity(
      opacity: updated ? 1 : 0.65,
      child: Card(
        color: isMe ? scheme.primaryContainer.withValues(alpha: 0.55) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isMe ? scheme.primary : scheme.outlineVariant,
            width: isMe ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rank <= 3 ? badgeColor : Colors.transparent,
                  border: Border.all(color: badgeColor, width: 1.5),
                ),
                child: rank <= 3
                    ? const Icon(Icons.emoji_events, size: 20, color: AppColors.white)
                    : Text(
                        '$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          InfoPill(text: l.t('you')),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      updated
                          ? '${l.t('goal_${entry.goal.name}')}  ·  '
                              '${Format.kg(entry.currentWeightKg)} ${l.t('kg')}'
                          : l.t('notUpdatedYet'),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    updated ? Format.signedKg(change) : '—',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: changeColor,
                    ),
                  ),
                  Text(
                    l.t('kg'),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: scheme.onSurfaceVariant,
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

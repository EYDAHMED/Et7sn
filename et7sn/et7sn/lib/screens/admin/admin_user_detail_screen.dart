import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../models/weight_entry.dart';
import '../../services/firestore_service.dart';
import '../../services/nutrition_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/format.dart';
import '../../utils/week_utils.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/weight_chart.dart';

/// Live view of one user's profile, nutrition targets and weekly weights.
class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({super.key, required this.uid});

  final String uid;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late final Stream<UserProfile?> _profile;
  late final Stream<List<WeightEntry>> _weights;

  @override
  void initState() {
    super.initState();
    final service = context.read<FirestoreService>();
    _profile = service.watchProfile(widget.uid);
    _weights = service.watchWeights(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.t('userDetails'))),
      body: StreamBuilder<UserProfile?>(
        stream: _profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l.t('adminLoadError')));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          if (profile == null) {
            return Center(child: Text(l.t('noUsersFound')));
          }
          return _Body(profile: profile, weights: _weights);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.profile, required this.weights});

  final UserProfile profile;
  final Stream<List<WeightEntry>> weights;

  Widget _row(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final targets = NutritionService.targets(profile);
    final change = profile.weightKg - profile.startWeightKg;
    final joined = profile.createdAt;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  child: Text(
                    profile.name.trim().isEmpty
                        ? '?'
                        : String.fromCharCode(profile.name.trim().runes.first)
                            .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        '@${profile.username}',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SectionTitle(l.t('profileData')),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _row(context, l.t('gender'), l.t(profile.gender.name)),
                const Divider(),
                _row(context, l.t('ageYears'), '${profile.age}'),
                const Divider(),
                _row(context, l.t('heightCm'), profile.heightCm.toStringAsFixed(0)),
                const Divider(),
                _row(
                  context,
                  l.t('currentWeightKg'),
                  Format.kg(profile.weightKg),
                ),
                const Divider(),
                _row(context, l.t('startWeight'), Format.kg(profile.startWeightKg)),
                const Divider(),
                _row(context, l.t('change'), Format.signedKg(change)),
                const Divider(),
                _row(
                  context,
                  l.t('activityLevel'),
                  l.t('activity_${profile.activity.name}'),
                ),
                const Divider(),
                _row(
                  context,
                  l.t('workoutDaysPerWeek'),
                  '${profile.workoutDays}',
                ),
                const Divider(),
                _row(context, l.t('goal'), l.t('goal_${profile.goal.name}')),
                if (joined != null) ...[
                  const Divider(),
                  _row(context, l.t('joined'), l.formatShortDate(joined)),
                ],
              ],
            ),
          ),
        ),
        SectionTitle(l.t('myNumbers')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                StatBlock(label: l.t('dailyTarget'), value: '${targets.calories}'),
                StatBlock(
                  label: '${l.t('protein')} (${l.t('gramsShort')})',
                  value: '${targets.proteinG}',
                ),
                StatBlock(
                  label: '${l.t('carbs')} (${l.t('gramsShort')})',
                  value: '${targets.carbsG}',
                ),
                StatBlock(
                  label: '${l.t('fat')} (${l.t('gramsShort')})',
                  value: '${targets.fatG}',
                ),
                StatBlock(
                  label: l.t('bmi'),
                  value: NutritionService.bmi(profile).toStringAsFixed(1),
                ),
              ],
            ),
          ),
        ),
        SectionTitle(l.t('weeklyProgress')),
        StreamBuilder<List<WeightEntry>>(
          stream: weights,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(l.t('adminLoadError'));
            }
            final entries = snapshot.data;
            if (entries == null) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (entries.isEmpty) {
              return Text(l.t('noWeightsYet'));
            }
            final newestFirst = entries.reversed.toList();
            return Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: WeightChart(
                      values: [for (final e in entries) e.weightKg],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < newestFirst.length; i++) ...[
                        if (i > 0) const Divider(),
                        _WeightRow(
                          entry: newestFirst[i],
                          previous: i + 1 < newestFirst.length
                              ? newestFirst[i + 1]
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WeightRow extends StatelessWidget {
  const _WeightRow({required this.entry, required this.previous});

  final WeightEntry entry;
  final WeightEntry? previous;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final delta = previous == null ? null : entry.weightKg - previous!.weightKg;
    Color deltaColor = scheme.onSurfaceVariant;
    if (delta != null && delta < -0.049) deltaColor = AppColors.positive;
    if (delta != null && delta > 0.049) deltaColor = scheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.tr('weekOf', {
                'date': l.formatShortDate(WeekUtils.weekStart(entry.weekIndex)),
              }),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${Format.kg(entry.weightKg)} ${l.t('kg')}',
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(
            width: 64,
            child: Text(
              delta == null ? '' : Format.signedKg(delta),
              textAlign: TextAlign.end,
              textDirection: TextDirection.ltr,
              style: TextStyle(fontWeight: FontWeight.w800, color: deltaColor),
            ),
          ),
        ],
      ),
    );
  }
}

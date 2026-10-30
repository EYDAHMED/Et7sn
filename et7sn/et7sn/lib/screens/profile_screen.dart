import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/prayer.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import '../providers/prayer_provider.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../services/firestore_service.dart';
import '../services/nutrition_service.dart';
import '../utils/format.dart';
import '../widgets/common_widgets.dart';
import '../widgets/weight_chart.dart';
import '../widgets/weight_sheet.dart';
import 'edit_profile_screen.dart';

/// Profile, weight history, language / theme settings and sign out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Stream<List<WeightEntry>>? _weights;
  String? _weightsUid;

  Stream<List<WeightEntry>> _weightStream(String uid) {
    if (_weightsUid != uid || _weights == null) {
      _weightsUid = uid;
      _weights = context.read<FirestoreService>().watchWeights(uid);
    }
    return _weights!;
  }

  Future<void> _confirmSignOut() async {
    final l = AppLocalizations.of(context);
    final session = context.read<SessionProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.t('signOut')),
        content: Text(l.t('signOutConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.t('signOut')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await session.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final profile = context.select<SessionProvider, UserProfile?>((s) => s.profile);
    final settings = context.watch<SettingsProvider>();
    final prayer = context.watch<PrayerProvider>();

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final targets = NutritionService.targets(profile);
    final bmi = NutritionService.bmi(profile);
    final change = profile.weightKg - profile.startWeightKg;
    final initial = profile.name.trim().isEmpty
        ? '?'
        : String.fromCharCode(profile.name.trim().runes.first).toUpperCase();

    return Scaffold(
      appBar: AppBar(title: Text(l.t('tabProfile'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: scheme.primary,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimary,
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
                        const SizedBox(height: 2),
                        Text(
                          '@${profile.username}',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        InfoPill(
                          text: l.t('goal_${profile.goal.name}'),
                          icon: Icons.flag_outlined,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l.t('editProfile'),
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionTitle(l.t('myProgress')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatBlock(
                          label: l.t('currentWeightKg'),
                          value: Format.kg(profile.weightKg),
                        ),
                      ),
                      Expanded(
                        child: StatBlock(
                          label: l.t('startWeight'),
                          value: Format.kg(profile.startWeightKg),
                        ),
                      ),
                      Expanded(
                        child: StatBlock(
                          label: l.t('change'),
                          value: Format.signedKg(change),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<WeightEntry>>(
                    stream: _weightStream(profile.uid),
                    builder: (context, snapshot) {
                      final entries = snapshot.data ?? const <WeightEntry>[];
                      if (entries.isEmpty) {
                        return const SizedBox(height: 8);
                      }
                      return WeightChart(
                        values: [for (final e in entries) e.weightKg],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => showWeightSheet(context),
                    icon: const Icon(Icons.monitor_weight_outlined),
                    label: Text(l.t('updateWeight')),
                  ),
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
                  StatBlock(
                    label: l.t('dailyTarget'),
                    value: '${targets.calories}',
                  ),
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
                  StatBlock(label: l.t('bmi'), value: bmi.toStringAsFixed(1)),
                ],
              ),
            ),
          ),
          SectionTitle(l.t('settings')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.t('language'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment<String>(
                          value: 'system',
                          label: Text(l.t('langSystem')),
                        ),
                        const ButtonSegment<String>(
                          value: 'en',
                          label: Text('English'),
                        ),
                        const ButtonSegment<String>(
                          value: 'ar',
                          label: Text('العربية'),
                        ),
                      ],
                      selected: {settings.locale?.languageCode ?? 'system'},
                      showSelectedIcon: false,
                      onSelectionChanged: (value) {
                        final code = value.first;
                        settings.setLocale(code == 'system' ? null : Locale(code));
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.t('theme'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto_outlined),
                          label: Text(l.t('themeSystem')),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode_outlined),
                          label: Text(l.t('themeLight')),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode_outlined),
                          label: Text(l.t('themeDark')),
                        ),
                      ],
                      selected: {settings.themeMode},
                      showSelectedIcon: false,
                      onSelectionChanged: (value) =>
                          settings.setThemeMode(value.first),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.t('prayerMethod'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PrayerMethod>(
                    initialValue: prayer.method,
                    isExpanded: true,
                    items: [
                      for (final method in PrayerMethod.values)
                        DropdownMenuItem<PrayerMethod>(
                          value: method,
                          child: Text(
                            l.t('method_${method.name}'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) prayer.setMethod(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _confirmSignOut,
            icon: const Icon(Icons.logout),
            label: Text(l.t('signOut')),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/session_provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/nutrition_service.dart';
import '../utils/parsing.dart';
import '../widgets/common_widgets.dart';
import '../widgets/profile_fields.dart';

/// First-run profile form. Saving it creates the user's profile, first weight
/// entry and leaderboard row.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  Gender _gender = Gender.male;
  ActivityLevel _activity = ActivityLevel.light;
  int _workoutDays = 3;
  Goal _goal = Goal.lose;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final controller in [_age, _height, _weight]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  /// A profile built from the current inputs, or null when they are incomplete.
  UserProfile? _draft() {
    final age = Parsing.toInt(_age.text);
    final height = Parsing.toDouble(_height.text);
    final weight = Parsing.toDouble(_weight.text);
    if (age == null || age < 10 || age > 100) return null;
    if (height == null || height < 100 || height > 250) return null;
    if (weight == null || weight < 25 || weight > 400) return null;
    final user = context.read<AuthService>().currentUser;
    return UserProfile(
      uid: user?.uid ?? '',
      name: _name.text.trim(),
      username: AuthService.usernameOf(user),
      age: age,
      heightCm: height,
      weightKg: weight,
      startWeightKg: weight,
      gender: _gender,
      activity: _activity,
      workoutDays: _workoutDays,
      goal: _goal,
    );
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final profile = _draft();
    final user = context.read<AuthService>().currentUser;
    if (profile == null || user == null) return;
    final service = context.read<FirestoreService>();

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await service.createProfile(profile);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l.t('errorGeneric');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final draft = _draft();
    final targets = draft == null ? null : NutritionService.targets(draft);
    final session = context.read<SessionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('onboardingTitle')),
        actions: [
          const LanguageMenuButton(),
          IconButton(
            tooltip: l.t('signOut'),
            icon: const Icon(Icons.logout),
            onPressed: session.signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              Text(
                l.t('onboardingSubtitle'),
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l.t('fullName'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty || text.length > 60) return l.t('enterName');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GenderSelector(
                value: _gender,
                onChanged: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _age,
                      label: l.t('ageYears'),
                      integerOnly: true,
                      validator: (value) {
                        final number = Parsing.toInt(value);
                        if (number == null || number < 10 || number > 100) {
                          return l.t('invalidAge');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberField(
                      controller: _height,
                      label: l.t('heightCm'),
                      validator: (value) {
                        final number = Parsing.toDouble(value);
                        if (number == null || number < 100 || number > 250) {
                          return l.t('invalidHeight');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NumberField(
                controller: _weight,
                label: l.t('currentWeightKg'),
                icon: Icons.monitor_weight_outlined,
                validator: (value) {
                  final number = Parsing.toDouble(value);
                  if (number == null || number < 25 || number > 400) {
                    return l.t('invalidWeight');
                  }
                  return null;
                },
              ),
              SectionTitle(l.t('activityLevel')),
              ActivitySelector(
                value: _activity,
                onChanged: (value) => setState(() => _activity = value),
              ),
              SectionTitle(l.t('workoutDaysPerWeek')),
              WorkoutDaysSelector(
                value: _workoutDays,
                onChanged: (value) => setState(() => _workoutDays = value),
              ),
              SectionTitle(l.t('goal')),
              GoalSelector(
                value: _goal,
                onChanged: (value) => setState(() => _goal = value),
              ),
              if (targets != null) ...[
                const SizedBox(height: 22),
                Card(
                  color: scheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.t('yourDailyTarget'),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l.tr('kcalPerDay', {'n': '${targets.calories}'}),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l.t('protein')} ${targets.proteinG} ${l.t('gramsShort')}  ·  '
                          '${l.t('carbs')} ${targets.carbsG} ${l.t('gramsShort')}  ·  '
                          '${l.t('fat')} ${targets.fatG} ${l.t('gramsShort')}',
                          style: TextStyle(color: scheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                ErrorBanner(_error!),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(l.t('getStarted')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.validator,
    this.icon,
    this.integerOnly = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool integerOnly;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !integerOnly),
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(integerOnly ? r'[0-9٠-٩]' : r'[0-9٠-٩.,٫]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
      validator: validator,
    );
  }
}

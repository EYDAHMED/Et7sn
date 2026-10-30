import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/session_provider.dart';
import '../services/firestore_service.dart';
import '../utils/parsing.dart';
import '../widgets/common_widgets.dart';
import '../widgets/profile_fields.dart';

/// Edit the onboarding answers. Weight is changed from the weekly weight sheet
/// so the leaderboard and weight history always stay consistent.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final UserProfile _original;
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _height;
  late Gender _gender;
  late ActivityLevel _activity;
  late int _workoutDays;
  late Goal _goal;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final profile = context.read<SessionProvider>().profile!;
    _original = profile;
    _name = TextEditingController(text: profile.name);
    _age = TextEditingController(text: '${profile.age}');
    _height = TextEditingController(text: profile.heightCm.toStringAsFixed(0));
    _gender = profile.gender;
    _activity = profile.activity;
    _workoutDays = profile.workoutDays;
    _goal = profile.goal;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final service = context.read<FirestoreService>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final updated = _original.copyWith(
      name: _name.text.trim(),
      age: Parsing.toInt(_age.text)!,
      heightCm: Parsing.toDouble(_height.text)!,
      gender: _gender,
      activity: _activity,
      workoutDays: _workoutDays,
      goal: _goal,
    );

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await service.updateProfile(updated);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l.t('profileSaved'))));
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
    return Scaffold(
      appBar: AppBar(title: Text(l.t('editProfile'))),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l.t('fullName'),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty || text.length > 60) return l.t('enterName');
                  return null;
                },
              ),
              const SizedBox(height: 14),
              GenderSelector(
                value: _gender,
                onChanged: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      decoration: InputDecoration(labelText: l.t('ageYears')),
                      validator: (value) {
                        final age = Parsing.toInt(value);
                        if (age == null || age < 10 || age > 100) {
                          return l.t('invalidAge');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _height,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.,٫]')),
                      ],
                      decoration: InputDecoration(labelText: l.t('heightCm')),
                      validator: (value) {
                        final height = Parsing.toDouble(value);
                        if (height == null || height < 100 || height > 250) {
                          return l.t('invalidHeight');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
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
              if (_error != null) ...[
                const SizedBox(height: 14),
                ErrorBanner(_error!),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(l.t('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

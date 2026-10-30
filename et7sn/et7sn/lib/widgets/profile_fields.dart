import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import 'common_widgets.dart';

/// Male / female picker shared by onboarding and profile editing.
class GenderSelector extends StatelessWidget {
  const GenderSelector({super.key, required this.value, required this.onChanged});

  final Gender value;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SegmentedButton<Gender>(
      segments: [
        ButtonSegment<Gender>(
          value: Gender.male,
          icon: const Icon(Icons.male),
          label: Text(l.t('male')),
        ),
        ButtonSegment<Gender>(
          value: Gender.female,
          icon: const Icon(Icons.female),
          label: Text(l.t('female')),
        ),
      ],
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

/// Job / daily activity picker.
class ActivitySelector extends StatelessWidget {
  const ActivitySelector({super.key, required this.value, required this.onChanged});

  final ActivityLevel value;
  final ValueChanged<ActivityLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        for (final level in ActivityLevel.values) ...[
          OptionTile<ActivityLevel>(
            value: level,
            groupValue: value,
            title: l.t('activity_${level.name}'),
            subtitle: l.t('activity_${level.name}_desc'),
            onChanged: onChanged,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Target workout days per week (1-7).
class WorkoutDaysSelector extends StatelessWidget {
  const WorkoutDaysSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var day = 1; day <= 7; day++)
          ChoiceChip(
            label: SizedBox(
              width: 22,
              child: Text('$day', textAlign: TextAlign.center),
            ),
            selected: value == day,
            showCheckmark: false,
            onSelected: (_) => onChanged(day),
          ),
      ],
    );
  }
}

/// Lose / maintain / gain picker.
class GoalSelector extends StatelessWidget {
  const GoalSelector({super.key, required this.value, required this.onChanged});

  final Goal value;
  final ValueChanged<Goal> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        for (final goal in Goal.values) ...[
          OptionTile<Goal>(
            value: goal,
            groupValue: value,
            title: l.t('goal_${goal.name}'),
            subtitle: l.t('goal_${goal.name}_desc'),
            onChanged: onChanged,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

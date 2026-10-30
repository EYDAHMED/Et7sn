import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/ingredient_catalog.dart';
import '../l10n/app_localizations.dart';
import '../models/meal.dart';
import '../models/nutrition.dart';
import '../providers/diet_provider.dart';
import '../providers/session_provider.dart';
import '../services/nutrition_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Daily targets and the day's meal plan with the Skip button.
class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync();
  }

  void _sync() {
    if (!mounted) return;
    final profile = context.read<SessionProvider>().profile;
    if (profile != null) {
      context.read<DietProvider>().ensureLoaded(profile.uid);
    }
  }

  Future<void> _skip(MealSlot slot, NutritionTargets targets) async {
    final l = AppLocalizations.of(context);
    final diet = context.read<DietProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final replacement = await diet.skip(slot, targets);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l.tr('mealReplaced', {'name': l.pick(replacement.template.name)}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final profile = context.watch<SessionProvider>().profile;
    final diet = context.watch<DietProvider>();
    if (profile == null) return const SizedBox.shrink();

    final targets = NutritionService.targets(profile);
    final meals = [
      for (final slot in MealSlot.values) diet.planned(slot, targets),
    ];
    final totals = DayTotals.of(meals);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('todaysPlan')),
        bottom: diet.loading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            l.tr('hello', {'name': profile.name.split(' ').first}),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            l.formatDate(DateTime.now()),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          _TargetCard(targets: targets, totals: totals),
          const SizedBox(height: 6),
          for (final meal in meals) ...[
            const SizedBox(height: 12),
            _MealCard(
              slot: meal.template.slot,
              meal: meal,
              onSkip: () => _skip(meal.template.slot, targets),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            l.t('dietDisclaimer'),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.targets, required this.totals});

  final NutritionTargets targets;
  final DayTotals totals;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const onDark = AppColors.white;
    final progress = targets.calories <= 0
        ? 0.0
        : (totals.kcal / targets.calories).clamp(0.0, 1.0).toDouble();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.oliveDark, AppColors.olive],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_outlined, color: onDark),
              const SizedBox(width: 8),
              Text(
                l.t('dailyTarget'),
                style: const TextStyle(
                  color: onDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l.tr('kcalPerDay', {'n': '${targets.calories}'}),
            style: const TextStyle(
              color: onDark,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: onDark.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldBright),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.tr('plannedOf', {
              'planned': totals.kcal.round().toString(),
              'target': '${targets.calories}',
            }),
            style: TextStyle(color: onDark.withValues(alpha: 0.85), fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MacroBox(
                label: l.t('protein'),
                target: targets.proteinG,
                planned: totals.protein,
              ),
              const SizedBox(width: 10),
              _MacroBox(
                label: l.t('carbs'),
                target: targets.carbsG,
                planned: totals.carbs,
              ),
              const SizedBox(width: 10),
              _MacroBox(
                label: l.t('fat'),
                target: targets.fatG,
                planned: totals.fat,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l.tr('bmrTdee', {
              'bmr': targets.bmr.round().toString(),
              'tdee': targets.tdee.round().toString(),
            }),
            style: TextStyle(color: onDark.withValues(alpha: 0.8), fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _MacroBox extends StatelessWidget {
  const _MacroBox({
    required this.label,
    required this.target,
    required this.planned,
  });

  final String label;
  final int target;
  final double planned;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$target ${l.t('gramsShort')}',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              '${planned.round()} ${l.t('planned')}',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.75),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.slot,
    required this.meal,
    required this.onSkip,
  });

  final MealSlot slot;
  final PlannedMeal meal;
  final VoidCallback onSkip;

  IconData get _icon {
    switch (slot) {
      case MealSlot.breakfast:
        return Icons.free_breakfast_outlined;
      case MealSlot.lunch:
        return Icons.lunch_dining_outlined;
      case MealSlot.snack:
        return Icons.fastfood_outlined;
      case MealSlot.dinner:
        return Icons.dinner_dining_outlined;
    }
  }

  String _amountText(IngredientAmount item, AppLocalizations l) {
    final ingredient = IngredientCatalog.of(item.ingredientId);
    final amount = item.amount;
    final number = amount == amount.roundToDouble()
        ? amount.round().toString()
        : amount.toStringAsFixed(1);
    final String quantity;
    switch (ingredient.unit) {
      case IngredientUnit.gram:
        quantity = '$number ${l.t('unitGram')}';
        break;
      case IngredientUnit.ml:
        quantity = '$number ${l.t('unitMl')}';
        break;
      case IngredientUnit.piece:
        quantity = '$number ${l.t('unitPiece')}';
        break;
    }
    return '$quantity  ·  ${l.pick(ingredient.name)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, size: 20, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.t('slot_${slot.name}'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                InfoPill(
                  text: l.tr('kcalShort', {'n': '${meal.kcal.round()}'}),
                  icon: Icons.local_fire_department_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l.pick(meal.template.name),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                InfoPill(
                  text: '${l.t('protein')} ${meal.protein.round()} ${l.t('gramsShort')}',
                  color: AppColors.gold,
                ),
                InfoPill(
                  text: '${l.t('carbs')} ${meal.carbs.round()} ${l.t('gramsShort')}',
                ),
                InfoPill(
                  text: '${l.t('fat')} ${meal.fat.round()} ${l.t('gramsShort')}',
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(
                  l.t('ingredientsAndSteps'),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                expandedAlignment: AlignmentDirectional.centerStart,
                children: [
                  for (final item in meal.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Icon(Icons.circle, size: 6, color: scheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_amountText(item, l))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    l.pick(meal.template.howTo),
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSkip,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: Text(l.t('skipMeal')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

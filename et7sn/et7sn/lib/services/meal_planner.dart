import '../data/ingredient_catalog.dart';
import '../data/meal_library.dart';
import '../models/meal.dart';

/// Scales meal templates to calorie targets and finds equivalent replacements.
class MealPlanner {
  MealPlanner._();

  static double _baseKcal(MealTemplate template) {
    double total = 0;
    for (final item in template.items) {
      final ingredient = IngredientCatalog.of(item.ingredientId);
      total += ingredient.kcal * ingredient.factor(item.amount);
    }
    return total;
  }

  /// Scales [template] so that it provides roughly [targetKcal] calories,
  /// rounding each ingredient to a practical portion size.
  static PlannedMeal scale(MealTemplate template, double targetKcal) {
    final base = _baseKcal(template);
    final factor = base <= 0 ? 1.0 : targetKcal / base;

    final items = <IngredientAmount>[];
    double kcal = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    for (final item in template.items) {
      final ingredient = IngredientCatalog.of(item.ingredientId);
      double amount = (item.amount * factor / ingredient.step).round() *
          ingredient.step;
      if (amount < ingredient.step) amount = ingredient.step;
      items.add(IngredientAmount(ingredient.id, amount));

      final f = ingredient.factor(amount);
      kcal += ingredient.kcal * f;
      protein += ingredient.protein * f;
      carbs += ingredient.carbs * f;
      fat += ingredient.fat * f;
    }

    return PlannedMeal(
      template: template,
      items: items,
      kcal: kcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }

  /// Picks the replacement for [current] whose protein (at the same calorie
  /// target) is closest to the current meal's protein. Meals in [seenIds]
  /// are avoided until every option of the slot has been shown once.
  static MealTemplate alternative({
    required MealSlot slot,
    required MealTemplate current,
    required double targetKcal,
    required List<String> seenIds,
  }) {
    final currentProtein = scale(current, targetKcal).protein;
    final options =
        MealLibrary.forSlot(slot).where((m) => m.id != current.id).toList();
    var pool = options.where((m) => !seenIds.contains(m.id)).toList();
    if (pool.isEmpty) pool = options;

    MealTemplate best = pool.first;
    double bestDiff = double.infinity;
    for (final candidate in pool) {
      final diff = (scale(candidate, targetKcal).protein - currentProtein).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = candidate;
      }
    }
    return best;
  }
}

import 'localized_text.dart';

enum MealSlot { breakfast, lunch, snack, dinner }

extension MealSlotShare on MealSlot {
  /// Share of the daily calorie target assigned to this slot.
  double get share {
    switch (this) {
      case MealSlot.breakfast:
        return 0.25;
      case MealSlot.lunch:
        return 0.35;
      case MealSlot.snack:
        return 0.15;
      case MealSlot.dinner:
        return 0.25;
    }
  }
}

enum IngredientUnit { gram, ml, piece }

/// A food item. Nutrition values are per 100 g / 100 ml, or per 1 piece
/// when [unit] is [IngredientUnit.piece].
class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.step,
  });

  final String id;
  final LocalizedText name;
  final IngredientUnit unit;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  /// Smallest portion increment used when scaling (e.g. 5 g, 1 egg).
  final double step;

  /// Multiplier applied to the per-100 (or per-piece) values for [amount].
  double factor(double amount) =>
      unit == IngredientUnit.piece ? amount : amount / 100;
}

class IngredientAmount {
  const IngredientAmount(this.ingredientId, this.amount);

  final String ingredientId;
  final double amount;
}

/// A reusable meal recipe at its base portion size.
class MealTemplate {
  const MealTemplate({
    required this.id,
    required this.slot,
    required this.name,
    required this.howTo,
    required this.items,
  });

  final String id;
  final MealSlot slot;
  final LocalizedText name;
  final LocalizedText howTo;
  final List<IngredientAmount> items;
}

/// A meal scaled to a calorie target, with its resulting nutrition.
class PlannedMeal {
  const PlannedMeal({
    required this.template,
    required this.items,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final MealTemplate template;
  final List<IngredientAmount> items;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
}

class DayTotals {
  const DayTotals({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  factory DayTotals.of(Iterable<PlannedMeal> meals) {
    double kcal = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    for (final meal in meals) {
      kcal += meal.kcal;
      protein += meal.protein;
      carbs += meal.carbs;
      fat += meal.fat;
    }
    return DayTotals(kcal: kcal, protein: protein, carbs: carbs, fat: fat);
  }
}

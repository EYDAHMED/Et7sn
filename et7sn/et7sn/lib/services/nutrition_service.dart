import 'dart:math' as math;

import '../models/nutrition.dart';
import '../models/user_profile.dart';

/// Calorie and macro calculations.
///
/// * BMR uses the Mifflin-St Jeor equation.
/// * TDEE = BMR x activity factor (job type + planned workout days).
/// * Calories are adjusted for the goal (-500 / 0 / +400 kcal) with safety floors.
/// * Protein is set per kg of body weight, fat is 25 % of calories and the
///   remaining calories go to carbohydrates.
class NutritionService {
  NutritionService._();

  static double bmr(UserProfile profile) {
    final base = 10 * profile.weightKg +
        6.25 * profile.heightCm -
        5 * profile.age;
    return profile.gender == Gender.male ? base + 5 : base - 161;
  }

  static double jobFactor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.3;
      case ActivityLevel.moderate:
        return 1.4;
      case ActivityLevel.heavy:
        return 1.5;
    }
  }

  static double activityFactor(ActivityLevel level, int workoutDays) {
    final days = math.max(0, math.min(7, workoutDays));
    return math.min(1.9, jobFactor(level) + 0.05 * days);
  }

  static NutritionTargets targets(UserProfile profile) {
    final bmrValue = bmr(profile);
    final factor = activityFactor(profile.activity, profile.workoutDays);
    final tdee = bmrValue * factor;

    double calories;
    switch (profile.goal) {
      case Goal.lose:
        final floor = profile.gender == Gender.male ? 1500.0 : 1200.0;
        calories = math.max(tdee - 500, math.min(floor, tdee));
        break;
      case Goal.maintain:
        calories = tdee;
        break;
      case Goal.gain:
        calories = tdee + 400;
        break;
    }
    final roundedCalories = math.max(1000, (calories / 10).round() * 10);

    final proteinPerKg = switch (profile.goal) {
      Goal.lose => 2.0,
      Goal.maintain => 1.6,
      Goal.gain => 1.8,
    };
    final proteinCap = roundedCalories * 0.35 / 4;
    final proteinG = math.min(profile.weightKg * proteinPerKg, proteinCap).round();
    final fatG = (roundedCalories * 0.25 / 9).round();
    final carbCalories = roundedCalories - proteinG * 4 - fatG * 9;
    final carbsG = math.max(0, (carbCalories / 4).round());

    return NutritionTargets(
      bmr: bmrValue,
      activityFactor: factor,
      tdee: tdee,
      calories: roundedCalories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
    );
  }

  /// Body-mass index (kg/m²).
  static double bmi(UserProfile profile) {
    final meters = profile.heightCm / 100;
    if (meters <= 0) return 0;
    return profile.weightKg / (meters * meters);
  }
}

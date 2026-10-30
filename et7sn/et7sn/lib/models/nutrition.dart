/// Daily energy and macro targets calculated from a user's profile.
class NutritionTargets {
  const NutritionTargets({
    required this.bmr,
    required this.activityFactor,
    required this.tdee,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  /// Basal metabolic rate (kcal/day, Mifflin-St Jeor).
  final double bmr;

  /// Multiplier applied to BMR to get TDEE.
  final double activityFactor;

  /// Total daily energy expenditure (kcal/day).
  final double tdee;

  /// Daily calorie target after applying the user's goal.
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
}

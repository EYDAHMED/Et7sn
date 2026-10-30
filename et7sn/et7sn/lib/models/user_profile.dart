import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female }

enum ActivityLevel { sedentary, light, moderate, heavy }

enum Goal { lose, maintain, gain }

T enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

double _asDouble(Object? value, [double fallback = 0]) =>
    value is num ? value.toDouble() : fallback;

int _asInt(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.startWeightKg,
    required this.gender,
    required this.activity,
    required this.workoutDays,
    required this.goal,
    this.onboardingComplete = true,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final String username;
  final int age;
  final double heightCm;
  final double weightKg;
  final double startWeightKg;
  final Gender gender;
  final ActivityLevel activity;
  final int workoutDays;
  final Goal goal;
  final bool onboardingComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    final weight = _asDouble(map['weightKg']);
    return UserProfile(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      username: (map['username'] as String?) ?? '',
      age: _asInt(map['age']),
      heightCm: _asDouble(map['heightCm']),
      weightKg: weight,
      startWeightKg: _asDouble(map['startWeightKg'], weight),
      gender: enumByName(Gender.values, map['gender'], Gender.male),
      activity: enumByName(
        ActivityLevel.values,
        map['activity'],
        ActivityLevel.light,
      ),
      workoutDays: _asInt(map['workoutDays'], 3),
      goal: enumByName(Goal.values, map['goal'], Goal.lose),
      onboardingComplete: (map['onboardingComplete'] as bool?) ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Fields stored in Firestore. Timestamps are added by the service layer.
  Map<String, dynamic> toMap() => {
        'name': name,
        'username': username,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'startWeightKg': startWeightKg,
        'gender': gender.name,
        'activity': activity.name,
        'workoutDays': workoutDays,
        'goal': goal.name,
        'onboardingComplete': onboardingComplete,
      };

  UserProfile copyWith({
    String? name,
    int? age,
    double? heightCm,
    double? weightKg,
    Gender? gender,
    ActivityLevel? activity,
    int? workoutDays,
    Goal? goal,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      username: username,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      startWeightKg: startWeightKg,
      gender: gender ?? this.gender,
      activity: activity ?? this.activity,
      workoutDays: workoutDays ?? this.workoutDays,
      goal: goal ?? this.goal,
      onboardingComplete: onboardingComplete,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

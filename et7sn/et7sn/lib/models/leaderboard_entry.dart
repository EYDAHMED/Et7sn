import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_profile.dart';

enum LeaderboardMode { week, overall }

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.goal,
    required this.startWeightKg,
    required this.currentWeightKg,
    required this.prevWeightKg,
    required this.weekIndex,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final Goal goal;
  final double startWeightKg;
  final double currentWeightKg;

  /// Weight at the end of the previous week (baseline for the weekly board).
  final double prevWeightKg;

  /// Week of the latest weight update.
  final int weekIndex;
  final DateTime? updatedAt;

  factory LeaderboardEntry.fromMap(String uid, Map<String, dynamic> map) {
    double number(Object? v) => v is num ? v.toDouble() : 0;
    return LeaderboardEntry(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      goal: enumByName(Goal.values, map['goal'], Goal.lose),
      startWeightKg: number(map['startWeightKg']),
      currentWeightKg: number(map['currentWeightKg']),
      prevWeightKg: number(map['prevWeightKg']),
      weekIndex: (map['weekIndex'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Signed weight change in kg (negative = lost weight).
  double changeKg(LeaderboardMode mode, int currentWeek) {
    if (mode == LeaderboardMode.week) {
      if (weekIndex != currentWeek) return 0;
      return currentWeightKg - prevWeightKg;
    }
    return currentWeightKg - startWeightKg;
  }

  /// Ranking score (higher is better) which respects each member's goal:
  /// losing weight for "lose", gaining for "gain", staying stable for "maintain".
  double score(LeaderboardMode mode, int currentWeek) {
    final change = changeKg(mode, currentWeek);
    switch (goal) {
      case Goal.lose:
        return -change;
      case Goal.gain:
        return change;
      case Goal.maintain:
        return -change.abs();
    }
  }

  bool updatedThisWeek(int currentWeek) => weekIndex == currentWeek;
}

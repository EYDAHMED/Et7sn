import 'package:cloud_firestore/cloud_firestore.dart';

/// One weekly weight check-in (document id "w<weekIndex>").
class WeightEntry {
  const WeightEntry({
    required this.weekIndex,
    required this.weightKg,
    this.recordedAt,
  });

  final int weekIndex;
  final double weightKg;
  final DateTime? recordedAt;

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      weekIndex: (map['weekIndex'] as num?)?.toInt() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0,
      recordedAt: (map['recordedAt'] as Timestamp?)?.toDate(),
    );
  }
}

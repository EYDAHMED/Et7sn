import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/meal_library.dart';
import '../models/meal.dart';
import '../models/nutrition.dart';
import '../services/firestore_service.dart';
import '../services/meal_planner.dart';
import '../utils/week_utils.dart';

/// Holds today's meal selection per slot and handles the "Skip" action.
class DietProvider extends ChangeNotifier {
  DietProvider(this._db);

  final FirestoreService _db;

  String? _uid;
  String _dateKey = '';
  bool _loading = false;
  final Map<MealSlot, String> _selected = {};
  final Map<MealSlot, List<String>> _seen = {};

  bool get loading => _loading;

  /// Loads (or reloads after midnight / a user change) today's selections.
  Future<void> ensureLoaded(String uid) async {
    final key = WeekUtils.dateKey(DateTime.now());
    if (_uid == uid && _dateKey == key) return;

    _uid = uid;
    _dateKey = key;
    _loading = true;
    _selected.clear();
    _seen.clear();
    notifyListeners();

    Map<String, dynamic>? data;
    try {
      data = await _db.loadMealDay(uid, key);
    } catch (_) {
      data = null;
    }
    if (_uid != uid || _dateKey != key) return;

    final selected = data?['selected'];
    final seen = data?['seen'];
    for (final slot in MealSlot.values) {
      final id = selected is Map ? selected[slot.name] : null;
      if (id is String) {
        final template = MealLibrary.byId(id);
        if (template != null && template.slot == slot) {
          _selected[slot] = id;
        }
      }
      final seenIds = seen is Map ? seen[slot.name] : null;
      if (seenIds is List) {
        _seen[slot] = seenIds.whereType<String>().toList();
      }
    }
    _loading = false;
    notifyListeners();
  }

  MealTemplate _templateFor(MealSlot slot) {
    final id = _selected[slot];
    final found = id == null ? null : MealLibrary.byId(id);
    return found ??
        MealLibrary.defaultFor(slot, WeekUtils.dayNumber(DateTime.now()));
  }

  PlannedMeal planned(MealSlot slot, NutritionTargets targets) {
    return MealPlanner.scale(_templateFor(slot), targets.calories * slot.share);
  }

  /// Replaces the meal in [slot] with an alternative that has the same
  /// calories and the closest protein, and returns the new meal.
  Future<PlannedMeal> skip(MealSlot slot, NutritionTargets targets) async {
    final current = _templateFor(slot);
    final target = targets.calories * slot.share;

    final seen = List<String>.of(_seen[slot] ?? const <String>[]);
    if (!seen.contains(current.id)) seen.add(current.id);

    final next = MealPlanner.alternative(
      slot: slot,
      current: current,
      targetKcal: target,
      seenIds: seen,
    );
    if (!seen.contains(next.id)) seen.add(next.id);
    if (seen.length >= MealLibrary.forSlot(slot).length) {
      seen
        ..clear()
        ..add(next.id);
    }

    _selected[slot] = next.id;
    _seen[slot] = seen;
    notifyListeners();

    final uid = _uid;
    if (uid != null) {
      unawaited(
        _db
            .saveMealDay(
              uid,
              _dateKey,
              {for (final e in _selected.entries) e.key.name: e.value},
              {for (final e in _seen.entries) e.key.name: e.value},
            )
            .catchError((Object _) {}),
      );
    }
    return MealPlanner.scale(next, target);
  }
}

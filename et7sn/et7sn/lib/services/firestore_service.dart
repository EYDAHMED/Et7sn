import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/leaderboard_entry.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import '../utils/week_utils.dart';

/// All Firestore access lives here.
///
/// Collections:
/// * `users/{uid}`                    profile data (owner + admin can read)
/// * `users/{uid}/weights/{w<week>}`  weekly weight check-ins
/// * `users/{uid}/mealDays/{date}`    the user's chosen meals for a day
/// * `leaderboard/{uid}`              public summary used by the leaderboard
/// * `admins/{uid}`                   existence of this document = super admin
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _weights(String uid) =>
      _userRef(uid).collection('weights');

  DocumentReference<Map<String, dynamic>> _leaderRef(String uid) =>
      _db.collection('leaderboard').doc(uid);

  // ------------------------------------------------------------------ Reads

  Stream<UserProfile?> watchProfile(String uid) {
    return _userRef(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return UserProfile.fromMap(uid, data);
    });
  }

  Stream<bool> watchIsAdmin(String uid) {
    return _db
        .collection('admins')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Stream<List<LeaderboardEntry>> watchLeaderboard() {
    return _db.collection('leaderboard').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<UserProfile>> watchAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      final users = snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.id, doc.data()))
          .toList();
      users.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return users;
    });
  }

  Stream<List<WeightEntry>> watchWeights(String uid) {
    return _weights(uid).orderBy('weekIndex').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => WeightEntry.fromMap(doc.data()))
          .toList();
    });
  }

  // ----------------------------------------------------------------- Writes

  /// Creates the profile, the first weight entry and the leaderboard row.
  Future<void> createProfile(UserProfile profile) async {
    final week = WeekUtils.weekIndex(DateTime.now());
    final batch = _db.batch();
    batch.set(_userRef(profile.uid), {
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      _weights(profile.uid).doc(WeekUtils.weekDocId(week)),
      _weightData(profile.weightKg, week),
    );
    batch.set(
      _leaderRef(profile.uid),
      _leaderData(
        profile: profile,
        current: profile.weightKg,
        prev: profile.weightKg,
        week: week,
      ),
    );
    await _commit(batch);
  }

  /// Updates editable profile fields and keeps the leaderboard name/goal in sync.
  Future<void> updateProfile(UserProfile profile) async {
    final batch = _db.batch();
    batch.set(
      _userRef(profile.uid),
      {
        ...profile.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _leaderRef(profile.uid),
      {
        'name': profile.name,
        'goal': profile.goal.name,
      },
      SetOptions(merge: true),
    );
    await _commit(batch);
  }

  /// Records this week's weight (replacing an earlier entry from the same
  /// week), updates the profile and refreshes the leaderboard row.
  Future<void> saveWeight({
    required UserProfile profile,
    required double weightKg,
  }) async {
    final week = WeekUtils.weekIndex(DateTime.now());

    // Baseline for the weekly board = the latest weight from a previous week.
    double prev = profile.startWeightKg;
    try {
      final previous = await _weights(profile.uid)
          .where('weekIndex', isLessThan: week)
          .orderBy('weekIndex', descending: true)
          .limit(1)
          .get();
      if (previous.docs.isNotEmpty) {
        final value = previous.docs.first.data()['weightKg'];
        if (value is num) prev = value.toDouble();
      }
    } catch (_) {
      // Fall back to the starting weight when offline or not yet indexed.
    }

    final batch = _db.batch();
    batch.set(
      _weights(profile.uid).doc(WeekUtils.weekDocId(week)),
      _weightData(weightKg, week),
    );
    batch.set(
      _userRef(profile.uid),
      {
        'weightKg': weightKg,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _leaderRef(profile.uid),
      _leaderData(
        profile: profile,
        current: weightKg,
        prev: prev,
        week: week,
      ),
    );
    await _commit(batch);
  }

  Future<Map<String, dynamic>?> loadMealDay(String uid, String dateKey) async {
    final snapshot = await _userRef(uid).collection('mealDays').doc(dateKey).get();
    return snapshot.data();
  }

  Future<void> saveMealDay(
    String uid,
    String dateKey,
    Map<String, String> selected,
    Map<String, List<String>> seen,
  ) {
    return _userRef(uid).collection('mealDays').doc(dateKey).set({
      'selected': selected,
      'seen': seen,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------------------------------------------------------------- Helpers

  Map<String, dynamic> _weightData(double weightKg, int week) => {
        'weightKg': weightKg,
        'weekIndex': week,
        'weekStart': WeekUtils.dateKey(WeekUtils.weekStart(week)),
        'recordedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> _leaderData({
    required UserProfile profile,
    required double current,
    required double prev,
    required int week,
  }) =>
      {
        'name': profile.name,
        'goal': profile.goal.name,
        'startWeightKg': profile.startWeightKg,
        'currentWeightKg': current,
        'prevWeightKg': prev,
        'weekIndex': week,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Firestore queues writes locally when the device is offline, so a commit
  /// that has not been acknowledged after a while is treated as "saved, will
  /// sync later" instead of leaving the UI waiting forever.
  Future<void> _commit(WriteBatch batch) {
    return batch.commit().timeout(
      const Duration(seconds: 12),
      onTimeout: () {},
    );
  }
}

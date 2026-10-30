import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum SessionStatus { loading, signedOut, needsOnboarding, ready, error }

/// Tracks who is signed in, their profile, and whether they are the super admin.
class SessionProvider extends ChangeNotifier {
  SessionProvider(this._auth, this._db) {
    _authSub = _auth.authChanges.listen(
      _onAuthChanged,
      onError: (Object error) {
        _authResolved = true;
        _error = error;
        notifyListeners();
      },
    );
  }

  final AuthService _auth;
  final FirestoreService _db;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserProfile?>? _profileSub;
  StreamSubscription<bool>? _adminSub;

  User? _user;
  UserProfile? _profile;
  bool _isAdmin = false;
  bool _authResolved = false;
  bool _profileResolved = false;
  Object? _error;

  User? get user => _user;

  UserProfile? get profile => _profile;

  bool get isAdmin => _isAdmin;

  Object? get error => _error;

  SessionStatus get status {
    if (_error != null) return SessionStatus.error;
    if (!_authResolved) return SessionStatus.loading;
    if (_user == null) return SessionStatus.signedOut;
    if (!_profileResolved) return SessionStatus.loading;
    final profile = _profile;
    if (profile == null || !profile.onboardingComplete) {
      return SessionStatus.needsOnboarding;
    }
    return SessionStatus.ready;
  }

  void _onAuthChanged(User? user) {
    _profileSub?.cancel();
    _adminSub?.cancel();
    _profileSub = null;
    _adminSub = null;

    _user = user;
    _profile = null;
    _isAdmin = false;
    _profileResolved = false;
    _error = null;
    _authResolved = true;

    if (user != null) {
      _profileSub = _db.watchProfile(user.uid).listen(
        (profile) {
          _profile = profile;
          _profileResolved = true;
          notifyListeners();
        },
        onError: (Object error) {
          _error = error;
          _profileResolved = true;
          notifyListeners();
        },
      );
      _adminSub = _db.watchIsAdmin(user.uid).listen(
        (isAdmin) {
          _isAdmin = isAdmin;
          notifyListeners();
        },
        onError: (Object _) {
          _isAdmin = false;
          notifyListeners();
        },
      );
    }
    notifyListeners();
  }

  /// Re-subscribes after a profile loading error (for example a missing rule).
  void retry() {
    _onAuthChanged(_auth.currentUser);
  }

  Future<void> signOut() => _auth.signOut();

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    _adminSub?.cancel();
    super.dispose();
  }
}

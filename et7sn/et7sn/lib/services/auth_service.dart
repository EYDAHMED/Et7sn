import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication with a simple username + password sign-in.
///
/// Firebase Auth identifies accounts by e-mail, so the username is mapped to a
/// private internal address (`<username>@et7sn.app`). Users never see or type an
/// e-mail and no verification message is ever sent.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  static const String internalDomain = 'et7sn.app';

  final FirebaseAuth _auth;

  Stream<User?> get authChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  static String normalize(String username) => username.trim().toLowerCase();

  static String _emailFor(String username) =>
      '${normalize(username)}@$internalDomain';

  /// The username shown in the app for a signed-in [user].
  static String usernameOf(User? user) {
    final email = user?.email ?? '';
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  Future<void> signIn(String username, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: _emailFor(username),
      password: password,
    );
  }

  Future<void> register(String username, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: _emailFor(username),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();
}

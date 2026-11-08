import 'package:firebase_auth/firebase_auth.dart';

/// Authentication failure with a message safe to show to the student.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Maps a Firebase Auth error code to a friendly message.
String friendlyAuthMessage(String? code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found for this email. Please sign up first.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password. Please try again.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'email-already-in-use':
      return 'An account already exists for this email. Please log in.';
    case 'weak-password':
      return 'Password is too weak — use at least 6 characters.';
    case 'user-disabled':
      return 'This account has been disabled. Please contact support.';
    case 'network-request-failed':
      return 'Network error. Check your internet connection and try again.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a little and try again.';
    case 'operation-not-allowed':
      return 'Email sign-in is not enabled right now. Please try later.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

/// Thin wrapper over FirebaseAuth so screens can be tested with fakes.
///
/// Implementations throw [AuthException] with friendly messages.
abstract class AuthService {
  /// Emits the signed-in user's uid, or null when signed out.
  Stream<String?> get authStateChanges;

  String? get currentUid;

  /// Signs in and returns the user's uid.
  Future<String> signIn({required String email, required String password});

  /// Creates the account and returns the new user's uid.
  /// (The profile document is written separately via PortalRepository.)
  Future<String> signUp({required String email, required String password});

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<String?> get authStateChanges =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(friendlyAuthMessage(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(friendlyAuthMessage(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(friendlyAuthMessage(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

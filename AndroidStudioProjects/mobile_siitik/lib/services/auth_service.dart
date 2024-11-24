import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: '272944052495-5979iuncr0ek5a198g7pdav572qm2tk0.apps.googleusercontent.com' // Client ID dari google-services.json
  );

  // Stream untuk mendengarkan status autentikasi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in dengan email dan password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return credential;
    } catch (e) {
      print('Error signing in: $e');
      rethrow; // Melempar error untuk ditangani di UI
    }
  }

  // Cek apakah email sudah terdaftar
  Future<bool> isEmailRegistered(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty; // Returns true if email is already registered
    } catch (e) {
      print('Error checking email registration: $e');
      rethrow;
    }
  }

  // Register dengan email dan password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Lakukan registrasi
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name (username)
      await userCredential.user?.updateDisplayName(username);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error registering user: $e');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  // Sign in dengan Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'cancelled',
          message: 'Sign in dibatalkan'
      );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Coba register user baru
      try {
        return await _auth.createUserWithEmailAndPassword(
            email: googleUser.email,
            password: 'google-${DateTime.now().millisecondsSinceEpoch}'
        );
      } catch (e) {
        // Jika email sudah ada, coba sign in
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      print('Detailed error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }
}
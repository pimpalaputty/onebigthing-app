import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: SupabaseConfig.googleClientId,
    scopes: <String>['email', 'profile'],
  );

  // Google bejelentkezés - Supabase OAuth használata
  static Future<bool> signInWithGoogle() async {
    try {
      // Supabase OAuth bejelentkezés (web kompatibilis)
      final bool success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
      );

      return success;
    } catch (e) {
      // Google sign in error: $e
      print('Google sign in error: $e');
      return false;
    }
  }

  // Kijelentkezés
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
    } catch (e) {
      // Sign out error: $e
    }
  }

  // Jelenlegi felhasználó
  static User? get currentUser => _supabase.auth.currentUser;

  // Auth state stream
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Be van-e jelentkezve
  static bool get isSignedIn => currentUser != null;
}

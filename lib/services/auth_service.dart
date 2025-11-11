import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/supabase_config.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final Logger _logger = Logger();

  // Google Sign-In instance (singleton pattern for v7.x)
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Initialize Google Sign-In (call this at app startup)
  static Future<void> initializeGoogleSignIn() async {
    try {
      // Web platform doesn't support serverClientId parameter
      // It reads the client ID from the meta tag in index.html
      if (kIsWeb) {
        await _googleSignIn.initialize();
      } else {
        // Mobile platforms (iOS, Android) need serverClientId
        await _googleSignIn.initialize(
          serverClientId: SupabaseConfig.googleWebClientId,
        );
      }
      _logger.i('Google Sign-In initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Google Sign-In: $e');
    }
  }

  // Google Sign-In authentication
  static Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web platform: Use Supabase OAuth (redirect flow)
        // This provides the best UX with Google One Tap on web
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'eu.manodesign.onebigthing_app://auth/callback',
        );

        // OAuth redirects to Google, so we return true immediately
        // The actual auth happens after redirect
        _logger.i('Google OAuth initiated');
        return true;
      } else {
        // Mobile platforms: Use native Google Sign-In
        final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

        if (googleUser == null) {
          _logger.w('Google Sign-In cancelled by user');
          return false;
        }

        // Get authentication details (idToken only in v7.x)
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken == null) {
          _logger.e('Failed to get ID token from Google Sign-In');
          return false;
        }

        // Sign in to Supabase with Google credentials
        final AuthResponse response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );

        if (response.user != null) {
          _logger.i('Successfully signed in with Google: ${response.user!.email}');
          return true;
        } else {
          _logger.e('Failed to authenticate with Supabase');
          return false;
        }
      }
    } catch (e) {
      _logger.e('Google Sign-In error: $e');
      return false;
    }
  }

  // Magic link küldése email címre
  static Future<bool> sendMagicLink(String email) async {
    try {
      // Email cím validáció
      if (email.isEmpty || !_isValidEmail(email)) {
        _logger.w('Invalid email address: $email');
        return false;
      }

      // Magic link küldése OTP-vel
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb
            ? null
            : 'eu.manodesign.onebigthing_app://auth/confirm',
      );

      _logger.i('Magic link sent successfully to: $email');
      return true;
    } catch (e) {
      _logger.e('Failed to send magic link: $e');
      return false;
    }
  }

  // Email cím validáció
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // OTP token ellenőrzése (opcionális, ha nem magic link-et használsz)
  static Future<bool> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      if (response.user != null) {
        _logger.i('OTP verified successfully for: $email');
        return true;
      } else {
        _logger.e('OTP verification failed');
        return false;
      }
    } catch (e) {
      _logger.e('OTP verification error: $e');
      return false;
    }
  }

  // Kijelentkezés
  static Future<void> signOut() async {
    try {
      // Sign out from Google Sign-In first
      await _googleSignIn.signOut();
      // Then sign out from Supabase
      await _supabase.auth.signOut();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }

  // Jelenlegi felhasználó
  static User? get currentUser => _supabase.auth.currentUser;

  // Auth state stream
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Be van-e jelentkezve
  static bool get isSignedIn => currentUser != null;
}

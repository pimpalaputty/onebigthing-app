import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final Logger _logger = Logger();

  // Google Sign-In v7.x - uses singleton instance
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isInitialized = false;

  // Initialize Google Sign-In (required for v7.x)
  // Must be called before any other Google Sign-In methods
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Platform-specific initialization
      await _googleSignIn.initialize(
        clientId: kIsWeb ? SupabaseConfig.googleClientId : null,
        serverClientId: kIsWeb ? SupabaseConfig.googleClientId : SupabaseConfig.googleAndroidClientId,
      );
      _isInitialized = true;
      _logger.i('Google Sign-In initialized successfully');

      // Listen to authentication events (v7.x pattern)
      _googleSignIn.authenticationEvents.listen(
        (event) {
          // Pattern match on authentication event type
          final user = switch (event) {
            GoogleSignInAuthenticationEventSignIn(:final user) => user,
            GoogleSignInAuthenticationEventSignOut() => null,
          };
          _logger.d('Auth event: ${user?.email ?? "signed out"}');
        },
        onError: (error) {
          _logger.e('Auth event error: $error');
        },
      );
    } catch (e) {
      _logger.e('Failed to initialize Google Sign-In: $e');
      rethrow;
    }
  }

  // Ensure Google Sign-In is initialized
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Google bejelentkezés - platform specifikus implementáció
  static Future<bool> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      if (kIsWeb) {
        // Web: Supabase OAuth használata
        final bool success = await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
        );
        return success;
      } else {
        // Android/iOS: Natív Google Sign-In v7.x + Supabase token exchange

        // Check if platform supports authenticate method
        if (!_googleSignIn.supportsAuthenticate()) {
          _logger.e('Platform does not support Google authentication');
          return false;
        }

        // Authenticate with Google (v7.x API)
        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

        // Get authentication tokens (v7.x API - authentication is now synchronous)
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        // Get authorization for required scopes to obtain access token
        final GoogleSignInClientAuthorization? authorization =
            await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);

        final String? idToken = googleAuth.idToken;
        final String? accessToken = authorization?.accessToken;

        if (idToken == null || accessToken == null) {
          _logger.e('Failed to get Google authentication tokens');
          return false;
        }

        // Supabase bejelentkezés Google token-ekkel
        final AuthResponse response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        if (response.user != null) {
          _logger.i('Successfully signed in with Google: ${response.user!.email}');
          return true;
        } else {
          _logger.e('Supabase sign in failed');
          return false;
        }
      }
    } catch (e) {
      _logger.e('Google sign in error: $e');
      return false;
    }
  }

  // Kijelentkezés
  static Future<void> signOut() async {
    try {
      await _ensureInitialized();

      // Always sign out from Supabase first
      await _supabase.auth.signOut();

      // Then sign out from Google (if not on web)
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (e) {
          _logger.w('Google sign out warning: $e');
        }
      }
    } catch (e) {
      _logger.e('Sign out error: $e');
    }
  }

  // Jelenlegi felhasználó
  static User? get currentUser => _supabase.auth.currentUser;

  // Auth state stream
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Be van-e jelentkezve
  static bool get isSignedIn => currentUser != null;
}

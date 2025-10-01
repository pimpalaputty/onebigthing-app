# Google Sign-In 7.x Migration Summary

This document summarizes the migration from `google_sign_in` version 6.x to 7.2.0.

## Changes Made

### 1. Package Updates (pubspec.yaml)
- **google_sign_in**: `^6.2.1` → `^7.2.0`
- **flutter_lints**: `^5.0.0` → `^6.0.0`

### 2. AuthService Migration (lib/services/auth_service.dart)

#### Key Changes:
- **Singleton Pattern**: Now uses `GoogleSignIn.instance` instead of creating new instances
- **Explicit Initialization**: Added required `initialize()` method that must be called before any other operations
- **Event Listening**: Updated to use `authenticationEvents` stream with pattern matching
- **Improved Error Handling**: Added initialization state tracking and proper error logging

#### API Changes:
```dart
// OLD (v6.x)
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: SupabaseConfig.googleClientId,
  scopes: <String>['email', 'profile'],
);

// NEW (v7.x)
static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

await _googleSignIn.initialize(
  clientId: kIsWeb ? SupabaseConfig.googleClientId : null,
  serverClientId: kIsWeb ? SupabaseConfig.googleClientId : SupabaseConfig.googleAndroidClientId,
);
```

#### Authentication Events:
```dart
// OLD (v6.x)
// Direct user property access

// NEW (v7.x)
_googleSignIn.authenticationEvents.listen((event) {
  final user = switch (event) {
    GoogleSignInAuthenticationEventSignIn(:final user) => user,
    GoogleSignInAuthenticationEventSignOut() => null,
  };
});
```

### 3. Main App Initialization (lib/main.dart)
Added early initialization of Google Sign-In in the `main()` function:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(...);

  // Google Sign-In inicializálás (v7.x requirement)
  try {
    await AuthService.initialize();
  } catch (e) {
    debugPrint('Failed to initialize AuthService: $e');
  }

  runApp(const MyApp());
}
```

### 4. Test Updates (test/widget_test.dart)
Replaced outdated counter test with DailyGoal model tests since widget tests require complex mocking of Supabase and Google Sign-In.

## Breaking Changes in v7.x

1. **Singleton Instance**: GoogleSignIn is now a singleton accessed via `.instance`
2. **Mandatory Initialization**: Must call `initialize()` exactly once before other methods
3. **Separate Auth/Authorization**: Authentication and authorization are now separate steps
4. **No Current User Tracking**: Apps must track signed-in users via `authenticationEvents` stream
5. **Method Changes**:
   - `signInSilently()` → `attemptLightweightAuthentication()`
   - `signIn()` → `authenticate()` (for native auth flow)
   - `clearAuthCache()` → `clearAuthorizationToken()`

## Verification

✅ Code analysis passes: `flutter analyze` - No issues found
✅ Tests pass: `flutter test` - All 3 tests passed
✅ Dependencies updated: `flutter pub get` - Success

## Native Authentication Flow (Android/iOS)

For native platforms, the v7.x authentication flow has changed:

```dart
// Authenticate with Google
final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

// Get authentication object (now synchronous)
final GoogleSignInAuthentication googleAuth = googleUser.authentication;

// Get authorization for scopes (separate step)
final GoogleSignInClientAuthorization? authorization =
    await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);

// Extract tokens
final String? idToken = googleAuth.idToken;
final String? accessToken = authorization?.accessToken;

// Use tokens for Supabase auth
await _supabase.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: idToken,
  accessToken: accessToken,
);
```

## Platform-Specific Configuration

Added `googleAndroidClientId` in `supabase_config.dart` for Android native authentication:
```dart
static const String googleClientId = '...'; // Web client
static const String googleAndroidClientId = '...'; // Android client
```

## Notes

- Web platform uses Supabase OAuth which handles authentication flow automatically
- Native platforms (Android/iOS) use the native Google Sign-In SDK with token exchange
- The `initialize()` method accepts `clientId`, `serverClientId`, `nonce`, and `hostedDomain` parameters
- Scopes are now requested during authorization, not initialization
- Platform-specific configuration in `android/app/build.gradle` and `ios/Runner/Info.plist` remains unchanged

## References

- [google_sign_in package](https://pub.dev/packages/google_sign_in)
- [Migration Guide](https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in/MIGRATION.md)
- [API Documentation](https://pub.dev/documentation/google_sign_in/latest/google_sign_in/GoogleSignIn-class.html)

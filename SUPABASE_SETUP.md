# Supabase Google Autentikáció Beállítása

## 1. Supabase Projekt Létrehozása

1. Menj a [supabase.com](https://supabase.com) oldalra
2. Regisztrálj vagy jelentkezz be
3. Hozz létre egy új projektet
4. Jegyezd fel a **Project URL** és **anon public** kulcsot

## 2. Google Cloud Platform Beállítása

1. Menj a [Google Cloud Console](https://console.cloud.google.com/) oldalra
2. Hozz létre egy új projektet vagy válassz egy meglévőt
3. Engedélyezd a **Google+ API**-t
4. Menj a **Credentials** szekcióba
5. Hozz létre **OAuth 2.0 Client ID**-t:
   - Application type: **Web application**
   - Authorized redirect URIs: `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`

## 3. Supabase Google Provider Beállítása

1. A Supabase dashboard-on menj az **Authentication** > **Providers** menüpontra
2. Kapcsold be a **Google** provider-t
3. Add meg a Google **Client ID** és **Client Secret** értékeket
4. Mentsd el a beállításokat

## 4. Flutter Alkalmazás Konfigurálása

### 4.1 Supabase Konfiguráció

Szerkeszd a `lib/config/supabase_config.dart` fájlt:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL'; // Supabase Project URL
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Supabase anon key
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID'; // Google Client ID
}
```

### 4.2 Függőségek Telepítése

```bash
flutter pub get
```

### 4.3 Android Beállítások

A `android/app/build.gradle` fájlban add hozzá:

```gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            'appAuthRedirectScheme': 'onebigthingapp'
        ]
    }
}
```

### 4.4 iOS Beállítások

A `ios/Runner/Info.plist` fájlban add hozzá:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>onebigthingapp</string>
    </array>
  </dict>
</array>
```

## 5. Tesztelés

1. Futtasd az alkalmazást: `flutter run`
2. Kattints a "Bejelentkezés Google-lel" gombra
3. Válaszd ki a Google fiókodat
4. Ellenőrizd, hogy sikeresen bejelentkeztél

## 6. Hibaelhárítás

### Gyakori hibák:

1. **"Invalid redirect URI"** - Ellenőrizd a Google Cloud Console redirect URI beállításait
2. **"Client ID not found"** - Ellenőrizd a Google Client ID-t a konfigurációban
3. **"Supabase connection failed"** - Ellenőrizd a Supabase URL-t és anon key-t

### Debug információk:

- Ellenőrizd a konzol kimenetét hibákért
- A Supabase dashboard-on nézd meg az Authentication log-okat
- A Google Cloud Console-ban ellenőrizd a OAuth consent screen beállításokat

## 7. További Fejlesztések

- Felhasználói profil szerkesztése
- Adatok mentése Supabase adatbázisban
- Push notification-ök
- Offline támogatás

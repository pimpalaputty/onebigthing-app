# One Big Thing App - Adatbázis Setup

## Supabase Adatbázis Konfiguráció

### 1. Adatbázis Táblák Létrehozása

Futtasd le a `database_setup.sql` fájl tartalmát a Supabase SQL Editor-ben:

1. Menj a Supabase Dashboard-ra
2. Válaszd ki a projektet
3. Menj a "SQL Editor" fülre
4. Másold be és futtasd le a `database_setup.sql` tartalmát

### 2. Táblák Leírása

#### `daily_goals` tábla
- **Cél**: Napi célok tárolása
- **Mezők**:
  - `id`: UUID primary key
  - `user_id`: Felhasználó ID (auth.users referencia)
  - `date`: Dátum (YYYY-MM-DD)
  - `big_goal`: Nagy cél szövege
  - `big_goal_completed`: Nagy cél teljesítve (boolean)
  - `small_goal_1`: Első kis cél
  - `small_goal_1_completed`: Első kis cél teljesítve
  - `small_goal_2`: Második kis cél
  - `small_goal_2_completed`: Második kis cél teljesítve
  - `created_at`, `updated_at`: Időbélyegek

#### `user_stats` tábla
- **Cél**: Felhasználói statisztikák
- **Mezők**:
  - `id`: UUID primary key
  - `user_id`: Felhasználó ID (egyedi)
  - `total_days`: Összes nap száma
  - `big_goals_completed`: Teljesített nagy célok
  - `small_goals_completed`: Teljesített kis célok
  - `current_streak`: Jelenlegi sorozat
  - `longest_streak`: Leghosszabb sorozat
  - `last_activity_date`: Utolsó aktivitás dátuma

### 3. Biztonsági Beállítások

A script automatikusan beállítja:
- **RLS (Row Level Security)**: Minden táblán engedélyezve
- **Policy-k**: Felhasználók csak a saját adataikat láthatják/módosíthatják
- **Indexek**: Optimalizált lekérdezésekhez
- **Trigger-ek**: Automatikus `updated_at` frissítéshez

### 4. Tesztelés

Az adatbázis setup után teszteld az alkalmazást:

1. **Bejelentkezés**: Google OAuth használatával
2. **Célok beállítása**: Új napi célok létrehozása
3. **Célok teljesítése**: Checkbox-ok használata
4. **Előzmények**: Előző napok megtekintése

### 5. Hibaelhárítás

Ha problémák merülnek fel:

1. **RLS hibák**: Ellenőrizd, hogy a policy-k megfelelően vannak beállítva
2. **Auth hibák**: Győződj meg róla, hogy a Google OAuth konfigurálva van
3. **Permission hibák**: Ellenőrizd a Supabase API kulcsokat

### 6. Következő Lépések

- [ ] Statisztikák oldal fejlesztése
- [ ] Achievement rendszer
- [ ] Push notification-ök
- [ ] Export funkciók

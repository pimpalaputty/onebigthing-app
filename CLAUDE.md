# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

One Big Thing is a Flutter-based daily goal tracking app that helps users focus on their most important tasks. Users set one "big thing" and two supporting small goals each day, tracking completion progress over time. The app uses Supabase for authentication (Google OAuth) and data persistence.

## Development Commands

### Building and Running
```bash
# Get dependencies
flutter pub get

# Run on preferred device (web, mobile, etc.)
flutter run

# Build for web
flutter build web

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Deployment
```bash
# Deploy to Vercel (uses pre-built web assets in public/)
npm run deploy

# Or use the shell script
./deploy.sh
```

## Architecture

### Core Structure
- **lib/main.dart**: App entry point with Supabase initialization and `AuthWrapper` that routes users to login or main navigation based on auth state
- **lib/config/**: Contains `supabase_config.dart` with Supabase URL, anon key, and Google OAuth client ID
- **lib/models/**: Data models, primarily `DailyGoal` with JSON serialization and completion tracking helpers
- **lib/services/**: Business logic layer
  - `auth_service.dart`: Google OAuth sign-in via Supabase, sign-out, and auth state management
  - `goal_service.dart`: CRUD operations for daily goals, completion toggling, statistics calculation
- **lib/screens/**: UI screens with navigation via `MainNavigation` (bottom nav bar)
- **lib/widgets/**: Reusable UI components

### Navigation Flow
1. **AuthWrapper** (main.dart:40): Listens to auth state changes
2. Unauthenticated → **LoginScreen**: Google OAuth button
3. Authenticated → **MainNavigation**: Three-tab interface (Home, History, Profile)

### Data Model
The `DailyGoal` model represents a single day's goals:
- One "big goal" (primary daily objective)
- Two "small goals" (supporting tasks)
- Each goal has a completion boolean
- Includes helper methods: `completedGoalsCount`, `progressPercentage`, `allGoalsCompleted`

### Database Schema
Supabase PostgreSQL with Row Level Security (RLS):
- **daily_goals**: Stores user goals by date with completion status
- **user_stats**: Aggregated statistics (streaks, total completions)
- See `database_setup.sql` for full schema and RLS policies
- See `DATABASE_SETUP.md` for setup instructions

### Service Layer Patterns
All services use static methods and maintain singleton instances of `SupabaseClient` and `Logger`. Key operations:
- **GoalService.getTodaysGoals()**: Fetches goals for current date
- **GoalService.saveGoals()**: Upsert pattern - updates existing or creates new
- **GoalService.toggleGoalCompletion()**: Read-modify-write pattern for safe state updates
- **GoalService.updateUserStats()**: Recalculates streaks and completion counts from all goals

## Configuration Requirements

### Environment Setup
Before running, configure `lib/config/supabase_config.dart` with:
- Supabase project URL
- Supabase anon key
- Google OAuth client ID

See `SUPABASE_SETUP.md` for full Google Cloud Platform and Supabase authentication setup.

### Platform-Specific Configuration
- **Android**: Requires `manifestPlaceholders` with `appAuthRedirectScheme: 'onebigthingapp'` in `android/app/build.gradle`
- **iOS**: Requires `CFBundleURLSchemes` with `onebigthingapp` in `ios/Runner/Info.plist`

## Testing Strategy

Run tests with `flutter test`. The codebase uses `flutter_test` for widget testing.

## Key Implementation Details

### Authentication Flow
Uses Supabase OAuth with `signInWithOAuth(OAuthProvider.google)` which handles web and mobile platforms. The auth state stream in `AuthWrapper` automatically handles navigation between login and main app.

### Goal Completion Pattern
Completion toggles use optimistic updates in UI with database confirmation:
1. Read current state from database
2. Toggle boolean
3. Update with timestamp in `updated_at` field

### Statistics Calculation
`updateUserStats()` in GoalService performs full recalculation by:
1. Fetching all user goals ordered by date
2. Counting completions and calculating streaks
3. Upserting results into `user_stats` table

Streak logic: Consecutive days where all three goals (big + 2 small) are completed.

## Logging
Uses the `logger` package throughout services. Errors are logged with `_logger.e()`, making debugging easier in production.

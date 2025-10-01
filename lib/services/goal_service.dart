import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../models/daily_goal.dart';

class GoalService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final Logger _logger = Logger();

  // Mai célok lekérése
  static Future<DailyGoal?> getTodaysGoals(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from('daily_goals')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DailyGoal.fromJson(response);
    } catch (e) {
      _logger.e('Error getting today\'s goals: $e');
      return null;
    }
  }

  // Célok mentése/frissítése
  static Future<DailyGoal?> saveGoals({
    required String userId,
    required String bigGoal,
    required String smallGoal1,
    required String smallGoal2,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateString = targetDate.toIso8601String().split('T')[0];

      // Ellenőrizzük, hogy létezik-e már a mai napra cél
      final existingGoal = await getTodaysGoals(userId);
      
      if (existingGoal != null) {
        // Frissítjük a meglévő célt
        final response = await _supabase
            .from('daily_goals')
            .update({
              'big_goal': bigGoal,
              'small_goal_1': smallGoal1,
              'small_goal_2': smallGoal2,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingGoal.id)
            .select()
            .single();

        return DailyGoal.fromJson(response);
      } else {
        // Új célt hozunk létre
        final response = await _supabase
            .from('daily_goals')
            .insert({
              'user_id': userId,
              'date': dateString,
              'big_goal': bigGoal,
              'small_goal_1': smallGoal1,
              'small_goal_2': smallGoal2,
            })
            .select()
            .single();

        return DailyGoal.fromJson(response);
      }
    } catch (e) {
      _logger.e('Error saving goals: $e');
      return null;
    }
  }

  // Cél completion toggle
  static Future<bool> toggleGoalCompletion(
    String goalId,
    String goalType, // 'big_goal', 'small_goal_1', 'small_goal_2'
  ) async {
    try {
      // Először lekérjük a jelenlegi állapotot
      final response = await _supabase
          .from('daily_goals')
          .select('$goalType, ${goalType}_completed')
          .eq('id', goalId)
          .single();

      final currentStatus = response['${goalType}_completed'] as bool;
      final newStatus = !currentStatus;

      // Frissítjük az állapotot
      await _supabase
          .from('daily_goals')
          .update({
            '${goalType}_completed': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);

      return newStatus;
    } catch (e) {
      _logger.e('Error toggling goal completion: $e');
      return false;
    }
  }

  // Előző napok céljai
  static Future<List<DailyGoal>> getPreviousGoals(
    String userId,
    int days,
  ) async {
    try {
      final response = await _supabase
          .from('daily_goals')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(days);

      return (response as List)
          .map((json) => DailyGoal.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error getting previous goals: $e');
      return [];
    }
  }

  // Cél törlése
  static Future<bool> deleteGoal(String goalId) async {
    try {
      await _supabase
          .from('daily_goals')
          .delete()
          .eq('id', goalId);

      return true;
    } catch (e) {
      _logger.e('Error deleting goal: $e');
      return false;
    }
  }

  // Felhasználó statisztikáinak lekérése
  static Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      _logger.e('Error getting user stats: $e');
      return null;
    }
  }

  // Statisztikák frissítése
  static Future<void> updateUserStats(String userId) async {
    try {
      // Számoljuk meg a teljesített célokat
      final goals = await _supabase
          .from('daily_goals')
          .select('big_goal_completed, small_goal_1_completed, small_goal_2_completed, date')
          .eq('user_id', userId)
          .order('date', ascending: false);

      int totalDays = goals.length;
      int bigGoalsCompleted = 0;
      int smallGoalsCompleted = 0;
      int currentStreak = 0;
      int longestStreak = 0;
      int tempStreak = 0;

      DateTime? lastDate;
      
      for (var goal in goals) {
        final date = DateTime.parse(goal['date']);
        final bigCompleted = goal['big_goal_completed'] as bool;
        final small1Completed = goal['small_goal_1_completed'] as bool;
        final small2Completed = goal['small_goal_2_completed'] as bool;
        
        if (bigCompleted) bigGoalsCompleted++;
        if (small1Completed) smallGoalsCompleted++;
        if (small2Completed) smallGoalsCompleted++;

        // Streak számítás
        if (bigCompleted && small1Completed && small2Completed) {
          if (lastDate == null || lastDate.difference(date).inDays == 1) {
            tempStreak++;
            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }
            if (currentStreak == 0) {
              currentStreak = tempStreak;
            }
          } else {
            tempStreak = 1;
          }
        } else {
          tempStreak = 0;
        }
        
        lastDate = date;
      }

      // Frissítjük vagy létrehozzuk a statisztikákat
      await _supabase
          .from('user_stats')
          .upsert({
            'user_id': userId,
            'total_days': totalDays,
            'big_goals_completed': bigGoalsCompleted,
            'small_goals_completed': smallGoalsCompleted,
            'current_streak': currentStreak,
            'longest_streak': longestStreak,
            'last_activity_date': DateTime.now().toIso8601String().split('T')[0],
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      _logger.e('Error updating user stats: $e');
    }
  }
}

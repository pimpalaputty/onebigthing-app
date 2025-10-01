// Basic tests for One Big Thing App
//
// Note: Widget tests require proper mocking of Supabase and Google Sign-In.
// For now, we verify that the code compiles and key models work correctly.

import 'package:flutter_test/flutter_test.dart';
import 'package:onebigthing_app/models/daily_goal.dart';

void main() {
  group('DailyGoal Model Tests', () {
    test('DailyGoal calculates completed goals correctly', () {
      final goal = DailyGoal(
        id: 'test-id',
        userId: 'user-id',
        date: DateTime.now(),
        bigGoal: 'Test Big Goal',
        bigGoalCompleted: true,
        smallGoal1: 'Small Goal 1',
        smallGoal1Completed: true,
        smallGoal2: 'Small Goal 2',
        smallGoal2Completed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(goal.completedGoalsCount, 2);
      expect(goal.totalGoalsCount, 3);
      expect(goal.progressPercentage, closeTo(0.666, 0.01));
      expect(goal.allGoalsCompleted, false);
    });

    test('DailyGoal detects all goals completed', () {
      final goal = DailyGoal(
        id: 'test-id',
        userId: 'user-id',
        date: DateTime.now(),
        bigGoal: 'Test Big Goal',
        bigGoalCompleted: true,
        smallGoal1: 'Small Goal 1',
        smallGoal1Completed: true,
        smallGoal2: 'Small Goal 2',
        smallGoal2Completed: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(goal.completedGoalsCount, 3);
      expect(goal.allGoalsCompleted, true);
      expect(goal.progressPercentage, 1.0);
    });

    test('DailyGoal toJson/fromJson roundtrip', () {
      final now = DateTime.now();
      final original = DailyGoal(
        id: 'test-id',
        userId: 'user-id',
        date: now,
        bigGoal: 'Test Big Goal',
        bigGoalCompleted: true,
        smallGoal1: 'Small Goal 1',
        smallGoal1Completed: false,
        smallGoal2: 'Small Goal 2',
        smallGoal2Completed: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = original.toJson();
      final restored = DailyGoal.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.bigGoal, original.bigGoal);
      expect(restored.bigGoalCompleted, original.bigGoalCompleted);
      expect(restored.smallGoal1Completed, original.smallGoal1Completed);
      expect(restored.smallGoal2Completed, original.smallGoal2Completed);
    });
  });
}

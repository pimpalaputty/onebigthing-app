class DailyGoal {
  final String id;
  final String userId;
  final DateTime date;
  final String bigGoal;
  final bool bigGoalCompleted;
  final String smallGoal1;
  final bool smallGoal1Completed;
  final String smallGoal2;
  final bool smallGoal2Completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyGoal({
    required this.id,
    required this.userId,
    required this.date,
    required this.bigGoal,
    this.bigGoalCompleted = false,
    required this.smallGoal1,
    this.smallGoal1Completed = false,
    required this.smallGoal2,
    this.smallGoal2Completed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON-ból objektum létrehozása
  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    return DailyGoal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      bigGoal: json['big_goal'] as String,
      bigGoalCompleted: json['big_goal_completed'] as bool? ?? false,
      smallGoal1: json['small_goal_1'] as String,
      smallGoal1Completed: json['small_goal_1_completed'] as bool? ?? false,
      smallGoal2: json['small_goal_2'] as String,
      smallGoal2Completed: json['small_goal_2_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Objektum JSON-ba konvertálása
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD formátum
      'big_goal': bigGoal,
      'big_goal_completed': bigGoalCompleted,
      'small_goal_1': smallGoal1,
      'small_goal_1_completed': smallGoal1Completed,
      'small_goal_2': smallGoal2,
      'small_goal_2_completed': smallGoal2Completed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Objektum másolása módosításokkal
  DailyGoal copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? bigGoal,
    bool? bigGoalCompleted,
    String? smallGoal1,
    bool? smallGoal1Completed,
    String? smallGoal2,
    bool? smallGoal2Completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      bigGoal: bigGoal ?? this.bigGoal,
      bigGoalCompleted: bigGoalCompleted ?? this.bigGoalCompleted,
      smallGoal1: smallGoal1 ?? this.smallGoal1,
      smallGoal1Completed: smallGoal1Completed ?? this.smallGoal1Completed,
      smallGoal2: smallGoal2 ?? this.smallGoal2,
      smallGoal2Completed: smallGoal2Completed ?? this.smallGoal2Completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Teljesített célok száma
  int get completedGoalsCount {
    int count = 0;
    if (bigGoalCompleted) count++;
    if (smallGoal1Completed) count++;
    if (smallGoal2Completed) count++;
    return count;
  }

  // Összes cél száma
  int get totalGoalsCount => 3;

  // Progress százalék
  double get progressPercentage => completedGoalsCount / totalGoalsCount;

  // Minden cél teljesítve
  bool get allGoalsCompleted => completedGoalsCount == totalGoalsCount;

  @override
  String toString() {
    return 'DailyGoal(id: $id, date: $date, bigGoal: $bigGoal, completed: $completedGoalsCount/$totalGoalsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyGoal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

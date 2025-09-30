import 'package:flutter/material.dart';
import '../models/daily_goal.dart';
import '../services/goal_service.dart';
import '../services/auth_service.dart';
import '../widgets/progress_indicator.dart' as custom;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DailyGoal> _previousGoals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPreviousGoals();
  }

  Future<void> _loadPreviousGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = AuthService.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Nincs bejelentkezve felhasználó';
          _isLoading = false;
        });
        return;
      }

      final goals = await GoalService.getPreviousGoals(user.id, 30); // Utolsó 30 nap
      setState(() {
        _previousGoals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Hiba történt a célok betöltése során: $e';
        _isLoading = false;
      });
    }
  }

  String _getDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Ma';
    } else if (targetDate == yesterday) {
      return 'Tegnap';
    } else {
      final months = [
        'jan', 'feb', 'már', 'ápr', 'máj', 'jún',
        'júl', 'aug', 'szep', 'okt', 'nov', 'dec'
      ];
      return '${date.day}. ${months[date.month - 1]}';
    }
  }

  String _getWeekdayString(DateTime date) {
    final days = ['H', 'K', 'Sze', 'Cs', 'P', 'Szo', 'V'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Előzmények'),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadPreviousGoals,
            icon: const Icon(Icons.refresh),
            tooltip: 'Frissítés',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _previousGoals.isEmpty
                  ? _buildEmptyState()
                  : _buildGoalsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Hiba történt',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPreviousGoals,
              icon: const Icon(Icons.refresh),
              label: const Text('Újrapróbálás'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Még nincsenek előzmények',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Amikor elkezded használni az alkalmazást, itt láthatod az előző napok céljait.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList() {
    return RefreshIndicator(
      onRefresh: _loadPreviousGoals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _previousGoals.length,
        itemBuilder: (context, index) {
          final goal = _previousGoals[index];
          final isToday = goal.date.day == DateTime.now().day &&
              goal.date.month == DateTime.now().month &&
              goal.date.year == DateTime.now().year;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: isToday ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isToday 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                width: isToday ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isToday 
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getDateString(goal.date),
                          style: TextStyle(
                            color: isToday 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getWeekdayString(goal.date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      // Progress
                      custom.CompactProgressIndicator(
                        completedGoals: goal.completedGoalsCount,
                        totalGoals: goal.totalGoalsCount,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // Big Goal
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: goal.bigGoalCompleted ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.bigGoal,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: goal.bigGoalCompleted 
                                ? Colors.grey[600]
                                : null,
                            decoration: goal.bigGoalCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Small Goals
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: goal.smallGoal1Completed ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.smallGoal1,
                          style: TextStyle(
                            fontSize: 14,
                            color: goal.smallGoal1Completed 
                                ? Colors.grey[600]
                                : null,
                            decoration: goal.smallGoal1Completed 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: goal.smallGoal2Completed ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.smallGoal2,
                          style: TextStyle(
                            fontSize: 14,
                            color: goal.smallGoal2Completed 
                                ? Colors.grey[600]
                                : null,
                            decoration: goal.smallGoal2Completed 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (goal.allGoalsCompleted) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.celebration,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Minden cél teljesítve!',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

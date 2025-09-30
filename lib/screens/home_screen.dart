import 'package:flutter/material.dart';
import '../models/daily_goal.dart';
import '../services/goal_service.dart';
import '../services/auth_service.dart';
import '../widgets/goal_card.dart';
import '../widgets/progress_indicator.dart' as custom;
import 'goal_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyGoal? _todaysGoal;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodaysGoals();
  }

  Future<void> _loadTodaysGoals() async {
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

      final goal = await GoalService.getTodaysGoals(user.id);
      setState(() {
        _todaysGoal = goal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Hiba történt a célok betöltése során: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleGoalCompletion(String goalType) async {
    if (_todaysGoal == null) return;

    try {
      final newStatus = await GoalService.toggleGoalCompletion(
        _todaysGoal!.id,
        goalType,
      );

      if (newStatus) {
        setState(() {
          switch (goalType) {
            case 'big_goal':
              _todaysGoal = _todaysGoal!.copyWith(bigGoalCompleted: newStatus);
              break;
            case 'small_goal_1':
              _todaysGoal = _todaysGoal!.copyWith(smallGoal1Completed: newStatus);
              break;
            case 'small_goal_2':
              _todaysGoal = _todaysGoal!.copyWith(smallGoal2Completed: newStatus);
              break;
          }
        });

        // Statisztikák frissítése
        await GoalService.updateUserStats(AuthService.currentUser!.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hiba történt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToGoalSetup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoalSetupScreen(),
      ),
    );

    if (result == true) {
      // Újratöltjük a célokat
      await _loadTodaysGoals();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Jó reggelt!';
    } else if (hour < 18) {
      return 'Jó napot!';
    } else {
      return 'Jó estét!';
    }
  }

  String _getDateString() {
    final now = DateTime.now();
    final months = [
      'január', 'február', 'március', 'április', 'május', 'június',
      'július', 'augusztus', 'szeptember', 'október', 'november', 'december'
    ];
    final days = [
      'hétfő', 'kedd', 'szerda', 'csütörtök', 'péntek', 'szombat', 'vasárnap'
    ];
    
    return '${days[now.weekday - 1]}, ${now.day}. ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('One Big Thing'),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _navigateToGoalSetup,
            icon: const Icon(Icons.edit),
            tooltip: 'Célok szerkesztése',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _todaysGoal == null
                  ? _buildNoGoalsState()
                  : _buildGoalsState(),
      floatingActionButton: _todaysGoal == null
          ? FloatingActionButton.extended(
              onPressed: _navigateToGoalSetup,
              icon: const Icon(Icons.add),
              label: const Text('Célok beállítása'),
            )
          : null,
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
              onPressed: _loadTodaysGoals,
              icon: const Icon(Icons.refresh),
              label: const Text('Újrapróbálás'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGoalsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _getDateString(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Még nincsenek beállítva a mai célok',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Állítsd be 1 nagy célt és 2 kisebb célt a mai napra!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToGoalSetup,
              icon: const Icon(Icons.add),
              label: const Text('Célok beállítása'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsState() {
    return RefreshIndicator(
      onRefresh: _loadTodaysGoals,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDateString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            custom.ProgressIndicator(
              completedGoals: _todaysGoal!.completedGoalsCount,
              totalGoals: _todaysGoal!.totalGoalsCount,
              title: 'Mai haladás',
            ),

            const SizedBox(height: 16),

            // Big Goal
            BigGoalCard(
              title: _todaysGoal!.bigGoal,
              isCompleted: _todaysGoal!.bigGoalCompleted,
              onToggle: () => _toggleGoalCompletion('big_goal'),
            ),

            const SizedBox(height: 8),

            // Small Goals
            Text(
              'Kisebb célok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),

            GoalCard(
              title: _todaysGoal!.smallGoal1,
              isCompleted: _todaysGoal!.smallGoal1Completed,
              onToggle: () => _toggleGoalCompletion('small_goal_1'),
            ),

            GoalCard(
              title: _todaysGoal!.smallGoal2,
              isCompleted: _todaysGoal!.smallGoal2Completed,
              onToggle: () => _toggleGoalCompletion('small_goal_2'),
            ),

            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }
}

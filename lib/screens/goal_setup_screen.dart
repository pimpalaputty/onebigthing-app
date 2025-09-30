import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import '../services/auth_service.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bigGoalController = TextEditingController();
  final _smallGoal1Controller = TextEditingController();
  final _smallGoal2Controller = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadExistingGoals();
  }

  @override
  void dispose() {
    _bigGoalController.dispose();
    _smallGoal1Controller.dispose();
    _smallGoal2Controller.dispose();
    super.dispose();
  }

  Future<void> _loadExistingGoals() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final existingGoal = await GoalService.getTodaysGoals(user.id);
      if (existingGoal != null) {
        setState(() {
          _isEditing = true;
          _bigGoalController.text = existingGoal.bigGoal;
          _smallGoal1Controller.text = existingGoal.smallGoal1;
          _smallGoal2Controller.text = existingGoal.smallGoal2;
        });
      }
    } catch (e) {
      print('Error loading existing goals: $e');
    }
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = AuthService.currentUser;
      if (user == null) {
        throw Exception('Nincs bejelentkezve felhasználó');
      }

      final goal = await GoalService.saveGoals(
        userId: user.id,
        bigGoal: _bigGoalController.text.trim(),
        smallGoal1: _smallGoal1Controller.text.trim(),
        smallGoal2: _smallGoal2Controller.text.trim(),
      );

      if (goal != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Célok frissítve!' : 'Célok mentve!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Nem sikerült menteni a célokat');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hiba történt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        title: Text(_isEditing ? 'Célok szerkesztése' : 'Célok beállítása'),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _isLoading ? null : _saveGoals,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              tooltip: 'Mentés',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isEditing ? 'Célok szerkesztése' : 'Új célok beállítása',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDateString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Állítsd be 1 nagy célt és 2 kisebb célt a mai napra. A nagy cél legyen valami jelentős, amit el szeretnél érni.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Big Goal
              _buildGoalSection(
                title: 'NAGY CÉL',
                subtitle: 'Ez a legfontosabb célod a mai napra',
                controller: _bigGoalController,
                icon: Icons.star,
                isBig: true,
                hintText: 'pl. Projekt befejezése, fontos beszélgetés, stb.',
              ),

              const SizedBox(height: 24),

              // Small Goals
              _buildGoalSection(
                title: 'ELSŐ KISEBB CÉL',
                subtitle: 'Egy kisebb, de fontos feladat',
                controller: _smallGoal1Controller,
                icon: Icons.check_circle_outline,
                isBig: false,
                hintText: 'pl. Email-ek megválaszolása, edzés, stb.',
              ),

              const SizedBox(height: 16),

              _buildGoalSection(
                title: 'MÁSODIK KISEBB CÉL',
                subtitle: 'Egy másik kisebb feladat',
                controller: _smallGoal2Controller,
                icon: Icons.check_circle_outline,
                isBig: false,
                hintText: 'pl. Bevásárlás, olvasás, stb.',
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveGoals,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(_isLoading 
                      ? 'Mentés...' 
                      : (_isEditing ? 'Célok frissítése' : 'Célok mentése')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Tippek',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• A nagy cél legyen valami, amit el tudsz érni egy nap alatt\n'
                      '• A kisebb célok segíthetnek a nagy cél elérésében\n'
                      '• Legyél konkrét és mérhető a célok megfogalmazásában',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSection({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required IconData icon,
    required bool isBig,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBig 
                    ? colorScheme.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isBig ? colorScheme.primary : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isBig ? colorScheme.primary : Colors.grey[700],
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: isBig ? 3 : 2,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isBig 
                    ? colorScheme.primary.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isBig 
                    ? colorScheme.primary.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isBig ? colorScheme.primary : Colors.grey,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isBig 
                ? colorScheme.primary.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Kérlek add meg a célt';
            }
            if (value.trim().length < 3) {
              return 'A cél legalább 3 karakter hosszú legyen';
            }
            return null;
          },
        ),
      ],
    );
  }
}

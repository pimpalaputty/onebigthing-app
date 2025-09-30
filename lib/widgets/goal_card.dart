import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onToggle;
  final bool isBigGoal;
  final String? subtitle;

  const GoalCard({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
    this.isBigGoal = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isBigGoal ? 4 : 2,
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isBigGoal ? 8 : 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted 
              ? Colors.green.withOpacity(0.3)
              : (isBigGoal ? colorScheme.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
          width: isBigGoal ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isBigGoal ? 20 : 16),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isBigGoal ? 28 : 24,
                height: isBigGoal ? 28 : 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                      ? Colors.green
                      : (isBigGoal ? colorScheme.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                  border: Border.all(
                    color: isCompleted 
                        ? Colors.green
                        : (isBigGoal ? colorScheme.primary : Colors.grey),
                    width: isBigGoal ? 2 : 1.5,
                  ),
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: isBigGoal ? 18 : 16,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Szöveg
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isBigGoal ? 18 : 16,
                        fontWeight: isBigGoal ? FontWeight.w600 : FontWeight.w500,
                        color: isCompleted 
                            ? Colors.grey[600]
                            : (isBigGoal ? colorScheme.onSurface : theme.textTheme.bodyLarge?.color),
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.grey[600],
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: isBigGoal ? 14 : 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Big goal ikon
              if (isBigGoal)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Speciális Big Goal kártya
class BigGoalCard extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onToggle;
  final String? subtitle;

  const BigGoalCard({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
              : [colorScheme.primary.withOpacity(0.1), colorScheme.primary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted 
              ? Colors.green.withOpacity(0.3)
              : colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Nagy checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted 
                            ? Colors.green
                            : colorScheme.primary.withOpacity(0.1),
                        border: Border.all(
                          color: isCompleted 
                              ? Colors.green
                              : colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Címke
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'NAGY CÉL',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isCompleted 
                        ? Colors.grey[600]
                        : colorScheme.onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

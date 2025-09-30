import 'package:flutter/material.dart';

class ProgressIndicator extends StatelessWidget {
  final int completedGoals;
  final int totalGoals;
  final String? title;

  const ProgressIndicator({
    super.key,
    required this.completedGoals,
    required this.totalGoals,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              // Progress bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Haladás',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '$completedGoals/$totalGoals',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: colorScheme.outline.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completedGoals == totalGoals 
                              ? Colors.green 
                              : colorScheme.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Ikon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: completedGoals == totalGoals 
                      ? Colors.green.withOpacity(0.1)
                      : colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  completedGoals == totalGoals 
                      ? Icons.celebration
                      : Icons.track_changes,
                  color: completedGoals == totalGoals 
                      ? Colors.green
                      : colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          if (completedGoals == totalGoals) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Minden cél teljesítve! 🎉',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Kompakt progress indicator
class CompactProgressIndicator extends StatelessWidget {
  final int completedGoals;
  final int totalGoals;

  const CompactProgressIndicator({
    super.key,
    required this.completedGoals,
    required this.totalGoals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    return Row(
      children: [
        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                completedGoals == totalGoals 
                    ? Colors.green 
                    : colorScheme.primary,
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Szám
        Text(
          '$completedGoals/$totalGoals',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: completedGoals == totalGoals 
                ? Colors.green
                : colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

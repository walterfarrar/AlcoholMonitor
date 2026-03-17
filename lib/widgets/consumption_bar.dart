import 'package:flutter/material.dart';

class ConsumptionBar extends StatelessWidget {
  final String label;
  final double fillPercent;
  final double remaining;
  final double limit;
  final String unitLabel;

  const ConsumptionBar({
    super.key,
    required this.label,
    required this.fillPercent,
    required this.remaining,
    required this.limit,
    required this.unitLabel,
  });

  Color _fillColor(double percent) {
    if (percent > 0.5) return const Color(0xFF4CAF50);
    if (percent > 0.25) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedFill = fillPercent.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        height: constraints.maxHeight * clampedFill,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              _fillColor(clampedFill),
                              _fillColor(clampedFill).withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '${(clampedFill * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                const Shadow(
                                  blurRadius: 4,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${remaining.toStringAsFixed(1)} $unitLabel',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

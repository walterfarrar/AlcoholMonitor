import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/consumption_provider.dart';
import '../widgets/consumption_bar.dart';
import 'bottles_screen.dart';
import 'log_drink_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsumptionProvider>();
    final theme = Theme.of(context);
    final hasSelection = provider.selectedBottle != null;
    final canLog = hasSelection && provider.canDrink;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alcohol Monitor'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.liquor),
            tooltip: 'My Bottles',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BottlesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ConsumptionBar(
                        label: 'Day',
                        fillPercent: provider.dailyFillPercent,
                        remaining: provider.displayValue(provider.dailyRemaining),
                        limit: provider.displayValue(provider.settings.dailyLimit),
                        unitLabel: provider.displayUnitLabel,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ConsumptionBar(
                        label: 'Week',
                        fillPercent: provider.weeklyFillPercent,
                        remaining: provider.displayValue(provider.weeklyRemaining),
                        limit: provider.displayValue(provider.settings.weeklyLimit),
                        unitLabel: provider.displayUnitLabel,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ConsumptionBar(
                        label: 'Month',
                        fillPercent: provider.monthlyFillPercent,
                        remaining: provider.displayValue(provider.monthlyRemaining),
                        limit: provider.displayValue(provider.settings.monthlyLimit),
                        unitLabel: provider.displayUnitLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- Fixed bottom section: dropdown + banner + button ---
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: SizedBox(
                width: double.infinity,
                child: DropdownMenu<String>(
                  label: const Text('Select a bottle'),
                  leadingIcon: const Icon(Icons.liquor),
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: provider.selectedBottle?.id,
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: '', label: 'None'),
                    ...provider.bottles.map(
                      (b) => DropdownMenuEntry(
                        value: b.id,
                        label: '${b.name} (${b.abvPercent}%)',
                      ),
                    ),
                  ],
                  onSelected: (id) {
                    if (id == null || id.isEmpty) {
                      provider.selectBottle(null);
                    } else {
                      final bottle = provider.bottles
                          .where((b) => b.id == id)
                          .firstOrNull;
                      provider.selectBottle(bottle);
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
              child: _InfoBanner(provider: provider, theme: theme),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: canLog
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LogDrinkScreen(
                                bottle: provider.selectedBottle!,
                              ),
                            ),
                          )
                      : null,
                  icon: Icon(
                    canLog
                        ? Icons.local_bar
                        : (hasSelection && !provider.canDrink
                            ? Icons.lock
                            : Icons.local_bar),
                  ),
                  label: Text(
                    hasSelection && !provider.canDrink
                        ? 'Limit Reached'
                        : 'Log a Drink',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final ConsumptionProvider provider;
  final ThemeData theme;

  const _InfoBanner({required this.provider, required this.theme});

  @override
  Widget build(BuildContext context) {
    final hasBottles = provider.bottles.isNotEmpty;
    final hasSelection = provider.selectedBottle != null;

    // No bottles in inventory
    if (!hasBottles) {
      return _banner(
        icon: Icons.info_outline,
        text: 'Add your bottles using the bottle icon above to get started.',
        bgColor: theme.colorScheme.surfaceContainerHighest,
        iconColor: theme.colorScheme.onSurfaceVariant,
        textColor: theme.colorScheme.onSurfaceVariant,
      );
    }

    // Bottles exist but none selected
    if (!hasSelection) {
      return _banner(
        icon: Icons.arrow_upward,
        text: 'Select a bottle above to log a drink.',
        bgColor: theme.colorScheme.surfaceContainerHighest,
        iconColor: theme.colorScheme.onSurfaceVariant,
        textColor: theme.colorScheme.onSurfaceVariant,
      );
    }

    // Limit reached
    if (!provider.canDrink) {
      return _banner(
        icon: Icons.lock,
        text: provider.lockReason,
        bgColor: theme.colorScheme.errorContainer,
        iconColor: theme.colorScheme.error,
        textColor: theme.colorScheme.onErrorContainer,
        bold: true,
      );
    }

    // Bottle selected, can drink
    final maxAmount = provider.maxForSelectedBottle;
    final unitLabel = provider.displayUnitLabel;

    if (maxAmount == null || maxAmount <= 0) {
      return _banner(
        icon: Icons.block,
        text: 'You\'ve reached your limit',
        bgColor: theme.colorScheme.errorContainer,
        iconColor: theme.colorScheme.error,
        textColor: theme.colorScheme.onErrorContainer,
        bold: true,
      );
    }

    return _banner(
      icon: Icons.local_drink,
      text: 'You can have up to ${maxAmount.toStringAsFixed(1)} $unitLabel of ${provider.selectedBottle!.name}',
      bgColor: theme.colorScheme.tertiaryContainer,
      iconColor: theme.colorScheme.onTertiaryContainer,
      textColor: theme.colorScheme.onTertiaryContainer,
      bold: true,
    );
  }

  Widget _banner({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
    bool bold = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.w600 : null,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

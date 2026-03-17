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
                        remaining: provider.dailyRemaining,
                        limit: provider.settings.dailyLimit,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ConsumptionBar(
                        label: 'Week',
                        fillPercent: provider.weeklyFillPercent,
                        remaining: provider.weeklyRemaining,
                        limit: provider.settings.weeklyLimit,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ConsumptionBar(
                        label: 'Month',
                        fillPercent: provider.monthlyFillPercent,
                        remaining: provider.monthlyRemaining,
                        limit: provider.settings.monthlyLimit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottleSelectorSection(provider: provider, theme: theme),
            if (!provider.canDrink)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.lockReason,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: provider.canDrink
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LogDrinkScreen(
                                preselectedBottle: provider.selectedBottle,
                              ),
                            ),
                          )
                      : null,
                  icon: Icon(
                    provider.canDrink ? Icons.local_bar : Icons.lock,
                  ),
                  label: Text(
                    provider.canDrink ? 'Log a Drink' : 'Limit Reached',
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

class _BottleSelectorSection extends StatelessWidget {
  final ConsumptionProvider provider;
  final ThemeData theme;

  const _BottleSelectorSection({
    required this.provider,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.bottles.isEmpty) return const SizedBox.shrink();

    final maxOz = provider.maxOzForSelectedBottle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 8),
      child: Column(
        children: [
          SizedBox(
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
          if (provider.selectedBottle != null && maxOz != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: maxOz > 0
                    ? theme.colorScheme.tertiaryContainer
                    : theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    maxOz > 0 ? Icons.local_drink : Icons.block,
                    color: maxOz > 0
                        ? theme.colorScheme.onTertiaryContainer
                        : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      maxOz > 0
                          ? 'You can have up to ${maxOz.toStringAsFixed(1)} oz of ${provider.selectedBottle!.name}'
                          : 'You\'ve reached your limit',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: maxOz > 0
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onErrorContainer,
                      ),
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

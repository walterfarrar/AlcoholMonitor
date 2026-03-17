import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/consumption_settings.dart';
import '../providers/consumption_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _daily;
  late double _weekly;
  late double _monthly;
  late DisplayUnit _displayUnit;

  @override
  void initState() {
    super.initState();
    final settings = context.read<ConsumptionProvider>().settings;
    _daily = settings.dailyLimit;
    _weekly = settings.weeklyLimit;
    _monthly = settings.monthlyLimit;
    _displayUnit = settings.displayUnit;
  }

  Future<void> _save() async {
    await context.read<ConsumptionProvider>().updateSettings(
      ConsumptionSettings(
        dailyLimit: _daily,
        weeklyLimit: _weekly,
        monthlyLimit: _monthly,
        displayUnitIndex: _displayUnit.index,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Drink History'),
        content: const Text(
          'This will clear all logged drinks and refill the day, week, and month bars. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ConsumptionProvider>().clearAllDrinks();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Drink history cleared.')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitControl({
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: value > 0.5
                      ? () => onChanged((value - 0.5).clamp(0.5, 100))
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 80,
                  child: Text(
                    value.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton.filled(
                  onPressed: () => onChanged((value + 0.5).clamp(0.5, 100)),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Limits')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildLimitControl(
                    title: 'Daily Limit',
                    subtitle: 'Max standard drinks per day',
                    value: _daily,
                    onChanged: (v) => setState(() => _daily = v),
                  ),
                  _buildLimitControl(
                    title: 'Weekly Limit',
                    subtitle: 'Max standard drinks per week (Mon–Sun)',
                    value: _weekly,
                    onChanged: (v) => setState(() => _weekly = v),
                  ),
                  _buildLimitControl(
                    title: 'Monthly Limit',
                    subtitle: 'Max standard drinks per calendar month',
                    value: _monthly,
                    onChanged: (v) => setState(() => _monthly = v),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Display Unit',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Unit shown under bars and in the bottle banner (oz/mL require a bottle selected)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<DisplayUnit>(
                            segments: DisplayUnit.values
                                .map(
                                  (u) => ButtonSegment(
                                    value: u,
                                    label: Text(u.shortLabel),
                                  ),
                                )
                                .toList(),
                            selected: {_displayUnit},
                            onSelectionChanged: (s) =>
                                setState(() => _displayUnit = s.first),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmReset(context),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset All Drink History'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

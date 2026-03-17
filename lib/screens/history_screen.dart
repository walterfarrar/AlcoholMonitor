import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/drink_entry.dart';
import '../providers/consumption_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsumptionProvider>();
    final drinks = provider.drinks;
    final grouped = _groupByDate(drinks);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: drinks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.no_drinks,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No drinks logged yet.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final dateKey = grouped.keys.elementAt(index);
                final entries = grouped[dateKey]!;
                return _DateGroup(
                  dateLabel: dateKey,
                  entries: entries,
                  onDelete: (id) => _confirmDelete(context, provider, id),
                );
              },
            ),
    );
  }

  Map<String, List<DrinkEntry>> _groupByDate(List<DrinkEntry> drinks) {
    final dateFormat = DateFormat.yMMMd();
    final grouped = <String, List<DrinkEntry>>{};
    for (final d in drinks) {
      final key = dateFormat.format(d.timestamp);
      grouped.putIfAbsent(key, () => []).add(d);
    }
    return grouped;
  }

  void _confirmDelete(
    BuildContext context,
    ConsumptionProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Remove this drink from your log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteDrink(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  final String dateLabel;
  final List<DrinkEntry> entries;
  final ValueChanged<String> onDelete;

  const _DateGroup({
    required this.dateLabel,
    required this.entries,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat.jm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            dateLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...entries.map(
          (e) => Dismissible(
            key: Key(e.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              color: theme.colorScheme.error,
              child: Icon(Icons.delete, color: theme.colorScheme.onError),
            ),
            onDismissed: (_) => onDelete(e.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.local_bar,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              title: Text(e.name ?? '${e.abvPercent}% ABV'),
              subtitle: Text(
                '${e.volumeOz.toStringAsFixed(1)} oz  ·  '
                '${e.abvPercent}% ABV  ·  '
                '${e.standardDrinks.toStringAsFixed(2)} std drinks',
              ),
              trailing: Text(
                timeFormat.format(e.timestamp),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ),
        const Divider(indent: 16, endIndent: 16),
      ],
    );
  }
}

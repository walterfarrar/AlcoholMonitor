import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bottle.dart';
import '../providers/consumption_provider.dart';

class BottlesScreen extends StatelessWidget {
  const BottlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsumptionProvider>();
    final bottles = provider.bottles;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bottles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBottleDialog(context),
        child: const Icon(Icons.add),
      ),
      body: bottles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.liquor,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bottles yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: bottles.length,
              itemBuilder: (context, index) {
                final b = bottles[index];
                return _BottleTile(bottle: b);
              },
            ),
    );
  }

  void _showAddBottleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AddBottleSheet(),
    );
  }
}

class _BottleTile extends StatelessWidget {
  final Bottle bottle;
  const _BottleTile({required this.bottle});

  IconData _iconForType(String type) {
    switch (type) {
      case 'Beer':
      case 'Cider':
      case 'Seltzer':
        return Icons.sports_bar;
      case 'Wine':
        return Icons.wine_bar;
      default:
        return Icons.liquor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(bottle.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Bottle'),
          content: Text('Remove "${bottle.name}" from your inventory?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      onDismissed: (_) =>
          context.read<ConsumptionProvider>().deleteBottle(bottle.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            _iconForType(bottle.type),
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(bottle.name),
        subtitle: Text('${bottle.type}  ·  ${bottle.abvPercent}% ABV'),
      ),
    );
  }
}

class _AddBottleSheet extends StatefulWidget {
  const _AddBottleSheet();

  @override
  State<_AddBottleSheet> createState() => _AddBottleSheetState();
}

class _AddBottleSheetState extends State<_AddBottleSheet> {
  final _nameController = TextEditingController();
  final _abvController = TextEditingController();
  String _selectedType = Bottle.commonTypes.first;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      (_abvController.text.isNotEmpty &&
          (double.tryParse(_abvController.text) ?? 0) > 0 &&
          (double.tryParse(_abvController.text) ?? 0) <= 100);

  @override
  void dispose() {
    _nameController.dispose();
    _abvController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<ConsumptionProvider>().addBottle(
          name: _nameController.text.trim(),
          type: _selectedType,
          abvPercent: double.parse(_abvController.text),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Bottle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Maker\'s Mark, Pinot Noir',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: Bottle.commonTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _abvController,
            decoration: const InputDecoration(
              labelText: 'ABV %',
              border: OutlineInputBorder(),
              suffixText: '%',
              prefixIcon: Icon(Icons.percent),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _isValid ? _save : null,
              child: const Text('Add', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

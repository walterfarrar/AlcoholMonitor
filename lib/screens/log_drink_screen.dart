import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bottle.dart';
import '../providers/consumption_provider.dart';
import '../services/alcohol_calculator.dart';

class LogDrinkScreen extends StatefulWidget {
  final Bottle bottle;

  const LogDrinkScreen({super.key, required this.bottle});

  @override
  State<LogDrinkScreen> createState() => _LogDrinkScreenState();
}

class _LogDrinkScreenState extends State<LogDrinkScreen> {
  final _volumeController = TextEditingController();

  double get _inputVolume => double.tryParse(_volumeController.text) ?? 0;

  double get _volumeOz {
    final provider = context.read<ConsumptionProvider>();
    return provider.displayUnitToOz(_inputVolume);
  }

  double get _calculatedStdDrinks =>
      AlcoholCalculator.calculateStandardDrinks(
        volumeOz: _volumeOz,
        abvPercent: widget.bottle.abvPercent,
      );

  bool get _isValid => _inputVolume > 0;

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<ConsumptionProvider>();
    await provider.logDrink(
      volumeOz: _volumeOz,
      abvPercent: widget.bottle.abvPercent,
      name: widget.bottle.name,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ConsumptionProvider>();
    final unitLabel = provider.displayUnitLabel;

    return Scaffold(
      appBar: AppBar(title: const Text('Log a Drink')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.liquor,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  title: Text(
                    widget.bottle.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${widget.bottle.type}  ·  ${widget.bottle.abvPercent}% ABV',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _volumeController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'How much did you have?',
                  border: const OutlineInputBorder(),
                  suffixText: unitLabel,
                  prefixIcon: const Icon(Icons.water_drop),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Standard Drinks',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isValid
                          ? _calculatedStdDrinks.toStringAsFixed(2)
                          : '--',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isValid ? _submit : null,
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

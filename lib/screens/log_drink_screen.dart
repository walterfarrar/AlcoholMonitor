import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bottle.dart';
import '../providers/consumption_provider.dart';
import '../services/alcohol_calculator.dart';

enum VolumeUnit { oz, cups }

class _Preset {
  final String label;
  final double abv;
  const _Preset(this.label, this.abv);
}

class LogDrinkScreen extends StatefulWidget {
  final Bottle? preselectedBottle;

  const LogDrinkScreen({super.key, this.preselectedBottle});

  @override
  State<LogDrinkScreen> createState() => _LogDrinkScreenState();
}

class _LogDrinkScreenState extends State<LogDrinkScreen> {
  final _volumeController = TextEditingController();
  final _abvController = TextEditingController();
  final _nameController = TextEditingController();
  VolumeUnit _unit = VolumeUnit.oz;

  static const _presets = [
    _Preset('Beer', 5.0),
    _Preset('Wine', 12.0),
    _Preset('Spirits', 40.0),
  ];

  @override
  void initState() {
    super.initState();
    final bottle = widget.preselectedBottle;
    if (bottle != null) {
      _nameController.text = bottle.name;
      _abvController.text = bottle.abvPercent.toString();
    }
  }

  double get _volumeOz {
    final raw = double.tryParse(_volumeController.text) ?? 0;
    return _unit == VolumeUnit.cups ? AlcoholCalculator.cupsToOz(raw) : raw;
  }

  double get _abv => double.tryParse(_abvController.text) ?? 0;

  double get _calculatedStdDrinks =>
      AlcoholCalculator.calculateStandardDrinks(
        volumeOz: _volumeOz,
        abvPercent: _abv,
      );

  bool get _isValid => _volumeOz > 0 && _abv > 0 && _abv <= 100;

  @override
  void dispose() {
    _volumeController.dispose();
    _abvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _selectPreset(_Preset preset) {
    _abvController.text = preset.abv.toString();
    setState(() {});
  }

  Future<void> _submit() async {
    final provider = context.read<ConsumptionProvider>();
    await provider.logDrink(
      volumeOz: _volumeOz,
      abvPercent: _abv,
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Log a Drink')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (optional)',
                  hintText: 'e.g. IPA, Merlot, Margarita',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_bar),
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _volumeController,
                      decoration: InputDecoration(
                        labelText: 'Volume',
                        border: const OutlineInputBorder(),
                        suffixText: _unit == VolumeUnit.oz ? 'oz' : 'cups',
                        prefixIcon: const Icon(Icons.water_drop),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<VolumeUnit>(
                    segments: const [
                      ButtonSegment(value: VolumeUnit.oz, label: Text('oz')),
                      ButtonSegment(
                        value: VolumeUnit.cups,
                        label: Text('cups'),
                      ),
                    ],
                    selected: {_unit},
                    onSelectionChanged: (s) => setState(() => _unit = s.first),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _presets
                    .map(
                      (p) => ActionChip(
                        label: Text('${p.label} (${p.abv}%)'),
                        onPressed: () => _selectPreset(p),
                        avatar: const Icon(Icons.auto_fix_high, size: 18),
                      ),
                    )
                    .toList(),
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

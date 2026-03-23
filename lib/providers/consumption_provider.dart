import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/bottle.dart';
import '../models/drink_entry.dart';
import '../models/consumption_settings.dart';
import '../services/alcohol_calculator.dart';
import '../services/storage_service.dart';

class ConsumptionProvider extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();

  List<DrinkEntry> _drinks = [];
  List<Bottle> _bottles = [];
  late ConsumptionSettings _settings;
  Bottle? _selectedBottle;

  ConsumptionProvider(this._storage) {
    _drinks = _storage.getAllDrinks();
    _bottles = _storage.getAllBottles();
    _settings = _storage.getSettings();
  }

  // --- Getters ---

  List<DrinkEntry> get drinks => _drinks;
  List<Bottle> get bottles => _bottles;
  ConsumptionSettings get settings => _settings;
  Bottle? get selectedBottle => _selectedBottle;

  double get dailyConsumed => _sumForPeriod(_startOfDay);
  double get weeklyConsumed => _sumForPeriod(_startOfWeek);
  double get monthlyConsumed => _sumForPeriod(_startOfMonth);

  double get dailyRemaining =>
      (settings.dailyLimit - dailyConsumed).clamp(0.0, settings.dailyLimit);
  double get weeklyRemaining =>
      (settings.weeklyLimit - weeklyConsumed).clamp(0.0, settings.weeklyLimit);
  double get monthlyRemaining =>
      (settings.monthlyLimit - monthlyConsumed)
          .clamp(0.0, settings.monthlyLimit);

  /// Effective remaining capped by tighter limits from longer periods.
  double get dailyEffectiveRemaining =>
      [dailyRemaining, weeklyRemaining, monthlyRemaining].reduce((a, b) => a < b ? a : b);
  double get weeklyEffectiveRemaining =>
      [weeklyRemaining, monthlyRemaining].reduce((a, b) => a < b ? a : b);
  double get monthlyEffectiveRemaining => monthlyRemaining;

  double get dailyFillPercent =>
      settings.dailyLimit > 0 ? dailyEffectiveRemaining / settings.dailyLimit : 0.0;
  double get weeklyFillPercent =>
      settings.weeklyLimit > 0 ? weeklyEffectiveRemaining / settings.weeklyLimit : 0.0;
  double get monthlyFillPercent =>
      settings.monthlyLimit > 0
          ? monthlyEffectiveRemaining / settings.monthlyLimit
          : 0.0;

  bool get isPastCutoff {
    final cutoff = _settings.cutoffMinutes;
    if (cutoff == null) return false;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    return nowMinutes >= cutoff;
  }

  bool get canDrink =>
      dailyRemaining > 0 &&
      weeklyRemaining > 0 &&
      monthlyRemaining > 0 &&
      !isPastCutoff;

  String get lockReason {
    if (isPastCutoff) {
      final cutoff = _settings.cutoffMinutes!;
      final h = cutoff ~/ 60;
      final m = cutoff % 60;
      final period = h >= 12 ? 'PM' : 'AM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      final timeStr = '${h12.toString()}:${m.toString().padLeft(2, '0')} $period';
      return 'No drinks after $timeStr.';
    }
    final reasons = <String>[];
    if (dailyRemaining <= 0) reasons.add('daily');
    if (weeklyRemaining <= 0) reasons.add('weekly');
    if (monthlyRemaining <= 0) reasons.add('monthly');
    if (reasons.isEmpty) return '';
    return 'You\'ve reached your ${reasons.join(' and ')} limit.';
  }

  /// The tightest remaining allowance across all three periods.
  double get effectiveRemaining {
    final vals = [dailyRemaining, weeklyRemaining, monthlyRemaining];
    return vals.reduce((a, b) => a < b ? a : b);
  }

  DisplayUnit get displayUnit => _settings.displayUnit;

  /// Whether we can show converted units (need a bottle selected).
  bool get hasBottleForConversion => _selectedBottle != null;

  /// Max beverage of the selected bottle the user can drink right now,
  /// in the user's preferred display unit.
  double? get maxForSelectedBottle {
    final bottle = _selectedBottle;
    if (bottle == null || bottle.abvPercent <= 0) return null;
    final remaining = effectiveRemaining;
    if (remaining <= 0) return 0;
    return _convertStdDrinks(remaining, bottle.abvPercent);
  }

  /// Converts a standard-drink amount to the preferred display unit,
  /// using the selected bottle's ABV. Falls back to standard drinks
  /// when no bottle is selected.
  double _convertStdDrinks(double stdDrinks, double abvPercent) {
    switch (_settings.displayUnit) {
      case DisplayUnit.flOz:
        return AlcoholCalculator.stdDrinksToOz(stdDrinks, abvPercent);
      case DisplayUnit.mL:
        return AlcoholCalculator.stdDrinksToMl(stdDrinks, abvPercent);
      case DisplayUnit.cups:
        return AlcoholCalculator.stdDrinksToCups(stdDrinks, abvPercent);
      case DisplayUnit.standardDrinks:
        return stdDrinks;
    }
  }

  /// Returns the display value for a remaining amount. Uses the selected
  /// bottle's ABV when a bottle is selected and unit != standardDrinks;
  /// otherwise returns standard drinks.
  double displayValue(double stdDrinks) {
    final bottle = _selectedBottle;
    if (bottle != null && _settings.displayUnit != DisplayUnit.standardDrinks) {
      return _convertStdDrinks(stdDrinks, bottle.abvPercent);
    }
    return stdDrinks;
  }

  /// The short unit label for what's currently being displayed.
  String get displayUnitLabel {
    if (_selectedBottle == null && _settings.displayUnit != DisplayUnit.standardDrinks) {
      return DisplayUnit.standardDrinks.shortLabel;
    }
    return _settings.displayUnit.shortLabel;
  }

  /// Converts a volume in the user's display unit to fl oz for storage.
  double displayUnitToOz(double value) {
    switch (_settings.displayUnit) {
      case DisplayUnit.flOz:
        return value;
      case DisplayUnit.mL:
        return value / AlcoholCalculator.ozPerMl;
      case DisplayUnit.cups:
        return AlcoholCalculator.cupsToOz(value);
      case DisplayUnit.standardDrinks:
        final bottle = _selectedBottle;
        if (bottle == null || bottle.abvPercent <= 0) return 0;
        return AlcoholCalculator.stdDrinksToOz(value, bottle.abvPercent);
    }
  }

  void selectBottle(Bottle? bottle) {
    _selectedBottle = bottle;
    notifyListeners();
  }

  // --- Actions ---

  Future<void> logDrink({
    required double volumeOz,
    required double abvPercent,
    String? name,
  }) async {
    final stdDrinks = AlcoholCalculator.calculateStandardDrinks(
      volumeOz: volumeOz,
      abvPercent: abvPercent,
    );
    final entry = DrinkEntry(
      id: _uuid.v4(),
      volumeOz: volumeOz,
      abvPercent: abvPercent,
      standardDrinks: stdDrinks,
      timestamp: DateTime.now(),
      name: name,
    );
    await _storage.addDrink(entry);
    _drinks = _storage.getAllDrinks();
    notifyListeners();
  }

  Future<void> deleteDrink(String id) async {
    await _storage.deleteDrink(id);
    _drinks = _storage.getAllDrinks();
    notifyListeners();
  }

  Future<void> clearAllDrinks() async {
    await _storage.clearAllDrinks();
    _drinks = [];
    notifyListeners();
  }

  Future<void> updateSettings(ConsumptionSettings newSettings) async {
    _settings = newSettings;
    await _storage.saveSettings(newSettings);
    notifyListeners();
  }

  // --- Bottle CRUD ---

  Future<void> addBottle({
    required String name,
    required String type,
    required double abvPercent,
  }) async {
    final bottle = Bottle(
      id: _uuid.v4(),
      name: name,
      type: type,
      abvPercent: abvPercent,
    );
    await _storage.addBottle(bottle);
    _bottles = _storage.getAllBottles();
    notifyListeners();
  }

  Future<void> deleteBottle(String id) async {
    if (_selectedBottle?.id == id) _selectedBottle = null;
    await _storage.deleteBottle(id);
    _bottles = _storage.getAllBottles();
    notifyListeners();
  }

  // --- Helpers ---

  double _sumForPeriod(DateTime start) {
    return _drinks
        .where((d) => d.timestamp.isAfter(start))
        .fold(0.0, (sum, d) => sum + d.standardDrinks);
  }

  DateTime get _startOfDay {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _startOfWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  DateTime get _startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
}

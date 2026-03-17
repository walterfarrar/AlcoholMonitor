import 'package:hive_flutter/hive_flutter.dart';
import '../models/bottle.dart';
import '../models/drink_entry.dart';
import '../models/consumption_settings.dart';

class StorageService {
  static const String _drinkBoxName = 'drinks';
  static const String _settingsBoxName = 'settings';
  static const String _bottleBoxName = 'bottles';
  static const String _settingsKey = 'consumption_settings';

  late Box<DrinkEntry> _drinkBox;
  late Box<ConsumptionSettings> _settingsBox;
  late Box<Bottle> _bottleBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DrinkEntryAdapter());
    Hive.registerAdapter(ConsumptionSettingsAdapter());
    Hive.registerAdapter(BottleAdapter());
    _drinkBox = await Hive.openBox<DrinkEntry>(_drinkBoxName);
    _settingsBox = await Hive.openBox<ConsumptionSettings>(_settingsBoxName);
    _bottleBox = await Hive.openBox<Bottle>(_bottleBoxName);
  }

  // --- Drink Entries ---

  List<DrinkEntry> getAllDrinks() {
    return _drinkBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addDrink(DrinkEntry entry) async {
    await _drinkBox.put(entry.id, entry);
  }

  Future<void> deleteDrink(String id) async {
    await _drinkBox.delete(id);
  }

  Future<void> clearAllDrinks() async {
    await _drinkBox.clear();
  }

  // --- Bottles ---

  List<Bottle> getAllBottles() {
    return _bottleBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> addBottle(Bottle bottle) async {
    await _bottleBox.put(bottle.id, bottle);
  }

  Future<void> deleteBottle(String id) async {
    await _bottleBox.delete(id);
  }

  // --- Settings ---

  ConsumptionSettings getSettings() {
    return _settingsBox.get(_settingsKey) ?? ConsumptionSettings();
  }

  Future<void> saveSettings(ConsumptionSettings settings) async {
    await _settingsBox.put(_settingsKey, settings);
  }
}

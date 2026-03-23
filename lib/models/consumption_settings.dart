import 'package:hive/hive.dart';

part 'consumption_settings.g.dart';

enum DisplayUnit {
  standardDrinks,
  flOz,
  mL,
  cups;

  String get label {
    switch (this) {
      case DisplayUnit.standardDrinks:
        return 'Standard Drinks';
      case DisplayUnit.flOz:
        return 'Fluid Ounces';
      case DisplayUnit.mL:
        return 'Milliliters';
      case DisplayUnit.cups:
        return 'Cups';
    }
  }

  String get shortLabel {
    switch (this) {
      case DisplayUnit.standardDrinks:
        return 'std';
      case DisplayUnit.flOz:
        return 'oz';
      case DisplayUnit.mL:
        return 'mL';
      case DisplayUnit.cups:
        return 'cups';
    }
  }
}

@HiveType(typeId: 1)
class ConsumptionSettings extends HiveObject {
  @HiveField(0)
  double dailyLimit;

  @HiveField(1)
  double weeklyLimit;

  @HiveField(2)
  double monthlyLimit;

  /// Stored as int index of DisplayUnit enum. Nullable for backward compat.
  @HiveField(3)
  int? displayUnitIndex;

  /// Cutoff time stored as minutes since midnight. Null = disabled.
  @HiveField(4)
  int? cutoffMinutes;

  DisplayUnit get displayUnit =>
      DisplayUnit.values[(displayUnitIndex ?? 0).clamp(0, DisplayUnit.values.length - 1)];

  set displayUnit(DisplayUnit unit) => displayUnitIndex = unit.index;

  bool get hasCutoff => cutoffMinutes != null;

  ConsumptionSettings({
    this.dailyLimit = 2.0,
    this.weeklyLimit = 7.0,
    this.monthlyLimit = 20.0,
    this.displayUnitIndex = 0,
    this.cutoffMinutes,
  });
}

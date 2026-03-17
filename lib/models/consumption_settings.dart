import 'package:hive/hive.dart';

part 'consumption_settings.g.dart';

/// 0 = standard drinks, 1 = fl oz, 2 = mL
enum DisplayUnit {
  standardDrinks,
  flOz,
  mL;

  String get label {
    switch (this) {
      case DisplayUnit.standardDrinks:
        return 'Standard Drinks';
      case DisplayUnit.flOz:
        return 'Fluid Ounces';
      case DisplayUnit.mL:
        return 'Milliliters';
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

  DisplayUnit get displayUnit =>
      DisplayUnit.values[(displayUnitIndex ?? 0).clamp(0, DisplayUnit.values.length - 1)];

  set displayUnit(DisplayUnit unit) => displayUnitIndex = unit.index;

  ConsumptionSettings({
    this.dailyLimit = 2.0,
    this.weeklyLimit = 7.0,
    this.monthlyLimit = 20.0,
    this.displayUnitIndex = 0,
  });
}

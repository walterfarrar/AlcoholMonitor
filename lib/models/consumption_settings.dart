import 'package:hive/hive.dart';

part 'consumption_settings.g.dart';

@HiveType(typeId: 1)
class ConsumptionSettings extends HiveObject {
  @HiveField(0)
  double dailyLimit;

  @HiveField(1)
  double weeklyLimit;

  @HiveField(2)
  double monthlyLimit;

  ConsumptionSettings({
    this.dailyLimit = 2.0,
    this.weeklyLimit = 7.0,
    this.monthlyLimit = 20.0,
  });
}

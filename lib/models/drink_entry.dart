import 'package:hive/hive.dart';

part 'drink_entry.g.dart';

@HiveType(typeId: 0)
class DrinkEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double volumeOz;

  @HiveField(2)
  final double abvPercent;

  @HiveField(3)
  final double standardDrinks;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String? name;

  DrinkEntry({
    required this.id,
    required this.volumeOz,
    required this.abvPercent,
    required this.standardDrinks,
    required this.timestamp,
    this.name,
  });
}

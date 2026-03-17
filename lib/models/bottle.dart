import 'package:hive/hive.dart';

part 'bottle.g.dart';

@HiveType(typeId: 2)
class Bottle extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final double abvPercent;

  Bottle({
    required this.id,
    required this.name,
    required this.type,
    required this.abvPercent,
  });

  static const List<String> commonTypes = [
    'Beer',
    'Wine',
    'Whiskey',
    'Vodka',
    'Rum',
    'Tequila',
    'Gin',
    'Brandy',
    'Sake',
    'Cider',
    'Seltzer',
    'Other',
  ];
}

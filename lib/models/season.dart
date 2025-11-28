import 'package:hive/hive.dart';

part 'season.g.dart';

@HiveType(typeId: 0)
class Season extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isActive;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime? endDate;

  Season({
    required this.id,
    required this.name,
    required this.isActive,
    required this.startDate,
    this.endDate,
  });
}

import 'package:hive/hive.dart';

part 'event_type.g.dart';

@HiveType(typeId: 14)
enum EventType {
  @HiveField(0)
  rehearsal,

  @HiveField(1)
  performance,

  @HiveField(2)
  meeting,

  @HiveField(3)
  social,
}

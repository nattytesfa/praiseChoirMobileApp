import 'package:hive/hive.dart';
import 'event_type.dart';

part 'event_model.g.dart';

@HiveType(typeId: 10)
class EventModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime endTime;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final EventType type;

  @HiveField(7)
  final List<String> attendeeIds;

  @HiveField(8)
  final String createdBy;

  @HiveField(9)
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    this.attendeeIds = const [],
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'type': type.toString(),
      'attendeeIds': attendeeIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      type: EventType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => EventType.rehearsal,
      ),
      attendeeIds: List<String>.from(json['attendeeIds']),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

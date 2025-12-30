import 'package:hive/hive.dart';

part 'poll_model.g.dart';

@HiveType(typeId: 12)
class PollModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final List<PollOption> options;

  @HiveField(3)
  final String createdBy;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime expiresAt;

  PollModel({
    required this.id,
    required this.question,
    required this.options,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: json['id'],
      question: json['question'],
      options: (json['options'] as List)
          .map((o) => PollOption.fromJson(o))
          .toList(),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}

@HiveType(typeId: 13)
class PollOption {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final List<String> voterIds;

  PollOption({required this.id, required this.text, this.voterIds = const []});

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'voterIds': voterIds};
  }

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'],
      text: json['text'],
      voterIds: List<String>.from(json['voterIds']),
    );
  }
}

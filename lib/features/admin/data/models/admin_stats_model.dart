import 'package:hive/hive.dart';

part 'admin_stats_model.g.dart';

@HiveType(typeId: 15)
class AdminStatsModel {
  @HiveField(0)
  final int totalMembers;

  @HiveField(1)
  final int activeMembers;

  @HiveField(2)
  final int totalSongs;

  @HiveField(3)
  final int songsWithAudio;

  @HiveField(4)
  final double monthlyCollectionRate;

  @HiveField(5)
  final int unreadMessages;

  @HiveField(6)
  final int upcomingEvents;

  @HiveField(7)
  final DateTime lastUpdated;
  
  @HiveField(8)
  final int adminCount;

  AdminStatsModel({
    required this.totalMembers,
    required this.activeMembers,
    required this.totalSongs,
    required this.songsWithAudio,
    required this.monthlyCollectionRate,
    required this.unreadMessages,
    required this.upcomingEvents,
    required this.lastUpdated,
    required this.adminCount, 
  });

  Map<String, dynamic> toJson() {
    return {
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'totalSongs': totalSongs,
      'songsWithAudio': songsWithAudio,
      'monthlyCollectionRate': monthlyCollectionRate,
      'unreadMessages': unreadMessages,
      'upcomingEvents': upcomingEvents,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalMembers: json['totalMembers'],
      activeMembers: json['activeMembers'],
      totalSongs: json['totalSongs'],
      songsWithAudio: json['songsWithAudio'],
      monthlyCollectionRate: json['monthlyCollectionRate'].toDouble(),
      unreadMessages: json['unreadMessages'],
      upcomingEvents: json['upcomingEvents'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      adminCount: json['admincount']
    );
  }

  AdminStatsModel copyWith({
    int? totalMembers,
    int? activeMembers,
    int? totalSongs,
    int? songsWithAudio,
    double? monthlyCollectionRate,
    int? unreadMessages,
    int? upcomingEvents,
    DateTime? lastUpdated,
  }) {
    return AdminStatsModel(
      totalMembers: totalMembers ?? this.totalMembers,
      activeMembers: activeMembers ?? this.activeMembers,
      totalSongs: totalSongs ?? this.totalSongs,
      songsWithAudio: songsWithAudio ?? this.songsWithAudio,
      monthlyCollectionRate:
          monthlyCollectionRate ?? this.monthlyCollectionRate,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      adminCount: adminCount,
    );
  }
}

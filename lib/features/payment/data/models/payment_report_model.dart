import 'package:hive/hive.dart';

part 'payment_report_model.g.dart';

@HiveType(typeId: 15)
class PaymentReportModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime month;

  @HiveField(2)
  final int totalMembers;

  @HiveField(3)
  final int paidCount;

  @HiveField(4)
  final int pendingCount;

  @HiveField(5)
  final int overdueCount;

  @HiveField(6)
  final double collectionRate;

  @HiveField(7)
  final double totalAmount;

  @HiveField(8)
  final DateTime generatedAt;

  PaymentReportModel({
    required this.id,
    required this.month,
    required this.totalMembers,
    required this.paidCount,
    required this.pendingCount,
    required this.overdueCount,
    required this.collectionRate,
    required this.totalAmount,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month.toIso8601String(),
      'totalMembers': totalMembers,
      'paidCount': paidCount,
      'pendingCount': pendingCount,
      'overdueCount': overdueCount,
      'collectionRate': collectionRate,
      'totalAmount': totalAmount,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory PaymentReportModel.fromJson(Map<String, dynamic> json) {
    return PaymentReportModel(
      id: json['id'],
      month: DateTime.parse(json['month']),
      totalMembers: json['totalMembers'],
      paidCount: json['paidCount'],
      pendingCount: json['pendingCount'],
      overdueCount: json['overdueCount'],
      collectionRate: json['collectionRate'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
}

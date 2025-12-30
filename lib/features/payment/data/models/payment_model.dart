import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 4)
class PaymentModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String memberId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final DateTime? paidDate;

  @HiveField(5)
  final PaymentStatus status;

  @HiveField(6)
  final String? proofImagePath;

  @HiveField(7)
  final String? adminNote;

  PaymentModel({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.proofImagePath,
    this.adminNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.toString(),
      'proofImagePath': proofImagePath,
      'adminNote': adminNote,
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      memberId: json['memberId'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      proofImagePath: json['proofImagePath'],
      adminNote: json['adminNote'],
    );
  }

  PaymentModel copyWith({
    double? amount,
    DateTime? paidDate,
    PaymentStatus? status,
    String? proofImagePath,
    bool clearProof = false,
    String? adminNote,
  }) {
    return PaymentModel(
      id: id,
      memberId: memberId,
      amount: amount ?? this.amount,
      dueDate: dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      proofImagePath: clearProof
          ? null
          : (proofImagePath ?? this.proofImagePath),
      adminNote: adminNote ?? this.adminNote,
    );
  }

  bool get isOverdue {
    return status == PaymentStatus.pending && dueDate.isBefore(DateTime.now());
  }
}

@HiveType(typeId: 5)
enum PaymentStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  paid,

  @HiveField(2)
  overdue,
}

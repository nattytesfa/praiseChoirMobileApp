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

  PaymentModel({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.proofImagePath,
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
    );
  }

  PaymentModel copyWith({
    DateTime? paidDate,
    PaymentStatus? status,
    String? proofImagePath,
  }) {
    return PaymentModel(
      id: id,
      memberId: memberId,
      amount: amount,
      dueDate: dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      proofImagePath: proofImagePath ?? this.proofImagePath,
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

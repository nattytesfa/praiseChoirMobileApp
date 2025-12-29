import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';

class PaymentEntity {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final PaymentStatus status;
  final String? proofImagePath;
  final bool isOverdue;

  PaymentEntity({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.proofImagePath,
    required this.isOverdue,
  });

  factory PaymentEntity.fromModel(PaymentModel payment, String memberName) {
    return PaymentEntity(
      id: payment.id,
      memberId: payment.memberId,
      memberName: memberName,
      amount: payment.amount,
      dueDate: payment.dueDate,
      paidDate: payment.paidDate,
      status: payment.status,
      proofImagePath: payment.proofImagePath,
      isOverdue: payment.isOverdue,
    );
  }
}

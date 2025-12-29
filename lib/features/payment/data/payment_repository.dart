import 'package:hive/hive.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'models/payment_model.dart';

class PaymentRepository {
  late Box<PaymentModel> _paymentBox;

  PaymentRepository() {
    _paymentBox = Hive.box<PaymentModel>(HiveBoxes.payments);
  }

  Future<List<PaymentModel>> getPaymentsForMember(String memberId) async {
    final allPayments = _paymentBox.values.toList();
    return allPayments
        .where((payment) => payment.memberId == memberId)
        .toList();
  }

  Future<List<PaymentModel>> getAllPayments() async {
    return _paymentBox.values.toList();
  }

  Future<List<PaymentModel>> getPaymentsForMonth(DateTime month) async {
    final allPayments = await getAllPayments();
    return allPayments.where((payment) {
      return payment.dueDate.year == month.year &&
          payment.dueDate.month == month.month;
    }).toList();
  }

  Future<void> markPaymentAsPaid(
    String paymentId,
    String proofImagePath,
  ) async {
    final payment = _paymentBox.values.firstWhere((p) => p.id == paymentId);
    final updatedPayment = payment.copyWith(
      status: PaymentStatus.paid,
      paidDate: DateTime.now(),
      proofImagePath: proofImagePath,
    );

    final index = _paymentBox.values.toList().indexWhere(
      (p) => p.id == paymentId,
    );
    if (index != -1) {
      await _paymentBox.putAt(index, updatedPayment);
    }
  }

  Future<void> createMonthlyPayments(
    List<String> memberIds,
    DateTime dueDate,
  ) async {
    for (final memberId in memberIds) {
      final payment = PaymentModel(
        id: 'payment_${memberId}_${dueDate.millisecondsSinceEpoch}',
        memberId: memberId,
        amount: AppConstants.monthlyPaymentAmount,
        dueDate: dueDate,
        status: PaymentStatus.pending,
      );
      await _paymentBox.add(payment);
    }
  }

  Future<Map<String, dynamic>> getPaymentSummary(DateTime month) async {
    final payments = await getPaymentsForMonth(month);
    final totalMembers = payments.length;
    final paidCount = payments
        .where((p) => p.status == PaymentStatus.paid)
        .length;
    final pendingCount = payments
        .where((p) => p.status == PaymentStatus.pending)
        .length;
    final overdueCount = payments.where((p) => p.isOverdue).length;

    return {
      'totalMembers': totalMembers,
      'paidCount': paidCount,
      'pendingCount': pendingCount,
      'overdueCount': overdueCount,
      'collectionRate': totalMembers > 0 ? (paidCount / totalMembers) * 100 : 0,
      'totalAmount': paidCount * AppConstants.monthlyPaymentAmount,
    };
  }

  Future<List<PaymentModel>> getOverduePayments() async {
    final allPayments = await getAllPayments();
    return allPayments.where((payment) => payment.isOverdue).toList();
  }
}

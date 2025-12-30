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
    String proofImagePath, {
    double additionalFee = 0,
  }) async {
    final Map<dynamic, PaymentModel> map = _paymentBox.toMap();
    dynamic keyToUpdate;
    PaymentModel? paymentToUpdate;

    for (final entry in map.entries) {
      if (entry.value.id == paymentId) {
        keyToUpdate = entry.key;
        paymentToUpdate = entry.value;
        break;
      }
    }

    if (keyToUpdate != null && paymentToUpdate != null) {
      final updatedPayment = paymentToUpdate.copyWith(
        status: PaymentStatus.paid,
        paidDate: DateTime.now(),
        proofImagePath: proofImagePath,
        amount: paymentToUpdate.amount + additionalFee,
      );
      await _paymentBox.put(keyToUpdate, updatedPayment);
    } else {
      throw Exception('Payment not found: $paymentId');
    }
  }

  Future<void> updatePaymentProof(
    String paymentId,
    String proofImagePath,
  ) async {
    final Map<dynamic, PaymentModel> map = _paymentBox.toMap();
    dynamic keyToUpdate;
    PaymentModel? paymentToUpdate;

    for (final entry in map.entries) {
      if (entry.value.id == paymentId) {
        keyToUpdate = entry.key;
        paymentToUpdate = entry.value;
        break;
      }
    }

    if (keyToUpdate != null && paymentToUpdate != null) {
      final updatedPayment = paymentToUpdate.copyWith(
        proofImagePath: proofImagePath,
        adminNote: 'Photo proof is changed',
      );
      await _paymentBox.put(keyToUpdate, updatedPayment);
    } else {
      throw Exception('Payment not found: $paymentId');
    }
  }

  Future<void> removePaymentProof(String paymentId) async {
    final Map<dynamic, PaymentModel> map = _paymentBox.toMap();
    dynamic keyToUpdate;
    PaymentModel? paymentToUpdate;

    for (final entry in map.entries) {
      if (entry.value.id == paymentId) {
        keyToUpdate = entry.key;
        paymentToUpdate = entry.value;
        break;
      }
    }

    if (keyToUpdate != null && paymentToUpdate != null) {
      final updatedPayment = paymentToUpdate.copyWith(clearProof: true);
      await _paymentBox.put(keyToUpdate, updatedPayment);
    } else {
      throw Exception('Payment not found: $paymentId');
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

  Future<void> deletePaymentsForMonth(
    DateTime month, {
    bool includePaid = false,
  }) async {
    final Map<dynamic, PaymentModel> map = _paymentBox.toMap();
    final keysToDelete = <dynamic>[];

    for (final entry in map.entries) {
      final payment = entry.value;
      if (payment.dueDate.year == month.year &&
          payment.dueDate.month == month.month) {
        if (includePaid || payment.status == PaymentStatus.pending) {
          keysToDelete.add(entry.key);
        }
      }
    }

    await _paymentBox.deleteAll(keysToDelete);
  }

  Future<Map<String, dynamic>> getPaymentSummary(DateTime month) async {
    final payments = await getPaymentsForMonth(month);
    final totalMembers = payments.length;
    final paidPayments = payments
        .where((p) => p.status == PaymentStatus.paid)
        .toList();
    final paidCount = paidPayments.length;
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
      'totalAmount': paidPayments.fold<double>(0, (sum, p) => sum + p.amount),
    };
  }

  Future<List<PaymentModel>> getOverduePayments() async {
    final allPayments = await getAllPayments();
    return allPayments.where((payment) => payment.isOverdue).toList();
  }
}
